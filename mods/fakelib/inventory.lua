
local fake_inventory = {}
local identifier = "fakelib:inventory"
local check, secure_table = ...

-- API functions
----------------------------------------

function fakelib.is_inventory(x)
	if type(x) == "userdata" and x.get_lists then
		return true
	elseif type(x) == "table" and getmetatable(x) == identifier then
		return true
	end
	return false
end

function fakelib.create_inventory(sizes)
	local lists = {}
	if type(sizes) == "table" then
		for listname, size in pairs(sizes) do
			if type(listname) == "string" and type(size) == "number" and size > 0 then
				local list = {}
				for i=1, size do
					list[i] = ItemStack()
				end
				lists[listname] = list
			end
		end
	end
	return secure_table({lists = lists}, fake_inventory, identifier)
end

-- Helper functions
----------------------------------------

local function copy_list(list)
	local copy = {}
	for i=1, #list do
		copy[i] = ItemStack(list[i])
	end
	return copy
end

local function stack_matches(a, b, match_meta)
	if a:get_name() ~= b:get_name() then
		return false
	end
	if match_meta then
		if a:get_wear() ~= b:get_wear() then
			return false
		end
		return a:get_meta():equals(b:get_meta())
	end
	return true
end

-- Inventory functions
----------------------------------------

function fake_inventory:is_empty(listname)
	check(1, listname, "string", "number")
	local list = self.lists[tostring(listname)]
	if not list or #list == 0 then
		return true
	end
	for _,stack in ipairs(list) do
		if not stack:is_empty() then
			return false
		end
	end
	return true
end

function fake_inventory:get_size(listname)
	check(1, listname, "string", "number")
	local list = self.lists[tostring(listname)]
	return list and #list or 0
end

function fake_inventory:set_size(listname, size)
	check(1, listname, "string", "number")
	check(2, size, "number")
	listname = tostring(listname)
	if size ~= size or size < 0 then
		return false
	end
	size = math.floor(size)
	if size == 0 then
		self.lists[listname] = nil
		return true
	end
	local list = self.lists[listname] or {}
	if #list < size then
		for i=#list+1, size do
			list[i] = ItemStack()
		end
	elseif #list > size then
		for i=size+1, #list do
			list[i] = nil
		end
	end
	self.lists[listname] = list
	return true
end

function fake_inventory:get_width(listname)
	check(1, listname, "string", "number")
	local list = self.lists[tostring(listname)]
	return list and list.width or 0
end

function fake_inventory:set_width(listname, width)
	check(1, listname, "string", "number")
	check(2, width, "number")
	local list = self.lists[tostring(listname)]
	if not list or width ~= width or width < 0 then
		return false
	end
	width = math.floor(width)
	list.width = width > 0 and width or nil
	return true
end

function fake_inventory:get_stack(listname, i)
	check(1, listname, "string", "number")
	check(2, i, "number")
	i = math.floor(i)
	local list = self.lists[tostring(listname)]
	if not list or not list[i] then
		return ItemStack()
	end
	return ItemStack(list[i])
end

function fake_inventory:set_stack(listname, i, stack)
	check(1, listname, "string", "number")
	check(2, i, "number")
	stack = ItemStack(stack)
	i = math.floor(i)
	local list = self.lists[tostring(listname)]
	if not list or not list[i] or stack:is_empty() then
		return false
	end
	list[i] = stack
	return true
end

function fake_inventory:get_list(listname)
	check(1, listname, "string", "number")
	local list = self.lists[tostring(listname)]
	return list and copy_list(list) or nil
end

function fake_inventory:set_list(listname, list)
	check(1, listname, "string", "number")
	listname = tostring(listname)
	if list == nil then
		self.lists[listname] = nil
		return
	end
	check(2, list, "table")
	local new_list, size = {}, 0
	for i,s in pairs(list) do
		check(4, i, "number")
		if i > size then
			size = i
		end
		new_list[i] = ItemStack(s)
	end
	for i=1, size do
		if not new_list[i] then
			new_list[i] = ItemStack()
		end
	end
	self.lists[listname] = new_list
end

function fake_inventory:get_lists()
	local lists = {}
	for listname, list in pairs(self.lists) do
		lists[listname] = copy_list(list)
	end
	return lists
end

function fake_inventory:set_lists(lists)
	check(1, lists, "table")
	local new_lists = {}
	for listname, list in pairs(lists) do
		check(3, listname, "string", "number")
		check(3, list, "table")
		listname = tostring(listname)
		local new_list, size = {}, 0
		for i,s in pairs(list) do
			check(5, i, "number")
			if i > size then
				size = i
			end
			new_list[i] = ItemStack(s)
		end
		for i=1, size do
			if not new_list[i] then
				new_list[i] = ItemStack()
			end
		end
		new_lists[listname] = new_list
	end
	self.lists = new_lists
end

function fake_inventory:add_item(listname, stack)
	check(1, listname, "string", "number")
	stack = ItemStack(stack)
	local list = self.lists[tostring(listname)]
	if not list or #list == 0 or stack:is_empty() then
		return stack
	end
	local empty = {}
	for _,s in ipairs(list) do
		if s:is_empty() then
			table.insert(empty, s)
		else
			stack = s:add_item(stack)
			if stack:is_empty() then
				return stack
			end
		end
	end
	for _,s in ipairs(empty) do
		stack = s:add_item(stack)
		if stack:is_empty() then
			return stack
		end
	end
	return stack
end

function fake_inventory:room_for_item(listname, stack)
	check(1, listname, "string", "number")
	stack = ItemStack(stack)
	local list = self.lists[tostring(listname)]
	if not list or #list == 0 or stack:is_empty() then
		return false
	end
	for _,s in ipairs(copy_list(list)) do
		stack = s:add_item(stack)
		if stack:is_empty() then
			return true
		end
	end
	return false
end

function fake_inventory:contains_item(listname, stack, match_meta)
	check(1, listname, "string", "number")
	stack = ItemStack(stack)
	local list = self.lists[tostring(listname)]
	if not list or stack:is_empty() or stack:is_empty() then
		return false
	end
	local count = stack:get_count()
	for _,s in ipairs(list) do
		if stack_matches(stack, s, match_meta) then
			count = count - s:get_count()
			if count <= 0 then
				return true
			end
		end
	end
	return false
end

function fake_inventory:remove_item(listname, stack)
	check(1, listname, "string", "number")
	stack = ItemStack(stack)
	local list = self.lists[tostring(listname)]
	if not list or #list == 0 or stack:is_empty() then
		return ItemStack()
	end
	local name, remaining, removed = stack:get_name(), stack:get_count()
	for i=#list, 1, -1 do
		local s = list[i]
		if s:get_name() == name then
			s = s:take_item(remaining)
			remaining = remaining - s:get_count()
			if not removed then
				removed = s
			else
				removed:set_count(removed:get_count() + s:get_count())
			end
			if remaining == 0 then
				break
			end
		end
	end
	return removed or ItemStack()
end

function fake_inventory.get_location()
	return {type = "undefined"}
end
