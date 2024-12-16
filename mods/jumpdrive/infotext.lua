jumpdrive.update_infotext = function(meta)
	local store = meta:get_int("power")
	meta:set_string("infotext", "Store: " .. sbz_api.format_power(store, jumpdrive.config.powerstorage))
end
