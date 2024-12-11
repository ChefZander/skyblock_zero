-- box definition below node boxes: https://github.com/minetest/minetest/blob/master/doc/lua_api.md#node-boxes

local x1 = 1
local y1 = 2
local z1 = 3
local x2 = 4
local y2 = 5
local z2 = 6

function futil.boxes_intersect(box1, box2)
	return not (
		(box1[x2] < box2[x1] or box2[x2] < box1[x1])
		or (box1[y2] < box2[y1] or box2[y2] < box1[y1])
		or (box1[z2] < box2[z1] or box2[z2] < box1[z1])
	)
end

function futil.box_offset(box, number_or_vector)
	if type(number_or_vector) == "number" then
		return {
			box[1] + number_or_vector,
			box[2] + number_or_vector,
			box[3] + number_or_vector,
			box[4] + number_or_vector,
			box[5] + number_or_vector,
			box[6] + number_or_vector,
		}
	else
		return {
			box[1] + number_or_vector.x,
			box[2] + number_or_vector.y,
			box[3] + number_or_vector.z,
			box[4] + number_or_vector.x,
			box[5] + number_or_vector.y,
			box[6] + number_or_vector.z,
		}
	end
end

function futil.is_box(box)
	if type(box) == "table" and #box == 6 then
		for _, x in ipairs(box) do
			if type(x) ~= "number" then
				return false
			end
		end
		return box[1] <= box[4] and box[2] <= box[5] and box[3] <= box[6]
	end
	return false
end

function futil.is_boxes(boxes)
	if type(boxes) ~= "table" or #boxes == 0 then
		return false
	end

	for _, box in ipairs(boxes) do
		if not futil.is_box(box) then
			return false
		end
	end

	return true
end

-- given a set of boxes, return a single box that covers all of them
function futil.cover_boxes(boxes)
	if not futil.is_boxes(boxes) then
		return { 0, 0, 0, 0, 0, 0 }
	end

	local cover = boxes[1]
	for i = 2, #boxes do
		for j = 1, 3 do
			cover[j] = math.min(cover[j], boxes[i][j])
		end
		for j = 4, 6 do
			cover[j] = math.max(cover[j], boxes[i][j])
		end
	end

	return cover
end

--[[
for nodes:
	A nodebox is defined as any of:

	{
		-- A normal cube; the default in most things
		type = "regular"
	}
	{
		-- A fixed box (or boxes) (facedir param2 is used, if applicable)
		type = "fixed",
		fixed = box OR {box1, box2, ...}
	}
	{
		-- A variable height box (or boxes) with the top face position defined
		-- by the node parameter 'leveled = ', or if 'paramtype2 == "leveled"'
		-- by param2.
		-- Other faces are defined by 'fixed = {}' as with 'type = "fixed"'.
		type = "leveled",
		fixed = box OR {box1, box2, ...}
	}
	{
		-- A box like the selection box for torches
		-- (wallmounted param2 is used, if applicable)
		type = "wallmounted",
		wall_top = box,
		wall_bottom = box,
		wall_side = box
	}
	{
		-- A node that has optional boxes depending on neighboring nodes'
		-- presence and type. See also `connects_to`.
		type = "connected",
		fixed = box OR {box1, box2, ...}
		connect_top = box OR {box1, box2, ...}
		connect_bottom = box OR {box1, box2, ...}
		connect_front = box OR {box1, box2, ...}
		connect_left = box OR {box1, box2, ...}
		connect_back = box OR {box1, box2, ...}
		connect_right = box OR {box1, box2, ...}
		-- The following `disconnected_*` boxes are the opposites of the
		-- `connect_*` ones above, i.e. when a node has no suitable neighbor
		-- on the respective side, the corresponding disconnected box is drawn.
		disconnected_top = box OR {box1, box2, ...}
		disconnected_bottom = box OR {box1, box2, ...}
		disconnected_front = box OR {box1, box2, ...}
		disconnected_left = box OR {box1, box2, ...}
		disconnected_back = box OR {box1, box2, ...}
		disconnected_right = box OR {box1, box2, ...}
		disconnected = box OR {box1, box2, ...} -- when there is *no* neighbor
		disconnected_sides = box OR {box1, box2, ...} -- when there are *no*
													  -- neighbors to the sides
	}

for objects:
	collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },  -- default
	selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = false },
	-- { xmin, ymin, zmin, xmax, ymax, zmax } in nodes from object position.
	-- Collision boxes cannot rotate, setting `rotate = true` on it has no effect.
	-- If not set, the selection box copies the collision box, and will also not rotate.
	-- If `rotate = false`, the selection box will not rotate with the object itself, remaining fixed to the axes.
	-- If `rotate = true`, it will match the object's rotation and any attachment rotations.
	-- Raycasts use the selection box and object's rotation, but do *not* obey attachment rotations
]]

futil.default_collision_box = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }

function futil.node_collision_box_to_object_collisionbox(collision_box)
	if type(collision_box) ~= "table" then
		return table.copy(futil.default_collision_box)
	elseif collision_box.type == "regular" then
		return table.copy(futil.default_collision_box)
	elseif collision_box.type == "fixed" or collision_box.type == "leveled" or collision_box.type == "connected" then
		if futil.is_box(collision_box.fixed) then
			return collision_box.fixed
		elseif futil.is_boxes(collision_box.fixed) then
			return futil.cover_boxes(collision_box.fixed)
		else
			return table.copy(futil.default_collision_box)
		end
	elseif collision_box.type == "wallmounted" then
		local boxes = {}
		if collision_box.wall_top then
			table.insert(boxes, collision_box.wall_top)
		end
		if collision_box.wall_bottom then
			table.insert(boxes, collision_box.wall_bottom)
		end
		if collision_box.wall_side then
			table.insert(boxes, collision_box.wall_side)
		end
		return futil.cover_boxes(boxes)
	else
		return table.copy(futil.default_collision_box)
	end
end

function futil.node_selection_box_to_object_selectionbox(selection_box, rotate)
	local selectionbox = futil.node_collision_box_to_object_collisionbox(selection_box)
	selectionbox.rotate = rotate or false
	return selectionbox
end
