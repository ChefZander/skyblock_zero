--[[
Luanti Mod Storage Drawers - A Mod adding storage drawers

Original Mod:
Copyright (C) 2017-2019 Linus Jahn <lnj@kaidan.im>

Modifications for Skyblock: Zero:
Copyright (C) 2026 Skyblock: Zero Contributors

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local S = core.get_translator('drawers')

-- To address part 5 of Issue #259:
-- Compute yaw from facedir direction so all four orientations are correct.
-- bdir is the vector the drawer face points toward (from core.facedir_to_dir).
-- The entity must face *toward the viewer*, i.e. opposite to bdir.

local function facedir_yaw(bdir)
	return math.atan2(-bdir.x, -bdir.z)
end

local function facedir(param2)
	return param2 % 32 -- ignore color bits
end

-- Nodes whose geometry can't be meaningfully represented as a flat sprite.
-- Use visual = "node" so the engine renders the actual mesh.
local COMPLEX_DRAWTYPES = {
	nodebox = true,
	mesh    = true,
	-- also a check below for animated blocks to render the same way
}
local function use_node_visual(item_def)
	if not item_def then return false end
	if COMPLEX_DRAWTYPES[item_def.drawtype] then
		local has_2d = (item_def.inventory_image and #item_def.inventory_image > 0)
			or (item_def.wield_image and #item_def.wield_image > 0)
		return not has_2d
	end
	-- Animated tiles with no explicit 2D image: render as node so the
	-- engine handles the animation rather than us mangling the spritesheet.
	if item_def.tiles then
		for _, tile in ipairs(item_def.tiles) do
			if type(tile) == "table" and tile.animation then
				local has_2d = (item_def.inventory_image and #item_def.inventory_image > 0)
					or (item_def.wield_image and #item_def.wield_image > 0)
				return not has_2d
			end
		end
	end
	return false
end

function drawers.spawn_visuals(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local drawerType = ndef.groups.drawer

	-- data for the new visual
	drawers.last_drawer_pos = pos
	drawers.last_drawer_type = drawerType

	if drawerType == 1 then -- 1x1 drawer
		drawers.last_visual_id = ""
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name"))

		local bdir = core.facedir_to_dir(facedir(node.param2))
		local fdir = vector.new(-bdir.x, 0, -bdir.z)
		local pos2 = vector.add(pos, vector.multiply(fdir, 0.45))

		local obj = core.add_entity(pos2, "drawers:visual")
		if not obj then return end

		obj:set_yaw(facedir_yaw(bdir))

		drawers.last_texture = nil
	elseif drawerType == 2 then
		local bdir = core.facedir_to_dir(facedir(node.param2))

		local fdir1
		local fdir2
		if facedir(node.param2) == 2 or facedir(node.param2) == 0 then
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x, -0.5, -bdir.z)
		else
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x, -0.5, -bdir.z)
		end

		-- Fix: declare objs and capture both entities so the yaw loop works
		local objs = {}

		drawers.last_visual_id = 1
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name1"))
		local pos1 = vector.add(pos, vector.multiply(fdir1, 0.45))
		objs[1] = core.add_entity(pos1, "drawers:visual")

		drawers.last_visual_id = 2
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name2"))
		local pos2 = vector.add(pos, vector.multiply(fdir2, 0.45))
		objs[2] = core.add_entity(pos2, "drawers:visual")

		local yaw = facedir_yaw(bdir)
		for _, obj in pairs(objs) do
			obj:set_yaw(yaw)
		end
	else -- 2x2 drawer
		local bdir = core.facedir_to_dir(facedir(node.param2))

		local fdir1
		local fdir2
		local fdir3
		local fdir4
		if facedir(node.param2) == 2 then
			fdir1 = vector.new(-bdir.x + 0.5, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x - 0.5, 0.5, -bdir.z)
			fdir3 = vector.new(-bdir.x + 0.5, -0.5, -bdir.z)
			fdir4 = vector.new(-bdir.x - 0.5, -0.5, -bdir.z)
		elseif facedir(node.param2) == 0 then
			fdir1 = vector.new(-bdir.x - 0.5, 0.5, -bdir.z)
			fdir2 = vector.new(-bdir.x + 0.5, 0.5, -bdir.z)
			fdir3 = vector.new(-bdir.x - 0.5, -0.5, -bdir.z)
			fdir4 = vector.new(-bdir.x + 0.5, -0.5, -bdir.z)
		elseif facedir(node.param2) == 1 then
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z + 0.5)
			fdir2 = vector.new(-bdir.x, 0.5, -bdir.z - 0.5)
			fdir3 = vector.new(-bdir.x, -0.5, -bdir.z + 0.5)
			fdir4 = vector.new(-bdir.x, -0.5, -bdir.z - 0.5)
		else
			fdir1 = vector.new(-bdir.x, 0.5, -bdir.z - 0.5)
			fdir2 = vector.new(-bdir.x, 0.5, -bdir.z + 0.5)
			fdir3 = vector.new(-bdir.x, -0.5, -bdir.z - 0.5)
			fdir4 = vector.new(-bdir.x, -0.5, -bdir.z + 0.5)
		end

		local objs = {}

		drawers.last_visual_id = 1
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name1"))
		local pos1 = vector.add(pos, vector.multiply(fdir1, 0.45))
		objs[1] = core.add_entity(pos1, "drawers:visual")

		drawers.last_visual_id = 2
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name2"))
		local pos2 = vector.add(pos, vector.multiply(fdir2, 0.45))
		objs[2] = core.add_entity(pos2, "drawers:visual")

		drawers.last_visual_id = 3
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name3"))
		local pos3 = vector.add(pos, vector.multiply(fdir3, 0.45))
		objs[3] = core.add_entity(pos3, "drawers:visual")

		drawers.last_visual_id = 4
		drawers.last_texture = drawers.get_inv_image(core.get_meta(pos):get_string("name4"))
		local pos4 = vector.add(pos, vector.multiply(fdir4, 0.45))
		objs[4] = core.add_entity(pos4, "drawers:visual")

		local yaw = facedir_yaw(bdir)
		for i, obj in pairs(objs) do
			obj:set_yaw(yaw)
		end
	end
end

function drawers.remove_visuals(pos)
	local objs = core.get_objects_inside_radius(pos, 0.56)
	if not objs then return end

	for _, obj in pairs(objs) do
		if obj and obj:get_luaentity() and
			obj:get_luaentity().name == "drawers:visual" then
			obj:remove()
		end
	end
end

--[[
	Returns the visual object for the visualid of the drawer at pos.

	visualid can be: "", "1", "2", ... or 1, 2, ...
]]
function drawers.get_visual(pos, visualid)
	local drawer_visuals = drawers.drawer_visuals[core.hash_node_position(pos)]
	if not drawer_visuals then
		return nil
	end

	-- not a real index (starts with 1)
	local index = tonumber(visualid)
	if visualid == "" then
		index = 1
	end

	return drawer_visuals[index]
end

core.register_entity("drawers:visual", {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = { -0.4374, -0.4374, 0, 0.4374, 0.4374, 0 }, -- for param2 0, 2
		visual = "upright_sprite",
		visual_size = { x = 0.6, y = 0.6 },
		textures = { "blank.png" },
		spritediv = { x = 1, y = 1 },
		initial_sprite_basepos = { x = 0, y = 0 },
		is_visible = true,
	},

	get_staticdata = function(self)
		return core.serialize({
			drawer_posx = self.drawer_pos.x,
			drawer_posy = self.drawer_pos.y,
			drawer_posz = self.drawer_pos.z,
			texture = self.texture,
			drawerType = self.drawerType,
			visualId = self.visualId,
			yaw = self.object:get_yaw(), -- Persist yaw across chunk reloads
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		-- Restore data
		local data = core.deserialize(staticdata)
		if data then
			self.drawer_pos = {
				x = data.drawer_posx,
				y = data.drawer_posy,
				z = data.drawer_posz,
			}
			self.texture = data.texture
			self.drawerType = data.drawerType or 1
			self.visualId = data.visualId or ""

			-- Restore yaw saved at serialize time
			if data.yaw then
				self.object:set_yaw(data.yaw)
			end

			-- backwards compatibility
			if self.texture == "drawers_empty.png" then
				self.texture = "blank.png"
			end
		else
			self.drawer_pos = drawers.last_drawer_pos
			self.texture = drawers.last_texture or "blank.png"
			self.visualId = drawers.last_visual_id
			self.drawerType = drawers.last_drawer_type
		end

		local node = core.get_node(self.object:get_pos())
		if core.get_item_group(node.name, "drawer") == 0 then
			self.object:remove()
			return
		end

		-- add self to public drawer visuals
		-- this is needed because there is no other way to get this class
		-- only the underlying LuaEntitySAO
		-- PLEASE contact me, if this is wrong
		local vId = self.visualId
		if vId == "" then vId = 1 end
		local posstr = core.hash_node_position(self.drawer_pos)
		if not drawers.drawer_visuals[posstr] then
			drawers.drawer_visuals[posstr] = { [vId] = self }
		else
			drawers.drawer_visuals[posstr][vId] = self
		end

		-- get meta
		self.meta = core.get_meta(self.drawer_pos)

		-- collisionbox
		-- Fix: use facedir() to strip color bits before comparing param2
		node = core.get_node(self.drawer_pos)
		local colbox
		if self.drawerType ~= 2 then
			if facedir(node.param2) == 1 or facedir(node.param2) == 3 then
				colbox = { 0, -0.4374, -0.4374, 0, 0.4374, 0.4374 }
			else
				colbox = { -0.4374, -0.4374, 0, 0.4374, 0.4374, 0 } -- for param2 = 0 or 2
			end
			-- only half the size if it's a small drawer
			if self.drawerType > 1 then
				for i, j in pairs(colbox) do
					colbox[i] = j * 0.5
				end
			end
		else
			if facedir(node.param2) == 1 or facedir(node.param2) == 3 then
				colbox = { 0, -0.2187, -0.4374, 0, 0.2187, 0.4374 }
			else
				colbox = { -0.4374, -0.2187, 0, 0.4374, 0.2187, 0 } -- for param2 = 0 or 2
			end
		end

		-- visual size
		local visual_size = { x = 0.6, y = 0.6 }
		if self.drawerType >= 2 then
			visual_size = { x = 0.3, y = 0.3 }
		end

		-- drawer values
		local vid = self.visualId
		self.count = self.meta:get_int("count" .. vid)
		self.itemName = self.meta:get_string("name" .. vid)
		self.maxCount = self.meta:get_int("max_count" .. vid)
		self.itemStackMax = self.meta:get_int("base_stack_max" .. vid)
		self.stackMaxFactor = self.meta:get_int("stack_max_factor" .. vid)

		-- infotext
		local infotext = self.meta:get_string("entity_infotext" .. vid) .. "\n\n\n\n\n"

		-- Use the same two-branch logic as updateTexture so node visuals
		-- don't try to load the item name as a texture filename on reload
		local item_def = core.registered_items[self.itemName]
		if use_node_visual(item_def) then
			local _visual_size = (self.drawerType >= 2)
				and { x = 0.22, y = 0.22, z = 0.0 }
				or { x = 0.44, y = 0.44, z = 0.0 }
			self.object:set_properties({
				collisionbox = colbox,
				infotext = infotext,
				visual = "node",
				node = { name = self.itemName },
				visual_size = _visual_size,
			})
		else
			self.object:set_properties({
				collisionbox = colbox,
				infotext = infotext,
				visual = "upright_sprite",
				textures = { self.texture },
				visual_size = visual_size,
			})
		end

		-- make entity undestroyable
		self.object:set_armor_groups({ immortal = 1 })
	end,
	on_rightclick = function(self, clicker)
		if core.is_protected(self.drawer_pos, clicker:get_player_name()) then
			core.record_protection_violation(self.drawer_pos, clicker:get_player_name())
			return
		end

		-- used to check if we need to play a sound in the end
		local inventoryChanged = false

		-- When the player uses the drawer with their bare hand all
		-- stacks from the inventory will be added to the drawer.
		if self.itemName ~= "" and
			clicker:get_wielded_item():get_name() == "" and
			not clicker:get_player_control().sneak then
			-- try to insert all items from inventory
			local i = 0
			local inv = clicker:get_inventory()

			while i <= inv:get_size("main") do
				-- set current stack to leftover of insertion
				local leftover = self.try_insert_stack(
					self,
					inv:get_stack("main", i),
					true
				)

				-- check if something was added
				if leftover:get_count() < inv:get_stack("main", i):get_count() then
					inventoryChanged = true
				end

				-- set new stack
				inv:set_stack("main", i, leftover)
				i = i + 1
			end
		else
			-- try to insert wielded item only
			local leftover = self.try_insert_stack(
				self,
				clicker:get_wielded_item(),
				not clicker:get_player_control().sneak
			)

			-- check if something was added
			if clicker:get_wielded_item():get_count() > leftover:get_count() then
				inventoryChanged = true
			end
			-- set the leftover as new wielded item for the player
			clicker:set_wielded_item(leftover)
		end

		if inventoryChanged then
			self:play_interact_sound()
		end
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local node = core.get_node(self.object:get_pos())

		if core.get_item_group(node.name, "drawer") == 0 then
			self.object:remove()
			return
		end
		local add_stack = not puncher:get_player_control().sneak
		if core.is_protected(self.drawer_pos, puncher:get_player_name()) then
			core.record_protection_violation(self.drawer_pos, puncher:get_player_name())
			return
		end
		local inv = puncher:get_inventory()
		if inv == nil then
			return
		end
		local spaceChecker = ItemStack(self.itemName)
		if add_stack then
			spaceChecker:set_count(spaceChecker:get_stack_max())
		end
		if not inv:room_for_item("main", spaceChecker) then
			return
		end

		local stack
		if add_stack then
			stack = self:take_stack()
		else
			stack = self:take_items(1)
		end

		if stack ~= nil then
			-- add removed stack to player's inventory
			inv:add_item("main", stack)

			-- play the interact sound
			self:play_interact_sound()
		end
	end,

	take_items = function(self, removeCount)
		local meta = core.get_meta(self.drawer_pos)

		if self.count <= 0 then
			return
		end

		if removeCount > self.count then
			removeCount = self.count
		end

		local stack = ItemStack(self.itemName)
		stack:set_count(removeCount)

		-- update the drawer count
		self.count = self.count - removeCount

		self:updateInfotext()
		self:update_texture()
		self:saveMetaData()

		-- return the stack that was removed from the drawer
		return stack
	end,

	take_stack = function(self)
		return self:take_items(ItemStack(self.itemName):get_stack_max())
	end,

	can_insert_stack = function(self, stack)
		if stack:get_name() == "" or stack:get_count() <= 0 then
			return 0
		end

		-- don't allow items with metadata
		if #stack:get_meta():get_keys() > 0 then
			return 0
		end

		-- don't allow unstackable stacks
		if self.itemName == "" and stack:get_stack_max() ~= 1 then
			return stack:get_count()
		end

		if self.itemName ~= stack:get_name() then
			return 0
		end

		if (self.count + stack:get_count()) <= self.maxCount then
			return stack:get_count()
		end
		return self.maxCount - self.count
	end,

	try_insert_stack = function(self, itemstack, insert_all)
		local stackCount = itemstack:get_count()
		local stackName = itemstack:get_name()

		local insertCount = self:can_insert_stack(itemstack)

		if insertCount == 0 then
			return itemstack
		end

		-- only add one, if player holding sneak key
		if not insert_all then
			insertCount = 1
		end

		-- in case the drawer was empty, initialize count, itemName, maxCount
		if self.itemName == "" then
			self.count = 0
			self.itemName = itemstack:get_name()
			self.maxCount = itemstack:get_stack_max() * self.stackMaxFactor
			self.itemStackMax = itemstack:get_stack_max()
		end

		-- update everything
		self.count = self.count + insertCount
		self:updateInfotext()
		self:update_texture()
		self:saveMetaData()

		-- return leftover
		itemstack:take_item(insertCount)
		if itemstack:get_count() == 0 then
			return ItemStack("")
		end
		return itemstack
	end,

	updateInfotext = function(self)
		local itemDescription = ""
		if core.registered_items[self.itemName] then
			itemDescription = core.registered_items[self.itemName].short_description or
				core.registered_items[self.itemName].description
		end

		if self.count <= 0 then
			self.itemName = ""
			self.meta:set_string("name" .. self.visualId, self.itemName)
			self.texture = "blank.png"
			itemDescription = S("Empty")
		end

		local infotext = drawers.gen_info_text(itemDescription,
			self.count, self.stackMaxFactor, self.itemStackMax)
		self.meta:set_string("entity_infotext" .. self.visualId, infotext)

		self.object:set_properties({
			infotext = infotext .. "\n\n\n\n\n"
		})
	end,

	update_texture = function(self)
		local item_def = core.registered_items[self.itemName]
		if use_node_visual(item_def) then
			local _visual_size = (self.drawerType >= 2)
				and { x = 0.22, y = 0.22, z = 0.0 }
				or { x = 0.44, y = 0.44, z = 0.0 }
			self.texture = self.itemName
			self.object:set_properties({
				visual = "node",
				node = { name = self.itemName },
				visual_size = _visual_size,
			})
		else
			self.texture = drawers.get_inv_image(self.itemName)
			local _visual_size = (self.drawerType >= 2)
				and { x = 0.3, y = 0.3 }
				or { x = 0.6, y = 0.6 }
			self.object:set_properties({
				visual = "upright_sprite",
				visual_size = _visual_size,
				textures = { self.texture },
			})
		end
	end,

	dropStack = function(self, itemStack)
		-- print warning if dropping higher stack counts than allowed
		if itemStack:get_count() > itemStack:get_stack_max() then
			core.log("warning", "[drawers] Dropping item stack with higher count than allowed")
		end
		-- find a position containing air
		local dropPos = core.find_node_near(self.drawer_pos, 1, { "air" }, false)
		-- if no pos found then drop on the top of the drawer
		if not dropPos then
			dropPos = self.object:get_pos()
			dropPos.y = dropPos.y + 1
		end
		-- drop the item stack
		core.item_drop(itemStack, nil, dropPos)
	end,

	dropItemOverload = function(self)
		-- drop stacks until there are no more items than allowed
		while self.count > self.maxCount do
			-- remove the overflow
			local removeCount = self.count - self.maxCount
			-- if this is too much for a single stack, only take the
			-- stack limit
			if removeCount > self.itemStackMax then
				removeCount = self.itemStackMax
			end
			-- remove this count from the drawer
			self.count = self.count - removeCount
			-- create a new item stack having the size of the remove
			-- count
			local stack = ItemStack(self.itemName)
			stack:set_count(removeCount)
			-- drop the stack
			self:dropStack(stack)
		end
	end,

	setStackMaxFactor = function(self, stackMaxFactor)
		self.stackMaxFactor = stackMaxFactor
		self.maxCount = self.stackMaxFactor * self.itemStackMax

		-- will drop possible overflowing items
		self:dropItemOverload()
		self:updateInfotext()
		self:saveMetaData()
	end,

	play_interact_sound = function(self)
		core.sound_play("drawers_interact", {
			pos = self.object:get_pos(),
			max_hear_distance = 6,
			gain = 2.0
		})
	end,

	saveMetaData = function(self, meta)
		self.meta:set_int("count" .. self.visualId, self.count)
		self.meta:set_string("name" .. self.visualId, self.itemName)
		self.meta:set_int("max_count" .. self.visualId, self.maxCount)
		self.meta:set_int("base_stack_max" .. self.visualId, self.itemStackMax)
		self.meta:set_int("stack_max_factor" .. self.visualId, self.stackMaxFactor)
	end
})

mesecon.register_mvps_kill("drawers:visual")

core.register_lbm({
	name              = "drawers:restore_visual",
	nodenames         = { "group:drawer" },
	run_at_every_load = true,
	action            = function(pos, node)
		local meta = core.get_meta(pos)
		-- create drawer upgrade inventory
		meta:get_inventory():set_size("upgrades", 5)
		-- set the formspec
		meta:set_string("formspec", drawers.drawer_formspec)

		-- count the drawer visuals
		local drawerType = core.registered_nodes[node.name].groups.drawer
		local foundVisuals = 0
		local objs = core.get_objects_inside_radius(pos, 0.56)
		if objs then
			for _, obj in pairs(objs) do
				if obj and obj:get_luaentity() and
					obj:get_luaentity().name == "drawers:visual" then
					foundVisuals = foundVisuals + 1
				end
			end
		end
		-- if all drawer visuals were found, return
		if foundVisuals == drawerType then
			return
		end

		-- not enough visuals found, remove existing and create new ones
		drawers.remove_visuals(pos)
		drawers.spawn_visuals(pos)
	end
})
