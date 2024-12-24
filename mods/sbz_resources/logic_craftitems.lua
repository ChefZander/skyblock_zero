minetest.register_craftitem("sbz_resources:luanium", {
    description = "Luanium",
    info_extra = "No, not moon matter",
    inventory_image = "luanium.png",
    groups = { ui_logic = 1 }
})
minetest.register_craftitem("sbz_resources:lua_chip", {
    description = "Lua Chip",
    inventory_image = "luachip.png",
    groups = { ui_logic = 1 }
})
minetest.register_craftitem("sbz_resources:ram_stick_1mb", {
    description = "Ram Stick",
    inventory_image = "ram1mb.png",
    groups = { ui_logic = 1 }
})

minetest.register_alias("sbz_resources:ram_stick_1kb", "sbz_resources:ram_stick_1mb")
