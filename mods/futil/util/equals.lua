local table_size = futil.table.size

local function equals(a, b)
	local t = type(a)

	if t ~= type(b) then
		return false
	end

	if t ~= "table" then
		return a == b
	elseif a == b then
		return true
	end

	local size_a = 0

	for key, value in pairs(a) do
		if not equals(value, b[key]) then
			return false
		end
		size_a = size_a + 1
	end

	return size_a == table_size(b)
end

futil.equals = equals
