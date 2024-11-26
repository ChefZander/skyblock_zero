local select, setmetatable, unpack = select, setmetatable, unpack

local vararg = {}

function vararg.aggregate(binary_func, initial, ...)
	local total = initial
	for i = 1, select("#", ...) do
		total = binary_func(total, select(i, ...))
	end
	return total
end

local metatable = {__index = {}}

function vararg.pack(...)
	return setmetatable({["#"] = select("#", ...); ...}, metatable)
end

local va = metatable.__index

function va:unpack()
	return unpack(self, 1, self["#"])
end

function va:select(n)
	if n > self["#"] then return end
	return self[n]
end

local function inext(self, i)
	i = i + 1
	if i > self["#"] then return end
	return i, self[i]
end

function va:ipairs()
	return inext, self, 0
end

function va:concat(other)
	local self_len, other_len = self["#"], other["#"]
	local res = {["#"] = self_len + other_len}
	for i = 1, self_len do
		res[i] = self[i]
	end
	for i = 1, other_len do
		res[self_len + i] = other[i]
	end
	return setmetatable(res, metatable)
end
metatable.__concat = va.concat

function va:equals(other)
	if self["#"] ~= other["#"] then return false end
	for i = 1, self["#"] do if self[i] ~= other[i] then return false end end
	return true
end
metatable.__eq = va.equals

function va:aggregate(binary_func, initial)
	return vararg.aggregate(binary_func, initial, self:unpack())
end

return vararg