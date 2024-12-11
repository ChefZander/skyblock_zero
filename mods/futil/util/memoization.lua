local private_state = ...
local mod_storage = private_state.mod_storage

function futil.memoize1(func)
	local memo = {}
	return function(arg)
		if arg == nil then
			return func(arg)
		end
		local rv = memo[arg]

		if not rv then
			rv = func(arg)
			memo[arg] = rv
		end

		return rv
	end
end

function futil.memoize_dumpable(func)
	local memo = {}
	return function(...)
		local key = dump({ ... })
		local rv = memo[key]

		if not rv then
			rv = func(...)
			memo[key] = rv
		end

		return rv
	end
end

function futil.memoize1_modstorage(id, func)
	local key_format = ("%%s:%s:memoize"):format(id)
	return function(arg)
		local key_key = key_format:format(tostring(arg))
		local rv = mod_storage:get(key_key)

		if not rv then
			rv = func(arg)
			mod_storage:set_string(key_key, tostring(rv))
		end

		return rv
	end
end

futil.memoize1ms = futil.memoize1_modstorage -- backwards compatibility
