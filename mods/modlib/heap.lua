-- Localize globals
local math_floor, setmetatable, table_insert = math.floor, setmetatable, table.insert

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

local metatable = {__index = _ENV}

function less_than(a, b) return a < b end

--> empty min heap
function new(less_than)
	return setmetatable({less_than = less_than}, metatable)
end

function push(self, value)
	table_insert(self, value)
	local function heapify(index)
		if index == 1 then
			return
		end
		local parent = math_floor(index / 2)
		if self.less_than(self[index], self[parent]) then
			self[parent], self[index] = self[index], self[parent]
			heapify(parent)
		end
	end
	heapify(#self)
end

function pop(self)
	local value = self[1]
	local last = #self
	if last == 1 then
		self[1] = nil
		return value
	end
	self[1], self[last] = self[last], nil
	last = last - 1
	local function heapify(index)
		local left_child = index * 2
		if left_child > last then
			return
		end
		local smallest_child = left_child + 1
		if smallest_child > last or self.less_than(self[left_child], self[smallest_child]) then
			smallest_child = left_child
		end
		if self.less_than(self[smallest_child], self[index]) then
			self[index], self[smallest_child] = self[smallest_child], self[index]
			heapify(smallest_child)
		end
	end
	heapify(1)
	return value
end

-- Export environment
return _ENV