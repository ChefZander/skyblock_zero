-- Logic gates
-- they are stateful machines yeah

local function def(d)
    d.inventory_image = d.tiles[1]
    return unifieddyes.def(d)
end

local linking_range = 15
sbz_api.register_stateful_machine("sbz_power:lgate_not", def {
    description = "NOT gate",
    tiles = {
        "lgate_not_on.png^[invert:rgb",
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    action_subtick = function(pos, _, meta, supply, demand)
        meta:set_string("infotext", "")
        local links = core.deserialize(meta:get_string("links"))
        if not links then
            meta:set_string("infotext",
                "Needs to be connected with machine linker, make one link with the name \"A\"")
            return 0
        end

        if not links.A or (links.A and not links.A[1]) then
            meta:set_string("infotext", "Needs an \"A\" link.")
            return 0
        end

        local state = sbz_api.is_on(links.A[1])
        state = not state
        if state then
            sbz_api.turn_on(pos)
        else
            sbz_api.turn_off(pos)
        end
        return 0
    end,
    linking_range = linking_range,
}, {
    light_source = 14,
    tiles = {
        "lgate_not_on.png",
    }
})

local function lgate_action(func)
    return function(pos, _, meta, supply, demand)
        meta:set_string("infotext", "")
        local links = core.deserialize(meta:get_string("links"))
        if not links then
            meta:set_string("infotext",
                "Needs to be connected with machine linker, make one link with the name \"A\" and one link with the name \"B\"")
            return 0
        end
        if not links.A or (links.A and not links.A[1]) then
            meta:set_string("infotext", "Needs an \"A\" link.")
            return 0
        end
        if not links.B or (links.B and not links.B[1]) then
            meta:set_string("infotext", "Needs a \"B\" link.")
            return 0
        end
        local state1 = sbz_api.is_on(links.A[1])
        local state2 = sbz_api.is_on(links.B[1])

        local result = func(state1, state2)
        if result then
            sbz_api.turn_on(pos)
        else
            sbz_api.turn_off(pos)
        end
        return 0
    end
end

sbz_api.register_stateful_machine("sbz_power:lgate_or", def {
    description = "OR gate",
    tiles = {
        "lgate_or_on.png^[invert:rgb",
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = linking_range,
    action_subtick = lgate_action(function(x, y) return x or y end),
}, {
    light_source = 14,
    tiles = {
        "lgate_or_on.png",
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_nor", def {
    description = "NOR gate",
    tiles = {
        "lgate_nor_on.png^[invert:rgb",
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = linking_range,
    action_subtick = lgate_action(function(x, y) return not (x or y) end),
}, {
    light_source = 14,
    tiles = {
        "lgate_nor_on.png",
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_and", def {
    description = "AND gate",
    tiles = {
        "lgate_and_on.png^[invert:rgb",
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = linking_range,
    action_subtick = lgate_action(function(x, y) return x and y end),
}, {
    light_source = 14,
    tiles = {
        "lgate_and_on.png",
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_nand", def {
    description = "NAND gate",
    tiles = {
        "lgate_nand_on.png^[invert:rgb",
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = linking_range,
    action_subtick = lgate_action(function(x, y) return not (x and y) end),
}, {
    light_source = 14,
    tiles = {
        "lgate_nand_on.png",
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_xor", def {
    description = "XOR gate",
    tiles = {
        "lgate_xor_on.png^[invert:rgb",
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = linking_range,
    action_subtick = lgate_action(function(x, y) return x ~= y end),
}, {
    light_source = 14,
    tiles = {
        "lgate_xor_on.png",
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_xnor", def {
    description = "XNOR gate",
    tiles = {
        "lgate_xnor_on.png^[invert:rgb",
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = linking_range,
    action_subtick = lgate_action(function(x, y) return not (x ~= y) end),
}, {
    light_source = 14,
    tiles = {
        "lgate_xnor_on.png",
    }
})
