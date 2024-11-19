-- URI escaping utilities
-- See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURI

local uri_unescaped_chars = {}
for char in ("-_.!~*'()"):gmatch(".") do
	uri_unescaped_chars[char] = true
end
local function add_unescaped_range(from, to)
	for byte = from:byte(), to:byte() do
		uri_unescaped_chars[string.char(byte)] = true
	end
end
add_unescaped_range("0", "9")
add_unescaped_range("a", "z")
add_unescaped_range("A", "Z")

local uri_allowed_chars = table.copy(uri_unescaped_chars)
for char in (";,/?:@&=+$#"):gmatch(".") do
	-- Reserved characters are allowed
	uri_allowed_chars[char] = true
end

local function encode(text, allowed_chars)
	return text:gsub(".", function(char)
		if allowed_chars[char] then
			return char
		end
		return ("%%%02X"):format(char:byte())
	end)
end

local uri = {}

function uri.encode_component(text)
	return encode(text, uri_unescaped_chars)
end

function uri.encode(text)
	return encode(text, uri_allowed_chars)
end

return uri