local v_add = vector.add
local v_mul = vector.multiply

local add_entity = minetest.add_entity
local get_node = minetest.get_node
local pos_to_string = minetest.pos_to_string
local serialize = minetest.serialize
local deserialize = minetest.deserialize

local ss_error = smartshop.util.error

local api = smartshop.api

local element_dir = smartshop.entities.element_dir
local entity_offset = smartshop.entities.entity_offset

local element_offset = {
	vector.new(0, 0, -0.1),
	vector.new(-0.1, 0, 0),
	vector.new(0, 0, 0.1),
	vector.new(0.1, 0, 0),
}

minetest.register_entity("smartshop:quad_upright_sprite", {
	initial_properties = {
		hp_max = 1,
		visual = "upright_sprite",
		visual_size = { x = 1.0, y = 1.0 },
		collisionbox = { 0, 0, 0, 0, 0, 0 },
		physical = false,
		textures = { "air" },
	},
	smartshop2 = true,

	get_staticdata = function(self)
		return serialize({
			self.pos,
			self.items,
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		local pos, items = unpack(deserialize(staticdata))
		local obj = self.object

		if not (pos and items and api.is_shop(pos)) then
			obj:remove()
			return
		end

		local param2 = get_node(pos).param2
		if 0 <= param2 and param2 < 4 then
			obj:set_yaw(math.pi * (2 - (param2 / 2)))
		else
			ss_error("shop @ %s has bad param2 value %s; cannot create entities", pos_to_string(pos), param2)
			obj:remove()
			return
		end

		self.pos = pos -- *MUST* set before calling api.get_entity

		for other_obj in api.iterate_entities(pos) do
			if obj ~= other_obj then
				obj:remove()
				return
			end
		end

		self.items = items

		obj:set_properties({ textures = { api.get_quad_image(items) } })
	end,

	on_blast = function()
		return false, false, {}
	end,
})

local function get_items(shop)
	local items = {}
	for index = 1, 4 do
		if shop:can_exchange(index) then
			table.insert(items, shop:get_give_stack(index):get_name())
		else
			table.insert(items, "")
		end
	end
	return items
end

local function get_entity_pos(shop_pos, param2)
	local dir = element_dir[param2 + 1]
	local base_pos = v_add(shop_pos, v_mul(dir, entity_offset))
	local offset = element_offset[param2 + 1]

	return v_add(base_pos, offset)
end

function smartshop.entities.add_quad_upright_sprite(shop)
	local shop_pos = shop.pos
	local param2 = get_node(shop_pos).param2
	if param2 >= 4 then
		ss_error("shop @ %s has bad param2 value %s; cannot create entities", pos_to_string(shop_pos), param2)
		return
	end

	local items = get_items(shop)

	local entity_pos = get_entity_pos(shop_pos, param2)
	local staticdata = serialize({ shop_pos, items })
	local obj = add_entity(entity_pos, "smartshop:quad_upright_sprite", staticdata)

	if not obj then
		smartshop.log("warning", "could not create quad_upright_sprite @ %s", pos_to_string(shop_pos))
		return
	end

	obj:set_yaw(math.pi * (2 - (param2 / 2)))

	return obj
end
