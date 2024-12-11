-- i have no idea how accurate this is, i use documentation from the below link for a few things
-- https://wowwiki-archive.fandom.com/wiki/Lua_object_memory_sizes

local function estimate_memory_usage(thing, seen)
	local typ = type(thing)
	if typ == "nil" then
		return 0
	end

	seen = seen or {}
	if seen[thing] then
		return 0
	end
	seen[thing] = true

	if typ == "boolean" then
		return 4
	elseif typ == "number" then
		return 8 -- this is probably larger?
	elseif typ == "string" then
		return 25 + typ:len()
	elseif typ == "function" then
		-- TODO: we can calculate the usage of upvalues, but that's complicated
		return 40
	elseif typ == "userdata" then
		return 0 -- this is probably larger
	elseif typ == "thread" then
		return 1224 -- this is probably larger
	elseif typ == "table" then
		local size = 64
		for k, v in pairs(thing) do
			if type(k) == "number" then
				size = size + 16 + estimate_memory_usage(v, seen)
			else
				size = size + 40 + estimate_memory_usage(k, seen) + estimate_memory_usage(v, seen)
			end
		end
		return size
	else
		futil.log("warning", "estimate_memory_usage: unknown type %s", typ)
		return 0 -- ????
	end
end

futil.estimate_memory_usage = estimate_memory_usage
