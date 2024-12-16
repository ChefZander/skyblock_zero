function futil.coalesce(...)
	local arg = futil.table.pack(...)
	for i = 1, arg.n do
		local v = arg[i]
		if v ~= nil then
			return v
		end
	end
end
