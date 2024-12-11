function futil.wait(us)
	local wait_until = minetest.get_us_time() + us
	local get_us_time = minetest.get_us_time
	while get_us_time() < wait_until do
		-- the NOTHING function does nothing.
	end
end
