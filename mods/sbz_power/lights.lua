local cost = 4
sbz_api.register_stateful_machine("sbz_power:powered_lamp", {
    description = "Powered Lamp",
    tiles = { "power_lamp_off.png^[colorize:black:50" },
    light_source = 0,
    info_extra = "Really cheap lamp. Uses up 10 power.",
    autostate = true,
    action = function(_, _, meta, supply, demand)
        meta:set_string("infotext", "")
        if supply < (demand + cost) then
            return cost, false
        else
            return cost, true
        end
    end,
    groups = { matter = 1 }
}, {
    light_source = 14,
})

-- https://github.com/mt-mods/technic/blob/32f1d5a9e76a17b075259b0824db29730c9beb06/technic/machines/LV/lamp.lua#L15
-- i used that to help with the registration
minetest.register_node("sbz_power:funny_air", {
    description = "Funny air (YOU HACKER YOU!!!!)",
    info_extra =
    "You weren't technically supposed to obtain this but you can, if you have added some mod soup on top of this.",
    drawtype = "airlike",
    paramtype = "light",
    -- drops = "" -- nope, intentionally commented out hehehehe, technic did the same thing, i mean this isnt a mod soup so you probably wont be able to obtain it but like yea, heheheheehe
    light_source = 14,
    diggable = false,
    groups = { not_in_creative_inventory = 1, habitat_conducts = 1, explody = 10000 },
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    pointable = false,
    is_ground_content = true,
    air = true,
    air_equivalent = true, -- deprecated
})

local size = {
    x = 6, y = 6, z = 6
} -- so 12x12x12 cube around the thing

local function illuminate(pos)
    for x = -size.x, size.x do
        for y = -size.y, size.y do
            for z = -size.z, size.z do
                local ax, ay, az = pos.x + x, pos.y + y, pos.z + z

                local p = { x = ax, y = ay, z = az }
                local n = sbz_api.get_node_force(p)

                if n and n.name == "air" then
                    minetest.set_node(p, { name = "sbz_power:funny_air" })
                end
            end
        end
    end
end

local function undo_illuminate(pos)
    for x = -size.x, size.x do
        for y = -size.y, size.y do
            for z = -size.z, size.z do
                local ax, ay, az = pos.x + x, pos.y + y, pos.z + z

                local p = { x = ax, y = ay, z = az }
                local n = sbz_api.get_node_force(p)

                if n and n.name == "sbz_power:funny_air" then
                    minetest.set_node(p, { name = "air" })
                end
            end
        end
    end
end
sbz_api.register_stateful_machine("sbz_power:super_powered_lamp", {
    description = "Super Powered Lamp",
    tiles = { "super_power_lamp_off.png^[colorize:black:50" },
    light_source = 0,
    info_extra = "Lights up a 12x12x12 square around itself!",
    autostate = true,
    action = function(pos, _, meta, supply, demand)
        meta:set_string("infotext", "")
        if sbz_api.is_on(pos) then
            illuminate(pos)
        else
            undo_illuminate(pos)
        end
        meta:set_string("infotext", "")
        if supply < (demand + cost * 5) then
            return cost * 5, false
        else
            return cost * 5, true
        end
    end,
    on_turn_off = undo_illuminate,
    after_dig_node = undo_illuminate,
    groups = { matter = 1 }
}, {
    light_source = 14,
})

minetest.register_craft {
    output = "sbz_power:powered_lamp_off",
    recipe = {
        { "sbz_resources:emittrium_glass", "sbz_resources:simple_circuit", "sbz_resources:antimatter_dust" }
    }
}

minetest.register_craft {
    output = "sbz_power:super_powered_lamp_off",
    recipe = {
        { "sbz_chem:silicon_ingot",        "sbz_chem:silicon_ingot",          "sbz_chem:silicon_ingot" },
        { "sbz_resources:antimatter_blob", "sbz_resources:emittrium_circuit", "sbz_resources:antimatter_blob" },
        { "sbz_chem:silicon_ingot",        "sbz_chem:silicon_ingot",          "sbz_chem:silicon_ingot" }
    }
}
