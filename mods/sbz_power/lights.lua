local cost = 1
sbz_api.register_stateful_machine("sbz_power:powered_lamp", {
    description = "Powered Lamp",
    tiles = { "power_lamp_off.png^[colorize:black:50" },
    light_source = 0,
    info_extra = "Really cheap lamp.",
    info_power_needed = cost,
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
    groups = { not_in_creative_inventory = 1, habitat_conducts = 1, explody = 10000, airlike = 1 },
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    pointable = false,
    is_ground_content = true,
    air = true,
    air_equivalent = true, -- deprecated
    floodable = true,
})

local size = {
    x = 6, y = 6, z = 6
}
-- so 12x12x12 cube around the thing

local c_funny_air = core.get_content_id("sbz_power:funny_air") -- we goin low level! (i havent used this function since mapgen...)
local c_air = core.get_content_id("air")
local data = {}
local function illuminate(pos)
    local smax, smin = vector.add(pos, size), vector.subtract(pos, size)
    local manip = VoxelManip(smin, smax)
    local pmin, pmax = manip:get_emerged_area()
    local area = VoxelArea(pmin, pmax)
    manip:get_data(data)
    local dirty = false -- "dirty" optimization borrowed from mt-mods/technic lv lamps
    for i in area:iterp(smin, smax) do
        if data[i] == c_air then
            dirty = true
            data[i] = c_funny_air
        end
    end
    if dirty then
        manip:set_data(data)
        manip:write_to_map(true)
    end
end

local function undo_illuminate(pos)
    local smax, smin = vector.add(pos, size), vector.subtract(pos, size)
    local manip = VoxelManip(smin, smax)
    local pmin, pmax = manip:get_emerged_area()
    local area = VoxelArea(pmin, pmax)
    manip:get_data(data)
    local dirty = false
    for i in area:iterp(smin, smax) do
        if data[i] == c_funny_air then
            dirty = true
            data[i] = c_air
        end
    end
    if dirty then
        manip:set_data(data)
        manip:write_to_map(true)
    end
end

sbz_api.register_stateful_machine("sbz_power:super_powered_lamp", {
    description = "Super Powered Lamp",
    tiles = { "super_power_lamp_off.png^[colorize:black:50" },
    light_source = 0,
    info_extra = "Lights up a 13x13x13 square around itself!",
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
