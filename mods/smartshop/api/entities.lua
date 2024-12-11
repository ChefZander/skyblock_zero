local api = smartshop.api

local table_insert = table.insert

local get_objects_in_area = minetest.get_objects_in_area

local escape_texture = futil.escape_texture
local get_wield_image = futil.get_wield_image

local v_add = vector.add
local v_sub = vector.subtract

-- i wanted to cache entities by position, but see
-- https://github.com/minetest/minetest/blob/8bf1609cccba24e2516ecb98dbf694b91fe697bf/doc/lua_api.txt#L6824-L6829
function api.get_entities(pos)
	local objects = {}

	for _, obj in ipairs(get_objects_in_area(v_sub(pos, 0.5), v_add(pos, 0.5))) do
		local ent = obj:get_luaentity()
		if ent and ent.name:sub(1, 10) == "smartshop:" then
			local ent_pos = ent.pos
			if not ent_pos then
				obj:remove()
			elseif vector.equals(ent_pos, pos) then
				table_insert(objects, obj)
			end
		end
	end

	return objects
end

function api.iterate_entities(pos)
	local entities = get_objects_in_area(v_sub(pos, 0.5), v_add(pos, 0.5))
	local index = 0

	return function()
		while true do
			index = index + 1

			local obj = entities[index]

			if not obj then
				return
			end

			local ent = obj:get_luaentity()

			if ent and ent.name:sub(1, 10) == "smartshop:" then
				local ent_pos = ent.pos
				if not ent_pos then
					obj:remove()
				elseif vector.equals(ent_pos, pos) then
					return obj
				end
			end
		end
	end
end

function api.clear_entities(pos)
	for _, obj in ipairs(get_objects_in_area(v_sub(pos, 0.5), v_add(pos, 0.5))) do
		local ent = obj:get_luaentity()

		if ent then
			local ent_pos = ent.pos
			if ent.name:sub(1, 10) == "smartshop:" and ((not ent_pos) or vector.equals(ent_pos, pos)) then
				obj:remove()
			end
		end
	end
end

function api.get_quad_image(items)
	local images = {}

	for i = 1, 4 do
		local image = get_wield_image(items[i])
		table_insert(images, escape_texture(image .. "^[resize:128x128"))
	end

	return ("[combine:260x260:1,1=%s:1,132=%s:132,1=%s:132,132=%s"):format(unpack(images))
end

function api.is_complicated_drawtype(drawtype)
	return (drawtype == "fencelike" or drawtype == "raillike" or drawtype == "nodebox" or drawtype == "mesh")
end

function api.get_image_type(shop, index)
	if not shop:can_exchange(index) then
		return "none"
	end

	local item = shop:get_give_stack(index)
	local def = item:get_definition()

	if item:is_empty() or not item:is_known() then
		return "none"
	elseif (def.inventory_image or "") ~= "" or (def.wield_image or "") ~= "" then
		return "sprite"
	elseif api.is_complicated_drawtype(def.drawtype) then
		return "wielditem"
	else
		return "sprite"
	end
end

function api.get_expected_entities(shop)
	local get_image_type = api.get_image_type

	local seen = {}
	local empty_count = 0
	local sprite_count = 0
	local entity_types = {}
	local last_sprite_index

	for index = 1, 4 do
		if shop:can_exchange(index) then
			local item = shop:get_give_stack(index):get_name()
			local image_type = get_image_type(shop, index)
			table_insert(entity_types, image_type)

			if seen[item] or image_type == "none" then
				empty_count = empty_count + 1
			elseif image_type == "sprite" then
				sprite_count = sprite_count + 1
				last_sprite_index = index
			end

			seen[item] = true
		else
			empty_count = empty_count + 1
			table_insert(entity_types, "none")
		end
	end

	local expected_entities = {}

	if empty_count == 3 and sprite_count == 1 then
		table_insert(expected_entities, { "single_upright_sprite", last_sprite_index })
	elseif (sprite_count + empty_count) == 4 then
		table_insert(expected_entities, { "quad_upright_sprite" })
	else
		for index, image_type in pairs(entity_types) do
			if image_type == "sprite" then
				table_insert(expected_entities, { "single_sprite", index })
			elseif image_type == "wielditem" then
				table_insert(expected_entities, { "single_wielditem", index })
			end
		end
	end

	return expected_entities
end

local function check_update_objects(shop, expected_types)
	local pos = shop.pos
	local ents = api.get_entities(pos)

	if #ents ~= #expected_types then
		return false
	end

	if #ents == 0 then
		return true
	end

	local get_image = get_wield_image

	for i = 1, #ents do
		local obj = ents[i]
		local entity = obj:get_luaentity()
		if not entity then
			return false
		end
		local expected_type = expected_types[i]
		local type = expected_type[1]
		local index_arg = expected_type[2]
		if type == "single_upright_sprite" then
			if entity.name ~= "smartshop:single_upright_sprite" then
				return false
			end
			local expected_item = shop:get_give_stack(index_arg):get_name()
			if entity.item ~= expected_item then
				local texture = get_image(expected_item)
				obj:set_properties({ textures = { texture } })
				entity.item = expected_item
			end
		elseif type == "quad_upright_sprite" then
			if entity.name ~= "smartshop:quad_upright_sprite" then
				return false
			end

			local items = entity.items
			local expected_items = {}
			local all_expected = true

			for index = 1, 4 do
				local expected_item
				if shop:can_exchange(index) then
					expected_item = shop:get_give_stack(index):get_name()
				else
					expected_item = ""
				end
				all_expected = all_expected and items[i] == expected_item
				table_insert(expected_items, expected_item)
			end

			if not all_expected then
				local texture = api.get_quad_image(expected_items)
				obj:set_properties({ textures = { texture } })
				entity.items = expected_items
			end
		elseif type == "single_sprite" then
			if entity.name ~= "smartshop:single_sprite" then
				return false
			end
			if entity.index ~= index_arg then
				return false
			end
			local expected_item = shop:get_give_stack(index_arg):get_name()
			if entity.item ~= expected_item then
				local texture = get_image(expected_item)
				obj:set_properties({ textures = { texture } })
				entity.item = expected_item
			end
		elseif type == "single_wielditem" then
			if entity.name ~= "smartshop:single_wielditem" then
				return false
			end
			if entity.index ~= index_arg then
				return false
			end
			local expected_item = shop:get_give_stack(index_arg):get_name()
			if entity.item ~= expected_item then
				obj:set_properties({ wield_item = expected_item })
				entity.item = expected_item
			end
		end
	end

	return true
end

function api.update_entities(shop)
	local pos = shop.pos

	local expected_entities = api.get_expected_entities(shop)

	if check_update_objects(shop, expected_entities) then
		return
	end

	api.clear_entities(pos)

	if #expected_entities == 0 then
		return
	end

	local entities = smartshop.entities

	for i = 1, #expected_entities do
		local type, index = unpack(expected_entities[i])

		entities.add_entity(shop, type, index)
	end
end
