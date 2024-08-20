sbz_api.register_machine("sbz_power:phosphor_off", {
    description = "Phosphor",
    tiles = { "matter_blob.png^phosphor_overlay.png" },
    groups = { matter = 1, cracky = 3 },
    action = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "")
        if demand + 1 <= supply then
            minetest.set_node(pos, { name = "sbz_power:phosphor_on" })
            return 1
        end
        return 0
    end,
    control_action_raw = true
})

sbz_api.register_machine("sbz_power:phosphor_on", {
    description = "Phosphor",
    tiles = { "emitter_imitator.png^phosphor_overlay.png" },
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 2,
    groups = { matter = 1, cracky = 3, pipe_connects = 1, sbz_machine = 1, not_in_creative_inventory = 1, pipe_conducts = 1 },
    drop = "sbz_power:phosphor_off",
    action = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "")
        if demand + 1 <= supply then
            return 1
        else
            minetest.set_node(pos, { name = "sbz_power:phosphor_off" })
            return 0
        end
    end,
    control_action_raw = true,
    on_timeout = function (pos, node)
        minetest.set_node(pos, { name = "sbz_power:phosphor_off" })
    end
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_power:phosphor_on",
    recipe = { "sbz_resources:emitter_imitator", "sbz_resources:emittrium_circuit" }
})