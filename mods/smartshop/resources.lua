smartshop.resources = {
	sounds = {},
	craft_materials = {},
}

if smartshop.has.default then
	-- luacheck: push globals default
	smartshop.resources.sounds.shop_sounds = default.node_sound_wood_defaults()
	smartshop.resources.sounds.storage_sounds = default.node_sound_wood_defaults()

	smartshop.resources.craft_materials = {
		chest_locked = "default:chest_locked",
		sign_wood = "default:sign_wall_wood",
		torch = "default:torch",
		mese_fragment = "default:mese_crystal_fragment",
		steel_ingot = "default:steel_ingot",
		copper_ingot = "default:copper_ingot",
	}
	-- luacheck: pop
end
