-- stairs/init.lua

-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.


-- Global namespace for functions

stairs = {}


local function rotate_and_place(itemstack, placer, pointed_thing)
	local p0 = pointed_thing.under
	local p1 = pointed_thing.above
	local param2 = 0

	if placer then
		local placer_pos = placer:get_pos()
		if placer_pos then
			local diff = vector.subtract(p1, placer_pos)
			param2 = minetest.dir_to_facedir(diff)
			-- The player places a node on the side face of the node he is standing on
			if p0.y == p1.y and math.abs(diff.x) <= 0.5 and math.abs(diff.z) <= 0.5 and diff.y < 0 then
				-- reverse node direction
				param2 = (param2 + 2) % 4
			end
		end

		local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
		local fpos = finepos.y % 1

		if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
			or (fpos < -0.5 and fpos > -0.999999999) then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end

-- Set backface culling and world-aligned textures
local function set_textures(images, worldalign)
	local stair_images = {}
	for i, image in ipairs(images) do
		stair_images[i] = type(image) == "string" and { name = image } or table.copy(image)
		if stair_images[i].backface_culling == nil then
			stair_images[i].backface_culling = true
		end
		if worldalign and stair_images[i].align_style == nil then
			stair_images[i].align_style = "world"
		end
	end
	return stair_images
end

local function internal2human(v)
	if v == "slab" then return "Slab" end
	if v == "stair" then return "Stair" end
	if v == "stair_inner" then return "Stair (inner)" end
	if v == "stair_outer" then return "Stair (outer)" end
	return "!Unknown! (FIX THIS IMMIADEDLY)"
end


function stairs.register(name, reg_def)
	local def = assert(minetest.registered_nodes[name])
	reg_def = reg_def or {}
	if reg_def == "leveled" then reg_def = { leveled = true } end
	local tex = reg_def.tex

	local has_color = def.paramtype2 == "color"
	for k, v in ipairs { "slab", "stair", "stair_inner", "stair_outer" } do
		local nb = {
			type = "fixed"
		}
		if v == "slab" then
			nb.fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
			}
		elseif v == "stair" then
			nb.fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.0, 0.5 },
				{ -0.5, 0.0,  0.0,  0.5, 0.5, 0.5 },
			}
		elseif v == "stair_inner" then
			nb.fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.0, 0.5 },
				{ -0.5, 0.0,  0.0,  0.5, 0.5, 0.5 },
				{ -0.5, 0.0,  -0.5, 0.0, 0.5, 0.0 }
			}
		elseif v == "stair_outer" then
			nb.fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.0, 0.5 },
				{ -0.5, 0.0,  0.0,  0.0, 0.5, 0.5 },
			}
		end

		local def_copy = table.copy(def)
		def_copy.groups[v] = 1
		def_copy.groups.not_in_creative_inventory = 1
		def_copy.groups.habitat_conducts = 1
		for k, v in pairs(unifieddyes.def {
			description = def_copy.description .. " " .. internal2human(v),
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = has_color and "colorfacedir" or "facedir",
			sunlight_propagates = true,
			use_texture_alpha = "clip",
			is_ground_content = false,
			on_place = function(itemstack, placer, pointed_thing)
				if pointed_thing.type ~= "node" then
					return itemstack
				end

				return rotate_and_place(itemstack, placer, pointed_thing)
			end,

			node_box = nb,
			tiles = set_textures(def_copy.tiles, reg_def.align)
		}) do
			def_copy[k] = v
		end

		if tex then
			if v == "slab" and tex.stair_front then
				def_copy.tiles[2] = def_copy.tiles[1]
				for i = 3, 6 do
					def_copy.tiles[i] = tex.stair_front
				end
			elseif v == "stair" and tex.stair_front and tex.stair_side then
				def_copy.tiles[1] = tex.stair_front -- top
				def_copy.tiles[2] = def.tiles[1] -- bottom
				-- sides
				def_copy.tiles[3] = tex.stair_side
				def_copy.tiles[4] = tex.stair_side .. "^[transformFX"

				def_copy.tiles[5] = def.tiles[1] --tex.stair_front
				def_copy.tiles[6] = tex.stair_front
			elseif v == "stair_outer" and tex.stair_cross and tex.stair_side then
				def_copy.tiles[1] = tex.stair_side
				def_copy.tiles[2] = def.tiles[1]
				def_copy.tiles[3] = tex.stair_cross
				def_copy.tiles[4] = tex.stair_side .. "^[transformFX"
				def_copy.tiles[5] = tex.stair_side
				def_copy.tiles[6] = tex.stair_cross
			elseif v == "stair_inner" and tex.stair_side then
				def_copy.tiles[1] = tex.stair_side .. "^[transformFXFY"
				def_copy.tiles[2] = def.tiles[1]
				def_copy.tiles[3] = tex.stair_side
				def_copy.tiles[4] = def.tiles[1]
				def_copy.tiles[5] = def.tiles[1]
				def_copy.tiles[6] = tex.stair_side .. "^[transformFX"
			end
			def_copy.tiles = set_textures(def_copy.tiles, reg_def.align)
		end
		minetest.register_node(name .. "_" .. v, def_copy)
	end

	if reg_def.leveled == true then
		local c = table.copy(def)
		for k, v in pairs {
			description = c.description .. " - Leveled",
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = "leveled",
			sunlight_propagates = true,
			use_texture_alpha = "clip",
			is_ground_content = false,
			node_box = {
				type = "leveled",
				fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }
			},
			tiles = set_textures(c.tiles, reg_def.align),
		} do
			c[k] = v
		end
		minetest.register_node(def.name .. "_leveled", c)
	end

	--[[
	minetest.register_craft {
		output = name .. "_slab 6",
		recipe = {
			{ name, name, name },
		}
	}

	minetest.register_craft {
		output = name,
		recipe = {
			{ name .. "_slab", name .. "_slab" }
		}
	}

	minetest.register_craft {
		output = name .. "_stair 8",
		recipe = {
			{ "",   "",   name },
			{ "",   name, name },
			{ name, name, name }
		}
	}
	minetest.register_craft {
		output = name .. "_stair 8",
		recipe = {
			{ name, "",   "" },
			{ name, name, "" },
			{ name, name, name }
		}
	}
	minetest.register_craft {
		output = name .. " 3",
		recipe = {
			{ name .. "_stair", name .. "_stair", },
			{ name .. "_stair", name .. "_stair", }
		}
	}

	minetest.register_craft {
		output = name .. "_stair_inner 7",
		recipe = {
			{ "",   name, "" },
			{ name, "",   name },
			{ name, name, name }
		}
	}

	minetest.register_craft {
		output = name .. "_stair_outer 6",
		recipe = {
			{ "",   name, "" },
			{ name, name, name }
		}
	}
	]]
	local to_override_info_extra = def.info_extra
	if type(def.info_extra) == "string" then
		to_override_info_extra = { def.info_extra }
	end
	if def.info_extra == nil then
		to_override_info_extra = {}
	end

	to_override_info_extra[#to_override_info_extra + 1] = "This node can be cut into stairs."

	local g = def.groups
	for k, v in pairs { cnc = 1, cnc_leveled = reg_def.leveled and 1 or 0 } do g[k] = v end
	minetest.override_item(name, {
		info_extra = to_override_info_extra,
		groups = g
	})
end

local action = function(action)
	return function(stack, placer, pointed)
		if pointed.type ~= "node" then return end
		local amount = (action == "place") and 1 or -1
		local control = placer:get_player_control()
		local r = 1
		if control.sneak then
			amount = amount * 5
		end
		if control.aux1 then
			amount = amount * 5
			r = 5
			if control.sneak then
				r = 30
			end
		end
		local bpos = pointed.under

		local function doit(pos, a)
			local n = minetest.get_node(pos)
			if n == nil then return end
			local ndef = minetest.registered_nodes[n.name]
			if ndef == nil then return end
			if ndef.paramtype2 ~= "leveled" then return end
			local level = minetest.get_node_level(pos)
			local max = minetest.get_node_max_level(pos)
			level = math.round(level + a)
			if level <= 0 then level = 0 end
			if level >= max then level = max end
			if control.zoom then level = 0 end
			minetest.set_node_level(pos, level)
		end

		if r == 1 then
			doit(bpos, amount)
		else
			local minpos = vector.subtract(bpos, r)
			local maxpos = vector.add(bpos, r)
			local y = bpos.y
			for x = minpos.x, maxpos.x do
				for z = minpos.z, maxpos.z do
					local p = vector.new(x, y, z)
					local dst = vector.distance(bpos, p)
					if dst < r then
						doit(p, amount - dst)
					end
				end
			end
		end
		return stack
	end
end
minetest.register_craftitem("stairs:leveled_tool", {
	description = "Leveled node tool",
	info_extra = {
		"Placing: Increase level by 1",
		"Breaking: Decrease level by 1",
		"Shift+<any action>: Multiply the increase/decrease by 5",
		"Aux+<any action>: Mountain making mode, and multiplies by 5, radius is changed by shift",
		"Zoom+<any action>: Resets the level",
	},
	groups = { ui_decor = 1, not_in_creative_inventory = 1, --[[ !!UNUSED!!]] },
	inventory_image = "leveled_tool.png",
	range = 10,
	liquids_pointable = true,
	on_place = action("place"), -- a fancy boy am i
	on_use = action("dig"),
	stack_max = 1
})
