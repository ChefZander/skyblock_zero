local f = string.format

return function(version)
	local y, m, d, h, mi, s
	y, m, d = version:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
	if y and m and d then
		return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d) })
	end

	y, m, d, s = version:match("^(%d%d%d%d)-(%d%d)-(%d%d)[%.%s](%d+)$")
	if y and m and d and s then
		return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), sec = tonumber(s) })
	end

	y, m, d, h, mi, s = version:match("^(%d%d%d%d)-(%d%d)-(%d%d)[T ](%d%d):(%d%d):(%d%d)$")
	if y and m and d and h and mi and s then
		return os.time({
			year = tonumber(y),
			month = tonumber(m),
			day = tonumber(d),
			hour = tonumber(h),
			min = tonumber(mi),
			sec = tonumber(s),
		})
	end

	error(f("can't parse version %q", version))
end
