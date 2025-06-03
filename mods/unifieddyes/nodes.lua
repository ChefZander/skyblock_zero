minetest.register_craftitem("unifieddyes:colorium", {
    description = "Colorium",
    inventory_image = "colorium.png",
})
minetest.register_craft {
    type = "cooking",
    output = "unifieddyes:colorium",
    recipe = "unifieddyes:colorium_powder",
}

minetest.register_craftitem("unifieddyes:colorium_powder", {
    description = "Colorium Powder",
    inventory_image = "powder.png^[mask:colorium.png",
})

minetest.register_node("unifieddyes:colorium_blob", unifieddyes.def {
    description = "Colorium Blob",
    tiles = {
        "blank.png^[invert:rgba"
    },
    light_source = 14,
    info_extra = "A pure white colorable node.",
    groups = { matter = 1, antimatter = 1, charged = 1 }
})

local height = 2 / 16
local width = 6 / 16
local full = 1 / 2

local full_m_width = full - width
local full_m_height = -full + height
minetest.register_node("unifieddyes:colorium_ground_line", unifieddyes.def {
    description = "Colorium Ground Line",
    tiles = {
        "blank.png^[invert:rgba",
    },
    drawtype = "nodebox",
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 14,
    info_extra = "It's a line on the ground",
    groups = { matter = 1, antimatter = 1, charged = 1, },
    connects_to = { "unifieddyes:colorium_ground_line" },
    node_box = {
        type = "connected",
        fixed = { -full_m_width, -full, -full_m_width, full_m_width, full_m_height, full_m_width },
        connect_top = { -full_m_width, -full, -full_m_width, full_m_width, full, full_m_width },
        connect_front = { -full_m_width, -full, -full, full_m_width, full_m_height, full_m_width },
        connect_back = { -full_m_width, -full, -full_m_width, full_m_width, full_m_height, full },
        connect_left = { -full, -full, -full_m_width, full_m_width, full_m_height, full_m_width },
        connect_right = { -full_m_width, -full, -full_m_width, full, full_m_height, full_m_width },
    },
})

core.register_node("unifieddyes:antiblock", unifieddyes.def {
    description = "Antiblock",
    tiles = {
        "blank.png"
    },
    drawtype = "normal",
    paramtype = "light",
    use_texture_alpha = "clip",
    light_source = 14,
    info_extra = "A what? Wait is this some sort of a joke...",
    groups = { matter = 3, antimatter = 1, charged = 1 },
})

core.register_node("unifieddyes:airlike_antiblock", unifieddyes.def {
    description = "Airlike Antiblock",
    tiles = {
        "blank.png"
    },
    drawtype = "normal", -- ITS NOT AIRLIKE HAHAHAHAAHAH.... ok no thats not funny
    walkable = false,    -- This is the thing thats important
    paramtype = "light",
    use_texture_alpha = "clip",
    light_source = 14,
    info_extra = "What???",
    groups = { matter = 3, antimatter = 1, charged = 1 },
})

minetest.register_craft {
    output = "unifieddyes:colorium_blob",
    recipe = {
        { "unifieddyes:colorium", "unifieddyes:colorium", "unifieddyes:colorium", },
        { "unifieddyes:colorium", "unifieddyes:colorium", "unifieddyes:colorium", },
        { "unifieddyes:colorium", "unifieddyes:colorium", "unifieddyes:colorium", },
    }
}

core.register_craft {
    type = "shapeless",
    output = "unifieddyes:antiblock",
    recipe = { "unifieddyes:colorium_blob", "sbz_resources:antimatter_dust" }
}

core.register_craft {
    type = "shapeless",
    output = "unifieddyes:airlike_antiblock",
    recipe = { "unifieddyes:antiblock" }
}

core.register_craft {
    output = "unifieddyes:colorium_ground_line 48",
    recipe = {
        { "unifieddyes:colorium_blob", "unifieddyes:colorium_blob", "unifieddyes:colorium_blob" }
    }
}

stairs.register("unifieddyes:colorium_blob")
