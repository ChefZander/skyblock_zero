local assert, tonumber, type, setmetatable, ipairs, unpack
	= assert, tonumber, type, setmetatable, ipairs, unpack

local math_floor, table_insert, table_concat
	= math.floor, table.insert, table.concat

local obj = {}

local metatable = {__index = obj}

local function read_floats(next_word, n)
	if n == 0 then return end
	local num = next_word()
	assert(num:find"^%-?%d+$" or num:find"^%-?%d+%.%d+$")
	return tonumber(num), read_floats(next_word, n - 1)
end

local function read_index(list, index)
	if not index then return end
	index = tonumber(index)
	if index < 0 then
		index = index + #list + 1
	end
	assert(list[index])
	return index
end

local function read_indices(self, next_word)
	local word = next_word()
	if not word then return end
	-- TODO optimize this (ideally using a vararg-ish split by `/`)
	local vertex, texcoord, normal
	vertex = word:match"^%-?%d+$"
	if not vertex then
		vertex, texcoord = word:match"^(%-?%d+)/(%-?%d+)$"
		if not vertex then
			vertex, normal = word:match"^(%-?%d+)//(%-?%d+)$"
			if not vertex then
				vertex, texcoord, normal = word:match"^(%-?%d+)/(%-?%d+)/(%-?%d+)$"
			end
		end
	end
	return {
		vertex = read_index(self.vertices, vertex),
		texcoord = read_index(self.texcoords, texcoord),
		normal = read_index(self.normals, normal)
	}, read_indices(self, next_word)
end

function obj.read_lines(
	... -- line iterator such as `modlib.text.lines"str"` or `io.lines"filename"`
)
	local self = {
		vertices = {},
		texcoords = {},
		normals = {},
		groups = {}
	}
	local groups = {}
	local active_group = {name = "default"}
	groups[1] = active_group
	groups.default = active_group
	for line in ... do
		if line:byte() ~= ("#"):byte() then
			local next_word = line:gmatch"%S+"
			local command = next_word()
			if command == "v" or command == "vn" then
				local x, y, z = read_floats(next_word, 3)
				x = -x
				table_insert(self[command == "v" and "vertices" or "normals"], {x, y, z})
			elseif command == "vt" then
				local x, y = read_floats(next_word, 2)
				y = 1 - y
				table_insert(self.texcoords, {x, y})
			elseif command == "f" then
				table_insert(active_group, {read_indices(self, next_word)})
			elseif command == "g" or command == "usemtl" then
				-- TODO consider distinguishing between materials & groups
				local name = next_word() or "default"
				if groups[name] then
					active_group = groups[name]
				else
					active_group = {name = name}
					table_insert(groups, active_group)
					groups[name] = active_group
				end
				assert(not next_word(), "only a single group/material name is supported")
			end
		end
	end
	-- Keep only nonempty groups
	for _, group in ipairs(groups) do
		if group[1] ~= nil then
			table_insert(self.groups, group)
		end
	end
	return setmetatable(self, metatable) -- obj object
end

-- Does not close a file handle if passed
--> obj object
function obj.read_file(file_or_name)
	if type(file_or_name) == "string" then
		return obj.read_lines(io.lines(file_or_name))
	end
	local handle = file_or_name
	-- `handle.read, handle` can be used as a line iterator
	return obj.read_lines(assert(handle.read), handle)
end

--> obj object
function obj.read_string(str)
	-- Empty lines can be ignored
	return obj.read_lines(str:gmatch"[^\r\n]+")
end

local function write_float(float)
	if math_floor(float) == float then
		return ("%d"):format(float)
	end
	return ("%f"):format(float):match"^(.-)0*$" -- strip trailing zeros
end

local function write_index(index)
	if index.texcoord then
		if index.normal then
			return("%d/%d/%d"):format(index.vertex, index.texcoord, index.normal)
		end
		return ("%d/%d"):format(index.vertex, index.texcoord)
	end if index.normal then
		return ("%d//%d"):format(index.vertex, index.normal)
	end
	return ("%d"):format(index.vertex)
end

-- Callback/"caller"-style iterator; use `iterator.for_generator` to turn this into a callee-style iterator
function obj:write_lines(
	write_line -- function(line: string) to write a line
)
	local function write_v3f(type, v3f)
		local x, y, z = unpack(v3f)
		x = -x
		write_line(("%s %s %s %s"):format(type, write_float(x), write_float(y), write_float(z)))
	end
	for _, vertex in ipairs(self.vertices) do
		write_v3f("v", vertex)
	end
	for _, normal in ipairs(self.normals) do
		write_v3f("vn", normal)
	end
	for _, texcoord in ipairs(self.texcoords) do
		local x, y = texcoord[1], texcoord[2]
		y = 1 - y
		write_line(("vt %s %s"):format(write_float(x), write_float(y)))
	end
	for _, group in ipairs(self.groups) do
		write_line("g " .. group.name) -- this will convert `usemtl` into `g` but that shouldn't matter
		for _, face in ipairs(group) do
			local command = {"f"}
			for i, index in ipairs(face) do
				command[i + 1] = write_index(index)
			end
			write_line(table_concat(command, " "))
		end
	end
end

-- Write `self` to a file
-- Does not close or flush a file handle if passed
function obj:write_file(file_or_name)
	if type(file_or_name) == "string" then
		file_or_name = io.open(file_or_name)
	end
	self:write_lines(function(line)
		file_or_name:write(line)
		file_or_name:write"\n"
	end)
end

-- Write `self` to a string
function obj:write_string()
	local rope = {}
	self:write_lines(function(line)
		table_insert(rope, line)
	end)
	table_insert(rope, "") -- trailing newline for good measure
	return table_concat(rope, "\n") -- string representation of `self`
end

return obj