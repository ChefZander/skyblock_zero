-- Localize globals
local VoxelArea, ItemStack, assert, error, io, ipairs, math, minetest, modlib, next, pairs, setmetatable, string, table, type, vector
	= VoxelArea, ItemStack, assert, error, io, ipairs, math, minetest, modlib, next, pairs, setmetatable, string, table, type, vector


local schematic = {}
local metatable = {__index = schematic}

function schematic.setmetatable(self)
	return setmetatable(self, metatable)
end

function schematic.create(params, pos_min, pos_max)
	pos_min, pos_max = vector.sort(pos_min, pos_max)
	local size = vector.add(vector.subtract(pos_max, pos_min), 1)
	local voxelmanip = minetest.get_voxel_manip(pos_min, pos_max)
	local emin, emax = voxelmanip:read_from_map(pos_min, pos_max)
	local voxelarea = VoxelArea:new{ MinEdge = emin, MaxEdge = emax }
	local nodes, light_values, param2s = {}, params.light_values and {}, {}
	local vm_nodes, vm_light_values, vm_param2s = voxelmanip:get_data(), light_values and voxelmanip:get_light_data(), voxelmanip:get_param2_data()
	local node_names, node_ids = {}, {}
	local i = 0
	for index in voxelarea:iterp(pos_min, pos_max) do
		if nodes[index] == minetest.CONTENT_UNKNOWN or nodes[index] == minetest.CONTENT_IGNORE then
			error("unknown or ignore node at " .. minetest.pos_to_string(voxelarea:position(index)))
		end
		local name = minetest.get_name_from_content_id(vm_nodes[index])
		local id = node_ids[name]
		if not id then
			table.insert(node_names, name)
			id = #node_names
			node_ids[name] = id
		end
		i = i + 1
		nodes[i] = id
		if params.light_values then
			light_values[i] = vm_light_values[index]
		end
		param2s[i] = vm_param2s[index]
	end
	local metas
	if params.metas or params.metas == nil then
		metas = {}
		for _, pos in ipairs(minetest.find_nodes_with_meta(pos_min, pos_max)) do
			local meta = minetest.get_meta(pos):to_table()
			if next(meta.fields) ~= nil or next(meta.inventory) ~= nil then
				local relative = vector.subtract(pos, pos_min)
				metas[((relative.z * size.y) + relative.y) * size.x + relative.x] = meta
			end
		end
	end
	return schematic.setmetatable({
		size = size,
		node_names = node_names,
		nodes = nodes,
		light_values = light_values,
		param2s = param2s,
		metas = metas,
	})
end

function schematic:write_to_voxelmanip(voxelmanip, pos_min)
	local size = self.size
	local pos_max = vector.subtract(vector.add(pos_min, size), 1) -- `pos_max` is inclusive
	local emin, emax = voxelmanip:read_from_map(pos_min, pos_max)
	local voxelarea = VoxelArea:new{ MinEdge = emin, MaxEdge = emax }
	local nodes, light_values, param2s, metas = self.nodes, self.light_values, self.param2s, self.metas
	local vm_nodes, vm_lights, vm_param2s = voxelmanip:get_data(), light_values and voxelmanip:get_light_data(), voxelmanip:get_param2_data()
	for _, pos in ipairs(minetest.find_nodes_with_meta(pos_min, pos_max)) do
		-- Clear all metadata. Due to an engine bug, nodes will actually have empty metadata.
		minetest.get_meta(pos):from_table{}
	end
	local content_ids = {}
	for index, name in ipairs(self.node_names) do
		content_ids[index] = assert(minetest.get_content_id(name), ("unknown node %q"):format(name))
	end
	local i = 0
	for index in voxelarea:iterp(pos_min, pos_max) do
		i = i + 1
		vm_nodes[index] = content_ids[nodes[i]]
		if light_values then
			vm_lights[index] = light_values[i]
		end
		vm_param2s[index] = param2s[i]
	end
	voxelmanip:set_data(vm_nodes)
	if light_values then
		voxelmanip:set_light_data(vm_lights)
	end
	voxelmanip:set_param2_data(vm_param2s)
	if metas then
		for index, meta in pairs(metas) do
			local floored = math.floor(index / size.x)
			local relative = {
				x = index % size.x,
				y = floored % size.y,
				z = math.floor(floored / size.y)
			}
			minetest.get_meta(vector.add(relative, pos_min)):from_table(meta)
		end
	end
end

function schematic:place(pos_min)
	local pos_max = vector.subtract(vector.add(pos_min, self.size), 1) -- `pos_max` is inclusive
	local voxelmanip = minetest.get_voxel_manip(pos_min, pos_max)
	self:write_to_voxelmanip(voxelmanip, pos_min)
	voxelmanip:write_to_map(not self.light_values)
	return voxelmanip
end

local function table_to_byte_string(tab)
	if not tab then return end
	return table.concat(modlib.table.map(tab, string.char))
end

local function write_bluon(self, stream)
	local metas = modlib.table.copy(self.metas)
	for _, meta in pairs(metas) do
		for _, list in pairs(meta.inventory) do
			for index, stack in pairs(list) do
				list[index] = stack:to_string()
			end
		end
	end
	modlib.bluon:write({
		size = self.size,
		node_names = self.node_names,
		nodes = self.nodes,
		light_values = table_to_byte_string(self.light_values),
		param2s = table_to_byte_string(self.param2s),
		metas = metas,
	}, stream)
end

function schematic:write_bluon(path)
	local file = io.open(path, "wb")
	-- Header, short for "ModLib Bluon Schematic"
	file:write"MLBS"
	write_bluon(self, file)
	file:close()
end

local function byte_string_to_table(self, field)
	local byte_string = self[field]
	if not byte_string then return end
	local tab = {}
	for i = 1, #byte_string do
		tab[i] = byte_string:byte(i)
	end
	self[field] = tab
end

local function read_bluon(file)
	local self = modlib.bluon:read(file)
	assert(not file:read(1), "expected EOF")
	for _, meta in pairs(self.metas) do
		for _, list in pairs(meta.inventory) do
			for index, itemstring in pairs(list) do
				assert(type(itemstring) == "string")
				list[index] = ItemStack(itemstring)
			end
		end
	end
	byte_string_to_table(self, "light_values")
	byte_string_to_table(self, "param2s")
	return self
end

function schematic.read_bluon(path)
	local file = io.open(path, "rb")
	assert(file:read(4) == "MLBS", "not a modlib bluon schematic")
	return schematic.setmetatable(read_bluon(file))
end

function schematic:write_zlib_bluon(path, compression)
	local file = io.open(path, "wb")
	-- Header, short for "ModLib Zlib-compressed-bluon Schematic"
	file:write"MLZS"
	local rope = modlib.table.rope{}
	write_bluon(self, rope)
	local text = rope:to_text()
	file:write(minetest.compress(text, "deflate", compression or 9))
	file:close()
end

function schematic.read_zlib_bluon(path)
	local file = io.open(path, "rb")
	assert(file:read(4) == "MLZS", "not a modlib zlib compressed bluon schematic")
	return schematic.setmetatable(read_bluon(modlib.text.inputstream(minetest.decompress(file:read"*a", "deflate"))))
end

return schematic
