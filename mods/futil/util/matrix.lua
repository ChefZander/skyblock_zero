futil.matrix = {}

function futil.matrix.multiply(m1, m2)
	assert(#m1[1] == #m2, "width of first argument must be height of second")
	local product = {}
	for i = 1, #m1 do
		local row = {}
		for j = 1, #m2[1] do
			local value = 0
			for k = 1, #m2 do
				value = value + m1[i][k] * m2[k][j]
			end
			row[j] = value
		end
		product[i] = row
	end
	return product
end

function futil.matrix.transpose(m)
	local t = {}
	for i = 1, #m[1] do
		local row = {}
		for j = 1, #m do
			row[j] = m[j][i]
		end
		t[i] = row
	end
	return t
end
