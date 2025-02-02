assert(type(travelnet.get_travelnets) == "function", "old travelnet-api found, please update the travelnet mod")

jumpdrive.register_after_jump(function()
	if travelnet.save_data ~= nil then
		-- write data back to files
		travelnet.save_data()
	end
end)
