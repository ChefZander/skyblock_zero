-- Localize globals
local assert, ipairs, math, next, pairs, rawget, rawset, getmetatable, setmetatable, select, string, table, type
	= assert, ipairs, math, next, pairs, rawget, rawset, getmetatable, setmetatable, select, string, table, type

local lt = modlib.func.lt

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

-- Empty table
empty = {}

-- Table helpers

function from_iterator(...)
	local table = {}
	for key, value in ... do
		table[key] = value
	end
	return table
end

function default(table, value)
	return setmetatable(table, {
		__index = function()
			return value
		end,
	})
end

function map_index(table, func)
	local mapping_metatable = {
		__index = function(table, key)
			return rawget(table, func(key))
		end,
		__newindex = function(table, key, value)
			rawset(table, func(key), value)
		end
	}
	return setmetatable(table, mapping_metatable)
end

function set_case_insensitive_index(table)
	return map_index(table, string.lower)
end

--+ nilget(a, "b", "c") == a?.b?.c
function nilget(value, ...)
	local n = select("#", ...)
	for i = 1, n do
		if value == nil then return nil end
		value = value[select(i, ...)]
	end
	return value
end

deepget = nilget

--+ `deepset(a, "b", "c", d)` is the same as `a.b = a.b ?? {}; a.b.c = d`
function deepset(table, ...)
	local n = select("#", ...)
	for i = 1, n - 2 do
		local key = select(i, ...)
		local parent = table
		table = parent[key]
		if table == nil then
			table = {}
			parent[key] = table
		end
	end
	table[select(n - 1, ...)] = select(n, ...)
end

-- Fisher-Yates
function shuffle(table)
	for index = 1, #table - 1 do
		local index_2 = math.random(index, #table)
		table[index], table[index_2] = table[index_2], table[index]
	end
	return table
end

local rope_metatable = {__index = {
	write = function(self, text)
		table.insert(self, text)
	end,
	to_text = function(self)
		return table.concat(self)
	end
}}
--> rope with simple metatable (:write(text) and :to_text())
function rope(table)
	return setmetatable(table or {}, rope_metatable)
end

local rope_len_metatable = {__index = {
	write = function(self, text)
		self.len = self.len + text:len()
	end
}}
--> rope for determining length of text supporting `:write(text)` and `.len` to get the length of written text
function rope_len(len)
	return setmetatable({len = len or 0}, rope_len_metatable)
end

function is_circular(table)
	assert(type(table) == "table")
	local known = {}
	local function _is_circular(value)
		if type(value) ~= "table" then
			return false
		end
		if known[value] then
			return true
		end
		known[value] = true
		for key, value in pairs(value) do
			if _is_circular(key) or _is_circular(value) then
				return true
			end
		end
	end
	return _is_circular(table)
end

--+ Simple table equality check. Stack overflow if tables are too deep or circular.
--+ Use `is_circular(table)` to check whether a table is circular.
--> Equality of noncircular tables if `table` and `other_table` are tables
--> `table == other_table` else
function equals_noncircular(table, other_table)
	local is_equal = table == other_table
	if is_equal or type(table) ~= "table" or type(other_table) ~= "table" then
		return is_equal
	end
	if #table ~= #other_table then
		return false
	end
	local table_keys = {}
	for key, value in pairs(table) do
		local value_2 = other_table[key]
		if not equals_noncircular(value, value_2) then
			if type(key) == "table" then
				table_keys[key] = value
			else
				return false
			end
		end
	end
	for other_key, other_value in pairs(other_table) do
		if type(other_key) == "table" then
			local found
			for table, value in pairs(table_keys) do
				if equals_noncircular(other_key, table) and equals_noncircular(other_value, value) then
					table_keys[table] = nil
					found = true
					break
				end
			end
			if not found then
				return false
			end
		else
			if table[other_key] == nil then
				return false
			end
		end
	end
	return true
end

equals = equals_noncircular

--+ Table equality check properly handling circular tables - tables are equal as long as they provide equal key/value-pairs
--> Table content equality if `table` and `other_table` are tables
--> `table == other_table` else
function equals_content(table, other_table)
	local equal_tables = {}
	local function _equals(table, other_equal_table)
		local function set_equal_tables(value)
			equal_tables[table] = equal_tables[table] or {}
			equal_tables[table][other_equal_table] = value
			return value
		end
		local is_equal = table == other_equal_table
		if is_equal or type(table) ~= "table" or type(other_equal_table) ~= "table" then
			return is_equal
		end
		if #table ~= #other_equal_table then
			return set_equal_tables(false)
		end
		local lookup_equal = (equal_tables[table] or {})[other_equal_table]
		if lookup_equal ~= nil then
			return lookup_equal
		end
		-- Premise
		set_equal_tables(true)
		local table_keys = {}
		for key, value in pairs(table) do
			local other_value = other_equal_table[key]
			if not _equals(value, other_value) then
				if type(key) == "table" then
					table_keys[key] = value
				else
					return set_equal_tables(false)
				end
			end
		end
		for other_key, other_value in pairs(other_equal_table) do
			if type(other_key) == "table" then
				local found = false
				for table_key, value in pairs(table_keys) do
					if _equals(table_key, other_key) and _equals(value, other_value) then
						table_keys[table_key] = nil
						found = true
						-- Breaking is fine as per transitivity
						break
					end
				end
				if not found then
					return set_equal_tables(false)
				end
			else
				if table[other_key] == nil then
					return set_equal_tables(false)
				end
			end
		end
		return true
	end
	return _equals(table, other_table)
end

--+ Table equality check: content has to be equal, relations between tables as well
--+ The only difference may be in the memory addresses ("identities") of the (sub)tables
--+ Performance may suffer if the tables contain table keys
--+ equals(table, copy(table)) is true
--> equality (same tables after table reference substitution) of circular tables if `table` and `other_table` are tables
--> `table == other_table` else
function equals_references(table, other_table)
	local function _equals(table, other_table, equal_refs)
		if equal_refs[table] then
			return equal_refs[table] == other_table
		end
		local is_equal = table == other_table
		-- this check could be omitted if table key equality is being checked
		if type(table) ~= "table" or type(other_table) ~= "table" then
			return is_equal
		end
		if is_equal then
			equal_refs[table] = other_table
			return true
		end
		-- Premise: table = other table
		equal_refs[table] = other_table
		local table_keys = {}
		for key, value in pairs(table) do
			if type(key) == "table" then
				table_keys[key] = value
			else
				local other_value = other_table[key]
				if not _equals(value, other_value, equal_refs) then
					return false
				end
			end
		end
		local other_table_keys = {}
		for other_key, other_value in pairs(other_table) do
			if type(other_key) == "table" then
				other_table_keys[other_key] = other_value
			elseif table[other_key] == nil then
				return false
			end
		end
		local function _next(current_key, equal_refs, available_keys)
			local key, value = next(table_keys, current_key)
			if key == nil then
				return true
			end
			for other_key, other_value in pairs(other_table_keys) do
				local copy_equal_refs = shallowcopy(equal_refs)
				if _equals(key, other_key, copy_equal_refs) and _equals(value, other_value, copy_equal_refs) then
					local copy_available_keys = shallowcopy(available_keys)
					copy_available_keys[other_key] = nil
					if _next(key, copy_equal_refs, copy_available_keys) then
						return true
					end
				end
			end
			return false
		end
		return _next(nil, equal_refs, other_table_keys)
	end
	return _equals(table, other_table, {})
end

-- Supports circular tables; does not support table keys
--> `true` if a mapping of references exists, `false` otherwise
function same(a, b)
	local same = {}
	local function is_same(a, b)
		if type(a) ~= "table" or type(b) ~= "table" then
			return a == b
		end
		if same[a] or same[b] then
			return same[a] == b and same[b] == a
		end
		if a == b then
			return true
		end

		same[a], same[b] = b, a
		local count = 0
		for k, v in pairs(a) do
			count = count + 1
			assert(type(k) ~= "table", "table keys not supported")
			if not is_same(v, b[k], same) then
				return false
			end
		end
		for _ in pairs(b) do
			count = count - 1
			if count < 0 then
				return false
			end
		end
		return true
	end
	return is_same(a, b)
end

function shallowcopy(
	table -- table to copy
	, strip_metatables -- whether to strip metatables; falsy by default; metatables are not copied
)
	if type(table) ~= "table" then
		return table
	end

	local copy = {}
	if not strip_metatables then
		setmetatable(copy, getmetatable(table))
	end
	for key, value in pairs(table) do
		copy[key] = value
	end
	return copy
end

function deepcopy_tree(
	table -- table; may not contain circular references; cross references will be copied multiple times
	, strip_metatables -- whether to strip metatables; falsy by default; metatables are not copied
)
	if type(table) ~= "table" then
		return table
	end

	local copy = {}
	if not strip_metatables then
		setmetatable(copy, getmetatable(table))
	end
	for key, value in pairs(table) do
		copy[deepcopy_tree(key)] = deepcopy_tree(value)
	end
	return copy
end
deepcopy_noncircular = deepcopy_tree

function deepcopy(
	table -- table to copy; reference equality will be preserved
	, strip_metatables -- whether to strip metatables; falsy by default; metatables are not copied
)
	local copies = {}
	local function _deepcopy(table)
		local copy = copies[table]
		if copy then
			return copy
		end
		copy = {}
		if not strip_metatables then
			setmetatable(copy, getmetatable(table))
		end
		copies[table] = copy
		local function _copy(value)
			if type(value) ~= "table" then
				return value
			end

			if copies[value] then
				return copies[value]
			end

			return _deepcopy(value)
		end
		for key, value in pairs(table) do
			copy[_copy(key)] = _copy(value)
		end
		return copy
	end
	return _deepcopy(table)
end

copy = deepcopy

function count(table)
	local count = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end

function count_equals(table, count)
	local k
	for _ = 1, count do
		k = next(table, k)
		if k == nil then return false end -- less than n keys
	end
	return next(table, k) == nil -- no (n + 1)th entry
end

function is_empty(table)
	return next(table) == nil
end

function clear(table)
	for k in pairs(table) do
		table[k] = nil
	end
end

function foreach(table, func)
	for k, v in pairs(table) do
		func(k, v)
	end
end

function deep_foreach_any(table, func)
	local seen = {}
	local function visit(value)
		func(value)
		if type(value) == "table" then
			if seen[value] then return end
			seen[value] = true
			for k, v in pairs(value) do
				visit(k)
				visit(v)
			end
		end
	end
	visit(table)
end

-- Recursively counts occurences of objects (non-primitives including strings) in a table.
function count_objects(value)
	local counts = {}
	if value == nil then
		-- Early return for nil
		return counts
	end
	local function count_values(value)
		local type_ = type(value)
		if type_ == "boolean" or type_ == "number" then return end
		local count = counts[value]
		counts[value] = (count or 0) + 1
		if not count and type_ == "table" then
			for k, v in pairs(value) do
				count_values(k)
				count_values(v)
			end
		end
	end
	count_values(value)
	return counts
end

function foreach_value(table, func)
	for _, v in pairs(table) do
		func(v)
	end
end

function call(table, ...)
	for _, func in pairs(table) do
		func(...)
	end
end

function icall(table, ...)
	for _, func in ipairs(table) do
		func(...)
	end
end

function foreach_key(table, func)
	for key, _ in pairs(table) do
		func(key)
	end
end

function map(table, func)
	for key, value in pairs(table) do
		table[key] = func(value)
	end
	return table
end

map_values = map

function map_keys(table, func)
	local new_tab = {}
	for key, value in pairs(table) do
		new_tab[func(key)] = value
	end
	return new_tab
end

function process(tab, func)
	local results = {}
	for key, value in pairs(tab) do
		table.insert(results, func(key, value))
	end
	return results
end

function call(funcs, ...)
	for _, func in ipairs(funcs) do
		func(...)
	end
end

function find(list, value)
	for index, other_value in pairs(list) do
		if value == other_value then
			return index
		end
	end
end

contains = find

function to_add(table, after_additions)
	local additions = {}
	for key, value in pairs(after_additions) do
		if table[key] ~= value then
			additions[key] = value
		end
	end
	return additions
end

difference = to_add

function deep_to_add(table, after_additions)
	local additions = {}
	for key, value in pairs(after_additions) do
		if type(table[key]) == "table" and type(value) == "table" then
			local sub_additions = deep_to_add(table[key], value)
			if next(sub_additions) ~= nil then
				additions[key] = sub_additions
			end
		elseif table[key] ~= value then
			additions[key] = value
		end
	end
	return additions
end

function add_all(table, additions)
	for key, value in pairs(additions) do
		table[key] = value
	end
	return table
end

function deep_add_all(table, additions)
	for key, value in pairs(additions) do
		if type(table[key]) == "table" and type(value) == "table" then
			deep_add_all(table[key], value)
		else
			table[key] = value
		end
	end
	return table
end

function complete(table, completions)
	for key, value in pairs(completions) do
		if table[key] == nil then
			table[key] = value
		end
	end
	return table
end

function deepcomplete(table, completions)
	for key, value in pairs(completions) do
		if table[key] == nil then
			table[key] = value
		elseif type(table[key]) == "table" and type(value) == "table" then
			deepcomplete(table[key], value)
		end
	end
	return table
end

function merge(table, other_table, merge_func)
	merge_func = merge_func or merge
	local res = {}
	for key, value in pairs(table) do
		local other_value = other_table[key]
		if other_value == nil then
			res[key] = value
		else
			res[key] = merge_func(value, other_value)
		end
	end
	for key, value in pairs(other_table) do
		if table[key] == nil then
			res[key] = value
		end
	end
	return res
end

function merge_tables(table, other_table)
	return add_all(shallowcopy(table), other_table)
end

union = merge_tables

function intersection(table, other_table)
	local result = {}
	for key, value in pairs(table) do
		if other_table[key] then
			result[key] = value
		end
	end
	return result
end

function append(table, other_table)
	local length = #table
	for index, value in ipairs(other_table) do
		table[length + index] = value
	end
	return table
end

function keys(table)
	local keys = {}
	for key, _ in pairs(table) do
		keys[#keys + 1] = key
	end
	return keys
end

function values(table)
	local values = {}
	for _, value in pairs(table) do
		values[#values + 1] = value
	end
	return values
end

function flip(table)
	local flipped = {}
	for key, value in pairs(table) do
		flipped[value] = key
	end
	return flipped
end

function set(table)
	local flipped = {}
	for _, value in pairs(table) do
		flipped[value] = true
	end
	return flipped
end

function unique(table)
	return keys(set(table))
end

function ivalues(table)
	local index = 0
	return function()
		index = index + 1
		return table[index]
	end
end

function rpairs(table)
	local index = #table
	return function()
		if index >= 1 then
			local value = table[index]
			index = index - 1
			if value ~= nil then
				return index + 1, value
			end
		end
	end
end

-- Iterates the hash (= non-list) part of the table. The list part may not be modified while iterating.
function hpairs(table)
	local len = #table -- length only has to be determined once as hnext is a closure
	local function hnext(key)
		local value
		key, value = next(table, key)
		if type(key) == "number" and key % 1 == 0 and key >= 1 and key <= len then -- list entry, skip
			return hnext(key)
		end
		return key, value
	end
	return hnext
end

function min_key(table, less_than)
	less_than = less_than or lt
	local min_key = next(table)
	if min_key == nil then
		return -- empty table
	end
	for candidate_key in next, table, min_key do
		if less_than(candidate_key, min_key) then
			min_key = candidate_key
		end
	end
	return min_key
end

function min_value(table, less_than)
	less_than = less_than or lt
	local min_key, min_value = next(table)
	if min_key == nil then
		return -- empty table
	end
	for candidate_key, candidate_value in next, table, min_key do
		if less_than(candidate_value, min_value) then
			min_key, min_value = candidate_key, candidate_value
		end
	end
	return min_value, min_key
end

-- TODO move all of the below functions to modlib.list eventually

--! deprecated
function default_comparator(value, other_value)
	if value == other_value then
		return 0
	end
	if value > other_value then
		return 1
	end
	return -1
end

--! deprecated, use `binary_search(list, value, less_than)` instead
--> index if element found
--> -index for insertion if not found
function binary_search_comparator(comparator)
	return function(list, value)
		local min, max = 1, #list
		while min <= max do
			local pivot = min + math.floor((max - min) / 2)
			local element = list[pivot]
			local compared = comparator(value, element)
			if compared == 0 then
				return pivot
			elseif compared > 0 then
				min = pivot + 1
			else
				max = pivot - 1
			end
		end
		return -min
	end
end

function binary_search(
	list -- sorted list
	, value -- value to be be searched for
	, less_than -- function(a, b) return a < b end
)
	less_than = less_than or lt
	local min, max = 1, #list
	while min <= max do
		local mid = math.floor((min + max) / 2)
		local element = list[mid]
		if less_than(value, element) then
			max = mid - 1
		elseif less_than(element, value) then
			min = mid + 1
		else -- neither smaller nor larger => must be equal
			return mid -- index if found
		end
	end
	return nil, min -- nil, insertion index if not found
end

--> whether the list is sorted in ascending order
function is_sorted(list, less_than --[[function(a, b) return a < b end]])
	less_than = less_than or function(a, b) return a < b end
	for index = 2, #list do
		if less_than(list[index], list[index - 1]) then
			return false
		end
	end
	return true
end

function reverse(table)
	local len = #table
	for index = 1, len / 2 do
		local index_from_end = len + 1 - index
		table[index_from_end], table[index] = table[index], table[index_from_end]
	end
	return table
end

function repetition(value, count)
	local table = {}
	for index = 1, count do
		table[index] = value
	end
	return table
end

function slice(list, from, to)
	from, to = from or 1, to or #list
	local res = {}
	for i = from, to do
		res[#res + 1] = list[i]
	end
	return res
end

-- JS-ish array splice
function splice(
	list, -- to modify
	start, -- index (inclusive) for where to start modifying the array (defaults to after the last element)
	delete_count, -- how many elements to remove (defaults to `0`)
	... -- elements to insert after `start`
)
	start, delete_count = start or (#list + 1), delete_count or 0
	if start < 0 then
		start = start + #list + 1
	end

	local add_count = select("#", ...)
	local shift = add_count - delete_count
	if shift > 0 then -- shift up
		for i = #list, start + delete_count, -1 do
			list[i + shift] = list[i]
		end
	elseif shift < 0 then -- shift down
		for i = start, #list do
			list[i] = list[i - shift]
		end
	end

	-- Add elements
	for i = 1, add_count do
		list[start + i - 1] = select(i, ...)
	end

	return list
end

-- Equivalent to to_list[to], ..., to_list[to + count] = from_list[from], ..., from_list[from + count]
function move(from_list, from, to, count, to_list)
	from, to, count, to_list = from or 1, to or 1, count or #from_list, to_list or from_list
	if to_list ~= from_list or to < from then
		for i = 0, count do
			to_list[to + i] = from_list[from + i]
		end
	else -- iterate in reverse order
		for i = count, 0, -1 do
			to_list[to + i] = from_list[from + i]
		end
	end
end

-- Export environment
return _ENV