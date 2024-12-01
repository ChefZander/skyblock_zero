signs_lib.register_sign("sbz_decor:antimatter_sign", {
    description = "Antimatter Sign",
    inventory_image = "[combine:32x32:0,0=antimatter_sign.png^[makealpha:0,0,0",
    tiles = {
        "antimatter_sign.png",
        "antimatter_sign_edges.png",
    },
    entity_info = "standard",
    groups = {
        matter = 1,
        antimatter = 1,
        explody = 5,
        sign_logic_compatible = 1,
        habitat_conducts = 1,
    },
    locked = true,

    allow_widefont = true,
    use_texture_alpha = "clip",
})

signs_lib.register_sign("sbz_decor:matter_sign", {
    description = "Matter Sign",
    inventory_image = "[combine:32x32:0,0=antimatter_sign.png^[makealpha:0,0,0^[invert:rgb",
    tiles = {
        "antimatter_sign.png^[invert:rgb",
        "antimatter_sign_edges.png^[invert:rgb",
    },
    entity_info = "standard",
    groups = {
        matter = 1,
        antimatter = 1,
        explody = 5,
        sign_logic_compatible = 1,
        habitat_conducts = 1,
    },
    locked = true,
    default_color = "f",

    allow_widefont = true,
    use_texture_alpha = "clip",
})

local A = "sbz_resources:antimatter_dust"
local M = "sbz_resources:matter_dust"

minetest.register_craft {
    output = "sbz_decor:matter_sign",
    recipe = {
        { A, A,                           A },
        { A, "sbz_resources:matter_blob", A },
        { A, A,                           A },
    }
}

minetest.register_craft {
    output = "sbz_decor:antimatter_sign",
    recipe = {
        { M, M,                               M },
        { M, "sbz_resources:antimatter_blob", M },
        { M, M,                               M },
    }
}
