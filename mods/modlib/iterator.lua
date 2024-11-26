--[[
	Iterators are always the *last* argument(s) to all functions here,
	which differs from other modules which take what they operate on as first argument.
	This is because iterators consist of three variables - iterator function, state & control variable -
	and wrapping them (using a table, a closure or the like) would be rather inconvenient.
	Having them as the last argument allows to just pass in the three variables returned by functions such as `[i]pairs`.
	Additionally, putting functions first - although syntactically inconvenient - is consistent with Python and Lisp.
]]

local coroutine_create, coroutine_resume, coroutine_yield, coroutine_status, unpack, select
	= coroutine.create, coroutine.resume, coroutine.yield, coroutine.status, unpack, select

local identity, not_, add = modlib.func.identity, modlib.func.not_, modlib.func.add

--+ For all functions which aggregate over single values, use modlib.table.ivalues - not ipairs - for lists!
--+ Otherwise they will be applied to the indices.
local iterator = {}

function iterator.wrap(iterator, state, control_var)
	local function update_control_var(...)
		control_var = ...
		return ...
	end
	return function()
		return update_control_var(iterator(state, control_var))
	end
end
iterator.closure = iterator.wrap
iterator.make_stateful = iterator.wrap

function iterator.filter(predicate, iterator, state, control_var)
	local function _filter(...)
		local cvar = ...
		if cvar == nil then
			return
		end
		if predicate(...) then
			return ...
		end
		return _filter(iterator(state, cvar))
	end
	return function(state, control_var)
		return _filter(iterator(state, control_var))
	end, state, control_var
end

function iterator.truthy(...)
	return iterator.filter(identity, ...)
end

function iterator.falsy(...)
	return iterator.filter(not_, ...)
end

function iterator.map(map_func, iterator, state, control_var)
	local function _map(...)
		control_var = ... -- update control var
		if control_var == nil then return end
		return map_func(...)
	end
	return function()
		return _map(iterator(state, control_var))
	end
end

function iterator.map_values(map_func, iterator, state, control_var)
	local function _map_values(cvar, ...)
		if cvar == nil then return end
		return cvar, map_func(...)
	end
	return function(state, control_var)
		return _map_values(iterator(state, control_var))
	end, state, control_var
end

-- Iterator must be restartable
function iterator.rep(times, iterator, state, control_var)
	times = times or 1
	if times == 1 then
		return iterator, state, control_var
	end
	local function _rep(cvar, ...)
		if cvar == nil then
			times = times - 1
			if times == 0 then return end
			return _rep(iterator(state, control_var))
		end
		return cvar, ...
	end
	return function(state, control_var)
		return _rep(iterator(state, control_var))
	end, state, control_var
end

-- Equivalent to `for x, y, z in iterator, state, ... do callback(x, y, z) end`
function iterator.foreach(callback, iterator, state, ...)
	local function loop(...)
		if ... == nil then return end
		callback(...)
		return loop(iterator(state, ...))
	end
	return loop(iterator(state, ...))
end

function iterator.for_generator(caller, ...)
	local co = coroutine_create(function(...)
		return caller(function(...)
			return coroutine_yield(...)
		end, ...)
	end)
	local args, n_args = {...}, select("#", ...)
	return function()
		if coroutine_status(co) == "dead" then
			return
		end
		local function _iterate(status, ...)
			if not status then
				error((...))
			end
			return ...
		end
		return _iterate(coroutine_resume(co, unpack(args, 1, n_args)))
	end
end

function iterator.range(from, to, step)
	if not step then
		if not to then
			from, to = 1, from
		end
		step = 1
	end

	return function(_, current)
		current = current + step
		if current > to then
			return
		end
		return current
	end, nil, from - step
end

function iterator.aggregate(binary_func, total, ...)
	for value in ... do
		total = binary_func(total, value)
	end
	return total
end

-- Like `iterator.aggregate`, but does not expect a `total`
function iterator.reduce(binary_func, iterator, state, control_var)
	local total = iterator(state, control_var)
	if total == nil then
		return -- nothing if the iterator is empty
	end
	for value in iterator, state, total do
		total = binary_func(total, value)
	end
	return total
end
iterator.fold = iterator.reduce

-- TODO iterator.find(predicate, iterator, state, control_var)

function iterator.any(...)
	for val in ... do
		if val then return true end
	end
	return false
end

function iterator.all(...)
	for val in ... do
		if not val then return false end
	end
	return true
end

function iterator.min(less_than_func, ...)
	local min
	for value in ... do
		if min == nil or less_than_func(value, min) then
			min = value
		end
	end
	return min
end

-- TODO iterator.max

function iterator.empty(iterator, state, control_var)
	return iterator(state, control_var) == nil
end

function iterator.first(iterator, state, control_var)
	return iterator(state, control_var)
end

function iterator.last(iterator, state, control_var)
	-- Storing a vararg in a table seems to be necessary: https://stackoverflow.com/questions/73914273/
	-- This could be optimized further for memory by keeping the same table across calls,
	-- but that might cause issues with multiple coroutines calling this
	local last, last_n = {}, 0

	local function _last(...)
		local cvar = ...
		if cvar == nil then
			return unpack(last, 1, last_n)
		end

		-- Write vararg to table: Avoid the creation of a garbage table every iteration by reusing the same table
		last_n = select("#", ...)
		for i = 1, last_n do
			last[i] = select(i, ...)
		end

		return _last(iterator(state, cvar))
	end

	return _last(iterator(state, control_var))
end

-- Converts a vararg starting with `nil` (end of loop control variable) into nothing
local function nil_to_nothing(...)
	if ... == nil then return end
	return ...
end

function iterator.select(n, iterator, state, control_var)
	for _ = 1, n - 1 do
		control_var = iterator(state, control_var)
		if control_var == nil then return end
	end
	-- Either all values returned by the n-th call iteration
	-- or nothing if the iterator holds fewer than `n` values
	return nil_to_nothing(iterator(state, control_var))
end

function iterator.limit(count, iterator, state, control_var)
	return function(state, control_var)
		count = count - 1
		if count < 0 then return end
		return iterator(state, control_var)
	end, state, control_var
end

function iterator.count(...)
	local count = 0
	for _ in ... do
		count = count + 1
	end
	return count
end

function iterator.sum(...)
	return iterator.aggregate(add, 0, ...)
end

function iterator.average(...)
	local count = 0
	local sum = 0
	for value in ... do
		count = count + 1
		sum = sum + value
	end
	return sum / count
end

--: ... **restartable** iterator
-- A single pass method for calculating the standard deviation exists but is highly inaccurate
function iterator.standard_deviation(...)
	local avg = iterator.average(...)
	local count = 0
	local sum = 0
	for value in ... do
		count = count + 1
		sum = sum + (value - avg)^2
	end
	return (sum / count)^.5
end

-- Comprehensions ("collectors")

-- Shorthand for `for k, v in ... do t[k] = v end`
function iterator.to_table(...)
	local t = {}
	for k, v in ... do
		t[k] = v
	end
	return t
end

-- Shorthand for `for k in ... do t[#t + 1] = k end`
function iterator.to_list(...)
	local t = {}
	for k in ... do
		t[#t + 1] = k
	end
	return t
end

-- Shorthand for `for k in ... do t[k] = true end`
function iterator.to_set(...)
	local t = {}
	for k in ... do
		t[k] = true
	end
	return t
end

return iterator