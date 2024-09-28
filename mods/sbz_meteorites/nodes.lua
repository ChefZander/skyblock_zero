minetest.register_node("sbz_meteorites:meteoric_matter", {
    description = "Meteoric Matter",
    tiles = { "matter_blob.png^meteoric_overlay.png" },
    paramtype = "light",
    light_source = 10,
    groups = { matter = 1, cracky = 3 },
    drop = {
        max_items = 9,
        items = {
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 2,  items = { "sbz_resources:matter_dust" } },
            { rarity = 16, items = { "sbz_resources:matter_blob" } },
        }
    }
})

minetest.register_node("sbz_meteorites:meteoric_antimatter", {
    description = "Meteoric Antimatter",
    tiles = { "antimatter_blob.png^(meteoric_overlay.png^[invert:rgb)" },
    paramtype = "light",
    light_source = 12,
    groups = { antimatter = 1, cracky = 3 },
    drop = {
        max_items = 9,
        items = {
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2,  items = { "sbz_resources:antimatter_dust" } },
            { rarity = 16, items = { "sbz_resources:antimatter_blob" } },
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
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } },
            { rarity = 8, items = { "sbz_resources:raw_emittrium 2" } },
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
        items = processed_drops
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
