local functional = {}

local t_iterate = futil.table.iterate
local t_insert = table.insert

function functional.noop()
	-- the NOTHING function does nothing.
end

function functional.identity(x)
	return x
end

function functional.izip(...)
	local is = { ... }
	if #is == 0 then
		return functional.noop
	end

	return function()
		local t = {}
		for i in t_iterate(is) do
			local v = i()
			if v ~= nil then
				t_insert(t, v)
			else
				return
			end
		end

		return t
	end
end

function functional.zip(...)
	local is = {}
	for t in t_iterate({ ... }) do
		t_insert(is, t_iterate(t))
	end
	return functional.izip(unpack(is))
end

function functional.imap(func, ...)
	local zipper = functional.izip(...)
	return function()
		local args = zipper()
		if args then
			return func(unpack(args))
		end
	end
end

function functional.map(func, ...)
	local zipper = functional.zip(...)
	return function()
		local args = zipper()
		if args then
			return func(unpack(args))
		end
	end
end

function functional.apply(func, t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = func(v)
	end
	return t2
end

function functional.reduce(func, t, initial)
	local i = t_iterate(t)
	if not initial then
		initial = i()
	end
	local next = i()
	while next do
		initial = func(initial, next)
		next = i()
	end
	return initial
end

function functional.partial(func, ...)
	local args = { ... }
	return function(...)
		return func(unpack(args), ...)
	end
end

function functional.compose(a, b)
	return function(...)
		return a(b(...))
	end
end

function functional.ifilter(pred, i)
	local v
	return function()
		v = i()
		while v ~= nil and not pred(v) do
			v = i()
		end
		return v
	end
end

function functional.filter(pred, t)
	return functional.ifilter(pred, t_iterate(t))
end

function functional.iall(i)
	while true do
		local v = i()
		if v == false then
			return false
		elseif v == nil then
			return true
		end
	end
end

function functional.all(t)
	for i = 1, #t do
		if not t[i] then
			return false
		end
	end

	return true
end

function functional.iany(i)
	while true do
		local v = i()
		if v == nil then
			return false
		elseif v then
			return true
		end
	end
end

function functional.any(t)
	for i = 1, #t do
		if t[i] then
			return true
		end
	end
	return false
end

function functional.wrap(f)
	return function(...)
		return f(...)
	end
end

futil.functional = functional
