local S = minetest.get_translator("travelnet")

minetest.register_on_mods_loaded(function()
	if travelnet.attach_priv == "travelnet_attach" then
		minetest.register_privilege("travelnet_attach", {
			description = S("allows to attach travelnet boxes to travelnets of other players"),
			give_to_singleplayer = false
		})
	elseif not minetest.registered_privileges[travelnet.attach_priv] then
		error("custom attach priv is not registered!")
	end

	if travelnet.remove_priv == "travelnet_remove" then
		minetest.register_privilege("travelnet_remove", {
			description = S("allows to dig travelnet boxes which belog to nets of other players"),
			give_to_singleplayer = false
		})
	elseif not minetest.registered_privileges[travelnet.remove_priv] then
		error("custom remove priv is not registered!")
	end
end)
