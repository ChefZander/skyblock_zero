local gametime
minetest.register_globalstep(function(dtime)
	if gametime then
		gametime = gametime + dtime
		return
	end
	gametime = assert(minetest.get_gametime())
	function modlib.minetest.get_gametime()
		local imprecise_gametime = minetest.get_gametime()
		if imprecise_gametime > gametime then
			minetest.log("warning", "modlib.minetest.get_gametime(): Called after increment and before first globalstep")
			return imprecise_gametime
		end
		return gametime
	end
end)