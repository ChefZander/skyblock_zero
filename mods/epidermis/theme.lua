-- Texture-modifier created textures
epidermis.textures = {
	dice = "[inventorycube{epidermis_dice_1.png{epidermis_dice_2.png{epidermis_dice_3.png",
	upload = "epidermis_arrow_up.png^[multiply:#00C6FF",
	download = "epidermis_arrow_up.png^[multiply:#10C14E^[transformFY",
	back = "epidermis_arrow_up.png^[multiply:#FFC14E^[transformR90",
	previous = "epidermis_arrow_up.png^[multiply:green^[transformR90",
	next = "epidermis_arrow_up.png^[multiply:green^[transformR270",
}

epidermis.colors = modlib.table.map({
	error = 0xDC3545,
	warning = 0xF76300,
	info = 0x0DCAF0,
	success = 0x198754,
}, modlib.minetest.colorspec.from_number_rgb)