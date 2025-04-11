-- controller, machine casing, furnace heaters
-- item I/O, power input

local ud = unifieddyes.def -- Why not!

local function get_furnce_controller_formspec(pos)
    local meta = core.get_meta(pos)
    local connections = core.deserialize(meta:get_string("connections"))
    if not connections then
        local fs = string.format([[
formspec_version[7]
size[8,6]
button[0.5,0.5;3,1;form_multiblock;Form Multiblock]
button[4.5,0.5;3,1;show_ghosts;Show Build Plan]
label[0.5,2;Number of heater rows:]
scrollbaroptions[min=1;max=4;smallstep=1;largestep=4;arrows=default]
scrollbar[0.5,2.5;7,0.5;horizontal;num_of_heater_rows;%s]

label[1.6,3.3;1]
label[3.2,3.3;2]
label[4.7,3.3;3]
label[6.25,3.3;4]
    ]], math.max(1, meta:get_int("num_of_heater_rows")))
        if #meta:get_string("errmsg") ~= 0 then
            fs = fs ..
                string.format("textarea[0.5,4;8,2;;Error message when trying to form multiblock:;%s]",
                    meta:get_string("errmsg"))
        end
    else
        return [[
formspec_version[7]
size[10.2,12]
list[current_player;main;0.2,7;8,4;]

button[0.2,5.6;4,1;furnace_modes;Furnace Mode: Blast]
label[4.5,6.1;Heat: 10Cj]


list[current_player;main;4.2,2;1,1;]

image[3.2,2;1,1;furnace_plus.png;]
list[current_player;main;2.2,2;1,1;]

image[1.2,2;1,1;furnace_plus.png;]
list[current_player;main;0.2,2;1,1;]


image[5.8,2;1,1;furnace_arrow.png;]
list[current_player;main;7,1.5;2,2;]

]]
    end
end


local function form_multiblock(pos)

end

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
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", get_furnce_controller_formspec(pos))
    end
})

core.register_node("sbz_multiblocks:blast_furnace_casing", ud {
    description = "Blast Furnace Casing",
    groups = {
        matter = 1,
        can_wallshare = 1,
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
        multiblock_power_port = 1,
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
        multiblock_item_input = 1,
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
        multiblock_item_output = 1,
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
