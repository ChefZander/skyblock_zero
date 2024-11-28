local assert, error, math_huge, modlib, minetest, setmetatable, type, table_insert, table_sort, pairs, ipairs
	= assert, error, math.huge, modlib, minetest, setmetatable, type, table.insert, table.sort, pairs, ipairs

local sqlite3 = ...

--[[
	Currently uses reference counting to immediately delete tables which aren't reachable from the root table anymore, which has two issues:
	1. Deletion might trigger a large deletion chain
	TODO defer deletion, clean up unused tables on startup, delete & iterate tables partially
	2. Reference counting is unable to handle cycles. `:collectgarbage()` implements a tracing "stop-the-world" garbage collector which handles cycles.
	TODO take advantage of Lua's garbage collection by keeping a bunch of "twin" objects in a weak structure using proxies (Lua 5.1) or the __gc metamethod (Lua 5.2)
	See https://wiki.c2.com/?ReferenceCountingCanHandleCycles, https://www.memorymanagement.org/mmref/recycle.html#mmref-recycle and https://wiki.c2.com/?GenerationalGarbageCollectio
	Weak tables are of no use here, as we need to be notified when a reference is dropped
]]

local ptab = {} -- SQLite3-backed implementation for a persistent Lua table ("ptab")
local metatable = {__index = ptab}
ptab.metatable = metatable

-- Note: keys may not be marked as weak references: wouldn't close the database: see persistence/lua_log_file.lua
local databases = {}

local types = {
	boolean = 1,
	number = 2,
	string = 3,
	table = 4
}

local function increment_highest_table_id(self)
	self.highest_table_id = self.highest_table_id + 1
	if self.highest_table_id > 2^50 then
		-- IDs are approaching double precision limit (52 bits mantissa), defragment them
		self:defragment_ids()
	end
	return self.highest_table_id
end

function ptab.new(file_path, root)
	return setmetatable({
		database = sqlite3.open(file_path),
		root = root
	}, metatable)
end

function ptab.setmetatable(self)
	assert(self.database and self.root)
	return setmetatable(self, metatable)
end

local set

local function add_table(self, table)
	if type(table) ~= "table" then return end
	if self.counts[table] then
		self.counts[table] = self.counts[table] + 1
		return
	end
	self.table_ids[table] = increment_highest_table_id(self)
	self.counts[table] = 1
	for k, v in pairs(table) do
		set(self, table, k, v)
	end
end

local decrement_reference_count

local function delete_table(self, table)
	local id = assert(self.table_ids[table])
	self.table_ids[table] = nil
	self.counts[table] = nil
	for k, v in pairs(table) do
		decrement_reference_count(self, k)
		decrement_reference_count(self, v)
	end
	local statement = self._prepared.delete_table
	statement:bind(1, id)
	statement:step()
	statement:reset()
end

function decrement_reference_count(self, table)
	if type(table) ~= "table" then return end
	local count = self.counts[table]
	if not count then return end
	count = count - 1
	if count == 0 then return delete_table(self, table) end
	self.counts[table] = count
end

function set(self, table, key, value)
	local deletion = value == nil
	if not deletion then
		add_table(self, key)
		add_table(self, value)
	end
	local previous_value = table[key]
	if type(previous_value) == "table" then
		decrement_reference_count(self, previous_value)
	end
	if deletion and type(key) == "table" then
		decrement_reference_count(self, key)
	end
	local statement = self._prepared[deletion and "delete" or "insert"]
	local function bind_type_and_content(n, value)
		local type_ = type(value)
		statement:bind(n, assert(types[type_]))
		if type_ == "boolean" then
			statement:bind(n + 1, value and 1 or 0)
		elseif type_ == "number" then
			if value ~= value then
				statement:bind(n + 1, "nan")
			elseif value == math_huge then
				statement:bind(n + 1, "inf")
			elseif value == -math_huge then
				statement:bind(n + 1, "-inf")
			else
				statement:bind(n + 1, value)
			end
		elseif type_ == "string" then
			-- Use bind_blob instead of bind as Lua strings are effectively byte strings
			statement:bind_blob(n + 1, value)
		elseif type_ == "table" then
			statement:bind(n + 1, self.table_ids[value])
		end
	end
	statement:bind(1, assert(self.table_ids[table]))
	bind_type_and_content(2, key)
	if not deletion then
		bind_type_and_content(4, value)
	end
	statement:step()
	statement:reset()
end

local function exec(self, sql)
	if self.database:exec(sql) ~= sqlite3.OK then
		error(self.database:errmsg())
	end
end

function ptab:init()
	local database = self.database
	local function prepare(sql)
		local stmt = database:prepare(sql)
		if not stmt then error(database:errmsg()) end
		return stmt
	end
	exec(self, [[
CREATE TABLE IF NOT EXISTS table_entries (
	table_id INTEGER NOT NULL,
	key_type INTEGER NOT NULL,
	key BLOB NOT NULL,
	value_type INTEGER NOT NULL,
	value BLOB NOT NULL,
	PRIMARY KEY (table_id, key_type, key)
)]])
	self._prepared = {
		insert = prepare"INSERT OR REPLACE INTO table_entries(table_id, key_type, key, value_type, value) VALUES (?, ?, ?, ?, ?)",
		delete = prepare"DELETE FROM table_entries WHERE table_id = ? AND key_type = ? AND key = ?",
		delete_table = prepare"DELETE FROM table_entries WHERE table_id = ?",
		update = {
			id = prepare"UPDATE table_entries SET table_id = ? WHERE table_id = ?",
			keys = prepare("UPDATE table_entries SET key = ? WHERE key_type = " .. types.table .. " AND key = ?"),
			values = prepare("UPDATE table_entries SET value = ? WHERE value_type = " .. types.table .. " AND value = ?")
		}
	}
	-- Default value
	self.highest_table_id = 0
	for id in self.database:urows"SELECT MAX(table_id) FROM table_entries" do
		-- Gets a single value
		self.highest_table_id = id
	end
	increment_highest_table_id(self)
	local tables = {}
	local counts = {}
	self.counts = counts
	local function get_value(type_, content)
		if type_ == types.boolean then
			if content == 0 then return false end
			if content == 1 then return true end
			error("invalid boolean value: " .. content)
		end
		if type_ == types.number then
			if content == "nan" then
				return 0/0
			end
			if content == "inf" then
				return math_huge
			end
			if content == "-inf" then
				return -math_huge
			end
			assert(type(content) == "number")
			return content
		end
		if type_ == types.string then
			assert(type(content) == "string")
			return content
		end
		if type_ == types.table then
			-- Table reference
			tables[content] = tables[content] or {}
			counts[content] = counts[content] or 1
			return tables[content]
		end
		-- Null is unused
		error("unsupported type: " .. type_)
	end
	-- Order by key_content to retrieve list parts in the correct order, making it easier for Lua
	for table_id, key_type, key, value_type, value in self.database:urows"SELECT * FROM table_entries ORDER BY table_id, key_type, key" do
		local table = tables[table_id] or {}
		counts[table] = counts[table] or 1
		table[get_value(key_type, key)] = get_value(value_type, value)
		tables[table_id] = table
	end
	if tables[1] then
		self.root = tables[1]
		counts[self.root] = counts[self.root] + 1
		self.table_ids = modlib.table.flip(tables)
		self:collectgarbage()
	else
		self.highest_table_id = 0
		self.table_ids = {}
		add_table(self, self.root)
	end
	databases[self] = true
end

function ptab:rewrite()
	exec(self, "BEGIN EXCLUSIVE TRANSACTION")
	exec(self, "DELETE FROM table_entries")
	self.highest_table_id = 0
	self.table_ids = {}
	self.counts = {}
	add_table(self, self.root)
	exec(self, "COMMIT TRANSACTION")
end

function ptab:set(table, key, value)
	exec(self, "BEGIN EXCLUSIVE TRANSACTION")
	local previous_value = table[key]
	if previous_value == value then
		-- no change
		return
	end
	set(self, table, key, value)
	table[key] = value
	exec(self, "COMMIT TRANSACTION")
end

function ptab:set_root(key, value)
	return self:set(self.root, key, value)
end

function ptab:collectgarbage()
	local marked = {}
	local function mark(table)
		if type(table) ~= "table" or marked[table] then return end
		marked[table] = true
		for k, v in pairs(table) do
			mark(k)
			mark(v)
		end
	end
	mark(self.root)
	for table in pairs(self.table_ids) do
		if not marked[table] then
			delete_table(self, table)
		end
	end
end

function ptab:defragment_ids()
	local ids = {}
	for _, id in pairs(self.table_ids) do
		table_insert(ids, id)
	end
	table_sort(ids)
	local update = self._prepared.update
	local tables = modlib.table.flip(self.table_ids)
	for new_id, old_id in ipairs(ids) do
		for _, stmt in pairs(update) do
			stmt:bind_values(new_id, old_id)
			stmt:step()
			stmt:reset()
		end
		self.table_ids[tables[old_id]] = new_id
	end
	self.highest_table_id = #ids
end

local function finalize_statements(table)
	for _, stmt in pairs(table) do
		if type(stmt) == "table" then
			finalize_statements(stmt)
		else
			local errcode = stmt:finalize()
			assert(errcode == sqlite3.OK, errcode)
		end
	end
end

function ptab:close()
	finalize_statements(self._prepared)
	self.database:close()
	databases[self] = nil
end

if minetest then
	minetest.register_on_shutdown(function()
		for self in pairs(databases) do
			self:close()
		end
	end)
end

return ptab