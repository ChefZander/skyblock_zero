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

function stairs.register(name, tex, worldalign)
	local def = assert(minetest.registered_nodes[name])


	local has_color = def.paramtype2 == "colorfacedir"
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
		for k, v in pairs({
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
			tiles = set_textures(def_copy.tiles, worldalign)
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
			def_copy.tiles = set_textures(def_copy.tiles, worldalign)
		end
		minetest.register_node(name .. "_" .. v, def_copy)
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

	to_override_info_extra[#to_override_info_extra + 1] = "You can make stairs with it!"

	minetest.override_item(name, {
		info_extra = to_override_info_extra,
		groups = { cnc = 1 },
	})
end
