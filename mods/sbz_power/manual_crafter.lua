--- The manual crafter doesn't support replacing stacks in recipes

local notify = core.chat_send_player

-- configure_craft -> configure_craft_output
local function validate_craft(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()

    local configured_craft = inv:get_list 'configure_craft'
    local out = core.get_craft_result {
        items = table.copy(configured_craft),
        width = 3,
        method = 'normal',
    }
    inv:set_stack('configure_craft_output', 1, out.item)
end

-- configure_craft_output -> configure_craft
local function configure_from_craft_output(pos, user)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local new_craft_output = inv:get_stack('configure_craft_output', 1)
    local recipes = core.get_all_craft_recipes(new_craft_output:get_name())
    if recipes == nil then
        notify(user:get_player_name(), "That item doesn't have any recipes.")
        return false
    end

    local chosen_recipe
    for _, recipe in ipairs(recipes) do
        if recipe.method == 'normal' then
            chosen_recipe = recipe
            break
        end
    end

    if not chosen_recipe then
        notify(user:get_player_name(), "Couldn't find a crafting recipe for that item.")
        return false
    end

    inv:set_list('configure_craft', table.copy(chosen_recipe.items))
    -- notify(
    --     user:get_player_name(),
    --     'Successfully set recipe. Warning: Recipes that replace items in the crafting ui will simply waste that item instead. Use regular autocrafters for that.'
    -- )

    return true
end

-- sneak+punch -- craft maximum
-- aux1+punch -- craft 10
-- punch - craft 1
-- Do not use to implement some sort of autocrafter this may perform badly at scale
local function craft(user, meta)
    local control = user:get_player_control()
    local craft_amount = 1
    if control.aux1 then
        craft_amount = math.huge
    elseif control.sneak then
        craft_amount = 10
    end

    local crafter_inv = meta:get_inventory()
    local crafter_craft = crafter_inv:get_list 'configure_craft'
    local required_items = {}
    for i = 1, #crafter_craft do
        local name = crafter_craft[i]:get_name()
        if not crafter_craft[i]:is_empty() then required_items[name] = (required_items[name] or 0) + 1 end
    end

    local user_inv = user:get_inventory()
    local user_list = user_inv:get_list 'main'

    local items = {}
    for name, _ in pairs(required_items) do -- patch a funny loophole, where the for loop below that one below, and that one, won't run cuz items would be empty
        items[name] = 0
    end

    for i = 1, #user_list do
        local name = user_list[i]:get_name()
        if required_items[name] then items[name] = items[name] + user_list[i]:get_count() end
    end

    local craft_result = (crafter_inv:get_list 'configure_craft_output')[1]
    if craft_result:get_count() == 0 then return notify(user:get_player_name(), "Manual crafter isn't configured!") end
    local craft_result_max = craft_result:get_stack_max()

    -- how much can we craft?
    --   => How much resources can we remove?
    --   => How much can we fit? (In inventory before the crafting, slightly inconvenient for players i know)

    local can_craft = craft_amount
    for name, amount in pairs(items) do
        can_craft = math.min(can_craft, amount / required_items[name])
    end

    -- Since there isn't a great way to judge free space in a player's inventory
    -- i have to resort to this
    local max_space = 0
    for i = 1, #user_list do
        local stack = user_list[i]
        if stack:get_name() == craft_result:get_name() then
            local fspace = stack:get_free_space()
            max_space = max_space + fspace
        elseif stack:is_empty() then
            max_space = max_space + craft_result_max
        end
    end

    local items_crafted = can_craft * craft_result:get_count() -- the amount of items that gets crafted
    can_craft = math.floor(math.min(max_space, items_crafted) / craft_result:get_count())

    -- okay.. so we just craft
    for name, amount in pairs(required_items) do
        for i = 1, amount do
            user_inv:remove_item('main', name)
        end
    end

    if can_craft > 0 then
        items_crafted = can_craft * craft_result:get_count()
        local split_into = math.floor(items_crafted / craft_result_max)
        if split_into > 0 then
            for _ = 1, split_into do
                user_inv:add_item('main', craft_result:get_name() .. ' ' .. craft_result_max)
            end
        end

        local remaining = items_crafted - (split_into * craft_result_max)
        user_inv:add_item('main', craft_result:get_name() .. ' ' .. remaining)

        notify(
            user:get_player_name(),
            ('Crafted %s %s!'):format(craft_result:get_count() * can_craft, craft_result:get_name())
        )
    else
        notify(
            user:get_player_name(),
            ("Couldn't craft %s! (Not enough material or out of inventory space.)"):format(craft_result:get_name())
        )
    end
end

core.register_node('sbz_power:manual_crafter', {
    description = 'Manual Crafter',
    info_extra = 'May be faster than navigating the inventory. See questbook for controls.',
    tiles = { 'manual_crafter.png' },
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size('configure_craft', 3 * 3)
        inv:set_size('configure_craft_output', 1)
        meta:set_int('configured', 0)
        meta:set_string(
            'formspec',
            [[
                formspec_version[8]
                size[10.25,9.6]
                list[context;configure_craft;0.25,0.25;3,3]
                list[context;configure_craft_output;5.25,1.525;1,1]
                list[current_player;main;0.25,4.6;8,4]
                button[8,0.25;2,1;configure;Configure]
            ]]
        )
    end,
    groups = { matter = 2 },
    on_punch = function(pos, _, puncher, _, _)
        craft(puncher, core.get_meta(pos))
    end,

    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if from_list ~= to_list then return 0 end
        return count
    end,

    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        validate_craft(pos)
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == 'configure_craft' or listname == 'configure_craft_output' then
            local from_inv = core.get_meta(pos):get_inventory()
            stack:set_count(1)
            from_inv:set_stack(listname, index, stack)
            if listname == 'configure_craft_output' then
                configure_from_craft_output(pos, player)
            else
                validate_craft(pos)
            end
        end
        return 0
    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if listname == 'configure_craft' or listname == 'configure_craft_output' then
            local from_inv = core.get_meta(pos):get_inventory()
            from_inv:set_stack(listname, index, '')
            if listname == 'configure_craft_output' then
                from_inv:set_list('configure_craft', { '', '', '',
                                                       '', '', '',
                                                       '', '', '' })
            else
                validate_craft(pos)
            end
        end
        return 0
    end,
})

local blob = 'sbz_resources:matter_blob'
core.register_craft {
    type = 'shaped',
    output = 'sbz_power:manual_crafter',
    recipe = {
        { blob, blob, blob },
        { blob, 'sbz_resources:simple_circuit', blob },
        { blob, blob, blob },
    },
}
