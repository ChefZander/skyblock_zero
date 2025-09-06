sbz_api.recipe.register_craft_type {
    type = 'alloying',
    description = 'Alloying',
    icon = 'simple_alloy_furnace.png^[verticalframe:13:1',
    width = 2,
    height = 1,
    uses_crafting_grid = false,
    single = false,
}

sbz_api.recipe.register_craft {
    output = 'sbz_chem:bronze_powder',
    items = { 'sbz_chem:copper_powder', 'sbz_chem:tin_powder' },
    type = 'alloying',
}

sbz_api.recipe.register_craft {
    output = 'sbz_chem:invar_powder',
    items = { 'sbz_chem:iron_powder', 'sbz_chem:nickel_powder' },
    type = 'alloying',
}

sbz_api.recipe.register_craft {
    output = 'sbz_chem:titanium_alloy_powder',
    items = { 'sbz_chem:titanium_powder', 'sbz_chem:aluminum_powder' },
    type = 'alloying',
}

sbz_api.register_stateful_machine('sbz_chem:simple_alloy_furnace', {
    description = 'Simple Alloy Furnace',
    tiles = {
        'simple_alloy_furnace.png^[verticalframe:13:1',
    },
    groups = { matter = 1 },
    paramtype2 = 'facedir',

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size('input', 2)
        inv:set_size('output', 1)

        meta:set_string(
            'formspec',
            [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;output;3.5,3;1,1;]
list[context;input;3,1;2,1;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]
listring[context;input]
listring[current_player;main]
listring[context;output]
listring[current_player;main]
    ]]
        )
    end,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 10
        local inv = meta:get_inventory()

        -- the good old solution:tm:
        ---@type any, any, any
        local out, count, decremented, _ = sbz_api.recipe.resolve_craft(inv:get_list 'input', 'alloying', true)
        if out == nil then
            meta:set_string('infotext', 'Inactive')
            return 0
        end

        if demand + power_needed > supply then
            meta:set_string('infotext', 'Not enough power')
            return power_needed, false
        else
            if inv:room_for_item('output', out) then
                meta:set_string('infotext', 'Alloying')
                sbz_api.play_sfx('simple_alloy_furnace_running.ogg', { pos = pos })

                inv:add_item('output', out)
                for _, item in pairs(decremented) do
                    inv:remove_item('input', item)
                end
            else
                meta:set_string('infotext', 'Output inventory full')
                return 0
            end

            return power_needed
        end
    end,
    input_inv = 'input',
    output_inv = 'output',
}, {
    tiles = {
        { name = 'simple_alloy_furnace.png', animation = { type = 'vertical_frames', length = 0.7 } },
    },
    light_source = 3,
})

minetest.register_craft {
    output = 'sbz_chem:simple_alloy_furnace',
    recipe = {
        { 'sbz_chem:nickel_ingot', 'sbz_resources:antimatter_dust', 'sbz_chem:nickel_ingot' },
        { 'sbz_resources:matter_blob', 'sbz_resources:emittrium_circuit', 'sbz_resources:matter_blob' },
        { 'sbz_chem:nickel_ingot', 'sbz_resources:matter_blob', 'sbz_chem:nickel_ingot' },
    },
}
