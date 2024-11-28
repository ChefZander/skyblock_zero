-- Localize globals
local math, minetest, modlib, pairs = math, minetest, modlib, pairs

-- Set environment
local _ENV = ...
setfenv(1, _ENV)

liquid_level_max = 8
--+ Calculates the corner levels of a flowingliquid node
--> 4 corner levels from -0.5 to 0.5 as list of `modlib.vector`
function get_liquid_corner_levels(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local source, flowing = def.liquid_alternative_source, node.name
	local range = def.liquid_range or liquid_level_max
	local neighbors = {}
	for x = -1, 1 do
		neighbors[x] = {}
		for z = -1, 1 do
			local neighbor_pos = {x = pos.x + x, y = pos.y, z = pos.z + z}
			local neighbor_node = minetest.get_node(neighbor_pos)
			local level
			if neighbor_node.name == source then
				level = 1
			elseif neighbor_node.name == flowing then
				local neighbor_level = neighbor_node.param2 % 8
				level = (math.max(0, neighbor_level - liquid_level_max + range) + 0.5) / range
			end
			neighbor_pos.y = neighbor_pos.y + 1
			local node_above = minetest.get_node(neighbor_pos)
			neighbors[x][z] = {
				air = neighbor_node.name == "air",
				level = level,
				above_is_same_liquid = node_above.name == flowing or node_above.name == source
			}
		end
	end
	local function get_corner_level(x, z)
		local air_neighbor
		local levels = 0
		local neighbor_count = 0
		for nx = x - 1, x do
			for nz = z - 1, z do
				local neighbor = neighbors[nx][nz]
				if neighbor.above_is_same_liquid then
					return 1
				end
				local level = neighbor.level
				if level then
					if level == 1 then
						return 1
					end
					levels = levels + level
					neighbor_count = neighbor_count + 1
				elseif neighbor.air then
					if air_neighbor then
						return 0.02
					end
					air_neighbor = true
				end
			end
		end
		if neighbor_count == 0 then
			return 0
		end
		return levels / neighbor_count
	end
	local corner_levels = {
		{0, nil, 0},
		{1, nil, 0},
		{1, nil, 1},
		{0, nil, 1}
	}
	for index, corner_level in pairs(corner_levels) do
		corner_level[2] = get_corner_level(corner_level[1], corner_level[3])
		corner_levels[index] = modlib.vector.subtract_scalar(modlib.vector.new(corner_level), 0.5)
	end
	return corner_levels
end

flowing_downwards = modlib.vector.new{0, -1, 0}
--+ Calculates the flow direction of a flowingliquid node
--> `modlib.minetest.flowing_downwards = modlib.vector.new{0, -1, 0}` if only flowing downwards
--> surface direction as `modlib.vector` else
function get_liquid_flow_direction(pos)
	local corner_levels = get_liquid_corner_levels(pos)
	local max_level = corner_levels[1][2]
	for index = 2, 4 do
		local level = corner_levels[index][2]
		if level > max_level then
			max_level = level
		end
	end
	local dir = modlib.vector.new{0, 0, 0}
	local count = 0
	for max_level_index, corner_level in pairs(corner_levels) do
		if corner_level[2] == max_level then
			for offset = 1, 3 do
				local index = (max_level_index + offset - 1) % 4 + 1
				local diff = corner_level - corner_levels[index]
				if diff[2] ~= 0 then
					diff[1] = diff[1] * diff[2]
					diff[3] = diff[3] * diff[2]
					if offset == 3 then
						diff = modlib.vector.divide_scalar(diff, math.sqrt(2))
					end
					dir = dir + diff
					count = count + 1
				end
			end
		end
	end
	if count ~= 0 then
		dir = modlib.vector.divide_scalar(dir, count)
	end
	if dir == modlib.vector.new{0, 0, 0} then
		if minetest.get_node(pos).param2 % 32 > 7 then
			return flowing_downwards
		end
	end
	return dir
end