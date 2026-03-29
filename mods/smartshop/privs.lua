local S = core.get_translator(core.get_current_modname())

if not core.registered_privileges[smartshop.settings.admin_shop_priv] then
	core.register_privilege(smartshop.settings.admin_shop_priv, {
		description = S("Smartshop admin"),
		give_to_singleplayer = false,
		give_to_admin = false,
	})
end
