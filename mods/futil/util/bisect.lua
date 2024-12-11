futil.bisect = {}

function futil.bisect.right(t, x, low, high, key)
	low = low or 1
	high = high or #t + 1
	if key then
		while low < high do
			local mid = math.floor((low + high) / 2)
			if x < key(t[mid]) then
				high = mid
			else
				low = mid + 1
			end
		end
	else
		while low < high do
			local mid = math.floor((low + high) / 2)
			if x < t[mid] then
				high = mid
			else
				low = mid + 1
			end
		end
	end
	return low
end

function futil.bisect.left(t, x, low, high, key)
	low = low or 1
	high = high or #t + 1
	if key then
		while low < high do
			local mid = math.floor((low + high) / 2)
			if key(t[mid]) < x then
				low = mid + 1
			else
				high = mid
			end
		end
	else
		while low < high do
			local mid = math.floor((low + high) / 2)
			if t[mid] < x then
				low = mid + 1
			else
				high = mid
			end
		end
	end
	return low
end
