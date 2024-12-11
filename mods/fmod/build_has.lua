return function(mod_conf)
	local optional_depends = mod_conf:get("optional_depends")
	if not optional_depends then
		return {}
	end
	local has = {}
	for _, mod in ipairs(optional_depends:split()) do
		mod = mod:trim()
		has[mod] = minetest.get_modpath(mod) and true or false
	end
	return has
end
