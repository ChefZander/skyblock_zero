-- Localize globals
local assert, math, minetest, modlib, pairs, setmetatable, vector = assert, math, minetest, modlib, pairs, setmetatable, vector

--+ Raycast wrapper with proper flowingliquid intersections
return function(_pos1, _pos2, objects, liquids)
	local raycast = minetest.raycast(_pos1, _pos2, objects, liquids)
	if not liquids then
		return raycast
	end
	local pos1 = modlib.vector.from_minetest(_pos1)
	local _direction = vector.direction(_pos1, _pos2)
	local direction = modlib.vector.from_minetest(_direction)
	local length = vector.distance(_pos1, _pos2)
	local function next()
		local pointed_thing = raycast:next()
		if (not pointed_thing) or pointed_thing.type ~= "node" then
			return pointed_thing
		end
		local _pos = pointed_thing.under
		local pos = modlib.vector.from_minetest(_pos)
		local node = minetest.get_node(_pos)
		local def = minetest.registered_nodes[node.name]
		if not (def and def.drawtype == "flowingliquid") then
			return pointed_thing
		end
		local corner_levels = modlib.minetest.get_liquid_corner_levels(_pos)
		local full_corner_levels = true
		for _, corner_level in pairs(corner_levels) do
			if corner_level[2] < 0.5 then
				full_corner_levels = false
				break
			end
		end
		if full_corner_levels then
			return pointed_thing
		end
		local relative = pos1 - pos
		local inside = true
		for _, prop in pairs(relative) do
			if prop <= -0.5 or prop >= 0.5 then
				inside = false
				break
			end
		end
		local function level(x, z)
			local function distance_squared(corner)
				return (x - corner[1]) ^ 2 + (z - corner[3]) ^ 2
			end
			local irrelevant_corner, distance = 1, distance_squared(corner_levels[1])
			for index = 2, 4 do
				local other_distance = distance_squared(corner_levels[index])
				if other_distance > distance then
					irrelevant_corner, distance = index, other_distance
				end
			end
			local function corner(off)
				return corner_levels[((irrelevant_corner + off) % 4) + 1]
			end
			local base = corner(2)
			local edge_1, edge_2 = corner(1) - base, corner(3) - base
			-- Properly selected edges will have a total length of 2
			assert(math.abs(edge_1[1] + edge_1[3]) + math.abs(edge_2[1] + edge_2[3]) == 2)
			if edge_1[1] == 0 then
				edge_1, edge_2 = edge_2, edge_1
			end
			local level = base[2] + (edge_1[2] * ((x - base[1]) / edge_1[1])) + (edge_2[2] * ((z - base[3]) / edge_2[3]))
			assert(level >= -0.5 and level <= 0.5)
			return level
		end
		inside = inside and (relative[2] < level(relative[1], relative[3]))
		if inside then
			-- pos1 is inside the liquid node
			pointed_thing.intersection_point = _pos1
			pointed_thing.intersection_normal = vector.new(0, 0, 0)
			return pointed_thing
		end
		local function intersection_normal(axis, dir)
			return {x = 0, y = 0, z = 0, [axis] = dir}
		end
		local function plane(axis, dir)
			local offset = dir * 0.5
			local diff_axis = (relative[axis] - offset) / -direction[axis]
			local intersection_point = {}
			for plane_axis = 1, 3 do
				if plane_axis ~= axis then
					local value = direction[plane_axis] * diff_axis + relative[plane_axis]
					if value < -0.5 or value > 0.5 then
						return
					end
					intersection_point[plane_axis] = value
				end
			end
			intersection_point[axis] = offset
			return intersection_point
		end
		if direction[2] > 0 then
			local intersection_point = plane(2, -1)
			if intersection_point then
				pointed_thing.intersection_point = (intersection_point + pos):to_minetest()
				pointed_thing.intersection_normal = intersection_normal("y", -1)
				return pointed_thing
			end
		end
		for coord, other in pairs{[1] = 3, [3] = 1} do
			if direction[coord] ~= 0 then
				local dir = direction[coord] > 0 and -1 or 1
				local intersection_point = plane(coord, dir)
				if intersection_point then
					local height = 0
					for _, corner in pairs(corner_levels) do
						if corner[coord] == dir * 0.5 then
							height = height + (math.abs(intersection_point[other] + corner[other])) * corner[2]
						end
					end
					if intersection_point[2] <= height then
						pointed_thing.intersection_point = (intersection_point + pos):to_minetest()
						pointed_thing.intersection_normal = intersection_normal(modlib.vector.index_aliases[coord], dir)
						return pointed_thing
					end
				end
			end
		end
		for _, triangle in pairs{
			{corner_levels[3], corner_levels[2], corner_levels[1]},
			{corner_levels[4], corner_levels[3], corner_levels[1]}
		} do
			local pos_on_ray = modlib.vector.ray_triangle_intersection(relative, direction, triangle)
			if pos_on_ray and pos_on_ray <= length then
				pointed_thing.intersection_point = (pos1 + modlib.vector.multiply_scalar(direction, pos_on_ray)):to_minetest()
				pointed_thing.intersection_normal = modlib.vector.triangle_normal(triangle):to_minetest()
				return pointed_thing
			end
		end
		return next()
	end
	return setmetatable({next = next}, {__call = next})
end
