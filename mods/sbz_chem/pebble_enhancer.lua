sbz_api.recipe.register_craft_type {
    type = 'pebble_enhancing',
    description = 'Enhancing',
    icon = 'pebble_enhancer_top.png',
    single = true,
}

sbz_api.recipe.register_craft {
    output = 'sbz_chem:enhanced_pebble',
    type = 'pebble_enhancing',
    items = {
        'sbz_resources:pebble',
    },
}

sbz_api.register_stateful_machine("sbz_chem:pebble_enhancer", {
    description = "Pebble Enhancer",
    info_extra = "Makes shiny, potentially radioactive pebbles.",
    tiles = {
        "pebble_enhancer_top.png",
        "pebble_enhancer_side.png"
    },
    groups = { matter = 1, weak_radioactive = 80 },

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("output", 16)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;output;3.5,0.5;4,4;]
list[context;input;1,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]listring[context;input]listring[current_player;main]listring[context;output]listring[current_player;main]
]])
    end,
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    info_power_consume = 128,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 128
        local inv = meta:get_inventory()

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        end

        local src = inv:get_list('input')
        local crafts, success, slot = sbz_api.recipe.resolve_craft_raw_single(src, 'pebble_enhancing', true)
        if not success then
            meta:set_string('infotext', 'Invalid/no recipe')
            return 0
        end

        local decremented_input = ItemStack(src[1])
        local outputs = {}

        for _, v in pairs(crafts) do
            if not v.chance or math.random() <= v.chance / 100 then
                outputs[#outputs + 1] = ItemStack(v.output)
            end
        end

        for k, v in ipairs(outputs) do
            if not inv:room_for_item('output', v) then
                meta:set_string('infotext', 'Full')
                -- undo previously added items
                for kk, vv in ipairs(outputs) do
                    if kk >= k then break end
                    inv:remove_item('output', vv)
                end
                return 0
            else
                inv:add_item('output', v)
            end
        end

        decremented_input:take_item(1)
        inv:set_stack('input', 1, decremented_input)
        meta:set_string("infotext", "Enhancing...")
        return power_needed
    end,
    input_inv = "input",
    output_inv = "output",
}, {
    tiles = {
        { name = "pebble_enhancer_top_on.png", animation = { type = "vertical_frames", length = 0.5 } },
        "pebble_enhancer_side.png"
    },
    light_source = 14,
})

do -- Pebble Enhancer recipe scope
    local Pebble_Enhancer = 'sbz_chem:pebble_enhancer_off'
    local UC = 'sbz_chem:uranium_crystal'
    local MB = 'sbz_resources:matter_blob'
    local PC = 'sbz_resources:phlogiston_circuit'
    local TC = 'sbz_chem:thorium_crystal'
    core.register_craft({
        output = Pebble_Enhancer,
        recipe = {
            { UC, UC, UC },
            { MB, PC, MB },
            { TC, TC, TC },
        }
    })
end
