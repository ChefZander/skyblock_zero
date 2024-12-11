local default_cmp = futil.math.cmp

futil.table = {}

function futil.table.set_all(t1, t2)
	for k, v in pairs(t2) do
		t1[k] = v
	end
	return t1
end

function futil.table.compose(t1, t2)
	local t = table.copy(t1)
	futil.table.set_all(t, t2)
	return t
end

function futil.table.pairs_by_value(t, cmp)
	cmp = cmp or default_cmp
	local s = {}
	for k, v in pairs(t) do
		table.insert(s, { k, v })
	end

	table.sort(s, function(a, b)
		return cmp(a[2], b[2])
	end)

	local i = 0
	return function()
		i = i + 1
		local v = s[i]
		if v then
			return unpack(v)
		else
			return nil
		end
	end
end

function futil.table.pairs_by_key(t, cmp)
	cmp = cmp or default_cmp
	local s = {}
	for k, v in pairs(t) do
		table.insert(s, { k, v })
	end

	table.sort(s, function(a, b)
		return cmp(a[1], b[1])
	end)

	local i = 0
	return function()
		i = i + 1
		local v = s[i]
		if v then
			return unpack(v)
		else
			return nil
		end
	end
end

function futil.table.size(t)
	local size = 0
	for _ in pairs(t) do
		size = size + 1
	end
	return size
end

function futil.table.is_empty(t)
	return next(t) == nil
end

function futil.table.count_elements(t)
	local counts = {}
	for _, item in ipairs(t) do
		counts[item] = (counts[item] or 0) + 1
	end
	return counts
end

function futil.table.sets_intersect(set1, set2)
	for k in pairs(set1) do
		if set2[k] then
			return true
		end
	end

	return false
end

function futil.table.iterate(t)
	local i = 0
	return function()
		i = i + 1
		return t[i]
	end
end

function futil.table.reversed(t)
	local len = #t
	local reversed = {}

	for i = len, 1, -1 do
		reversed[len - i + 1] = t[i]
	end

	return reversed
end

function futil.table.contains(t, value)
	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end

	return false
end

function futil.table.keys(t)
	local keys = {}
	for key in pairs(t) do
		keys[#keys + 1] = key
	end
	return keys
end

function futil.table.ikeys(t)
	local key
	return function()
		key = next(t, key)
		return key
	end
end

function futil.table.values(t)
	local values = {}
	for _, value in pairs(t) do
		values[#values + 1] = value
	end
	return values
end

function futil.table.sort_keys(t, cmp)
	local keys = futil.table.keys(t)
	table.sort(keys, cmp)
	return keys
end

-- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
function futil.table.shuffle(t, rnd)
	rnd = rnd or math.random
	for i = #t, 2, -1 do
		local j = rnd(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

local function swap(t, i, j)
	t[i], t[j] = t[j], t[i]
end

futil.table.swap = swap

function futil.table.get(t, key, default)
	local value = t[key]
	if value == nil then
		return default
	end
	return value
end

function futil.table.setdefault(t, key, default)
	local value = t[key]
	if value == nil then
		t[key] = default
		return default
	end
	return value
end

function futil.table.pack(...)
	return { n = select("#", ...), ... }
end
