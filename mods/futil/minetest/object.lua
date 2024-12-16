local v_new = vector.new

-- if object is attached, get the velocity of the object it is attached to
function futil.get_velocity(object)
	local parent = object:get_attach()
	while parent do
		object = parent
		parent = object:get_attach()
	end
	return object:get_velocity()
end

function futil.get_horizontal_speed(object)
	local velocity = futil.get_velocity(object)
	velocity.y = 0
	return vector.length(velocity)
end

local function insert_connected(boxes, something)
	if futil.is_box(something) then
		table.insert(boxes, something)
	elseif futil.is_boxes(something) then
		table.insert_all(boxes, something)
	end
end

local function get_boxes(cb)
	if not cb then
		return { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
	end

	if cb.type == "regular" then
		return { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
	elseif cb.type == "fixed" then
		if futil.is_box(cb.fixed) then
			return { cb.fixed }
		elseif futil.is_boxes(cb.fixed) then
			return cb.fixed
		else
			return { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
		end
	elseif cb.type == "leveled" then
		-- TODO: have to check param2
		if futil.is_box(cb.fixed) then
			return { cb.fixed }
		elseif futil.is_boxes(cb.fixed) then
			return cb.fixed
		else
			return { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
		end
	elseif cb.type == "wallmounted" then
		-- TODO: have to check param2? or?
		local boxes = {}

		if futil.is_box(cb.wall_top) then
			table.insert(boxes, cb.wall_top)
		end
		if futil.is_box(cb.wall_bottom) then
			table.insert(boxes, cb.wall_bottom)
		end
		if futil.is_box(cb.wall_side) then
			table.insert(boxes, cb.wall_side)
		end

		if #boxes > 0 then
			return boxes
		else
			return { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
		end
	elseif cb.type == "connected" then
		-- TODO: very very complicated to check, just fudge and add everything
		local boxes = {}

		insert_connected(boxes, cb.fixed)
		insert_connected(boxes, cb.connect_top)
		insert_connected(boxes, cb.connect_bottom)
		insert_connected(boxes, cb.connect_front)
		insert_connected(boxes, cb.connect_left)
		insert_connected(boxes, cb.connect_back)
		insert_connected(boxes, cb.connect_right)
		insert_connected(boxes, cb.disconnected_top)
		insert_connected(boxes, cb.disconnected_bottom)
		insert_connected(boxes, cb.disconnected_front)
		insert_connected(boxes, cb.disconnected_left)
		insert_connected(boxes, cb.disconnected_back)
		insert_connected(boxes, cb.disconnected_right)
		insert_connected(boxes, cb.disconnected)
		insert_connected(boxes, cb.disconnected_sides)

		if #boxes > 0 then
			return boxes
		else
			return { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
		end
	end

	return { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
end

local function get_collision_boxes(node)
	local node_def = minetest.registered_nodes[node.name]

	if not node_def then
		-- unknown nodes are regular solid nodes
		return { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
	end

	if not node_def.walkable then
		return {}
	end

	local boxes
	if node_def.collision_box then
		boxes = get_boxes(node_def.collision_box)
	elseif node_def.drawtype == "nodebox" then
		boxes = get_boxes(node_def.node_box)
	else
		boxes = { { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } }
	end

	--[[
	if node_def.paramtype2 == "facedir" then
		-- TODO: re-orient boxes
	end
	]]

	return boxes
end

local function is_pos_on_ground(feet_pos, player_box)
	local node = minetest.get_node(feet_pos)
	local node_boxes = get_collision_boxes(node)

	for _, node_box in ipairs(node_boxes) do
		local actual_node_box = futil.box_offset(node_box, feet_pos)
		if futil.boxes_intersect(actual_node_box, player_box) then
			return true
		end
	end

	return false
end

function futil.is_on_ground(player)
	local p_pos = player:get_pos()
	local cb = player:get_properties().collisionbox

	-- collect the positions of the nodes below the player's feet
	local feet_poss = {
		v_new(math.round(p_pos.x + cb[1]), math.ceil(p_pos.y + cb[2] - 0.5), math.round(p_pos.z + cb[3])),
		v_new(math.round(p_pos.x + cb[1]), math.ceil(p_pos.y + cb[2] - 0.5), math.round(p_pos.z + cb[6])),
		v_new(math.round(p_pos.x + cb[4]), math.ceil(p_pos.y + cb[2] - 0.5), math.round(p_pos.z + cb[3])),
		v_new(math.round(p_pos.x + cb[4]), math.ceil(p_pos.y + cb[2] - 0.5), math.round(p_pos.z + cb[6])),
	}

	for _, feet_pos in ipairs(feet_poss) do
		if is_pos_on_ground(feet_pos, futil.box_offset(cb, p_pos)) then
			return true
		end
	end

	return false
end

function futil.get_object_center(object)
	local pos = object:get_pos()
	if not pos then
		return
	end
	local cb = object:get_properties().collisionbox
	return v_new(pos.x + (cb[1] + cb[4]) / 2, pos.y + (cb[2] + cb[5]) / 2, pos.z + (cb[3] + cb[6]) / 2)
end

function futil.is_player(obj)
	return minetest.is_player(obj) and not obj.is_fake_player
end

function futil.is_valid_object(obj)
	return obj and type(obj.get_pos) == "function" and vector.check(obj:get_pos())
end

-- this is meant to be able to get the HP of any object, including "immortal" ones whose health is managed themselves
-- it is *NOT* complete - i've got no idea where every mob API stores its hp.
-- "health" is mobs_redo (which is actually redundant with `:get_hp()` because they're not actually immortal.
-- "hp" is mobkit (and petz, which comes with its own fork of mobkit), and also creatura.
function futil.get_hp(obj)
	if not futil.is_valid_object(obj) then
		-- not an object or dead
		return 0
	end
	local ent = obj:get_luaentity()
	if ent and (type(ent.hp) == "number" or type(ent.health) == "number") then
		return ent.hp or ent.health
	end
	local armor_groups = obj:get_armor_groups()
	if (armor_groups["immortal"] or 0) == 0 then
		return obj:get_hp()
	end
	return math.huge -- presumably actually immortal
end
