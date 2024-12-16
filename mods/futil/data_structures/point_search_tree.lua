--[[
a data structure which can efficiently retrieve values within specific rectangular regions of 3d space.

the closest relevant descriptions of this problem and solution are in the following:
https://en.wikipedia.org/wiki/Min/max_kd-tree
https://medium.com/omarelgabrys-blog/geometric-applications-of-bsts-e58f0a5019f3

creation is O(n log n)
finding objects in a region is O(m + log n) if there's m objects in the region.

the hope here is that this will provide a faster alternative to `minetest.get_objects_in_area()`. that currently
iterates over *all* active objects in the world, which can be slow when there's ten thousand or more of objects in the
world, and you are only interested in a few of them. in particular, the your-land server usually has 5-8 thousand
objects loaded at once, and can have hundreds of mobs calling `get_objects_in_area` every couple server steps. perftop
definitively implicated this routine as being a major source of lag. the question, now, is what to do about it.

the current implementation doesn't allow for insertion, deletion, or changes in location. if your points move around,
you're gonna have to rebuild the whole tree from scratch, which currently limits the usefulness.

TODO: read this and incorporate if applicable: https://arxiv.org/abs/1410.5420

== footnotes about the algorithms ==
currently, we're hard-coding the usage of the [median of medians](https://en.wikipedia.org/wiki/Median_of_medians)
algorithm as the pivot strategy, as this resulted in unexpectedly dramatic improvements over random selection in
some informal performance tests i did.

== footnotes about results ==
currently, performance can range from taking 1/20th of the time of the engine call, to 100 times as long. this
makes me realize that this is worth pursuing, but probably this will need to be ported to c++ to consistently provide
a benefit. but, i'll absolutely need to figure out a self-balancing strategy before that'll be appropriate.
]]
local sort = table.sort

local in_area = vector.in_area
	or function(pos, pmin, pmax)
		local x, y, z = pos.x, pos.y, pos.z
		return pmin.x <= x and x <= pmax.x and pmin.y <= y and y <= pmax.y and pmin.z <= z and z <= pmax.z
	end

local axes = { "x", "y", "z" }
local POS = 1
local VALUE = 2

local Leaf = futil.class1()

function Leaf:_init(pos_and_value)
	self[POS] = pos_and_value[POS]
	self[VALUE] = pos_and_value[VALUE]
end

local Node = futil.class1()

function Node:_init(min, max, left, right)
	self.min = min
	self.max = max
	self.left = left
	self.right = right
end

local PointSearchTree = futil.class1()

futil.min_median_max = {}

function futil.min_median_max.sort(t, indexer)
	if indexer then
		sort(t, function(a, b)
			return indexer(a) < indexer(b)
		end)
	else
		sort(t)
	end
	return t[1], math.floor(#t / 2), t[#t]
end

function futil.min_median_max.gen_select(pivot_alg)
	return function(t, indexer)
		local median = futil.selection.select(t, pivot_alg, function(a, b)
			return indexer(a) < indexer(b)
		end)
		local min = indexer(t[1])
		local max = min
		for i = 2, #t do
			local v = indexer(t[i])
			if v < min then
				min = v
			elseif v > max then
				max = v
			end
		end
		return min, median, max
	end
end

local function bisect(pos_and_values, axis_i, min_median_max)
	if #pos_and_values == 1 then
		return Leaf(pos_and_values[1])
	end

	local axis = axes[axis_i]

	local min, median, max = min_median_max(pos_and_values, function(i)
		return i[POS][axis]
	end)

	local next_axis_i = (axis_i % #axes) + 1
	return Node(
		min,
		max,
		bisect({ unpack(pos_and_values, 1, median) }, next_axis_i, min_median_max),
		bisect({ unpack(pos_and_values, median + 1) }, next_axis_i, min_median_max)
	)
end

function PointSearchTree:_init(pos_and_values, min_median_max)
	pos_and_values = pos_and_values or {}
	min_median_max = min_median_max or futil.min_median_max.gen_select(futil.selection.pivot.median_of_medians)
	self._len = #pos_and_values
	if #pos_and_values > 0 then
		self._root = bisect(pos_and_values, 1, min_median_max)
	end
end

-- -DLUAJIT_ENABLE_LUA52COMPAT
function PointSearchTree:__len()
	return self._len
end

function PointSearchTree:dump()
	local function getlines(node, axis_i)
		local axis = axes[axis_i]
		if not node then
			return {}
		elseif node:is_a(Leaf) then
			return { minetest.pos_to_string(node[POS], 1) }
		else
			local lines = {}
			for _, line in ipairs(getlines(node.left, (axis_i % #axes) + 1)) do
				lines[#lines + 1] = string.format("%s=[%.1f,%.1f] %s", axis, node.min, node.max, line)
			end
			for _, line in ipairs(getlines(node.right, (axis_i % #axes) + 1)) do
				lines[#lines + 1] = string.format("%s=[%.1f,%.1f] %s", axis, node.min, node.max, line)
			end
			return lines
		end
	end

	return table.concat(getlines(self._root, 1), "\n")
end

local function make_iterator(pmin, pmax, predicate, accumulate)
	local function iterate(node, axis_i)
		local next_axis_i = (axis_i % 3) + 1
		local next_axis = axes[next_axis_i]

		local left = node.left
		if left then
			if left:is_a(Leaf) then
				if predicate(left) then
					accumulate(left)
				end
			elseif pmin[next_axis] <= left.max then
				iterate(left, next_axis_i)
			end
		end

		local right = node.right
		if right then
			if right:is_a(Leaf) then
				if predicate(right) then
					accumulate(right)
				end
			elseif right.min <= pmax[next_axis] then
				iterate(right, next_axis_i)
			end
		end
	end
	return iterate
end

function PointSearchTree:iterate_values_in_area(pmin, pmax)
	if not self._root then
		return function() end
	end

	pmin, pmax = vector.sort(pmin, pmax)

	if self._root.max < pmin.x or pmax.x < self._root.min then
		return function() end
	end

	return coroutine.wrap(function()
		make_iterator(pmin, pmax, function(leaf)
			return in_area(leaf[POS], pmin, pmax)
		end, function(leaf)
			coroutine.yield(leaf[POS], leaf[VALUE])
		end)(self._root, 1)
	end)
end

function PointSearchTree:get_values_in_area(pmin, pmax)
	local via = {}
	if not self._root then
		return via
	end

	pmin, pmax = vector.sort(pmin, pmax)

	if self._root.max < pmin.x or pmax.x < self._root.min then
		return via
	end

	make_iterator(pmin, pmax, function(leaf)
		return in_area(leaf[POS], pmin, pmax)
	end, function(leaf)
		via[#via + 1] = leaf[VALUE]
	end)(self._root, 1)

	return via
end

function PointSearchTree:iterate_values_inside_radius(center, radius)
	if not self._root then
		return function() end
	end

	local pmin = vector.subtract(center, radius)
	local pmax = vector.add(center, radius)

	if self._root.max < pmin.x or pmax.x < self._root.min then
		return function() end
	end

	local v_distance = vector.distance

	return coroutine.wrap(function()
		make_iterator(pmin, pmax, function(leaf)
			return v_distance(center, leaf[POS]) <= radius
		end, function(leaf)
			coroutine.yield(leaf[POS], leaf[VALUE])
		end)(self._root, 1)
	end)
end

function PointSearchTree:get_values_inside_radius(center, radius)
	local vir = {}
	if not self._root then
		return vir
	end

	local pmin = vector.subtract(center, radius)
	local pmax = vector.add(center, radius)

	if self._root.max < pmin.x or pmax.x < self._root.min then
		return vir
	end

	local v_distance = vector.distance

	make_iterator(pmin, pmax, function(leaf)
		return v_distance(center, leaf[POS]) <= radius
	end, function(leaf)
		vir[#vir + 1] = leaf[VALUE]
	end)(self._root, 1)

	return vir
end

futil.PointSearchTree = PointSearchTree
