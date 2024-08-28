local luaentity = pipeworks.luaentity
local enable_max_limit = minetest.settings:get_bool("pipeworks_enable_items_per_tube_limit")
local max_tube_limit = tonumber(minetest.settings:get("pipeworks_max_items_per_tube")) or 30
if enable_max_limit == nil then enable_max_limit = true end

function pipeworks.tube_inject_item(pos, start_pos, velocity, item, owner, tags)
	-- Take item in any format
	local stack = ItemStack(item)
	local obj = luaentity.add_entity(pos, "pipeworks:tubed_item")
	obj:set_item(stack:to_string())
	obj.start_pos = vector.new(start_pos)
	obj:set_velocity(velocity)
	obj.owner = owner
	obj.tags = {}
	--obj:set_color("red") -- todo: this is test-only code
	return obj
end

-- adding two tube functions
-- can_remove(pos,node,stack,dir) returns the maximum number of items of that stack that can be removed
-- remove_items(pos,node,stack,dir,count) removes count items and returns them
-- both optional w/ sensible defaults and fallback to normal allow_* function
-- XXX: possibly change insert_object to insert_item

local default_adjlist = { { x = 0, y = 0, z = 1 }, { x = 0, y = 0, z = -1 }, { x = 0, y = 1, z = 0 }, { x = 0, y = -1, z = 0 }, { x = 1, y = 0, z = 0 }, { x = -1, y = 0, z = 0 } }

function pipeworks.notvel(tbl, vel)
	local tbl2 = {}
	for _, val in ipairs(tbl) do
		if val.x ~= -vel.x or val.y ~= -vel.y or val.z ~= -vel.z then table.insert(tbl2, val) end
	end
	return tbl2
end

local tube_item_count = {}

minetest.register_globalstep(function(dtime)
	if not luaentity.entities then
		return
	end
	tube_item_count = {}
	for _, entity in pairs(luaentity.entities) do
		if entity.name == "pipeworks:tubed_item" then
			local h = minetest.hash_node_position(vector.round(entity._pos))
			tube_item_count[h] = (tube_item_count[h] or 0) + 1
		end
	end
end)



-- tube overload mechanism:
-- when the tube's item count (tracked in the above tube_item_count table)
-- exceeds the limit configured per tube, replace it with a broken one.

function pipeworks.break_tube(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("the_tube_was", minetest.serialize(node))
	minetest.swap_node(pos, { name = "pipeworks:broken_tube_1" })
	pipeworks.scan_for_tube_objects(pos)
end

local crunch_tube = function(pos, cnode, cmeta)
	if enable_max_limit then
		local h = minetest.hash_node_position(pos)
		local itemcount = tube_item_count[h] or 0
		if itemcount > max_tube_limit then
			pipeworks.logger("Warning - a tube at " ..
				minetest.pos_to_string(pos) .. " broke due to too many items (" .. itemcount .. ")")
			pipeworks.break_tube(pos)
		end
	end
end



-- compatibility behaviour for the existing can_go() callbacks,
-- which can only specify a list of possible positions.
local function go_next_compat(pos, cnode, cmeta, cycledir, vel, stack, owner, tags)
	local next_positions = {}
	local max_priority = 0
	local can_go

	local def = minetest.registered_nodes[cnode.name]
	if def and def.tube and def.tube.can_go then
		can_go = def.tube.can_go(pos, cnode, vel, stack, tags)
	else
		local adjlist_string = minetest.get_meta(pos):get_string("adjlist")
		local adjlist = minetest.deserialize(adjlist_string) or
			default_adjlist -- backward compat: if not found, use old behavior: all directions

		can_go = pipeworks.notvel(adjlist, vel)
	end
	-- can_go() is expected to return an array-like table of candidate offsets.
	-- for each one, look at the node at that offset and determine if it can accept the item.
	-- also note the prioritisation:
	-- if any tube is found with a greater priority than previously discovered,
	-- then the valid positions are reset and and subsequent positions under this are skipped.
	-- this has the effect of allowing only equal priorities to co-exist.
	for _, vect in ipairs(can_go) do
		local npos = vector.add(pos, vect)
		pipeworks.load_position(npos)
		local node = minetest.get_node(npos)
		local reg_node = minetest.registered_nodes[node.name]
		if reg_node then
			local tube_def = reg_node.tube
			local tubedevice = minetest.get_item_group(node.name, "tubedevice")
			local tube_priority = (tube_def and tube_def.priority) or 100
			if tubedevice > 0 and tube_priority >= max_priority then
				if not tube_def or not tube_def.can_insert or
					tube_def.can_insert(npos, node, stack, vect, owner) then
					if tube_priority > max_priority then
						max_priority = tube_priority
						next_positions = {}
					end
					next_positions[#next_positions + 1] = { pos = npos, vect = vect }
				end
			end
		end
	end

	-- indicate not found if no valid rules were picked up,
	-- and don't change the counter.
	if not next_positions[1] then
		return cycledir, false, nil, nil
	end

	-- otherwise rotate to the next output direction and return that
	local n = (cycledir % (#next_positions)) + 1
	local new_velocity = vector.multiply(next_positions[n].vect, vel.speed)
	return n, true, new_velocity, nil
end




-- function called by the on_step callback of the pipeworks tube luaentity.
-- the routine is passed the current node position, velocity, itemstack,
-- and owner name.
-- returns three values:
-- * a boolean "found destination" status;
-- * a new velocity vector that the tubed item should use, or nil if not found;
-- * a "multi-mode" data table (or nil if N/A) where a stack was split apart.
--	if this is not nil, the luaentity spawns new tubed items for each new fragment stack,
--	then deletes itself (i.e. the original item stack).
local function go_next(pos, velocity, stack, owner, tags)
	local cnode = minetest.get_node(pos)
	local cmeta = minetest.get_meta(pos)
	local speed = math.abs(velocity.x + velocity.y + velocity.z)
	if speed == 0 then
		speed = 1
	end
	local vel = { x = velocity.x / speed, y = velocity.y / speed, z = velocity.z / speed, speed = speed }
	if speed >= 4.1 then
		speed = 4
	elseif speed >= 1.1 then
		speed = speed - 0.1
	else
		speed = 1
	end
	vel.speed = speed

	crunch_tube(pos, cnode, cmeta)
	-- cycling of outputs:
	-- an integer counter is kept in each pipe's metadata,
	-- which allows tracking which output was previously chosen.
	-- note reliance on get_int returning 0 for uninitialised.
	local cycledir = cmeta:get_int("tubedir")

	-- pulled out and factored out into go_next_compat() above.
	-- n is the new value of the cycle counter.
	-- XXX: this probably needs cleaning up after being split out,
	-- seven args is a bit too many
	local n, found, new_velocity, multimode = go_next_compat(pos, cnode, cmeta, cycledir, vel, stack, owner, tags)

	-- if not using output cycling,
	-- don't update the field so it stays the same for the next item.
	if pipeworks.enable_cyclic_mode then
		cmeta:set_int("tubedir", n)
	end
	return found, new_velocity, multimode
end



minetest.register_entity("pipeworks:tubed_item", {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collisionbox = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		visual = "wielditem",
		visual_size = { x = pipeworks.tube_size, y = pipeworks.tube_size },
		textures = { "" },
		spritediv = { x = 1, y = 1 },
		initial_sprite_basepos = { x = 0, y = 0 },
		is_visible = false,
	},

	physical_state = false,

	from_data = function(self, itemstring)
		local stack = ItemStack(itemstring)
		--[[
		local itemtable = stack:to_table()
		local itemname = nil
		if itemtable then
			itemname = stack:to_table().name
		end
		local item_texture = nil
		local item_type = ""
		if minetest.registered_items[itemname] then
			item_texture = minetest.registered_items[itemname].inventory_image
			item_type = minetest.registered_items[itemname].type
		end
		--]]
		self.object:set_properties({
			is_visible = true,
			textures = { stack:get_name() }
		})
		local def = stack:get_definition()
		self.object:set_yaw((def and def.type == "node") and 0 or math.pi * 0.25)
	end,

	get_staticdata = luaentity.get_staticdata,
	on_activate = function(self, staticdata) -- Legacy code, should be replaced later by luaentity.on_activate
		if staticdata == "" or staticdata == nil then
			return
		end
		if staticdata == "toremove" then
			self.object:remove()
			return
		end
		local item = minetest.deserialize(staticdata)
		pipeworks.tube_inject_item(self.object:get_pos(), item.start_pos, item.velocity, item.itemstring)
		self.object:remove()
	end,
})

minetest.register_entity("pipeworks:color_entity", {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collisionbox = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		visual = "cube",
		visual_size = { x = 3.5, y = 3.5, z = 3.5 }, -- todo: find correct size
		textures = { "" },
		is_visible = false,
	},

	physical_state = false,

	from_data = function(self, color)
		local t = "pipeworks_color_" .. color .. ".png"
		local prop = {
			is_visible = true,
			visual = "cube",
			textures = { t, t, t, t, t, t } -- todo: textures
		}
		self.object:set_properties(prop)
	end,

	get_staticdata = luaentity.get_staticdata,
	on_activate = luaentity.on_activate,
})

-- see below for usage:
-- determine if go_next returned a multi-mode set.
local is_multimode = function(v)
	return (type(v) == "table") and (v.__multimode)
end

luaentity.register_entity("pipeworks:tubed_item", {
	itemstring = '',
	item_entity = nil,
	color_entity = nil,
	color = nil,
	start_pos = nil,
	tags = nil,

	set_item = function(self, item)
		local itemstring = ItemStack(item):to_string() -- Accept any input format
		if self.itemstring == itemstring then
			return
		end
		if self.item_entity then
			self:remove_attached_entity(self.item_entity)
		end
		self.itemstring = itemstring
		self.item_entity = self:add_attached_entity("pipeworks:tubed_item", itemstring)
	end,

	set_color = function(self, color)
		if self.color == color then
			return
		end
		self.color = color
		if self.color_entity then
			self:remove_attached_entity(self.color_entity)
		end
		if color then
			self.color_entity = self:add_attached_entity("pipeworks:color_entity", color)
		else
			self.color_entity = nil
		end
	end,

	on_step = function(self, dtime)
		local pos = self:get_pos()
		if self.start_pos == nil then
			self.start_pos = vector.round(pos)
			self:set_pos(pos)
		end

		local velocity = self:get_velocity()

		local moved = false
		local speed = math.abs(velocity.x + velocity.y + velocity.z)
		if speed == 0 then
			speed = 1
			moved = true
		end
		local vel = { x = velocity.x / speed, y = velocity.y / speed, z = velocity.z / speed, speed = speed }
		local moved_by = vector.distance(pos, self.start_pos)

		if moved_by >= 1 then
			self.start_pos = vector.add(self.start_pos, vel)
			moved = true
		end

		if not moved then
			return
		end

		local stack = ItemStack(self.itemstring)

		pipeworks.load_position(self.start_pos)
		local node = minetest.get_node(self.start_pos)
		if minetest.get_item_group(node.name, "tubedevice_receiver") == 1 then
			local leftover
			local def = minetest.registered_nodes[node.name]
			if def.tube and def.tube.insert_object then
				leftover = def.tube.insert_object(self.start_pos, node, stack, vel, self.owner)
			else
				leftover = stack
			end
			if leftover:is_empty() then
				self:remove()
				return
			end
			velocity = vector.multiply(velocity, -1)
			self:set_pos(vector.subtract(self.start_pos, vector.multiply(vel, moved_by - 1)))
			self:set_velocity(velocity)
			self:set_item(leftover:to_string())
			return
		end

		local tags
		if pipeworks.enable_item_tags then
			tags = self.tags or {}
		end
		local found_next, new_velocity, multimode = go_next(self.start_pos, velocity, stack, self.owner, tags) -- todo: color
		if pipeworks.enable_item_tags then
			self.tags = #tags > 0 and tags or nil
		end
		local rev_vel = vector.multiply(velocity, -1)
		local rev_dir = vector.direction(self.start_pos, vector.add(self.start_pos, rev_vel))
		local rev_node = minetest.get_node(vector.round(vector.add(self.start_pos, rev_dir)))
		local tube_present = minetest.get_item_group(rev_node.name, "tubedevice") == 1
		if not found_next then
			if pipeworks.drop_on_routing_fail or not tube_present or
				minetest.get_item_group(rev_node.name, "tube") ~= 1 then
				-- Using add_item instead of item_drop since this makes pipeworks backward
				-- compatible with Minetest 0.4.13.
				-- Using item_drop here makes Minetest 0.4.13 crash.
				local dropped_item = minetest.add_item(self.start_pos, stack)
				if dropped_item then
					dropped_item:set_velocity(vector.multiply(velocity, 5))
					self:remove()
				end
				return
			else
				velocity = vector.multiply(velocity, -1)
				self:set_pos(vector.subtract(self.start_pos, vector.multiply(vel, moved_by - 1)))
				self:set_velocity(velocity)
			end
		elseif is_multimode(multimode) then
			-- create new stacks according to returned data.
			local s = self.start_pos
			for _, split in ipairs(multimode) do
				pipeworks.tube_inject_item(s, s, split.velocity, split.itemstack, self.owner)
			end
			-- remove ourself now the splits are sent
			self:remove()
			return
		end

		if new_velocity and not vector.equals(velocity, new_velocity) then
			local nvelr = math.abs(new_velocity.x + new_velocity.y + new_velocity.z)
			self:set_pos(vector.add(self.start_pos, vector.multiply(new_velocity, (moved_by - 1) / nvelr)))
			self:set_velocity(new_velocity)
		end
	end
})

if minetest.get_modpath("mesecons_mvps") then
	mesecon.register_mvps_unmov("pipeworks:tubed_item")
	mesecon.register_mvps_unmov("pipeworks:color_entity")
	mesecon.register_on_mvps_move(function(moved_nodes)
		local moved = {}
		for _, n in ipairs(moved_nodes) do
			moved[minetest.hash_node_position(n.oldpos)] = vector.subtract(n.pos, n.oldpos)
		end
		for _, entity in pairs(luaentity.entities) do
			if entity.name == "pipeworks:tubed_item" then
				local pos = entity:get_pos()
				local rpos = vector.round(pos)
				local dir = moved[minetest.hash_node_position(rpos)]
				if dir then
					entity:set_pos(vector.add(pos, dir))
					entity.start_pos = vector.add(entity.start_pos, dir)
				end
			end
		end
	end)
end
