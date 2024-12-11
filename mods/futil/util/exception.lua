function futil.safe_wrap(func, rv_on_fail, error_callback)
	-- wrap a function w/ logic to avoid crashing
	return function(...)
		local rvs = { xpcall(func, debug.traceback, ...) }

		if rvs[1] then
			return unpack(rvs, 2)
		else
			if error_callback then
				error_callback(debug.getinfo(func), { ... }, rvs[2])
			else
				futil.log(
					"error",
					"(check_call): %s args: %s out: %s",
					dump(debug.getinfo(func)),
					dump({ ... }),
					rvs[2]
				)
			end
			return rv_on_fail
		end
	end
end

function futil.safe_call(func, rv_on_fail, error_callback, ...)
	return futil.safe_wrap(func, rv_on_fail, error_callback)(...)
end

futil.check_call = futil.safe_wrap -- backwards compatibility
