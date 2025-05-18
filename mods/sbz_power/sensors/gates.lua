-- Logic gates
-- they are stateful machines yeah

local function def(d)
    d.inventory_image = d.tiles[1]
    return unifieddyes.def(d)
end

local linking_range = sbz_api.logic_gate_linking_range

local function simple_lgate_action(f)
    return function(pos, _, meta, supply, demand)
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
        state = f(state)
        if state then
            sbz_api.turn_on(pos)
        else
            sbz_api.turn_off(pos)
        end
        return 0
    end
end

local function make_tex_on(tex)
    return "(lgate_base.png^lgate_" .. tex .. ".png)"
end
local function make_tex_off(tex)
    return make_tex_on(tex) .. "^[hsl:0:0:-30"
end
sbz_api.register_stateful_machine("sbz_power:lgate_not", def {
    description = "NOT gate",
    tiles = {
        make_tex_off("not")
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    action_subtick = simple_lgate_action(function(x) return not x end),
    linking_range = linking_range,
}, {
    light_source = 14,
    tiles = {
        make_tex_on("not")
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_buffer", def {
    description = "Buffer gate",
    info_extra = "whats the use for this again...",
    tiles = {
        make_tex_off("buffer")
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    action_subtick = simple_lgate_action(function(x) return x end),
    linking_range = linking_range,
}, {
    light_source = 14,
    tiles = {
        make_tex_on("buffer")
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
        make_tex_off("or")
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
        make_tex_on("or")
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_nor", def {
    description = "NOR gate",
    tiles = {
        make_tex_off("nor")
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
        make_tex_on("nor")
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_and", def {
    description = "AND gate",
    tiles = {
        make_tex_off("and")
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
        make_tex_on("and")
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_nand", def {
    description = "NAND gate",
    tiles = {
        make_tex_off("nand")
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
        make_tex_on("nand")
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_xor", def {
    description = "XOR gate",
    tiles = {
        make_tex_off("xor")
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
        make_tex_on("xor")
    }
})

sbz_api.register_stateful_machine("sbz_power:lgate_xnor", def {
    description = "XNOR gate",
    tiles = {
        make_tex_off("xnor")
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
        make_tex_on("xnor")
    }
})

function sbz_api.make_sensor_tex_on(tex)
    return "(lgate_base.png^" .. tex .. ".png)"
end

function sbz_api.make_sensor_tex_off(tex)
    return sbz_api.make_sensor_tex_on(tex) .. "^[hsl:0:0:-30"
end

sbz_api.register_stateful_machine("sbz_power:machine_controller", unifieddyes.def {
    description = "Machine Controller",
    tiles = {
        sbz_api.make_sensor_tex_off("machine_controller")
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = linking_range,
    action_subtick = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "")
        local links = core.deserialize(meta:get_string("links"))
        if not links then
            meta:set_string("infotext",
                "Needs to be connected with machine linker, make one link with the name \"A\" and \"B\"")
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

        local state = sbz_api.is_on(links.A[1])
        for k, v in pairs(links.B) do
            local meta = core.get_meta(v)
            if state then
                sbz_api.force_turn_on(v, meta)
            else
                sbz_api.force_turn_off(v, meta)
            end
        end
        if state then
            sbz_api.turn_on(pos)
        else
            sbz_api.turn_off(pos)
        end
        return 0
    end,
}, {
    light_source = 14,
    tiles = {
        sbz_api.make_sensor_tex_on("machine_controller")
    }
})

-- ==RECIPES==
core.register_craft {
    output = "sbz_power:lgate_buffer_off",
    recipe = {
        { "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate",  "sbz_resources:sensor_casing_plate", },
        { "sbz_resources:sensor_casing_plate", "sbz_resources:simple_logic_circuit", "sbz_resources:sensor_casing_plate", },
        { "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate",  "sbz_resources:sensor_casing_plate", },
    },
}

local function register_inverted_craft(name1, name2)
    core.register_craft {
        type = "shapeless",
        output = name1,
        recipe = {
            name2, "sbz_resources:simple_inverted_logic_circuit"
        },
    }
    core.register_craft {
        type = "shapeless",
        output = name2,
        recipe = {
            name1, "sbz_resources:simple_inverted_logic_circuit"
        },
    }
end

-- Ok, now introducing: An elaborate multi-step process for crafting logic gates
-- People are going to hate me for this

register_inverted_craft("sbz_power:lgate_buffer_off", "sbz_power:lgate_not_off")
register_inverted_craft("sbz_power:lgate_and_off", "sbz_power:lgate_nand_off")
register_inverted_craft("sbz_power:lgate_or_off", "sbz_power:lgate_nor_off")
register_inverted_craft("sbz_power:lgate_xor_off", "sbz_power:lgate_xnor_off")

core.register_craft {
    type = "shapeless",
    output = "sbz_power:lgate_or_off 2",
    recipe = {
        "sbz_power:lgate_buffer_off", "sbz_power:lgate_buffer_off",
    }
}
core.register_craft {
    type = "shapeless",
    output = "sbz_power:lgate_and_off 2",
    recipe = {
        "sbz_power:lgate_buffer_off", "sbz_power:lgate_not_off"
    }
}

core.register_craft {
    type = "shapeless",
    output = "sbz_power:lgate_xor_off 2",
    recipe = {
        "sbz_power:lgate_or_off", "sbz_power:lgate_and_off"
    }
}

core.register_craft {
    output = "sbz_power:machine_controller",
    recipe = {
        { "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate", },
        { "sbz_resources:sensor_casing_plate", "sbz_power:connector_off",           "sbz_resources:sensor_casing_plate", },
        { "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate", },
    }
}
