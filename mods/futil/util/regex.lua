function futil.is_valid_regex(pattern)
	return futil.safe_call(function()
		(""):match(pattern)
		return true
	end, false, futil.functional.noop)
end
