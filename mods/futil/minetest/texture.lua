-- https://github.com/minetest/minetest/blob/9fc018ded10225589d2559d24a5db739e891fb31/doc/lua_api.txt#L453-L462
function futil.escape_texture(texturestring)
	-- store in a variable so we don't return both rvs of gsub
	local v = texturestring:gsub("[%^:]", {
		["^"] = "\\^",
		[":"] = "\\:",
	})
	return v
end
