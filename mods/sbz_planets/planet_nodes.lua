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
    groups = { matter = 1, charged = 1 },
    sounds = sbz_api.sounds.matter(),
})

core.register_node("sbz_planets:basalt", {
    description = "Basalt",
    tiles = { { name = "basalt.png", } },
    groups = { matter = 1, charged = 1 },
    sounds = sbz_api.sounds.matter(),
})

core.register_node("sbz_planets:red_stone", {
    description = "Red Stone",
    tiles = { { name = "stone.png^[colorize:red:128", } },
    groups = { matter = 1, charged = 1 },
    sounds = sbz_api.sounds.matter(),
})

core.register_node("sbz_planets:granite", {
    description = "Granite",
    tiles = { { name = "granite.png", align_style = "world", scale = 2 } },
    groups = { matter = 1, charged = 1 },
    sounds = sbz_api.sounds.matter(),
})

core.register_node("sbz_planets:dead_core", {
    description = "Dead Core Piece",
    tiles = { "dead_core_piece.png" },
    groups = { matter = 1, charged = 1 },
    sounds = sbz_api.sounds.matter(),
    light_source = 14,
    damage_per_second = 20,
})
