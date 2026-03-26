local S = core.get_translator(core.get_current_modname())

core.register_craftitem("sbz_resources:luanium", {
    description = S("Luanium"),
    info_extra = "No, not moon matter",
    inventory_image = "luanium.png",
    groups = { ui_logic = 1 }
})
core.register_craftitem("sbz_resources:lua_chip", {
    description = S("Lua Chip"),
    inventory_image = "luachip.png",
    groups = { ui_logic = 1 }
})
core.register_craftitem("sbz_resources:ram_stick_1mb", {
    description = S("Ram Stick"),
    inventory_image = "ram1mb.png",
    groups = { ui_logic = 1 }
})

core.register_alias("sbz_resources:ram_stick_1kb", "sbz_resources:ram_stick_1mb")
