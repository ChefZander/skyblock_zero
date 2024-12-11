local floor = math.floor
local min = math.min
local random = math.random

local swap = futil.table.swap
local default_cmp = futil.math.cmp

futil.selection = {}

local function partition5(t, left, right, cmp)
	cmp = cmp or default_cmp
	local i = left + 1
	while i <= right do
		local j = i
		while j > left and cmp(t[j], t[j - 1]) do
			swap(t, j - 1, j)
			j = j - 1
		end
		i = i + 1
	end
	return floor((left + right) / 2)
end

local function partition(t, left, right, pivot_i, i, cmp)
	cmp = cmp or default_cmp
	local pivot_v = t[pivot_i]
	swap(t, pivot_i, right)
	local store_i = left
	for j = left, right - 1 do
		if cmp(t[j], pivot_v) then
			swap(t, store_i, j)
			store_i = store_i + 1
		end
	end
	local store_i_eq = store_i
	for j = store_i, right - 1 do
		if t[j] == pivot_v then
			swap(t, store_i_eq, j)
			store_i_eq = store_i_eq + 1
		end
	end
	swap(t, right, store_i_eq)
	if i < store_i then
		return store_i
	elseif i <= store_i_eq then
		return i
	else
		return store_i_eq
	end
end

local function quickselect(t, left, right, i, pivot_alg, cmp)
	cmp = cmp or default_cmp
	while true do
		if left == right then
			return left
		end
		local pivot_i = partition(t, left, right, pivot_alg(t, left, right, cmp), i, cmp)
		if i == pivot_i then
			return i
		elseif i < pivot_i then
			right = pivot_i - 1
		else
			left = pivot_i + 1
		end
	end
end

futil.selection.quickselect = quickselect

futil.selection.pivot = {}

function futil.selection.pivot.random(t, left, right, cmp)
	return random(left, right)
end

local function pivot_medians_of_medians(t, left, right, cmp)
	cmp = cmp or default_cmp
	if right - left < 5 then
		return partition5(t, left, right, cmp)
	end
	for i = left, right, 5 do
		local sub_right = min(i + 4, right)
		local median5 = partition5(t, i, sub_right, cmp)
		swap(t, median5, left + floor((i - left) / 5))
	end
	local mid = floor((right - left) / 10) + left + 1
	return quickselect(t, left, left + floor((right - left) / 5), mid, pivot_medians_of_medians, cmp)
end

futil.selection.pivot.median_of_medians = pivot_medians_of_medians

--[[
make use of quickselect to munge a table:
	median_index = math.floor(#t / 2)
	after calling this,
	t[1] through t[median_index - 1] will be the elements less than t[median_index]
	t[median_index] will be the median (or element less-than-the-median for even length tables)
	t[median_index + 1] through t[#t] will be the elements greater than t[median_index]
pivot is a pivot algorithm, defaults to random selection
cmp is a comparison function.
returns median_index.
]]
function futil.selection.select(t, pivot_alg, cmp)
	cmp = cmp or default_cmp
	pivot_alg = pivot_alg or futil.selection.pivot.random
	local median_index = math.floor(#t / 2)
	return quickselect(t, 1, #t, median_index, pivot_alg, cmp)
end
