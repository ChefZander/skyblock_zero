-- Comparator utilities for "less than" functions returning whether a < b
local less_than = {}
setfenv(1, less_than)

default = {}

function default.less_than(a, b) return a < b end; default.lt = default.less_than
function default.less_or_equal(a, b) return a <= b end; default.leq = default.less_or_equal
function default.greater_than(a, b) return a > b end; default.gt = default.greater_than
function default.greater_or_equal(a, b) return a >= b end; default.geq = default.greater_or_equal

function less_or_equal(less_than)
	return function(a, b) return not less_than(b, a) end
end
leq = less_or_equal

function greater_or_equal(less_than)
	return function(a, b) return not less_than(a, b) end
end
geq = greater_or_equal

function greater_than(less_than)
	return function(a, b) return less_than(b, a) end
end
gt = greater_than

function equal(less_than)
	return function(a, b)
		return not (less_than(a, b) or less_than(b, a))
	end
end

function relation(less_than)
	return function(a, b)
		if less_than(a, b) then return "<"
		elseif less_than(b, a) then return ">"
		else return "=" end
	end
end

function by_func(func)
	return function(a, b)
		return func(a) < func(b)
	end
end

function by_field(key)
	return function(a, b)
		return a[key] < b[key]
	end
end

return less_than