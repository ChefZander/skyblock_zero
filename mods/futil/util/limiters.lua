--[[
	functions to limit the growth of a variable.
	the intention here is to provide a family of functions for which
	* f(x) is defined for all x >= 0
	* f(0) = 0
	* f(1) = 1
	* f is continuous
	* f is nondecreasing
	* f\'(x) is nonincreasing when x > 1 (when the parameters are appropriate)
]]

local log = math.log
local pow = math.pow
local tanh = math.tanh

futil.limiters = {
	-- no limiting
	none = futil.functional.identity,
	-- f(x) = x ^ param_1. param_1 should be < 1 for f\'(x) to be nonincreasing
	-- f(x) will grow arbitrarily, but at a decreasing rate.
	gamma = function(x, param_1)
		return pow(x, param_1)
	end,
	-- the hyperbolic tangent scaled so that f(0) = 0 and f(1) = 1.
	-- f(x) will grow approximately linearly for small x, but it will never grow beyond a maximum value, which is
	-- approximately equal to param_1 + 1
	tanh = function(x, param_1)
		return (tanh((x - 1) / param_1) - tanh(-1 / param_1)) / -tanh(-1 / param_1)
	end,
	-- f(x) = log^param_2(param_1 * x + 1), scaled so that f(0) = 0 and f(1) = 1.
	-- f(x) will grow arbitrarily, but at a much slower rate than a gamma limiter
	log__n = function(x, param_1, param_2)
		return (log(x + 1) * pow(log(param_1 * x + 1), param_2) / (log(2) * pow(log(param_1 + 1), param_2)))
	end,
}

function futil.create_limiter(name, param_1, param_2)
	local f = futil.limiters[name]
	return function(x)
		return f(x, param_1, param_2)
	end
end
