minetest.register_node("sbz_meteorites:meteoric_matter", {
    description = "Meteoric Matter",
    tiles = { "matter_blob.png^meteoric_overlay.png" },
    paramtype = "light",
    light_source = 10,
    groups = { matter = 1, cracky = 3 },
    drop = {
        max_items = 9,
        items = {
<<<<<<< HEAD
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } }
=======
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=16, items={"sbz_resources:matter_blob"}},
>>>>>>> c534db112651f9a1e7fa63e6f00030634233eb95
        }
    }
})

minetest.register_node("sbz_meteorites:meteoric_antimatter", {
    description = "Meteoric Antimatter",
<<<<<<< HEAD
    tiles = { "antimatter_blob.png^(meteoric_overlay.png^[invert:rgb)" },
=======
    tiles = {"antimatter_blob.png^(meteoric_overlay.png^[invert:rgb)"},
>>>>>>> c534db112651f9a1e7fa63e6f00030634233eb95
    paramtype = "light",
    light_source = 12,
    groups = { antimatter = 1, cracky = 3 },
    drop = {
        max_items = 9,
        items = {
<<<<<<< HEAD
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } }
=======
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=2, items={"sbz_resources:antimatter_dust"}},
            {rarity=16, items={"sbz_resources:antimatter_blob"}},
>>>>>>> c534db112651f9a1e7fa63e6f00030634233eb95
        }
    }
})

minetest.register_node("sbz_meteorites:meteoric_emittrium", {
    description = "Meteoric Emittrium",
    tiles = { "emitter.png^meteoric_overlay.png" },
    paramtype = "light",
    light_source = 10,
    groups = { matter = 1, cracky = 3 },
    drop = {
        max_items = 9,
        items = {
<<<<<<< HEAD
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } }
=======
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=8, items={"sbz_resources:raw_emittrium 2"}},
>>>>>>> c534db112651f9a1e7fa63e6f00030634233eb95
        }
    }
})

local drops = sbz_api.crusher_drops
local processed_drops = {}

for k, v in ipairs(drops) do
    processed_drops[#processed_drops + 1] = {
        rarity = 16, items = { v }
    }
end

minetest.register_node("sbz_meteorites:meteoric_metal", {
    description = "Meteoric Metal",
    tiles = { "metal.png^meteoric_overlay.png" },
    paramtype = "light",
    light_source = 10,
    groups = { matter = 1, cracky = 3 },
    drop = {
        max_items = 9,
<<<<<<< HEAD
        items = processed_drops
=======
        items = {
            {rarity=16, items={"sbz_chem:gold_powder"}},
            {rarity=16, items={"sbz_chem:silver_powder"}},
            {rarity=16, items={"sbz_chem:iron_powder"}},
            {rarity=16, items={"sbz_chem:copper_powder"}},
            {rarity=16, items={"sbz_chem:aluminum_powder"}},
            {rarity=16, items={"sbz_chem:lead_powder"}},
            {rarity=16, items={"sbz_chem:zinc_powder"}},
            {rarity=16, items={"sbz_chem:tin_powder"}},
            {rarity=16, items={"sbz_chem:nickel_powder"}},
            {rarity=16, items={"sbz_chem:platinum_powder"}},
            {rarity=16, items={"sbz_chem:mercury_powder"}},
            {rarity=16, items={"sbz_chem:cobalt_powder"}},
            {rarity=16, items={"sbz_chem:titanium_powder"}},
            {rarity=16, items={"sbz_chem:magnesium_powder"}},
            {rarity=16, items={"sbz_chem:calcium_powder"}},
            {rarity=16, items={"sbz_chem:sodium_powder"}},
            {rarity=16, items={"sbz_chem:lithium_powder"}},
            {rarity=64, items={"sbz_chem:bronze_powder"}},
            {rarity=64, items={"sbz_chem:white_gold_powder"}},
            {rarity=64, items={"sbz_chem:invar_powder"}},
            {rarity=64, items={"sbz_chem:brass_powder"}},
            {rarity=64, items={"sbz_chem:titanium_alloy_powder"}},
        }
>>>>>>> c534db112651f9a1e7fa63e6f00030634233eb95
    }
})

minetest.register_node("sbz_meteorites:neutronium", {
    description = "Neutronium",
    tiles = { "neutronium.png" },
    paramtype = "light",
    light_source = 14,
    groups = { gravity = 300, matter = 1 }
})
minetest.register_node("sbz_meteorites:antineutronium", {
    description = "Antineutronium",
    tiles = { "antineutronium.png" },
    paramtype = "light",
    light_source = 10,
    groups = { antigravity = 300, antimatter = 1 }
})
