
function fakelib.is_vector(x, add_metatable)
	if type(x) ~= "table" or type(x.x) ~= "number" or type(x.y) ~= "number" or type(x.z) ~= "number" then
		return false
	end
	if add_metatable and getmetatable(x) ~= vector.metatable then
		setmetatable(x, vector.metatable)
	end
	return true
end
