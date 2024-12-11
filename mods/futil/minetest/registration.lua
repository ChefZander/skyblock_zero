function futil.make_registration()
	local t = {}
	local registerfunc = function(func)
		t[#t + 1] = func
	end
	return t, registerfunc
end

function futil.make_registration_reverse()
	local t = {}
	local registerfunc = function(func)
		table.insert(t, 1, func)
	end
	return t, registerfunc
end
