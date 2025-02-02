-- biomelist.lua

local core_cid = minetest.get_content_id
local function cid(name)
	if not name then
		return
	end
	local result
	pcall(function() --< try
		result = core_cid(name)
	end)
	if not result then
		print("[biomegen] Node " .. name .. " not found!")
	end
	return result
end

local function make_biomelist()
	local biomes = {}

	for _, a in pairs(minetest.registered_biomes) do
		local b = {}
		b.name = a.name
		biomes[b.name] = b
		b.id = minetest.get_biome_id(a.name)

		if a.node_dust then
			b.node_dust_name = a.node_dust
			b.node_dust = cid(a.node_dust)
		end

		b.node_top = cid(a.node_top) or cid("mapgen_stone")
		b.depth_top = a.depth_top or 0

		b.node_filler = cid(a.node_filler) or cid("mapgen_stone")
		b.depth_filler = a.depth_filler or 0

		b.node_stone = cid(a.node_stone) or cid("mapgen_stone")

		b.node_water_top = cid(a.node_water_top) or cid("mapgen_water_source")
		b.depth_water_top = a.depth_water_top or 0

		b.node_water = cid(a.node_water) or cid("mapgen_water_source")
		b.node_river_water = cid(a.node_river_water) or cid("mapgen_river_water_source")

		b.node_riverbed = cid(a.node_riverbed) or cid("mapgen_stone")
		b.depth_riverbed = a.depth_riverbed or 0

		-- b.node_cave_liquid = ...
		-- b.node_dungeon = ...
		-- b.node_dungeon_alt = ...
		-- b.node_dungeon_stair = ...

		b.min_pos = a.min_pos or {x=-31000, y=-31000, z=-31000}
		if a.y_min then
			b.min_pos.y = math.max(b.min_pos.y, a.y_min)
		end
		b.max_pos = a.max_pos or {x=31000, y=31000, z=31000}
		if a.y_max then
			b.max_pos.y = math.min(b.max_pos.y, a.y_max)
		end

		b.vertical_blend = a.vertical_blend or 0

		b.heat_point = a.heat_point or 50
		b.humidity_point = a.humidity_point or 50
	end

	return biomes
end

return make_biomelist
