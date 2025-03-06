minetest.register_node("sbz_meteorites:meteoric_matter", {
    description = "Meteoric Matter",
    tiles = { "matter_blob.png^meteoric_overlay.png" },
    paramtype = "light",
    light_source = 10,
    groups = { matter = 1, cracky = 3 },
    drop = {
        max_items = 9,
        items = {
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } },
            { rarity = 2, items = { "sbz_resources:matter_dust" } }
        }
    },
    sounds = sbz_api.sounds.matter(),
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
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } },
            { rarity = 2, items = { "sbz_resources:antimatter_dust" } }
        }
    },
    sounds = sbz_api.sounds.antimatter(),
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
            { rarity = 2, items = { "sbz_resources:raw_emittrium" } }
        }
    },
    sounds = sbz_api.sounds.matter(),
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
    },
    sounds = sbz_api.sounds.matter(),
})

minetest.register_node("sbz_meteorites:neutronium", {
    description = "Neutronium",
    tiles = { "neutronium.png" },
    paramtype = "light",
    light_source = 4,
    groups = { gravity = 300, matter = 1, charged = 1, attraction = 256 },
    sounds = sbz_api.sounds.matter(),
})
minetest.register_node("sbz_meteorites:antineutronium", {
    description = "Antineutronium",
    tiles = { "neutronium.png^[invert:rgb" },
    paramtype = "light",
    light_source = 8,
    groups = { antigravity = 300, antimatter = 1, charged = 1, attraction = -256 },
    sounds = sbz_api.sounds.antimatter(),
})


local core_blob = "sbz_resources:compressed_core_dust"
minetest.register_craft {
    output = "sbz_meteorites:neutronium",
    recipe = {
        { core_blob, core_blob,                       core_blob },
        { core_blob, "sbz_meteorites:antineutronium", core_blob },
        { core_blob, core_blob,                       core_blob },
    }
}

minetest.register_craft {
    output = "sbz_meteorites:antineutronium",
    recipe = {
        { core_blob, core_blob,                   core_blob },
        { core_blob, "sbz_meteorites:neutronium", core_blob },
        { core_blob, core_blob,                   core_blob },
    }
}


-- clean meteorite stuff that isnt used
local meteorite_nodes = {
    "sbz_meteorites:meteoric_matter",
    "sbz_meteorites:meteoric_antimatter",
    "sbz_meteorites:meteoric_emittrium",
    "sbz_meteorites:meteoric_metal",
    "sbz_meteorites:neutronium",
    "sbz_meteorites:antineutronium",
}

minetest.register_abm({
    nodenames = meteorite_nodes,
    interval = 60,
    chance = 1,
    action = function(pos, node)
        local meta = minetest.get_meta(pos)
        local placed_at = meta:get_int("placed_at")
        if placed_at == 0 then
            meta:set_int("placed_at", os.time())
        elseif os.time() - placed_at >= 3600 then
            minetest.remove_node(pos)
        end
    end,
})
