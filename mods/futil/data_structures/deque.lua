-- inspired by https://www.lua.org/pil/11.4.html

local Deque = futil.class1()

function Deque:_init(def)
	self._a = 0
	self._z = -1
	self._m = def and def.max_size
end

function Deque:size()
	return self._z - self._a + 1
end

function Deque:push_front(value)
	local max_size = self._m
	if max_size and (self._z - self._a + 1) >= max_size then
		return false
	end
	local a = self._a - 1
	self._a = a
	self[a] = value
	return true, a
end

function Deque:peek_front()
	return self[self._a]
end

function Deque:pop_front()
	local a = self._a
	if a > self._z then
		return nil
	end
	local value = self[a]
	self[a] = nil
	self._a = a + 1
	return value
end

function Deque:push_back(value)
	local max_size = self._m
	if max_size and (self._z - self._a + 1) >= max_size then
		return false
	end
	local z = self._z + 1
	self._z = z
	self[z] = value
	return true, z
end

function Deque:peek_back()
	return self[self._z]
end

function Deque:pop_back()
	local z = self._z
	if self._a > z then
		return nil
	end
	local value = self[z]
	self[z] = nil
	self._z = z + 1
	return value
end

-- this iterator is kinda wonky, and the behavior may be changed in the future.
-- unexpected behavior may result from modifying a deque *while* iterating it.
-- note that you *cannot* iterate the deque directly using `pairs()` because of e.g. "_a" and "_z"
function Deque:iterate()
	local i = self._a - 1
	return function()
		i = i + 1
		return self[i]
	end
end

function Deque:clear()
	for k in pairs(self) do
		if type(k) == "number" then
			self[k] = nil
		end
	end
	self._a = 0
	self._z = -1
end

futil.Deque = Deque
