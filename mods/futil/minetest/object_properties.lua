local f = string.format

local iall = futil.functional.iall
local map = futil.map

local in_bounds = futil.math.in_bounds

local is_integer = futil.math.is_integer
local is_number = futil.is_number
local is_string = futil.is_string
local is_table = futil.is_table

local function valid_box(value)
	if value == nil then
		return true
	elseif not is_table(value) then
		return false
	elseif #value ~= 6 then
		return false
	else
		return iall(map(is_number, value))
	end
end

local function valid_visual_size(value)
	if not is_table(value) then
		return false
	end

	local z_type = type(value.z)
	return is_number(value.x) and is_integer(value.y) and (z_type == "number" or z_type == nil)
end

local function valid_textures(value)
	if not is_table(value) then
		return false
	end

	return iall(map(is_string, value))
end

local function valid_color_spec(value)
	local t = type(value)
	if t == "string" then
		-- TODO: we could check for valid values, but that's ... tedious
		return true
	elseif t == "table" then
		local is_number_ = is_number
		local is_integer_ = is_integer
		local in_bounds_ = in_bounds
		local x = value.x
		local y = value.y
		local z = value.z
		local a = value.a

		return (
			is_number_(x)
			and in_bounds_(0, x, 255)
			and is_integer_(x)
			and is_number_(y)
			and in_bounds_(0, y, 255)
			and is_integer_(y)
			and is_number_(z)
			and in_bounds_(0, z, 255)
			and is_integer_(z)
			and (a == nil or (is_number_(a) and in_bounds_(0, a, 255) and is_integer_(a)))
		)
	end

	return false
end

local function valid_colors(value)
	if not is_table(value) then
		return false
	end

	return iall(map(valid_color_spec, value))
end

local function valid_spritediv(value)
	if not is_table(value) then
		return false
	end

	local x = value.x
	local y = value.y

	return is_number(x) and is_integer(x) and is_number(y) and is_number(y)
end

local function valid_automatic_face_movement_dir(value)
	return value == false or is_number(value)
end

local function valid_hp_max(value)
	return is_number(value) and is_integer(value) and in_bounds(1, value, 65535)
end

local object_property = {
	visual = "string",
	visual_size = valid_visual_size,
	mesh = "string",
	textures = valid_textures,
	colors = valid_colors,
	use_texture_alpha = "boolean",
	spritediv = valid_spritediv,
	initial_sprite_basepos = valid_spritediv,
	is_visible = "boolean",
	automatic_rotate = "number",
	automatic_face_movement_dir = valid_automatic_face_movement_dir,
	automatic_face_movement_max_rotation_per_sec = "number",
	backface_culling = "number",
	glow = "number",
	damage_texture_modifier = "string",
	shaded = "boolean",

	hp_max = valid_hp_max,
	physical = "boolean",
	pointable = "boolean",
	collide_with_objects = "boolean",
	collisionbox = valid_box,
	selectionbox = valid_box,

	makes_footstep_sound = "boolean",

	stepheight = "number",

	nametag = "string",
	nametag_color = valid_color_spec,
	nametag_bgcolor = valid_color_spec,

	infotext = "string",

	static_save = "boolean",

	show_on_minimap = "boolean",
}

function futil.is_property_key(key)
	return object_property[key] ~= nil
end

function futil.is_valid_property_value(key, value)
	local kind = object_property[key]

	if not kind then
		return false
	end

	if type(kind) == "string" then
		return type(value) == kind
	elseif type(kind) == "function" then
		return kind(value)
	else
		error(f("coding error in futil for key %q", key))
	end
end
