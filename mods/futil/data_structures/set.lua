-- based more-or-less on python's set

local f = string.format

local Set = futil.class1()

local function is_a_set(thing)
	return type(thing) == "table" and type(thing.is_a) == "function" and thing:is_a(Set)
end

function Set:_init(t_or_i)
	self._size = 0
	self._set = {}
	if t_or_i then
		if type(t_or_i.is_a) == "function" then
			if t_or_i:is_a(Set) then
				self._set = table.copy(t_or_i._set)
				self._size = t_or_i._size
			else
				for v in t_or_i:iterate() do
					self:add(v)
				end
			end
		elseif type(t_or_i) == "table" then
			for i = 1, #t_or_i do
				self:add(t_or_i[i])
			end
		elseif type(t_or_i) == "function" or getmetatable(t_or_i).__call then
			for v in t_or_i do
				self:add(v)
			end
		else
			error(f("unknown argument of type %s", type(t_or_i)))
		end
	end
end

-- turn a table like {foo=true, bar=true} into a Set
function Set.convert(t)
	local set = Set()
	set._set = t
	set._size = futil.table.size(t)
	return set
end

-- -DLUAJIT_ENABLE_LUA52COMPAT
function Set:__len()
	return self._size
end

function Set:len()
	return self._size
end

function Set:size()
	return self._size
end

function Set:is_empty()
	return self._size == 0
end

function Set:__tostring()
	local elements = {}
	for element in pairs(self._set) do
		elements[#elements + 1] = f("%q", element)
	end
	return f("Set({%s})", table.concat(elements, ", "))
end

function Set:__eq(other)
	if not is_a_set(other) then
		return false
	end
	for k in pairs(self._set) do
		if not other._set[k] then
			return false
		end
	end
	return self._size == other._size
end

function Set:contains(element)
	return self._set[element] == true
end

function Set:add(element)
	if not self:contains(element) then
		self._set[element] = true
		self._size = self._size + 1
	end
end

function Set:remove(element)
	if not self:contains(element) then
		error(f("set does not contain %s", element))
	end
	self._set[element] = nil
	self._size = self._size - 1
end

function Set:discard(element)
	if self:contains(element) then
		self._set[element] = nil
		self._size = self._size - 1
	end
end

function Set:clear()
	self._set = {}
	self._size = 0
end

function Set:iterate()
	return futil.table.ikeys(self._set)
end

function Set:intersects(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	local smaller, bigger
	if other:size() < self:size() then
		smaller = other
		bigger = self
	else
		smaller = self
		bigger = other
	end
	for element in smaller:iterate() do
		if bigger:contains(element) then
			return true
		end
	end
	return false
end

function Set:isdisjoint(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	local smaller, bigger
	if other:size() < self:size() then
		smaller = other
		bigger = self
	else
		smaller = self
		bigger = other
	end
	for element in smaller:iterate() do
		if bigger:contains(element) then
			return false
		end
	end
	return true
end

function Set:issubset(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	if self:size() > other:size() then
		return false
	end
	for element in self:iterate() do
		if not other:contains(element) then
			return false
		end
	end
	return true
end

function Set:__le(other)
	return self:issubset(other)
end

function Set:__lt(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	if self:size() >= other:size() then
		return false
	end
	for element in self:iterate() do
		if not other:contains(element) then
			return false
		end
	end
	return true
end

function Set:issuperset(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	return other:issubset(self)
end

function Set:update(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	for element in other:iterate() do
		self:add(element)
	end
end

function Set:union(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	local union = Set(self)
	union:update(other)
	return union
end

function Set:__add(other)
	return self:union(other)
end

function Set:intersection_update(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	for element in self:iterate() do
		if not other:contains(element) then
			self:remove(element)
		end
	end
end

function Set:intersection(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	local intersection = Set()
	for element in self:iterate() do
		if other:contains(element) then
			intersection:add(element)
		end
	end
	return intersection
end

function Set:difference_update(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	for element in other:iterate() do
		self:discard(element)
	end
end

function Set:difference(other)
	if not is_a_set(other) then
		other = Set(other)
	end
	local difference = Set(self)
	difference:difference_update(other)
	return difference
end

function Set:__sub(other)
	return self:difference(other)
end

futil.Set = Set
