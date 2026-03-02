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

do -- Matter Sign recipe scope
    local Matter_Sign = 'sbz_decor:matter_sign'
    local AD = "sbz_resources:antimatter_dust"
    local MB = 'sbz_resources:matter_blob'
    core.register_craft({
        output = Matter_Sign,
        recipe = {
            { AD, AD, AD },
            { AD, MB, AD },
            { AD, AD, AD },
        }
    })
end

do -- Antimatter Sign recipe scope
    local Antimatter_Sign = 'sbz_decor:antimatter_sign'
    local MD = "sbz_resources:matter_dust"
    local AB = 'sbz_resources:antimatter_blob'
    core.register_craft({
        output = Antimatter_Sign,
        recipe = {
            { MD, MD, MD },
            { MD, AB, MD },
            { MD, MD, MD },
        }
    })
end
