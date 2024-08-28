
local fake_player = {is_fake_player = true}
local identifier = "fakelib:player"
local check, secure_table = ...

local player_controls = {
	up = 1, down = 2, left = 4, right = 8, jump = 16,
	aux1 = 32, sneak = 64, dig = 128, place = 256, zoom = 512,
}

-- API functions
----------------------------------------

function fakelib.is_player(x)
	if type(x) == "userdata" and x.is_player and x:is_player() then
		return true
	elseif type(x) == "table" and getmetatable(x) == identifier then
		return true
	end
	return false
end

function fakelib.create_player(options)
	local data = {}
	if type(options) == "table" then
		if type(options.name) == "string" then
			data.name = options.name
		end
		if fakelib.is_vector(options.position) then
			data.position = vector.copy(options.position)
		end
		if fakelib.is_vector(options.direction) then
			local dir = vector.normalize(options.direction)
			data.pitch = -math.asin(dir.y)
			data.yaw = math.atan2(-dir.x, dir.z) % (math.pi * 2)
		end
		if type(options.controls) == "table" then
			data.controls = {}
			for name in pairs(player_controls) do
				data.controls[name] = options.controls[name] == true
			end
			data.controls.dig = data.controls.dig or options.controls.LMB
			data.controls.place = data.controls.place or options.controls.RMB
		end
		if fakelib.is_metadata(options.metadata) then
			data.metadata = options.metadata
		end
		if fakelib.is_inventory(options.inventory) then
			data.inventory = options.inventory
		end
		local size = 32
		if data.inventory and type(options.wield_list) == "string" then
			size = data.inventory:get_size(options.wield_list)
			if size > 0 then
				data.wield_list = options.wield_list
			end
		end
		if type(options.wield_index) == "number" then
			if options.wield_index > 0 and options.wield_index <= size then
				data.wield_index = options.wield_index
			end
		end
	elseif type(options) == "string" then
		data.name = options
	end
	return secure_table({data = data}, fake_player, identifier)
end

-- Helper functions
----------------------------------------

local function check_vector(v)
	local t = type(v)
	if t ~= "table" then
		error(string.format("\"Invalid vector (expected table got %s).\"", t), 3)
	end
	for _,c in ipairs({"x", "y", "z"}) do
		t = type(v[c])
		if t ~= "number" then
			error(string.format("\"Invalid vector coordinate %s (expected number got %s).\"", c, t), 3)
		end
	end
end

-- Dynamic get/set functions
----------------------------------------

function fake_player:get_player_name()
	return self.data.name or ""
end

function fake_player:get_inventory()
	if not self.data.inventory then
		self.data.inventory = fakelib.create_inventory({
			main = 32, craft = 9, craftpreview = 1, craftresult = 1
		})
	end
	return self.data.inventory
end

function fake_player:get_meta()
	if not self.data.metadata then
		self.data.metadata = fakelib:create_metadata()
	end
	return self.data.metadata
end

function fake_player:get_look_dir()
	local p, y = self.data.pitch or 0, self.data.yaw or 0
	return vector.new(math.sin(-y) * math.cos(p), math.sin(-p), math.cos(y) * math.cos(p))
end

function fake_player:get_look_horizontal()
	return self.data.yaw or 0
end

function fake_player:set_look_horizontal(value)
	check(1, value, "number")
	self.data.yaw = value % (math.pi * 2)
end

function fake_player:get_look_vertical()
	return self.data.pitch or 0
end

function fake_player:set_look_vertical(value)
	check(1, value, "number")
	self.data.pitch = math.max(-math.pi / 2, math.min(value, math.pi / 2))
end

function fake_player:get_player_control()
	local controls = {}
	if self.data.controls then
		for name in pairs(player_controls) do
			controls[name] = self.data.controls[name]
		end
	else
		for name in pairs(player_controls) do
			controls[name] = false
		end
	end
	controls.LMB = controls.dig
	controls.RMB = controls.place
	return controls
end

function fake_player:get_player_control_bits()
	if not self.data.controls then
		return 0
	end
	local total = 0
	for name, value in pairs(player_controls) do
		total = total + self.data.controls[name] and value or 0
	end
	return total
end

function fake_player:get_pos()
	if self.data.position then
		return vector.copy(self.data.position)
	end
	return vector.zero()
end

function fake_player:set_pos(pos)
	check_vector(pos)
	self.data.position = vector.copy(pos)
end
fake_player.move_to = fake_player.set_pos

function fake_player:add_pos(pos)
	check_vector(pos)
	if self.data.position then
		self.data.position = vector.add(self.data.position, pos)
	else
		self.data.position = vector.copy(pos)
	end
end

function fake_player:get_wield_index()
	return self.data.wield_index or 1
end

function fake_player:get_wield_list()
	return self.data.wield_list or "main"
end

function fake_player:get_wielded_item()
	if self.data.inventory then
		return self.data.inventory:get_stack(self:get_wield_list(), self:get_wield_index())
	end
	return ItemStack()
end

function fake_player:set_wielded_item(stack)
	stack = ItemStack(stack)
	if not self.data.inventory and stack:is_empty() then
		return true
	end
	self:get_inventory():set_stack(self:get_wield_list(), self:get_wield_index(), stack)
	return true
end

-- Static get functions
----------------------------------------

function fake_player.is_player()
	return true
end

function fake_player.get_animation()
	return {x = 1, y = 1}, 15, 0, true
end

function fake_player.get_armor_groups()
	return {immortal = 1}
end

function fake_player.get_bone_override()
	return {
		position = {absolute = false, vec = vector.zero(), interpolation = 0},
		rotation = {absolute = false, vec = vector.zero(), interpolation = 0},
		scale = {absolute = false, vec = vector.new(1, 1, 1), interpolation = 0},
	}
end

function fake_player.get_bone_overrides()
	return {}
end

function fake_player.get_bone_position()
	return vector.zero(), vector.zero()
end

function fake_player.get_breath()
	return 10
end

function fake_player.get_children()
	return {}
end

function fake_player.get_clouds()
	return {
		ambient = {r = 0, g = 0, b = 0, a = 255},
		color = {r = 240, g = 240, b = 255, a = 229},
		density = 0.4,
		height = 120,
		speed = {x = 0, y = -2},
		thickness = 16,
	}
end

function fake_player.get_eye_offset()
	return vector.zero(), vector.zero(), vector.zero()
end

function fake_player.get_formspec_prepend()
	return ""
end

function fake_player.get_fov()
	return 0, false, 0
end

function fake_player.get_hp()
	return 20
end

function fake_player.get_inventory_formspec()
	return ""
end

function fake_player.get_lighting()
	return {
		exposure = {
			speed_bright_dark = 1000,
			center_weight_power = 1,
			luminance_min = -3,
			luminance_max = -3,
			exposure_correction = 0,
			speed_dark_bright = 1000
		},
		saturation = 1,
		shadows = {intensity = 0},
		volumetric_light = {strength = 0},
	}
end

function fake_player.get_local_animation()
	return {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}, 0
end

function fake_player.get_moon()
	return {
		scale = 1,
		texture = "moon.png",
		tonemap = "moon_tonemap.png",
		visible = true,
	}
end

function fake_player.get_nametag_attributes()
	return {
		bgcolor = false,
		color = {r = 255, g = 255, b = 255, a = 255},
		text = "",
	}
end

function fake_player.get_physics_override()
	return {
		acceleration_air = 1, acceleration_default = 1, acceleration_fast = 1,
		gravity = 1, jump = 1, speed = 1,
		liquid_fluidity = 1, liquid_fluidity_smooth = 1, liquid_sink = 1,
		speed_climb = 1, speed_crouch = 1, speed_fast = 1, speed_walk = 1,
		new_move = true, sneak = true, sneak_glitch = false,
	}
end

function fake_player.get_properties()
	return {
		automatic_face_movement_dir = false,
		automatic_face_movement_max_rotation_per_sec = -1,
		automatic_rotate = 0,
		backface_culling = false,
		breath_max = 10,
		collide_with_objects = true,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		colors = {{r = 255, g = 255, b = 255, a = 255}},
		damage_texture_modifier = "^[brighten",
		eye_height = 0,
		glow = 0,
		hp_max = 20,
		infotext = "",
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = true,
		makes_footstep_sound = true,
		mesh = "",
		nametag = "",
		nametag_bgcolor = false,
		nametag_color = {r = 255, g = 255, b = 255, a = 255},
		physical = false,
		pointable = true,
		selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = false},
		shaded = true,
		show_on_minimap = true,
		spritediv = {x = 1, y = 1},
		static_save = true,
		stepheight = 0.6,
		textures = {"blank.png"},
		use_texture_alpha = false,
		visual = "cube",
		visual_size = vector.new(1, 1, 1),
		wield_item = "",
		zoom_fov = 15,
	}
end

function fake_player.get_sky_color()
	return fake_player.get_sky(true).sky_color
end

function fake_player.get_sky(as_table)
	if as_table then
		return {
			base_color = {r = 255, g = 255, b = 255, a = 255},
			clouds = true,
			fog = {fog_distance = -1, fog_start = -1},
			sky_color = {
				day_sky = {r = 97, g = 181, b = 245, a = 255},
				day_horizon = {r = 144, g = 211, b = 246, a = 255},
				dawn_sky = {r = 180, g = 186, b = 250, a = 255},
				dawn_horizon = {r = 186, g = 193, b = 240, a = 255},
				night_sky = {r = 0, g = 107, b = 255, a = 255},
				night_horizon = {r = 64, g = 144, b = 255, a = 255},
				indoors = {r = 100, g = 100, b = 100, a = 255},
				fog_sun_tint = {r = 244, g = 125, b = 29, a = 255},
				fog_moon_tint = {r = 128, g = 153, b = 204, a = 255},
				fog_tint_type = "default",
			},
			textures = {},
			type = "regular",
		}
	end
	return {r = 255, g = 255, b = 255, a = 255}, "regular", {}, true
end

function fake_player.get_stars()
	return {
		count = 1000,
		day_opacity = 0,
		scale = 1,
		star_color = {r = 235, g = 235, b = 255, a = 105},
		visible = true,
	}
end

function fake_player.get_sun()
	return {
		scale = 1,
		sunrise = "sunrisebg.png",
		sunrise_visible = true,
		texture = "sun.png",
		tonemap = "sun_tonemap.png",
		visible = true,
	}
end

function fake_player.get_velocity()
	return vector.zero()
end

function fake_player.hud_get_all()
	return {}
end

function fake_player.hud_get_flags()
	return {
		basic_debug = false,
		breathbar = false,
		chat = false,
		crosshair = false,
		healthbar = false,
		hotbar = false,
		minimap = false,
		minimap_radar = false,
		wielditem = false,
	}
end

function fake_player.hud_get_hotbar_image()
	return ""
end

function fake_player.hud_get_hotbar_itemcount()
	return 8
end

function fake_player.hud_get_hotbar_selected_image()
	return ""
end

function fake_player.is_valid()
	return true
end

-- No-op functions
----------------------------------------
do
	local functions = {
		-- Lua entity only (no-op for players)
		"get_acceleration", "get_entity_name", "get_luaentity", "get_rotation",
		"get_texture_mod", "get_yaw", "getacceleration", "getyaw", "remove",
		"set_acceleration", "set_rotation", "set_sprite", "set_texture_mod",
		"set_velocity", "set_yaw", "setacceleration", "setsprite",
		"settexturemod", "setvelocity", "setyaw",
		-- Non-functional get/set functions
		"add_velocity", "get_attach", "get_attribute", "get_day_night_ratio",
		"hud_add", "hud_change", "hud_get", "hud_remove", "hud_set_flags",
		"hud_set_hotbar_image", "hud_set_hotbar_itemcount",
		"hud_set_hotbar_selected_image", "override_day_night_ratio",
		"set_animation", "set_animation_frame_speed", "set_armor_groups",
		"set_attach", "set_attribute", "set_bone_override", "set_bone_position",
		"set_breath", "set_clouds", "set_detach", "set_eye_offset",
		"set_formspec_prepend", "set_fov", "set_hp", "set_inventory_formspec",
		"set_lighting", "set_local_animation", "set_minimap_modes", "set_moon",
		"set_nametag_attributes", "set_physics_override",
		"set_properties", "set_sky", "set_stars", "set_sun",
		-- Other functions that do nothing
		"punch", "respawn", "right_click", "send_mapblock",
	}
	for _,func in ipairs(functions) do
		fake_player[func] = function() end
	end
end

-- Deprecated functions
----------------------------------------

function fake_player:get_look_pitch()
	return self:get_look_vertical() * -1
end

function fake_player:get_look_yaw()
	return self:get_look_horizontal() + math.pi / 2
end

fake_player.set_look_pitch = fake_player.set_look_vertical
fake_player.set_look_yaw = fake_player.set_look_horizontal
fake_player.getpos = fake_player.get_pos
fake_player.setpos = fake_player.set_pos
fake_player.moveto = fake_player.set_pos
fake_player.getvelocity = fake_player.get_velocity
fake_player.add_player_velocity = fake_player.add_velocity
fake_player.get_player_velocity = fake_player.get_velocity
