local function char_to_hex(c)
	return string.format("%%%02X", string.byte(c))
end

function futil.urlencode(text)
	text = text:gsub("\n", "\r\n")
	text = text:gsub("([^0-9a-zA-Z !'()*._~-])", char_to_hex)
	text = text:gsub(" ", "+")
	return text
end
