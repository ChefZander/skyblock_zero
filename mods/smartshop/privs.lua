local S = core.get_translator(core.get_current_modname())

if not minetest.registered_privileges[smartshop.settings.admin_shop_priv] then
	minetest.register_privilege(smartshop.settings.admin_shop_priv, {
		description = S("Smartshop admin"),
		give_to_singleplayer = false,
		give_to_admin = false,
	})
end
