local iterators = {}

function iterators.range(...)
	local a, b, c = ...
	if type(a) ~= "number" then
		error("invalid range")
	end
	if not b then
		a, b = 1, a
	end
	if type(b) ~= "number" then
		error("invalid range")
	end
	c = c or 1
	if type(c) ~= "number" or c == 0 then
		error("invalid range")
	end

	if c > 0 then
		return function()
			if a > b then
				return
			end
			local to_return = a
			a = a + c
			return to_return
		end
	else
		return function()
			if a < b then
				return
			end
			local to_return = a
			a = a + c
			return to_return
		end
	end
end

function iterators.repeat_(value, times)
	if times then
		local i = 0
		return function()
			i = i + 1
			if i <= times then
				return value
			end
		end
	else
		return function()
			return value
		end
	end
end

function iterators.chain(...)
	local arg = { ... }
	local i = 1

	return function()
		while i <= #arg do
			local v = arg[i]()
			if v then
				return v
			end
		end
	end
end

function iterators.count(start, step)
	step = step or 1
	return function()
		local rv = start
		start = start + step
		return rv
	end
end

function iterators.values(t)
	local k
	return function()
		local value
		k, value = next(t, k)
		return value
	end
end

function iterators.accumulate(t, composer, initial)
	local value = initial
	local i = futil.table.iterate(t)
	return function()
		local next_value = i()
		if next_value then
			if value == nil then
				value = next_value
			elseif composer then
				value = composer(value, next_value)
			else
				value = value + next_value
			end
			return value
		end
	end
end

futil.iterators = iterators
