local html = setmetatable({}, {__index = function(self, key)
	if key == "unescape" then
		local func = assert(loadfile(modlib.mod.get_resource("modlib", "web", "html", "entities.lua")))
		setfenv(func, {})
		local named_entities = assert(func())
		local function unescape(text)
			return text
				:gsub("&([A-Za-z]+);", named_entities) -- named
				:gsub("&#(%d+);", function(digits) return modlib.utf8.char(tonumber(digits)) end) -- decimal
				:gsub("&#x(%x+);", function(digits) return modlib.utf8.char(tonumber(digits, 16)) end) -- hex
		end
		self.unescape = unescape
		return unescape
	end
end})

function html.escape(text)
	return text:gsub(".", {
		["<"] = "&lt;",
		[">"] = "&gt;",
		["&"] = "&amp;",
		["'"] = "&apos;",
		['"'] = "&quot;",
	})
end

return html