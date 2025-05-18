-- "placer facing" = things like buttons
-- should have 2 nodes: a private variant, and a public variant
-- usually not machines, afterall they don't need to be
for _, variant in pairs { "public", "private" } do
    sbz_api.register_stateful("sbz_power:switch_" .. variant, unifieddyes.def {
        description = "Switch " .. "(" .. variant .. ")",
        tiles = {
            "lgate_base.png",
            "lgate_base.png",
            "lgate_base.png",
            "lgate_base.png",
            "lgate_base.png",
            "switch_" .. variant .. "_off.png",
        },
        paramtype2 = "colorfacedir",
        groups = {
            matter = 1,
            public = variant == "public" and 1 or 0,
        },
        on_rightclick = function(pos, node, clicker)
            if variant == "private" then
                if core.is_protected(pos, clicker:get_player_name()) then
                    return core.record_protection_violation(pos, clicker:get_player_name())
                end
            end
            local state = sbz_api.is_on(pos)
            if state then
                sbz_api.turn_off(pos)
            else
                sbz_api.turn_on(pos)
            end
        end
    }, {
        light_source = 14,
        tiles = {
            "lgate_base.png",
            "lgate_base.png",
            "lgate_base.png",
            "lgate_base.png",
            "lgate_base.png",
            "switch_" .. variant .. "_on.png",
        }
    })
end


core.register_craft {
    output = "sbz_power:switch_private_off",
    recipe = {
        { "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate",  "sbz_resources:sensor_casing_plate", },
        { "sbz_resources:sensor_casing_plate", "sbz_resources:simple_logic_circuit", "sbz_power:connector_off", },
        { "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate",  "sbz_resources:sensor_casing_plate", },
    }
}

core.register_craft {
    type = "shapeless",
    output = "sbz_power:switch_public_off",
    recipe = {
        "sbz_power:switch_private_off"
    }
}

core.register_craft {
    type = "shapeless",
    output = "sbz_power:switch_private_off",
    recipe = {
        "sbz_power:switch_public_off"
    }
}
