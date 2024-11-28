-- Localize globals
local modlib, unpack, select, setmetatable
	= modlib, unpack, select, setmetatable

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

function no_op() end

function identity(...) return ... end

-- TODO switch all of these to proper vargs

function curry(func, ...)
	local args = { ... }
	return function(...) return func(unpack(args), ...) end
end

function curry_tail(func, ...)
	local args = { ... }
	return function(...) return func(unpack(modlib.table.concat({...}, args))) end
end

function curry_full(func, ...)
	local args = { ... }
	return function() return func(unpack(args)) end
end

function args(...)
	local args = { ... }
	return function(func) return func(unpack(args)) end
end

function value(val) return function() return val end end

function values(...)
	local args = { ... }
	return function() return unpack(args) end
end

function memoize(func)
	return setmetatable({}, {
		__index = function(self, key)
			local value = func(key)
			self[key] = value
			return value
		end,
		__call = function(self, arg)
			return self[arg]
		end,
		__mode = "k"
	})
end

function compose(func, other_func)
	return function(...)
		return func(other_func(...))
	end
end

function override_chain(func, override)
	return function(...)
		func(...)
		return override(...)
	end
end

--+ Calls func using the provided arguments, deepcopies all arguments
function call_by_value(func, ...)
	return func(unpack(modlib.table.deepcopy{...}, 1, select("#", ...)))
end

-- Functional wrappers for Lua's builtin metatable operators (arithmetic, concatenation, length, comparison, indexing, call)

-- TODO (?) add operator table `["+"] = add, ...`

function add(a, b) return a + b end

function sub(a, b) return a - b end

function mul(a, b) return a * b end

function div(a, b) return a / b end

function mod(a, b) return a % b end

function pow(a, b) return a ^ b end

function unm(a) return -a end

function concat(a, b) return a .. b end

function len(a) return #a end

function eq(a, b) return a == b end

function neq(a, b) return a ~= b end

function lt(a, b) return a < b end

function gt(a, b) return a > b end

function le(a, b) return a <= b end

function ge(a, b) return a >= b end

function index(object, key) return object[key] end

function newindex(object, key, value) object[key] = value end

function call(object, ...) object(...) end

-- Functional wrappers for logical operators, suffixed with _ for syntactical convenience

function not_(a) return not a end
_ENV["not"] = not_

function and_(a, b) return a and b end
_ENV["and"] = and_

function or_(a, b) return a or b end
_ENV["or"] = or_

-- Export environment
return _ENV