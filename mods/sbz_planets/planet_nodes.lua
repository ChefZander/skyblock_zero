--[[
dead planets:
    Crust:
       - Red Sand - sbz_resources:red_sand - also nofall ver
       - Dark Sand - sbz_resources:dark_sand - also nofall ver
       - Black Sand - sbz_resources:black_sand - also nofall ver
       - Gravel - sbz_resources:gravel
       - Sand - sbz_resources:sand - also nofall ver
       - Marble - yup
       - Basalt - yup
       - Red Stone - yup
       - Granite - yup
       - Gravel - yup

       - Shape noise
       - Mountains - it's okay to use 3D noise for 2D things...
       - 1/10 chance of having rings
    Core:
       - Liquid Iron (flowing)
       - Liquid Nickel (flowing)
       - Dead Corium (not flowing..)
         - you can extract the dead orb with this, also other radioactive materials

Where liquid chemicals would be registered in sbz_chem
]]

-- sands
local function make_nofall(name)
    local new_name = "sbz_planets:" .. name:sub(name.find(name, ":") + 1, -1) .. "_nofall"
    local def = table.copy(core.registered_nodes[name])
    def.groups.falling_node = 0
    def.groups.not_in_creative_inventory = 1
    def.drop = name
    core.register_node(new_name, def)
end

make_nofall("sbz_resources:sand")
make_nofall("sbz_resources:red_sand")
make_nofall("sbz_resources:gravel")
make_nofall("sbz_resources:dark_sand")
make_nofall("sbz_resources:black_sand")
make_nofall("sbz_resources:white_sand")

core.register_node("sbz_planets:marble", unifieddyes.def {
    description = "Marble",
    tiles = { { name = "marble.png", scale = 2, align_style = "world" } },
    groups = { matter = 1, charged = 1, explody = 10 },
    sounds = sbz_api.sounds.matter(),
})
stairs.register("sbz_planets:marble")



core.register_node("sbz_planets:basalt", {
    description = "Basalt",
    tiles = { { name = "basalt.png", } },
    groups = { matter = 1, charged = 1, explody = 10, },
    sounds = sbz_api.sounds.matter(),
})
stairs.register("sbz_planets:basalt")

core.register_node("sbz_planets:red_stone", {
    description = "Red Stone",
    tiles = { { name = "red_stone.png", } },
    groups = { matter = 1, charged = 1, explody = 10 },
    sounds = sbz_api.sounds.matter(),
})
stairs.register("sbz_planets:red_stone")

core.register_node("sbz_planets:red_stone", {
    description = "Red Stone",
    tiles = { { name = "red_stone.png", } },
    groups = { matter = 1, charged = 1, explody = 10 },
    sounds = sbz_api.sounds.matter(),
})

core.register_node("sbz_planets:thorium_ore", {
    description = "Thorium Ore",
    tiles = { { name = "thorium_ore.png", } },
    groups = { matter = 1, charged = 1, explody = 10, silktouch = 1, level = 2, ore = 1, radioactive = 1 },
    sounds = sbz_api.sounds.matter(),
    drop = "sbz_chem:thorium_powder",

})
core.register_ore {
    ore_type = "scatter",
    ore = "sbz_planets:thorium_ore",
    wherein = "sbz_planets:red_stone",
    clust_scarcity = 12 ^ 3,
    clust_num_ores = 8,
    clust_size = 3,
    y_min = 2000,
}
core.register_node("sbz_planets:blue_stone", {
    description = "Blue Stone",
    tiles = { { name = "stone.png^[colorize:blue:128", } },
    groups = { matter = 1, charged = 1, explody = 10 },
    sounds = sbz_api.sounds.matter(),
})

core.register_node("sbz_planets:uranium_ore", {
    description = "Uranium Ore",
    tiles = { { name = "uranium_ore.png", } },
    groups = { matter = 1, charged = 1, explody = 10, silktouch = 1, level = 2, ore = 1, radioactive = 1 },
    sounds = sbz_api.sounds.matter(),
    drop = "sbz_chem:uranium_powder",
    light_source = 8,
})

core.register_ore {
    ore_type = "scatter",
    ore = "sbz_planets:uranium_ore",
    wherein = "sbz_planets:blue_stone",
    clust_scarcity = 12 ^ 3,
    clust_num_ores = 8,
    clust_size = 3,
    y_min = 2000,
}


stairs.register("sbz_planets:blue_stone")

core.register_node("sbz_planets:granite", {
    description = "Granite",
    tiles = { { name = "granite.png", align_style = "world", scale = 2 } },
    groups = { matter = 1, charged = 1, explody = 10 },
    sounds = sbz_api.sounds.matter(),
})
stairs.register("sbz_planets:granite")

core.register_node("sbz_planets:dead_core", {
    description = "Dead Core Piece",
    tiles = { "dead_core_piece.png" },
    groups = { matter = 1, charged = 1, explody = 1, level = 2 },
    sounds = sbz_api.sounds.matter(),
    light_source = 14,
    damage_per_second = 20,
})

-- ice planet:
-- +gravel

core.register_node("sbz_planets:ice", {
    description = "Ice",
    tiles = { "ice.png" },
    groups = { matter = 1, water = 1, charged = 1, slippery = 5, explody = 20 },
    sounds = sbz_api.sounds.ice(),
    light_source = 1,
})
stairs.register("sbz_planets:ice")

core.register_node("sbz_planets:ice_core", {
    description = "Ice Core Piece",
    tiles = { "ice_core_piece.png" },
    groups = { matter = 1, charged = 1, slippery = (2 ^ 15) - 1, explody = 10, level = 2 },
    sounds = sbz_api.sounds.ice(),
    light_source = core.LIGHT_MAX,
})



core.register_node("sbz_planets:snow", {
    description = "Snow",
    tiles = { "snow.png" },
    drawtype = "liquid",
    paramtype = "light",
    groups = { oddly_breakable_by_hand = 1, matter = 3, water = 1, charged = 1, explody = 100, },
    sounds = sbz_api.sounds.snow(),
    walkable = false,
    climbable = true,
    move_resistance = 1,
    post_effect_color = "#ffffff9f",
    sunlight_propagates = true,
    drowning = 0.5,
    liquid_alternative_flowing = "sbz_planets:snow_layer",
    liquid_alternative_source = "sbz_planets:snow"
})

stairs.register("sbz_planets:snow")

local snowbox = {
    type = "fixed",
    fixed = {
        -0.5, -0.5, -0.5, 0.5, -(5 / 16), 0.5
    },
}

core.register_node("sbz_planets:snow_layer", {
    description = "Snow layer",
    tiles = { "snow.png", "blank.png", "snow.png" },
    use_texture_alpha = "clip",
    drawtype = "nodebox",
    paramtype2 = "wallmounted",
    paramtype = "light",
    groups = { oddly_breakable_by_hand = 1, matter = 3, water = 1, charged = 1, explody = 1000, not_in_creative_inventory = 1, attached_node = 1, },
    sounds = sbz_api.sounds.snow(),
    node_box = snowbox,
    collision_box = snowbox,
    walkable = false,
    climbable = false,
    post_effect_color = "#ffffff9f",
    sunlight_propagates = true,
    drop = "sbz_planets:snowball"
})

core.register_craftitem("sbz_planets:snowball", {
    description = "Snowball",
    inventory_image = "snowball.png"
})

core.register_node("sbz_planets:colorium_core", {
    description = "Colorium Core Piece",
    tiles = { "blank.png^[invert:rgba" },
    groups = { matter = 1, charged = 1, slippery = (2 ^ 15) - 1, explody = 1, level = 2 },
    sounds = sbz_api.sounds.matter(),
    light_source = core.LIGHT_MAX,
})

local water_color = "#576ee180"

core.register_node("sbz_planets:water_source_nofall", {
    description = "Water Source-Like Product :D",
    drawtype = "liquid",
    tiles = {
        { name = "water.png", backface_culling = false },
        { name = "water.png", backface_culling = true }
    },
    inventory_image = (minetest.inventorycube "water.png") .. "^[colorize:blue:50",
    use_texture_alpha = "blend",
    groups = { liquid = 3, habitat_conducts = 1, transparent = 1, liquid_capturable = 0, water = 1 },
    post_effect_color = water_color,
    paramtype = "light",
    walkable = false,
    pointable = false,
    climbable = true,
    buildable_to = true,
    liquid_renewable = false,
    liquidtype = "none",
    liquid_viscosity = 1,
    drowning = 1,
})

core.register_node("sbz_planets:colorium_mapgen_sapling", {
    description = "Mapgen Sapling (i guess you just got an insant sapling lol)",
    -- drop = "",
    groups = { not_in_creative_inventory = 1 },
    drawtype = "allfaces",
    tiles = {
        { name = "colorium_sapling.png", backface_culling = false }
    },
    use_texture_alpha = "clip",
})

--[[
    THE FOLLOWING 2 FUNCTIONS and the moves string ARE FROM STELLUA
    https://github.com/theidealist101/stellua/blob/main/mods/stl_core/trees.lua#L4
    https://github.com/theidealist101/stellua/blob/main/mods/stl_core/trees.lua#L15

    They are licensed under GNU GPL v3.0

Stellua
Copyright (C) 2024 theidealist (theidealistmusic@gmail.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

These functions have been modified.
Anything else besides those functions is licensed normally.
]]

local MOVES = "FfffTTTABCDabcd++--&&^^//**"

--Create random axiom recursively
local max_depth = 4
local function make_axiom(rand, depth)
    depth = depth or 0
    if depth > max_depth then return "" end
    local out = {}
    for _ = 1, rand:next(4, 8) do
        local char = rand:next(-2, string.len(MOVES))
        if char <= 0 then
            out[#out + 1] = "[" .. make_axiom(rand, depth + 1) .. "]"
        else
            out[#out + 1] = string.sub(MOVES, char, char)
        end
    end
    return table.concat(out)
end

--Generate random L-system definition
local function make_treedef(rand)
    return {
        axiom = make_axiom(rand),
        rules_a = make_axiom(rand),
        rules_b = make_axiom(rand),
        rules_c = make_axiom(rand),
        rules_d = make_axiom(rand),
        trunk = "sbz_bio:colorium_tree",
        leaves = "sbz_bio:colorium_leaves",
        angle = rand:next(10, 50),
        iterations = rand:next(1, 6),
        random_level = rand:next(0, 3),
        trunk_type = ({ "single", "single", "single", "double", "crossed" })[rand:next(1, 5)],
        thin_branches = true,
        fruit_chance = 0,
        seed = rand:next(),
        tree_core = "sbz_bio:colorium_tree_core"
    }
end

--[[ things are licensed normally now... ]]

core.register_abm {
    label = "Colorium mapgen sapling",
    nodenames = { "sbz_planets:colorium_mapgen_sapling" },
    interval = 1,
    chance = 1,
    catch_up = false,
    action = function(pos, node, aoc, aocw)
        local planet = select(2, next(sbz_api.planets.area:get_areas_for_pos(pos, true, false)))
        if planet == nil then
            return core.remove_node(pos)
        end

        local center = (vector.subtract(planet.max, planet.min) / 2) + planet.min
        local angle = vector.dir_to_rotation(vector.normalize(vector.subtract(center, pos)))
        core.remove_node(pos)
        local dna = make_treedef(PcgRandom(math.random(-10000, 10000)))
        sbz_api.spawn_tree(pos, dna, "", angle)
    end
}
