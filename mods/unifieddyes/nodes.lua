minetest.register_craftitem('unifieddyes:colorium', {
    description = 'Colorium',
    inventory_image = 'colorium.png',
})

do -- Colorium recipe scope
    local Colorium = 'unifieddyes:colorium'
    local colorium_powder = 'unifieddyes:colorium_powder'
    core.register_craft({
        type = 'cooking',
        output = Colorium,
        recipe = colorium_powder,
    })
end

minetest.register_craftitem('unifieddyes:colorium_powder', {
    description = 'Colorium Powder',
    inventory_image = 'powder.png^[mask:colorium.png',
})

minetest.register_node(
    'unifieddyes:colorium_blob',
    unifieddyes.def {
        description = 'Colorium Blob',
        tiles = {
            'blank.png^[invert:rgba',
        },
        light_source = 14,
        info_extra = 'A pure white colorable node.',
        groups = { matter = 1, antimatter = 1, charged = 1 },
    }
)

local height = 2 / 16
local width = 6 / 16
local full = 1 / 2

local full_m_width = full - width
local full_m_height = -full + height
minetest.register_node(
    'unifieddyes:colorium_ground_line',
    unifieddyes.def {
        description = 'Colorium Ground Line',
        tiles = {
            'blank.png^[invert:rgba',
        },
        drawtype = 'nodebox',
        paramtype = 'light',
        sunlight_propagates = true,
        light_source = 14,
        info_extra = "It's a line on the ground",
        groups = { matter = 1, antimatter = 1, charged = 1 },
        connects_to = { 'unifieddyes:colorium_ground_line' },
        node_box = {
            type = 'connected',
            fixed = { -full_m_width, -full, -full_m_width, full_m_width, full_m_height, full_m_width },
            connect_top = { -full_m_width, -full, -full_m_width, full_m_width, full, full_m_width },
            connect_front = { -full_m_width, -full, -full, full_m_width, full_m_height, full_m_width },
            connect_back = { -full_m_width, -full, -full_m_width, full_m_width, full_m_height, full },
            connect_left = { -full, -full, -full_m_width, full_m_width, full_m_height, full_m_width },
            connect_right = { -full_m_width, -full, -full_m_width, full, full_m_height, full_m_width },
        },
    }
)

minetest.register_node(
    'unifieddyes:power_ground_line',
    unifieddyes.def {
        description = 'Power Ground Line',
        tiles = {
            {
                name = 'power_ground_line.png',
                animation = {
                    type = 'vertical_frames',
                    aspect_w = 16,
                    aspect_h = 16,
                    length = 2.0,
                },
            },
        },
        drawtype = 'nodebox',
        paramtype = 'light',
        sunlight_propagates = true,
        light_source = 14,
        info_extra = 'Conducts power.',
        groups = { matter = 1, antimatter = 1, charged = 1, pipe_conducts = 1 },
        connects_to = { 'unifieddyes:colorium_ground_line', 'unifieddyes:power_ground_line', 'group:pipe_connects' },
        connect_sides = { 'front', 'left', 'back', 'right' },
        node_box = {
            type = 'connected',
            fixed = { -full_m_width, -full, -full_m_width, full_m_width, full_m_height, full_m_width },
            connect_top = { -full_m_width, -full, -full_m_width, full_m_width, full, full_m_width },
            connect_front = { -full_m_width, -full, -full, full_m_width, full_m_height, full_m_width },
            connect_back = { -full_m_width, -full, -full_m_width, full_m_width, full_m_height, full },
            connect_left = { -full, -full, -full_m_width, full_m_width, full_m_height, full_m_width },
            connect_right = { -full_m_width, -full, -full_m_width, full, full_m_height, full_m_width },
        },
    }
)

do -- Power Ground Line recipe scope
    local Power_Ground_Line = 'unifieddyes:power_ground_line'
    local CG = 'unifieddyes:colorium_ground_line'
    local PP = 'sbz_power:power_pipe'
    core.register_craft({
        output = Power_Ground_Line,
        recipe = { { CG, PP } }
    })
end

core.register_node(
    'unifieddyes:antiblock',
    unifieddyes.def {
        description = 'Antiblock',
        tiles = {
            'blank.png',
        },
        drawtype = 'normal',
        paramtype = 'light',
        use_texture_alpha = 'clip',
        light_source = 14,
        info_extra = 'A what? Wait is this some sort of a joke...',
        groups = { matter = 3, antimatter = 1, charged = 1 },
    }
)

core.register_node(
    'unifieddyes:airlike_antiblock',
    unifieddyes.def {
        description = 'Airlike Antiblock',
        -- I tried to make it work without noclip but failed so ehh you get magic airlike antiblock that's not airlike and kinda lame
        overlay_tiles = {
            { name = 'blank.png', backface_culling = false },
        },
        tiles = {
            { name = 'blank.png', backface_culling = false },
        },
        drawtype = 'normal', -- ITS NOT AIRLIKE HAHAHAHAAHAH.... ok no thats not funny
        walkable = false, -- This is the thing thats important
        sunlight_propagates = true,
        paramtype = 'light',
        use_texture_alpha = 'blend',
        light_source = 14,
        info_extra = 'What???',
        post_effect_color = '#00000000',
        groups = { matter = 3, antimatter = 1, charged = 1 },
    }
)

do -- Colorium Blob recipe scope
    local Colorium_Blob = 'unifieddyes:colorium_blob'
    local Co = 'unifieddyes:colorium'
    core.register_craft({
        output = Colorium_Blob,
        recipe = {
            { Co, Co, Co },
            { Co, Co, Co },
            { Co, Co, Co },
        },
    })
end

do -- Colorium recipe scope
    local Colorium = 'unifieddyes:colorium'
    local amount = 9
    local CB = 'unifieddyes:colorium_blob'
    core.register_craft({
        type = 'shapeless',
        output = Colorium .. ' ' .. tostring(amount),
        recipe = { CB },
    })
end

do -- Antiblock recipe scope
    local Antiblock = 'unifieddyes:antiblock'
    local CB = 'unifieddyes:colorium_blob'
    local AD = 'sbz_resources:antimatter_dust'
    core.register_craft({
        type = 'shapeless',
        output = Antiblock,
        recipe = { CB, AD },
    })
end

do -- Airlike Antiblock recipe scope
    local Airlike_Antiblock = 'unifieddyes:airlike_antiblock'
    local An = 'unifieddyes:antiblock'
    core.register_craft({
        type = 'shapeless',
        output = Airlike_Antiblock,
        recipe = { An },
    })
end

do -- Colorium Ground Line recipe scope
    local Colorium_Ground_Line = 'unifieddyes:colorium_ground_line'
    local amount = 48
    local CB = 'unifieddyes:colorium_blob'
    core.register_craft({
        output = Colorium_Ground_Line .. ' ' .. tostring(amount),
        recipe = {
            { CB, CB, CB },
        },
    })
end

stairs.register('unifieddyes:colorium_blob')
