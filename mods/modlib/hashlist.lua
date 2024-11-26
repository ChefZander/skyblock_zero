-- Localize globals
local setmetatable = setmetatable

-- Table based list, can handle at most 2^52 pushes
local list = {}
-- TODO use __len for Lua version > 5.1
local metatable = {__index = list}
list.metatable = metatable

-- Takes a list
function list:new()
	self.head = 0
	self.length = #self
	return setmetatable(self, metatable)
end

function list:in_bounds(index)
	return index >= 1 and index <= self.length
end

function list:get(index)
	return self[self.head + index]
end

function list:set(index, value)
	assert(value ~= nil)
	self[self.head + index] = value
end

function list:len()
	return self.length
end

function list:ipairs()
	local index = 0
	return function()
		index = index + 1
		if index > self.length then
			return
		end
		return index, self[self.head + index]
	end
end

function list:rpairs()
	local index = self.length + 1
	return function()
		index = index - 1
		if index < 1 then
			return
		end
		return index, self[self.head + index]
	end
end

function list:push_tail(value)
	assert(value ~= nil)
	self.length = self.length + 1
	self[self.head + self.length] = value
end

function list:get_tail()
	return self[self.head + self.length]
end

function list:pop_tail()
	if self.length == 0 then return end
	local value = self:get_tail()
	self[self.head + self.length] = nil
	self.length = self.length - 1
	return value
end

function list:push_head(value)
	self[self.head] = value
	self.head = self.head - 1
	self.length = self.length + 1
end

function list:get_head()
	return self[self.head + 1]
end

function list:pop_head()
	if self.length == 0 then return end
	local value = self:get_head()
	self.length = self.length - 1
	self.head = self.head + 1
	self[self.head] = nil
	return value
end

return list