
fakelib = {}

local function check(n, v, a, b)
	local t = type(v)
	if t == a or t == b then
		return v
	end
	local info = debug.getinfo(2, "n")
	local f = info.name or "?"
	if info.namewhat ~= "method" then
		-- Offset argument number when called using '.' instead of ':'
		n = n + 1
	end
	error(string.format("bad argument #%i to '%s' (%s expected, got %s)", n, f, a, t), 3)
end

local function secure_table(t, index, id)
	setmetatable(t, {
		__index = index,
		__newindex = {},
		__metatable = id,
	})
	return t
end

local path = minetest.get_modpath("fakelib")

for _,file in pairs({"metadata", "inventory", "player"}) do
	loadfile(path.."/"..file..".lua")(check, secure_table)
end

dofile(path.."/misc.lua")

-- Tests are not included in releases, so check for them before registering the command.

local tests = loadfile(path.."/tests.lua")

if tests and minetest.is_singleplayer() then
	minetest.register_chatcommand("fakelib_test", {
		description = "Test fakelib's API.",
		params = "[<run error tests>]",
		func = function(_, param)
			local start_time = minetest.get_us_time()
			local success = tests(param == "true")
			local end_time = minetest.get_us_time()
			if success then
				return true, string.format("Testing completed in %i us", end_time - start_time)
			end
			return true, "Testing failed. See console for errors."
		end,
	})
end
