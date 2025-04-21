local media_paths = epidermis.media_paths
local send_notification = epidermis.send_notification

minetest.register_craftitem("epidermis:spawner_paintable", {
	description = "Paintable Spawner",
	inventory_image = "epidermis_paintable_spawner.png",
	on_place = function(itemstack, user, pointed_thing)
		if not pointed_thing.above then return end
		local base_texture = epidermis.get_skin(user)
		if not media_paths[base_texture] then
			send_notification(user, "Invalid (combined?) texture! Defaulting to character.png.", "warning")
			base_texture = "character.png"
		end
		local object = minetest.add_entity(
			vector.divide(vector.add(pointed_thing.under, pointed_thing.above), 2),
			"epidermis:paintable",
			minetest.serialize {
				owner = user:get_player_name(),
				base_texture = base_texture,
				mesh = assert(epidermis.get_model(user))
			}
		)
		if not object then
			send_notification(user, "Can't spawn paintable!", "error")
			return
		end
		local entity = object:get_luaentity()
		entity:_face(user)
		if epidermis.get_epidermis_path_from_texture(base_texture) then
			-- Force-copy the texture if it belongs to another epidermis,
			-- as the texture will be dropped when the player & the other epidermis stop using it
			entity:_write_texture(modlib.func.no_op)
		end
		itemstack:take_item()
		return itemstack
	end,
})

core.register_craft {
	output = "epidermis:spawner_paintable",
	recipe = {
		{ "unifieddyes:colorium_blob", "unifieddyes:colorium_blob",        "unifieddyes:colorium_blob" },
		{ "unifieddyes:colorium_blob", "sbz_resources:phlogiston_circuit", "unifieddyes:colorium_blob" },
		{ "unifieddyes:colorium_blob", "unifieddyes:colorium_blob",        "unifieddyes:colorium_blob" },
	}
}

local colorpicker_name = "epidermis:colorpicker"
local colorpicker_thickness = minetest.registered_entities[colorpicker_name]._thickness
minetest.register_craftitem("epidermis:spawner_colorpicker", {
	description = "HSV Color Picker Spawner",
	inventory_image = "epidermis_palette.png",
	on_place = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		-- HACK assuming a node size of exactly one
		local face_pos = vector.divide(vector.add(pointed_thing.above, pointed_thing.under), 2)
		local direction = vector.direction(pointed_thing.under, pointed_thing.above)
		local object = minetest.add_entity(
			vector.add(face_pos, vector.multiply(direction, colorpicker_thickness / 2)),
			colorpicker_name)
		if not object then
			send_notification(user, "Can't spawn colorpicker!", "error")
			return
		end
		local normal = vector.subtract(pointed_thing.above, pointed_thing.under)
		object:get_luaentity():_set_rotation(moblib.get_rotation(normal))
		itemstack:take_item()
		return itemstack
	end,
})

core.register_craft {
	output = "epidermis:spawner_colorpicker",
	recipe = {
		{ "unifieddyes:colorium",      "unifieddyes:colorium",      "unifieddyes:colorium" },
		{ "unifieddyes:colorium_blob", "unifieddyes:colorium_blob", "unifieddyes:colorium_blob" },
		{ "unifieddyes:colorium_blob", "unifieddyes:colorium_blob", "unifieddyes:colorium_blob" },
	}
}

local function set_item_color(itemstack, colorspec)
	local colorstring = colorspec:to_string()
	itemstack:get_meta():set_string("color", colorstring)
	local foreground = "#FFFFFF"
	if (colorspec.r + colorspec.g + colorspec.b) > 3 * 127 then
		-- Bright background: Choose a dark foreground  color
		foreground = "#000000"
	end
	itemstack:get_meta():set_string("description",
		minetest.get_background_escape_sequence(colorstring)
		.. minetest.colorize(foreground, itemstack:get_definition().description))
end

local function get_entity(user, pointed_thing, allow_any)
	if not (user and user:is_player()) then
		return
	end
	if not pointed_thing or pointed_thing.type ~= "object" then
		return
	end
	local object = pointed_thing.ref
	local entity = object:get_luaentity()
	if not entity then
		return
	end
	if entity.name == "epidermis:paintable" then
		if not entity:_can_edit(user) then
			return
		end
		if object:get_animation().y > 1 then
			send_notification(user, "Playing animation!", "warning")
			return
		end
		return entity
	elseif allow_any then
		return entity
	end
end

local function get_eye_pos(player)
	local eye_pos = player:get_pos()
	eye_pos.y = eye_pos.y + player:get_properties().eye_height
	local first, third = player:get_eye_offset()
	if not vector.equals(first, third) then
		minetest.log("warning", "First & third person eye offsets don't match, assuming first person")
	end
	return vector.add(eye_pos, vector.divide(first, 10))
end

local function get_intersection_infos(user, paintable)
	return paintable:_get_intersection_infos(get_eye_pos(user), user:get_look_dir())
end

local function get_paintable_intersection(user, paintable)
	local intersection_infos = get_intersection_infos(user, paintable)
	for _, intersection_info in ipairs(intersection_infos) do
		if intersection_info.color.a > 0 then
			return intersection_info
		end
	end
end

local color_tools = {}
local default_color = "#FFFFFF"
local function on_secondary_use(itemstack, user, pointed_thing)
	local entity = get_entity(user, pointed_thing, true)
	if entity then
		if entity.name == "epidermis:colorpicker" then
			local color = entity:_get_color(user)
			if color then
				set_item_color(itemstack, color)
				return itemstack
			end
			return
		end
		if entity.name == "epidermis:paintable" then
			local intersection_info = get_paintable_intersection(user, entity)
			if intersection_info then
				set_item_color(itemstack, intersection_info.color)
				return itemstack
			end
			return
		end
	end
	local colorstring = itemstack:get_meta():get "color" or default_color
	local colorspec = assert(modlib.minetest.colorspec.from_string(colorstring))
	epidermis.show_colorpicker_formspec(user, colorspec, function(color)
		if not color then return end
		local wstack = user:get_wielded_item()
		if not color_tools[wstack:get_name()] then return end
		set_item_color(wstack, color)
		user:set_wielded_item(wstack)
	end)
end

local function register_color_tool(name, def, on_paint)
	color_tools[name] = true
	def.color = default_color
	def.on_secondary_use = on_secondary_use
	def.on_place = on_secondary_use
	function def.on_use(itemstack, user, pointed_thing)
		local entity = get_entity(user, pointed_thing, true)
		if not entity then
			return
		end
		if entity.name == "epidermis:colorpicker" then
			-- The other params aren't used by the on_punch handler
			entity:on_punch(user)
			return
		end
		if entity.name ~= "epidermis:paintable" then
			return
		end
		local colorstring = itemstack:get_meta():get "color" or default_color
		local color = assert(modlib.minetest.colorspec.from_string(colorstring), colorstring)
		local intersection_info = get_paintable_intersection(user, entity)
		if intersection_info then
			return on_paint(entity, intersection_info.pixelcoord, color, user)
		end
	end

	epidermis.register_tool(name, def)
end

register_color_tool("epidermis:pen", {
	description = "Pen",
	inventory_image = "epidermis_pen_tip.png",
	inventory_overlay = "epidermis_pen_handle.png",
}, function(entity, pixelcoord, color)
	entity:_set_color(entity:_get_pixel_index(unpack(pixelcoord)), color:to_number(), "undo")
	entity:_update_texture()
end)

core.register_craft {
	output = "epidermis:pen",
	recipe = {
		{ "sbz_resources:phlogiston", "unifieddyes:coloring_tool", "sbz_resources:phlogiston" }
	}
}

-- TODO (?) allow holding these items using a globalstep

epidermis.register_tool("epidermis:eraser", {
	description = "Eraser",
	inventory_image = "epidermis_eraser.png",
	on_secondary_use = function(_, user, pointed_thing)
		local paintable = get_entity(user, pointed_thing)
		if not paintable then
			return
		end
		local last_transparent_frontface
		local intersection_infos = get_intersection_infos(user, paintable)
		for _, intersection_info in ipairs(intersection_infos) do
			if intersection_info.color.a < 255 then
				last_transparent_frontface = intersection_info
			else
				break
			end
		end
		if last_transparent_frontface then
			local idx = paintable:_get_pixel_index(unpack(last_transparent_frontface.pixelcoord))
			paintable:_set_color(idx, paintable:_get_color(idx) % 0x1000000 + 0xFF * 0x1000000, true)
			paintable:_update_texture()
		end
	end,
	on_use = function(_, user, pointed_thing)
		local paintable = get_entity(user, pointed_thing)
		if not paintable then
			return
		end
		local intersection_infos = get_intersection_infos(user, paintable)
		for _, intersection_info in ipairs(intersection_infos) do
			if intersection_info.color.a > 0 then
				local idx = paintable:_get_pixel_index(unpack(intersection_info.pixelcoord))
				paintable:_set_color(idx, paintable:_get_color(idx) % 0x1000000, true)
				paintable:_update_texture()
				return
			end
		end
	end
})

core.register_craft {
	output = "epidermis:eraser",
	recipe = {
		{ "epidermis:pen", "unifieddyes:colorium" }
	}
}

local function undo_redo_use_func(logname)
	return function(_, user, pointed_thing)
		local paintable = get_entity(user, pointed_thing)
		if not paintable then
			return
		end
		if not paintable:_reverse_last_log_action(logname) then
			send_notification(user, "Nothing to " .. logname .. "!", "warning")
		else
			paintable:_update_texture()
		end
	end
end

epidermis.register_tool("epidermis:undo_redo", {
	description = "Undo / Redo",
	inventory_image = "epidermis_undo_redo.png",
	on_secondary_use = undo_redo_use_func "redo",
	on_use = undo_redo_use_func "undo"
})

core.register_craft {
	output = "epidermis:undo_redo",
	recipe = {
		{ "sbz_resources:retaining_circuit", "sbz_resources:retaining_circuit", "sbz_resources:retaining_circuit", },
		{ "sbz_resources:retaining_circuit", "unifieddyes:coloring_tool",       "sbz_resources:retaining_circuit", },
		{ "sbz_resources:retaining_circuit", "sbz_resources:retaining_circuit", "sbz_resources:retaining_circuit", }
	}
}

register_color_tool("epidermis:filling_bucket", {
	description = "Filling Bucket",
	inventory_image = "epidermis_filling_paint.png",
	inventory_overlay = "epidermis_filling_bucket.png",
}, function(entity, pixelcoord, color)
	local start_index = entity:_get_pixel_index(unpack(pixelcoord))
	local replace_color = entity:_get_color(start_index)
	local to_fill = { [start_index] = replace_color }
	local additions
	local width, height = entity._.width, entity._.height
	local function fill(index)
		if to_fill[index] or not entity._paintable_pixels[index] then
			return
		end
		local actual_color = entity:_get_color(index)
		-- Doesn't need to handle transparent pixels, as those can't be pointed anyways
		if actual_color ~= replace_color then
			return
		end
		additions[index] = actual_color
	end
	repeat
		additions = {}
		for index in pairs(to_fill) do
			local x, y = entity:_get_xy(index)
			if x > 0 then
				fill(index - 1)
			end
			if x < width - 1 then
				fill(index + 1)
			end
			if y > 0 then
				fill(index - width)
			end
			if y < height - 1 then
				fill(index + width)
			end
		end
		modlib.table.add_all(to_fill, additions)
	until not next(additions)
	local color_argb = color:to_number()
	for index in pairs(to_fill) do
		entity:_set_color(index, color_argb)
	end
	entity:_log_actions("undo", to_fill)
	entity:_update_texture()
end)

core.register_craft {
	output = "epidermis:filling_bucket",
	recipe = {
		{ "epidermis:pen", "sbz_chem:empty_fluid_cell", "unifieddyes:colorium_blob" }
	}
}

-- Dragging tools (line & rectangle)

local dragging = {}

modlib.minetest.register_on_wielditem_change(function(player)
	local name = player:get_player_name()
	if dragging[name] then
		-- Clear preview
		dragging[name].entity:_update_texture()
		send_notification(player, "Dragging stopped (wielded item changed)", "warning")
		dragging[name] = nil
	end
end)

minetest.register_globalstep(function()
	for player in modlib.minetest.connected_players() do
		local name = player:get_player_name()
		local LMB = player:get_player_control().LMB
		if dragging[name] then
			local wielded_item = player:get_wielded_item()
			local def = wielded_item:get_definition()
			local range = def.range or 4
			local eye_pos = get_eye_pos(player)
			local raycast = minetest.raycast(eye_pos,
				vector.add(eye_pos, vector.multiply(player:get_look_dir(), range)),
				true, def.liquids_pointable)
			local pointed_thing = raycast()
			if pointed_thing.type == "object"
				and pointed_thing.ref:is_player()
				and pointed_thing.ref:get_player_name() == name
			then
				-- Skip player
				pointed_thing = raycast(pointed_thing)
			end
			local entity = pointed_thing and get_entity(player, pointed_thing)
			if not (entity and entity == dragging[name].entity) then
				send_notification(player, "Dragging stopped (pointed thing changed)", "warning")
				-- Clear preview
				dragging[name].entity:_update_texture()
				dragging[name] = nil
			else
				local intersection_info = get_paintable_intersection(player, entity)
				if intersection_info then
					if LMB then -- still dragging
						if dragging[name].preview then
							dragging[name].preview(intersection_info.pixelcoord)
						else
							local action_preview, color = dragging[name].pixels(intersection_info.pixelcoord)
							for k in pairs(action_preview) do
								action_preview[k] = color
							end
							entity:_update_texture(action_preview)
						end
					else -- dragging stopped, finish the action
						local actions, color = dragging[name].pixels(intersection_info.pixelcoord)
						for idx in pairs(actions) do
							entity:_set_color(idx, color)
						end
						entity:_log_actions("undo", actions)
						entity:_update_texture()
						dragging[name] = nil
					end
				end
			end
		end
	end
end)

register_color_tool("epidermis:rectangle", {
	description = "Rectangle",
	inventory_image = "epidermis_rectangle_background.png",
	inventory_overlay = "epidermis_rectangle_border.png",
}, function(entity, pixelcoord_start, color, user)
	local color_argb = color:to_number()
	dragging[user:get_player_name()] = {
		entity = entity,
		-- Texture modifier based preview as up to width * height pixels might be needed
		preview = function(pixelcoord_end)
			local min = modlib.vector.combine(pixelcoord_start, pixelcoord_end, math.min)
			local max = modlib.vector.combine(pixelcoord_start, pixelcoord_end, math.max)
			local dim = max - min
			local preview = "^[combine:" .. entity._.width .. "x" .. entity._.height
				.. ":" .. min[1] .. "," .. min[2] .. "=epxw.png\\^[multiply\\:" .. color:to_string()
				.. "\\^[resize\\:" .. (dim[1] + 1) .. "x" .. (dim[2] + 1)
			entity:_update_texture(preview)
		end,
		pixels = function(pixelcoord_end)
			local actions = {}
			local min = modlib.vector.combine(pixelcoord_start, pixelcoord_end, math.min)
			local max = modlib.vector.combine(pixelcoord_start, pixelcoord_end, math.max)
			for x = min[1], max[1] do
				for y = min[2], max[2] do
					local idx = entity:_get_pixel_index(x, y)
					actions[idx] = entity:_get_color(idx)
				end
			end
			return actions, color_argb
		end
	}
end)

core.register_craft {
	type = "shapeless",
	output = "epidermis:rectangle",
	recipe = {
		"epidermis:filling_bucket", "sbz_resources:matter_plate"
	}
}

register_color_tool("epidermis:line", {
	description = "Line",
	inventory_image = "epidermis_line_background.png",
	inventory_overlay = "epidermis_line_border.png",
}, function(entity, pixelcoord_start, color, user)
	local color_argb = color:to_number()
	dragging[user:get_player_name()] = {
		entity = entity,
		-- A pixel preview is sufficient here as the line may at most have max(width, height) pixels
		pixels = function(pixelcoord_end)
			-- This might be copied & swapped. We don't want this to affect the upvalue, so we localize it.
			local pixelcoord_start_copy = pixelcoord_start
			-- Uses Bresenham's line algorithm
			local diff = modlib.vector.subtract(pixelcoord_end, pixelcoord_start_copy)
			if diff:norm() == 0 then
				-- Early return: We would divide by zero when obtaining the slope otherwise
				local idx = entity:_get_pixel_index(unpack(pixelcoord_start_copy))
				return { [idx] = entity:_get_color(idx) }, color_argb
			end
			local swapped
			if math.abs(diff[2]) > math.abs(diff[1]) then
				swapped = true
				pixelcoord_start_copy = { pixelcoord_start_copy[2], pixelcoord_start_copy[1] }
				pixelcoord_end = { pixelcoord_end[2], pixelcoord_end[1] }
			end
			local actions = {}
			local min = pixelcoord_start_copy
			local max = pixelcoord_end
			if min[1] > max[1] then
				min, max = max, min
			end
			local slope = (max[2] - min[2]) / (max[1] - min[1])
			for x = min[1], max[1] do
				local y = math.floor(0.5 + slope * (x - min[1])) + min[2]
				if swapped then
					x, y = y, x
				end
				local idx = entity:_get_pixel_index(x, y)
				actions[idx] = entity:_get_color(idx)
			end
			return actions, color_argb
		end
	}
end)

core.register_craft {
	output = "epidermis:line",
	type = "shapeless",
	recipe = { "epidermis:pen" }
}
core.register_craft {
	output = "epidermis:pen",
	type = "shapeless",
	recipe = { "epidermis:line" }
}
