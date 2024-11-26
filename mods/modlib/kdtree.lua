-- Localize globals
local assert, math, modlib, setmetatable, table, unpack = assert, math, modlib, setmetatable, table, unpack

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

local metatable = {__index = _ENV}

distance = modlib.vector.distance

--: vectors first vector is used to infer the dimension
--: distance (vector, other_vector) -> number, default: modlib.vector.distance
function new(vectors, distance)
	assert(#vectors > 0, "vector list must not be empty")
	local dimension = #vectors[1]
	local function builder(vectors, axis)
		if #vectors == 1 then return { value = vectors[1] } end
		table.sort(vectors, function(a, b) return a[axis] > b[axis] end)
		local median = math.floor(#vectors / 2)
		local next_axis = ((axis + 1) % dimension) + 1
		return setmetatable({
			axis = axis,
			pivot = vectors[median],
			left = builder({ unpack(vectors, 1, median) }, next_axis),
			right = builder({ unpack(vectors, median + 1) }, next_axis)
		}, metatable)
	end
	local self = builder(vectors, 1)
	self.distance = distance
	return setmetatable(self, metatable)
end

function get_nearest_neighbor(self, vector)
	local min_distance = math.huge
	local nearest_neighbor
	local distance_func = self.distance
	local function visit(tree)
		local axis = tree.axis
		if tree.value ~= nil then
			local distance = distance_func(tree.value, vector)
			if distance < min_distance then
				min_distance = distance
				nearest_neighbor = tree.value
			end
			return
		else
			local this_side, other_side = tree.left, tree.right
			if vector[axis] < tree.pivot[axis] then this_side, other_side = other_side, this_side end
			visit(this_side)
			if tree.pivot then
				local dist = math.abs(tree.pivot[axis] - vector[axis])
				if dist <= min_distance then visit(other_side) end
			end
		end
	end
	visit(self)
	return nearest_neighbor, min_distance
end

-- TODO insertion & deletion + rebalancing

-- Export environment
return _ENV