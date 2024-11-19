return setmetatable({}, {__index = function(self, module_name)
	if module_name == "uri" or module_name == "html" then
		local module = assert(loadfile(modlib.mod.get_resource(modlib.modname, "web", module_name .. ".lua")))()
		self[module_name] = module
		return module
	end
end})