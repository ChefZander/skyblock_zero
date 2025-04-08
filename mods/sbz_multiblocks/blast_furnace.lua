-- controller, machine casing, furnace heaters
-- item I/O, power input

local ud = unifieddyes.def -- Why not!

-- contains storage
core.register_node("sbz_multiblocks:blast_furnace_controller", ud {
    description = "Blast Furnace Controller",
    groups = {
        matter = 1,
        multiblock_controller = 1,
    },
    paramtype2 = "color",
    tiles = {
        "blast_furnace_controller_top.png",
        "blast_furnace_controller_bottom.png",
        "blast_furnace_controller_sides.png",
    },
    light_source = 3,
})

core.register_node("sbz_multiblocks:blast_furnace_casing", ud {
    description = "Blast Furnace Casing",
    groups = {
        matter = 1,
    },
    drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "color",
    tiles = {
        "blast_furnace_casing_frame.png",
        "blast_furnace_casing_inner.png",
    },
    light_source = 3,
    wallmounted_rotate_vertical = true,
})

core.register_node("sbz_multiblocks:blast_furnace_heater", ud {
    description = "Blast Furnace Heater",
    heater_power_use = 5,
    info_power_needed = 5, -- they do not connect to cables directly
    groups = {
        matter = 1,
        explody = -100,
    },
    drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "color",
    tiles = {
        "blast_furnace_heater_frame.png",
        "blast_furnace_heater_inner.png",
    },
    --    overlay_tiles = {
    -- Hehe, whoever made the glasslike_framed drawtype certainly did NOT think of this use i can bet,
    --        "blast_furnace_heater_top.png",
    --},
    -- edit: does not work
    use_texture_alpha = "clip",
    light_source = 3,
    wallmounted_rotate_vertical = true,
})

sbz_api.register_machine("sbz_multiblocks:blast_furnace_power_port", ud {
    description = "Blast Furnace Power Port",
    groups = {
        matter = 1,
    },
    connect_sides = { "front" },
    paramtype = "light",
    paramtype2 = "colorwallmounted",
    tiles = {
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_front.png",
    },
    light_source = 3,
    action = function(...) return 0 end,
    wallmounted_rotate_vertical = true,
})

core.register_node("sbz_multiblocks:blast_furnace_item_input", ud {
    description = "Blast Furnace Item Input",
    groups = {
        matter = 1,
        tubedevice = 1,
        tubedevice_receiver = 1,
    },
    connect_sides = { "front" },
    paramtype = "light",
    paramtype2 = "colorwallmounted",
    tiles = {
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_input_front.png",
    },
    light_source = 3,
    disallow_pipeworks = true,
    tube = {
        connect_sides = { front = 1 },
        can_insert = function(pos, node, stack, direction)
            return false
        end,
        insert_object = function(pos, node, stack, direction)
            return stack
        end,
    },
    wallmounted_rotate_vertical = true,
})
core.register_node("sbz_multiblocks:blast_furnace_item_output", ud {
    description = "Blast Furnace Item Input",
    groups = {
        matter = 1,
        tubedevice = 1,
        tubedevice_receiver = 1,
    },
    connect_sides = { "front" },
    paramtype = "light",
    paramtype2 = "colorwallmounted",
    tiles = {
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_output_front.png",
    },
    light_source = 3,
    disallow_pipeworks = true,
    tube = {
        connect_sides = { front = 1 },
        can_insert = function(pos, node, stack, direction)
            return false
        end,
        insert_object = function(pos, node, stack, direction)
            return stack
        end,
        priority = -1,
    },
    wallmounted_rotate_vertical = true,
})

sbz_api.multiblocks.register_multiblock {
    name = "blast_furnace",
    desc = "Blast Furnace",
    wallsharing_allowed = {
        ["sbz_multiblocks:blast_furnace_casing"] = true,
    },
}
