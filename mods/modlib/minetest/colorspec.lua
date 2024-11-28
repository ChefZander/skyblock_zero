-- Localize globals
local assert, error, math, minetest, setmetatable, tonumber, type = assert, error, math, minetest, setmetatable, tonumber, type
local floor = math.floor

-- Set environment
local _ENV = ...
setfenv(1, _ENV)

-- As in src/util/string.cpp
named_colors = {
	aliceblue = 0xf0f8ff,
	antiquewhite = 0xfaebd7,
	aqua = 0x00ffff,
	aquamarine = 0x7fffd4,
	azure = 0xf0ffff,
	beige = 0xf5f5dc,
	bisque = 0xffe4c4,
	black = 0x000000,
	blanchedalmond = 0xffebcd,
	blue = 0x0000ff,
	blueviolet = 0x8a2be2,
	brown = 0xa52a2a,
	burlywood = 0xdeb887,
	cadetblue = 0x5f9ea0,
	chartreuse = 0x7fff00,
	chocolate = 0xd2691e,
	coral = 0xff7f50,
	cornflowerblue = 0x6495ed,
	cornsilk = 0xfff8dc,
	crimson = 0xdc143c,
	cyan = 0x00ffff,
	darkblue = 0x00008b,
	darkcyan = 0x008b8b,
	darkgoldenrod = 0xb8860b,
	darkgray = 0xa9a9a9,
	darkgreen = 0x006400,
	darkgrey = 0xa9a9a9,
	darkkhaki = 0xbdb76b,
	darkmagenta = 0x8b008b,
	darkolivegreen = 0x556b2f,
	darkorange = 0xff8c00,
	darkorchid = 0x9932cc,
	darkred = 0x8b0000,
	darksalmon = 0xe9967a,
	darkseagreen = 0x8fbc8f,
	darkslateblue = 0x483d8b,
	darkslategray = 0x2f4f4f,
	darkslategrey = 0x2f4f4f,
	darkturquoise = 0x00ced1,
	darkviolet = 0x9400d3,
	deeppink = 0xff1493,
	deepskyblue = 0x00bfff,
	dimgray = 0x696969,
	dimgrey = 0x696969,
	dodgerblue = 0x1e90ff,
	firebrick = 0xb22222,
	floralwhite = 0xfffaf0,
	forestgreen = 0x228b22,
	fuchsia = 0xff00ff,
	gainsboro = 0xdcdcdc,
	ghostwhite = 0xf8f8ff,
	gold = 0xffd700,
	goldenrod = 0xdaa520,
	gray = 0x808080,
	green = 0x008000,
	greenyellow = 0xadff2f,
	grey = 0x808080,
	honeydew = 0xf0fff0,
	hotpink = 0xff69b4,
	indianred = 0xcd5c5c,
	indigo = 0x4b0082,
	ivory = 0xfffff0,
	khaki = 0xf0e68c,
	lavender = 0xe6e6fa,
	lavenderblush = 0xfff0f5,
	lawngreen = 0x7cfc00,
	lemonchiffon = 0xfffacd,
	lightblue = 0xadd8e6,
	lightcoral = 0xf08080,
	lightcyan = 0xe0ffff,
	lightgoldenrodyellow = 0xfafad2,
	lightgray = 0xd3d3d3,
	lightgreen = 0x90ee90,
	lightgrey = 0xd3d3d3,
	lightpink = 0xffb6c1,
	lightsalmon = 0xffa07a,
	lightseagreen = 0x20b2aa,
	lightskyblue = 0x87cefa,
	lightslategray = 0x778899,
	lightslategrey = 0x778899,
	lightsteelblue = 0xb0c4de,
	lightyellow = 0xffffe0,
	lime = 0x00ff00,
	limegreen = 0x32cd32,
	linen = 0xfaf0e6,
	magenta = 0xff00ff,
	maroon = 0x800000,
	mediumaquamarine = 0x66cdaa,
	mediumblue = 0x0000cd,
	mediumorchid = 0xba55d3,
	mediumpurple = 0x9370db,
	mediumseagreen = 0x3cb371,
	mediumslateblue = 0x7b68ee,
	mediumspringgreen = 0x00fa9a,
	mediumturquoise = 0x48d1cc,
	mediumvioletred = 0xc71585,
	midnightblue = 0x191970,
	mintcream = 0xf5fffa,
	mistyrose = 0xffe4e1,
	moccasin = 0xffe4b5,
	navajowhite = 0xffdead,
	navy = 0x000080,
	oldlace = 0xfdf5e6,
	olive = 0x808000,
	olivedrab = 0x6b8e23,
	orange = 0xffa500,
	orangered = 0xff4500,
	orchid = 0xda70d6,
	palegoldenrod = 0xeee8aa,
	palegreen = 0x98fb98,
	paleturquoise = 0xafeeee,
	palevioletred = 0xdb7093,
	papayawhip = 0xffefd5,
	peachpuff = 0xffdab9,
	peru = 0xcd853f,
	pink = 0xffc0cb,
	plum = 0xdda0dd,
	powderblue = 0xb0e0e6,
	purple = 0x800080,
	rebeccapurple = 0x663399,
	red = 0xff0000,
	rosybrown = 0xbc8f8f,
	royalblue = 0x4169e1,
	saddlebrown = 0x8b4513,
	salmon = 0xfa8072,
	sandybrown = 0xf4a460,
	seagreen = 0x2e8b57,
	seashell = 0xfff5ee,
	sienna = 0xa0522d,
	silver = 0xc0c0c0,
	skyblue = 0x87ceeb,
	slateblue = 0x6a5acd,
	slategray = 0x708090,
	slategrey = 0x708090,
	snow = 0xfffafa,
	springgreen = 0x00ff7f,
	steelblue = 0x4682b4,
	tan = 0xd2b48c,
	teal = 0x008080,
	thistle = 0xd8bfd8,
	tomato = 0xff6347,
	turquoise = 0x40e0d0,
	violet = 0xee82ee,
	wheat = 0xf5deb3,
	white = 0xffffff,
	whitesmoke = 0xf5f5f5,
	yellow = 0xffff00,
	yellowgreen = 0x9acd32
}

colorspec = {}

local metatable = {__index = colorspec}
colorspec.metatable = metatable

function colorspec.new(table)
	return setmetatable({
		r = assert(table.r),
		g = assert(table.g),
		b = assert(table.b),
		a = table.a or 255
	}, metatable)
end

colorspec.from_table = colorspec.new

local c_comp = { "r", "g", "g", "b", "b", "r" }
local x_comp = { "g", "r", "b", "g", "r", "b" }
function colorspec.from_hsv(
	-- 0 (inclusive) to 1 (exclusive)
	hue,
	-- 0 to 1 (both inclusive)
	saturation,
	-- 0 to 1 (both inclusive)
	value
)
	hue = hue * 6
	local chroma = saturation * value
	local m = value - chroma
	local color = {r = m, g = m, b = m}
	local idx = 1 + floor(hue)
	color[c_comp[idx]] = color[c_comp[idx]] + chroma
	local x = chroma * (1 - math.abs(hue % 2 - 1))
	color[x_comp[idx]] = color[x_comp[idx]] + x
	color.r = floor(color.r * 255 + 0.5)
	color.g = floor(color.g * 255 + 0.5)
	color.b = floor(color.b * 255 + 0.5)
	return colorspec.from_table(color)
end

function colorspec.from_string(string)
	string = string:lower() -- names and hex are case-insensitive
	local number, alpha = named_colors[string], 0xFF
	if not number then
		local name, alpha_text = string:match("^([a-z]+)#(%x+)$")
		if name then
			if alpha_text:len() > 2 then
				return
			end
			number = named_colors[name]
			if not number then
				return
			end
			alpha = tonumber(alpha_text, 0x10)
			if alpha_text:len() == 1 then
				alpha = alpha * 0x11
			end
		end
	end
	if number then
		return colorspec.from_number_rgba(number * 0x100 + alpha)
	end
	local hex_text = string:match("^#(%x+)$")
	if not hex_text then
		return
	end
	local len, num = hex_text:len(), tonumber(hex_text, 0x10)
	if len == 8 then
		return colorspec.from_number_rgba(num)
	end
	if len == 6 then
		return colorspec.from_number_rgba(num * 0x100 + 0xFF)
	end
	if len == 4 then
		return colorspec.from_table{
			a = (num % 0x10) * 0x11,
			b = (floor(num / 0x10) % 0x10) * 0x11,
			g = (floor(num / (0x100)) % 0x10) * 0x11,
			r = (floor(num / (0x1000)) % 0x10) * 0x11
		}
	end
	if len == 3 then
		return colorspec.from_table{
			b = (num % 0x10) * 0x11,
			g = (floor(num / 0x10) % 0x10) * 0x11,
			r = (floor(num / (0x100)) % 0x10) * 0x11
		}
	end
end

colorspec.from_text = colorspec.from_string

function colorspec.from_number_rgba(number)
	return colorspec.from_table{
		a = number % 0x100,
		b = floor(number / 0x100) % 0x100,
		g = floor(number / 0x10000) % 0x100,
		r = floor(number / 0x1000000)
	}
end

function colorspec.from_number_rgb(number)
	return colorspec.from_table{
		a = 0xFF,
		b = number % 0x100,
		g = floor(number / 0x100) % 0x100,
		r = floor(number / 0x10000)
	}
end

function colorspec.from_number(number)
	return colorspec.from_table{
		b = number % 0x100,
		g = floor(number / 0x100) % 0x100,
		r = floor(number / 0x10000) % 0x100,
		a = floor(number / 0x1000000)
	}
end

function colorspec.from_any(value)
	local type = type(value)
	if type == "table" then
		return colorspec.from_table(value)
	end
	if type == "string" then
		return colorspec.from_string(value)
	end
	if type == "number" then
		return colorspec.from_number(value)
	end
	error("Unsupported type " .. type)
end

function colorspec:to_table()
	return self
end

--> hex string, omits alpha if possible (if opaque)
function colorspec:to_string()
	if self.a == 255 then
		return ("#%02X%02X%02X"):format(self.r, self.g, self.b)
	end
	return ("#%02X%02X%02X%02X"):format(self.r, self.g, self.b, self.a)
end
metatable.__tostring = colorspec.to_string

function colorspec:to_number_rgba()
	return self.r * 0x1000000 + self.g * 0x10000 + self.b * 0x100 + self.a
end

function colorspec:to_number_rgb()
	return self.r * 0x10000 + self.g * 0x100 + self.b
end

function colorspec:to_number()
	return self.a * 0x1000000 + self.r * 0x10000 + self.g * 0x100 + self.b
end

colorspec_to_colorstring = minetest.colorspec_to_colorstring or function(spec)
	local color = colorspec.from_any(spec)
	if not color then
		return nil
	end
	return color:to_string()
end
