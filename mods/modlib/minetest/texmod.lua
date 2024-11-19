-- Texture Modifier representation for building, parsing and stringifying texture modifiers according to
-- https://github.com/minetest/minetest_docs/blob/master/doc/texture_modifiers.adoc

local function component(component_name, ...)
	return assert(loadfile(modlib.mod.get_resource(modlib.modname, "minetest", "texmod", component_name .. ".lua")))(...)
end

local texmod, metatable = component"dsl"
local methods = metatable.__index
methods.write = component"write"
texmod.read = component("read", texmod)
methods.calc_dims = component"calc_dims"
methods.gen_tex = component"gen_tex"

function metatable:__tostring()
	local rope = {}
	self:write(function(str) rope[#rope+1] = str end)
	return table.concat(rope)
end

function texmod.read_string(str, warn --[[function(warn_str)]])
	local i = 0
	return texmod.read(function()
		i = i + 1
		if i > #str then return end
		return str:sub(i, i)
	end, warn)
end

return texmod
