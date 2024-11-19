-- Localize globals
local assert, error, io, loadfile, math, minetest, modlib, pairs, setfenv, setmetatable, type
	= assert, error, io, loadfile, math, minetest, modlib, pairs, setfenv, setmetatable, type

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

-- Default value
reference_strings = true

-- Note: keys may not be marked as weak references: garbage collected log files wouldn't close the file:
-- The `__gc` metamethod doesn't work for tables in Lua 5.1; a hack using `newproxy` would be needed
-- See https://stackoverflow.com/questions/27426704/lua-5-1-workaround-for-gc-metamethod-for-tables)
-- Therefore, :close() must be called on log files to remove them from the `files` table
local files = {}
local metatable = {__index = _ENV}
_ENV.metatable = metatable

function new(file_path, root, reference_strings)
	local self = setmetatable({
		file_path = assert(file_path),
		root = root,
		reference_strings = reference_strings
	}, metatable)
	if minetest then
		files[self] = true
	end
	return self
end

local function set_references(self, table)
	-- Weak table keys to allow the collection of dead reference tables
	-- TODO garbage collect strings in the references table
	self.references = setmetatable(table, {__mode = "k"})
end

function load(self)
	-- Bytecode is blocked by the engine
	local read = assert(loadfile(self.file_path))
	-- math.huge is serialized to inf
	local env = {inf = math.huge}
	setfenv(read, env)
	read()
	env.R = env.R or {{}}
	local reference_count = #env.R
	for ref in pairs(env.R) do
		if ref > reference_count then
			-- Ensure reference count always has the value of the largest reference
			-- in case of "holes" (nil values) in the reference list
			reference_count = ref
		end
	end
	self.reference_count = reference_count
	self.root = env.R[1]
	set_references(self, {})
end

function open(self)
	self.file = io.open(self.file_path, "a+")
end

function init(self)
	if modlib.file.exists(self.file_path) then
		self:load()
		self:_rewrite()
		self:open()
		return
	end
	self:open()
	self:_write()
end

function log(self, statement)
	self.file:write(statement)
	self.file:write"\n"
end

function flush(self)
	self.file:flush()
end

function close(self)
	self.file:close()
	self.file = nil
	files[self] = nil
end

if minetest then
	minetest.register_on_shutdown(function()
		for self in pairs(files) do
			self.file:close()
		end
	end)
end

local function _dump(self, value, is_key)
	if value == nil then
		return "nil"
	end
	if value == true then
		return "true"
	end
	if value == false then
		return "false"
	end
	if value ~= value then
		-- nan
		return "0/0"
	end
	local _type = type(value)
	if _type == "number" then
		return ("%.17g"):format(value)
	end
	local reference = self.references[value]
	if reference then
		return "R[" .. reference .."]"
	end
	reference = self.reference_count + 1
	local key = "R[" .. reference .."]"
	local function create_reference()
		self.reference_count = reference
		self.references[value] = reference
	end
	if _type == "string" then
		local reference_strings = self.reference_strings
		if is_key and ((not reference_strings) or value:len() <= key:len()) and modlib.text.is_identifier(value) then
			-- Short key
			return value, true
		end
		local formatted = ("%q"):format(value)
		if (not reference_strings) or formatted:len() <= key:len()  then
			-- Short string
			return formatted
		end
		-- Use reference
		create_reference()
		self:log(key .. "=" .. formatted)
	elseif _type == "table" then
		-- Tables always need a reference before they are traversed to prevent infinite recursion
		create_reference()
		-- TODO traverse tables to determine whether this is actually needed
		self:log(key .. "={}")
		for k, v in pairs(value) do
			local dumped, short = _dump(self, k, true)
			self:log(key .. (short and ("." .. dumped) or ("[" .. dumped .. "]")) .. "=" .. _dump(self, v))
		end
	else
		error("unsupported type: " .. _type)
	end
	return key
end

function set(self, table, key, value)
	if not self.references[table] then
		error"orphan table"
	end
	if table[key] == value then
		-- No change
		return
	end
	table[key] = value
	table = _dump(self, table)
	local key, short_key = _dump(self, key, true)
	self:log(table .. (short_key and ("." .. key) or ("[" .. key .. "]")) .. "=" .. _dump(self, value))
end

function set_root(self, key, value)
	return self:set(self.root, key, value)
end

function _write(self)
	set_references(self, {})
	self.reference_count = 0
	self:log"R={}"
	_dump(self, self.root)
end

function _rewrite(self)
	self.file = io.open(self.file_path, "w+")
	self:_write()
	self.file:close()
end

function rewrite(self)
	if self.file then
		self.file:close()
	end
	self:_rewrite()
	self:open()
end

-- Export environment
return _ENV