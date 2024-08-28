
local error_tests = ...
local success = true

-- Helper functions
------------------------------

local function round(x)
	if x >= 0 then
		return math.floor(x + 0.5)
	end
	return math.ceil(x - 0.5)
end

local function is_equal(a, b)
	local ta, tb = type(a), type(b)
	-- Compare table values recursively
	if ta == "table" and tb == "table" then
		if next(a) == nil and next(b) == nil then
			return true
		end
		local keys = {}
		for k in pairs(a) do
			keys[k] = true
		end
		for k in pairs(b) do
			keys[k] = true
		end
		for k in pairs(keys) do
			if not is_equal(a[k], b[k]) then
				return false
			end
		end
		return true
	end
	-- Get rid of floating point errors
	if ta == "number" and tb == "number" then
		a = round(a * 1000) / 1000
		b = round(b * 1000) / 1000
	end
	return a == b
end

local function test(real, fake, func, ...)
	local rvals_real = {pcall(real[func], real, ...)}
	local rvals_fake = {pcall(fake[func], fake, ...)}
	local i = 1
	while true do
		if rvals_real[i] == nil and rvals_fake[i] == nil then
			break
		end
		if not is_equal(rvals_real[i], rvals_fake[i]) then
			success = false
			print(string.format("[fakelib] Test failed with function '%s' and return value #%i", func, i-1))
			if #{...} > 0 then
				print("        > Function arguments: ", ...)
			end
			local a = type(rvals_real[i]) == "table" and dump(rvals_real[i]) or tostring(rvals_real[i])
			print(string.format("        > Real return value: %s", a))
			local b = type(rvals_fake[i]) == "table" and dump(rvals_fake[i]) or tostring(rvals_fake[i])
			print(string.format("        > Fake return value: %s", b))
		end
		i = i + 1
	end
end

local test_values = {"abc", "", 0, -1, {}, {true}, true, function() end, 0/0, nil}

local function iter_values()
	local i = 0
	return function ()
		i = i + 1
		if i <= 1 then return test_values[i] end
	end
end

-- Player tests
------------------------------

local real_player = minetest.get_player_by_name("singleplayer")
local fake_player = fakelib.create_player("singleplayer")

-- Type check
if not fakelib.is_player(real_player) then
	success = false
	print("[fakelib] Real player is not a player.")
end
if not fakelib.is_player(fake_player) then
	success = false
	print("[fakelib] Fake player is not a player.")
end
for value in iter_values() do
	if fakelib.is_player(value) then
		print(string.format("[fakelib] Value '%s' is a player.", tostring(value)))
	end
end

-- Function check
for func in pairs(getmetatable(real_player)) do
	if not fake_player[func] then
		success = false
		print(string.format("[fakelib] Missing function '%s'", func))
	end
end

-- Functional tests
test(real_player, fake_player, "get_player_name")
test(real_player, fake_player, "get_player_control")
test(real_player, fake_player, "get_player_control_bits")
test(real_player, fake_player, "set_pos", vector.zero())
test(real_player, fake_player, "add_pos", vector.new(1, 1, 1))
test(real_player, fake_player, "get_pos")
test(real_player, fake_player, "set_look_horizontal", 0.6)
test(real_player, fake_player, "set_look_vertical", 0.3)
test(real_player, fake_player, "get_look_dir")
test(real_player, fake_player, "get_look_horizontal")
test(real_player, fake_player, "get_look_pitch")
test(real_player, fake_player, "get_look_yaw")
test(real_player, fake_player, "set_wielded_item", ItemStack("air 99"))
test(real_player, fake_player, "get_wielded_item")

-- Error tests
if error_tests then
	for value in iter_values() do
		-- Only test dynamic functions, no-op functions don't check arguments
		test(real_player, fake_player, "set_pos", value)
		test(real_player, fake_player, "add_pos", value)
		test(real_player, fake_player, "set_look_horizontal", value)
		test(real_player, fake_player, "set_look_vertical", value)
		test(real_player, fake_player, "set_wielded_item", value)
	end
end

-- Inventory tests
------------------------------

local real_inv = real_player:get_inventory()
local fake_inv = fakelib.create_inventory()

-- Type check
if not fakelib.is_inventory(real_inv) then
	success = false
	print("[fakelib] Real inventory is not an inventory.")
end
if not fakelib.is_inventory(fake_inv) then
	success = false
	print("[fakelib] Fake inventory is not an inventory.")
end
for value in iter_values() do
	if fakelib.is_inventory(value) then
		print(string.format("[fakelib] Value '%s' is an inventory.", tostring(value)))
	end
end

-- Function check
for func in pairs(getmetatable(real_inv)) do
	if not fake_inv[func] then
		success = false
		print(string.format("[fakelib] Missing function '%s'", func))
	end
end

-- Save and clear
local old_inv = real_inv:get_lists()
real_inv:set_lists({})

local test_item = ItemStack({name = "air", meta = {test = "abc"}})
local test_list = {"", "air 50", test_item, "", "air 50", test_item}

-- Functional tests
test(real_inv, fake_inv, "set_list", "test", test_list)
test(real_inv, fake_inv, "is_empty", "test")
test(real_inv, fake_inv, "set_lists", {test = test_list})
test(real_inv, fake_inv, "set_size", "test", 10)
test(real_inv, fake_inv, "get_size", "test")
test(real_inv, fake_inv, "set_width", "test", 3)
test(real_inv, fake_inv, "get_width", "test")
test(real_inv, fake_inv, "set_stack", "test", 1.5, "air")
test(real_inv, fake_inv, "get_stack", "test", 1)
test(real_inv, fake_inv, "get_list", "test")
test(real_inv, fake_inv, "add_item", "test", "air")
test(real_inv, fake_inv, "room_for_item", "test", "air 99")
test(real_inv, fake_inv, "contains_item", "test", "air 99")
test(real_inv, fake_inv, "contains_item", "test", test_item, true)
test(real_inv, fake_inv, "remove_item", "test", "air 99")
test(real_inv, fake_inv, "get_lists")

-- Error tests
if error_tests then
	for value in iter_values() do
		test(real_inv, fake_inv, "set_list", value, {})
		test(real_inv, fake_inv, "set_list", "test", value)
		test(real_inv, fake_inv, "is_empty", value)
		test(real_inv, fake_inv, "set_lists", value)
		test(real_inv, fake_inv, "set_size", value, 1)
		test(real_inv, fake_inv, "set_size", "test", value)
		test(real_inv, fake_inv, "get_size", value)
		test(real_inv, fake_inv, "set_width", value, 1)
		test(real_inv, fake_inv, "set_width", "test", value)
		test(real_inv, fake_inv, "get_width", value)
		test(real_inv, fake_inv, "set_stack", value, 1, "test")
		test(real_inv, fake_inv, "set_stack", "test", value, "test")
		test(real_inv, fake_inv, "set_stack", "test", 1, value)
		test(real_inv, fake_inv, "get_stack", value, 1)
		test(real_inv, fake_inv, "get_stack", "test", value)
		test(real_inv, fake_inv, "get_list", value)
		test(real_inv, fake_inv, "add_item", value, "test")
		test(real_inv, fake_inv, "add_item", "test", value)
		test(real_inv, fake_inv, "room_for_item", value, "test")
		test(real_inv, fake_inv, "room_for_item", "test", value)
		test(real_inv, fake_inv, "contains_item", value, "test")
		test(real_inv, fake_inv, "contains_item", "test", value)
		test(real_inv, fake_inv, "contains_item", "test", "test", value)
		test(real_inv, fake_inv, "remove_item", value, "test")
		test(real_inv, fake_inv, "remove_item", "test", value)
	end
end

-- Reset
real_inv:set_lists(old_inv)


-- Metadata tests
------------------------------

local real_meta = real_player:get_meta()
local fake_meta = fakelib.create_metadata()

-- Type check
if not fakelib.is_metadata(real_meta) then
	success = false
	print("[fakelib] Real metadata is not metadata.")
end
if not fakelib.is_metadata(fake_meta) then
	success = false
	print("[fakelib] Fake metadata is not metadata.")
end
for value in iter_values() do
	if fakelib.is_metadata(value) then
		print(string.format("[fakelib] Value '%s' is metadata.", tostring(value)))
	end
end

-- Function check
for func in pairs(getmetatable(real_meta)) do
	if not fake_meta[func] then
		success = false
		print(string.format("[fakelib] Missing function '%s'", func))
	end
end

-- Save and clear
local old_meta = real_meta:to_table()
real_meta:from_table({})

local test_data = {fields = {test = "abc"}}

-- Functional tests
test(real_meta, fake_meta, "from_table", test_data)
test(real_meta, fake_meta, "contains", "test")
test(real_meta, fake_meta, "get", "test")
test(real_meta, fake_meta, "set_string", "test", "xyz")
test(real_meta, fake_meta, "get_string", "test")
test(real_meta, fake_meta, "set_int", "test", 123)
test(real_meta, fake_meta, "get_int", "test")
test(real_meta, fake_meta, "set_float", "test", 123.456789)
test(real_meta, fake_meta, "get_float", "test")
test(real_meta, fake_meta, "get_keys")
test(real_meta, fake_meta, "to_table")
test(real_meta, fake_meta, "equals", real_meta)

-- Error tests
if error_tests then
	for value in iter_values() do
		test(real_meta, fake_meta, "from_table", value)
		test(real_meta, fake_meta, "contains", value)
		test(real_meta, fake_meta, "get", value)
		test(real_meta, fake_meta, "set_string", value, "test")
		test(real_meta, fake_meta, "set_string", "test", value)
		test(real_meta, fake_meta, "get_string", value)
		test(real_meta, fake_meta, "set_int", value, 0)
		test(real_meta, fake_meta, "set_int", "test", value)
		test(real_meta, fake_meta, "get_int", value)
		test(real_meta, fake_meta, "set_float", value, 0)
		test(real_meta, fake_meta, "set_float", "test", value)
		test(real_meta, fake_meta, "get_float", value)
		test(real_meta, fake_meta, "equals", value)
	end
end

-- Reset
real_meta:from_table(old_meta)


-- Misc tests
------------------------------

local basic_vector = {x = 1, y = 1, z = 1}

-- Vector type check
if not fakelib.is_vector({x = 1, y = 1, z = 1}) then
	success = false
	print("[fakelib] Basic vector is not a vector.")
end
if not fakelib.is_vector(vector.new(1, 1, 1)) then
	success = false
	print("[fakelib] Vector is not a vector.")
end
for value in iter_values() do
	if fakelib.is_vector(value) then
		print(string.format("[fakelib] Value '%s' is a vector.", tostring(value)))
	end
end

-- Vector metatable
if fakelib.is_vector(basic_vector, true) then
	if not basic_vector.add then
		print("[fakelib] Failed to add vector metatable to basic vector.")
	end
end

------------------------------

return success
