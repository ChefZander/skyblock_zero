local bar_size = 1 / 16
local bar_width = bar_size * 256 --[[px]]
assert(bar_width % 1 == 0)
local c_comp = { "r", "g", "g", "b", "b", "r" }
local x_comp = { "g", "r", "b", "g", "r", "b" }

local function get_gradient_texture(hue)
	hue = hue * 6
	local idx = 1 + math.floor(hue)
	local mul_color = { r = 0, g = 0, b = 0 }
	mul_color[c_comp[idx]] = 255
	mul_color[x_comp[idx]] = math.floor(255 * (1 - math.abs(hue % 2 - 1)) + 0.5)
	return ("epidermis_gradient_field_chroma.png^[multiply:%s^epidermis_gradient_field_m.png"):format(
		modlib.minetest.colorspec.new(mul_color):to_string()
	)
end

local function get_texture(hue)
	return ("[combine:%dx256:0,0="):format(256 + bar_width)
		.. get_gradient_texture(hue):gsub("[\\^:]", function(char)
			return "\\" .. char
		end) -- escape
		.. ([[:256,0=epidermis_gradient_hue.png\^[transformR270\^[resize\:%dx256]]):format(bar_width)
end

local function get_uv(self, user)
	if not (user and user:is_player()) then
		return
	end
	local direction = modlib.vector.from_minetest(user:get_look_dir())
	local rotation = self.object:get_rotation()
	local rotation_axis, rotation_angle = epidermis.vector_axis_angle(rotation)
	local normal = modlib.vector.new({ 0, 0, -1 }):rotate3(rotation_axis, rotation_angle)
	if vector.dot(direction, normal) < 0 then
		return -- Backface
	end
	local pos = self.object:get_pos()
	local visual_size = modlib.vector.from_minetest(self.object:get_properties().visual_size)
	local parent, _, position, _ = self.object:get_attach()
	if parent then
		pos = modlib.vector.from_minetest(vector.add(parent:get_pos(), vector.divide(position, 10)))
		visual_size = visual_size * modlib.vector.from_minetest(parent:get_properties().visual_size)
	end
	local relative = modlib.vector.from_minetest(vector.subtract(moblib.get_eye_pos(user), pos))
	local function transform(vertex)
		return modlib.vector.rotate3(modlib.vector.multiply(vertex, visual_size), rotation_axis, rotation_angle)
	end
	local pos_on_ray, u, v = modlib.vector.ray_parallelogram_intersection(relative, direction, {
		transform { -0.5, -0.5, 0.5 },
		transform { 0.5, -0.5, 0.5 },
		transform { -0.5, 0.5, 0.5 },
	})
	if pos_on_ray then
		return u, v
	end
end

local function vector_combine(v, w, func)
	return vector.new(func(v.x, w.x), func(v.y, w.y), func(v.z, w.z))
end

local function rotate_boxes(self)
	local collisionbox = self.initial_properties.collisionbox
	local rotation = self.object:get_rotation()
	local min, max = vector.new(math.huge, math.huge, math.huge), vector.new(-math.huge, -math.huge, -math.huge)
	for index_x = 1, 1 + 3, 3 do
		for index_y = 2, 2 + 3, 3 do
			for index_z = 3, 3 + 3, 3 do
				local pos = vector.rotate(
					vector.new(collisionbox[index_x], collisionbox[index_y], collisionbox[index_z]),
					rotation
				)
				min = vector_combine(min, pos, math.min)
				max = vector_combine(max, pos, math.max)
			end
		end
	end
	local box = { min.x, min.y, min.z, max.x, max.y, max.z }
	self.object:set_properties {
		collisionbox = box,
		selectionbox = box,
	}
end

local colorpicker = {}

local thickness = 0.01
colorpicker._thickness = thickness
local height = 1 / (1 + bar_size)
local box = { -0.5, -height / 2, -thickness / 2, 0.5, height / 2, thickness / 2 }
colorpicker.initial_properties = {
	visual = "cube",
	visual_size = vector.new(1, height, thickness),
	selectionbox = box,
	collisionbox = box,
	static_save = true,
	physical = true,
	infotext = "HSV colorpicker",
}

colorpicker.lua_properties = {
	staticdata = "lua",
}

function colorpicker:_set_hue(hue)
	self._.hue = hue
	self.object:set_properties {
		textures = {
			"epxb.png",
			"epxb.png",
			"epxb.png",
			"epxb.png",
			get_texture(hue),
			"epxb.png",
		},
	}
end

function colorpicker:_set_rotation(rotation)
	self.object:set_rotation(rotation)
	rotate_boxes(self)
	self._.rotation = rotation
end

function colorpicker:on_activate()
	self:_set_hue(self._.hue or math.random())
	self:_set_rotation(self._.rotation or vector.new(0, 0, 0))
	local object = self.object
	--object:set_acceleration(vector.new(0, -0.981, 0))
	object:set_armor_groups { immortal = 1, punch_operable = 1 }
end

function colorpicker:_get_color(user)
	local u, v = get_uv(self, user)
	if not u then
		return
	end
	local hue = self._.hue
	local saturation, value = 1 - v, (1 - u) * (1 + bar_size)
	if value > 1 then -- hue bar
		hue = saturation
		saturation, value = 1, 1
	end
	return modlib.minetest.colorspec.from_hsv(hue, saturation, value)
end

function colorpicker:on_punch(puncher)
	local u, v = get_uv(self, puncher)
	if u then
		local hue, value = 1 - v, (1 - u) * (1 + bar_size)
		if value > 1 then -- hue bar
			self:_set_hue(hue)
			return
		end
	end
	local inventory = puncher:get_inventory()
	if not inventory:room_for_item("main", "epidermis:spawner_colorpicker") then
		return
	end
	self.object:remove()
	inventory:add_item("main", "epidermis:spawner_colorpicker")
end

moblib.register_entity("epidermis:colorpicker", colorpicker)
