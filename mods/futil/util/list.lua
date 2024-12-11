function futil.list(iterator)
	local t = {}
	local v = iterator()
	while v do
		t[#t + 1] = v
		v = iterator()
	end
	return t
end

function futil.list_multiple(iterator)
	local t = {}
	local v = { iterator() }
	while #v > 0 do
		t[#t + 1] = v
		v = { iterator() }
	end
	return t
end
