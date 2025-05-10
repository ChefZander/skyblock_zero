--[[
16 slot storinator

16 slots for storage, 16 slots for pattern

Pattern = something that dictates how many items should be in each slot

Once the storinator has been filled (=> no things can enter it, all the patterns satisfied), it will:
- Dump: Dump the entire storinator's contents into one direction
- thats it for now :3

Just a tubedevice, not a machine
]]

local function check_and_act_if_filled(pos, meta, inv)
    local filled = true
    local storage = inv:get_list("storage")
    local pattern = inv:get_list("pattern")

    for index = 1, #pattern do
        if storage[index]:get_count() ~= pattern[index]:get_count() then
            filled = false
            break
        end
    end
    if filled then
        meta:set_int("output_mode", 1)
    end
    return filled
end

core.register_node("pipeworks:pattern_storinator", unifieddyes.def {
    description = "Pattern Storinator",
    info_extra = "16 slots",
    groups = {
        tubedevice = 1,
        tubedevice_receiver = 1,
        matter = 1,
    },
    after_place_node = function(pos, placer)
        minetest.get_meta(pos):set_string("owner", placer:get_player_name())
        local node = minetest.get_node(pos)
        node.param2 = node.param2 + 1
        minetest.swap_node(pos, node)
        pipeworks.after_place(pos)
    end,
    after_dig_node = pipeworks.after_dig,
    paramtype2 = "colorfacedir",
    paramtype = "light",
    tiles = {
        { name = "pattern_storinator_side.png^[transformFX", animation = { type = "vertical_frames", length = 3 } },
        { name = "pattern_storinator_side.png^[transformFX", animation = { type = "vertical_frames", length = 3 } },
        "pattern_storinator_back.png",
        "pattern_storinator_back.png",
        { name = "pattern_storinator_side.png",              animation = { type = "vertical_frames", length = 3 } },
        { name = "pattern_storinator_side.png^[transformFX", animation = { type = "vertical_frames", length = 3 } },
    },
    tube = {
        input_inventory = "storage",
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local can_insert = true
            local inv = meta:get_inventory()
            local storage = inv:get_list("storage")
            local pattern = inv:get_list("pattern")

            if meta:get_int("output_mode") == 1 then
                local is_storage_empty = true
                for index = 1, #pattern do
                    local sstack = storage[index]
                    if not sstack:is_empty() then
                        is_storage_empty = false
                        break
                    end
                end
                if is_storage_empty == true then
                    meta:set_int("output_mode", 0)
                else
                    can_insert = false
                end
            end

            if can_insert then
                for index = 1, #pattern do
                    if pattern[index]:get_name() == stack:get_name() then
                        local old_sstack = ItemStack(storage[index])
                        local new_sstack = storage[index]
                        local pattern_stack = pattern[index]
                        new_sstack:add_item(stack)
                        if new_sstack:get_count() <= pattern_stack:get_count() then
                            inv:set_stack("storage", index, new_sstack)
                            check_and_act_if_filled(pos, meta, inv)
                            return ItemStack()
                        elseif old_sstack:get_count() < pattern_stack:get_count() then
                            local diffcount = new_sstack:get_count() - pattern_stack:get_count()
                            local setstack = ItemStack(new_sstack)
                            setstack:take_item(diffcount)
                            inv:set_stack("storage", index, setstack)
                            check_and_act_if_filled(pos, meta, inv)
                            return new_sstack:peek_item(diffcount)
                        end
                    end
                end
            end
            return stack
        end,
        can_insert = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()

            local storage = inv:get_list("storage")
            local pattern = inv:get_list("pattern")

            if meta:get_int("output_mode") == 1 then
                local is_storage_empty = true
                for index = 1, #pattern do
                    local sstack = storage[index]
                    if not sstack:is_empty() then
                        is_storage_empty = false
                        break
                    end
                end
                if is_storage_empty == true then
                    meta:set_int("output_mode", 0)
                else
                    return false
                end
            end

            --            local oldstack = stack
            stack = stack:peek_item(1)

            if pattern then -- can be nil in really rare cases
                for index = 1, #pattern do
                    if pattern[index]:get_name() == stack:get_name() then
                        if storage[index]:get_count() + stack:get_count() <= pattern[index]:get_count() then
                            return true, pattern[index]:get_count() - storage[index]:get_count()
                        end
                    end
                end
            end
            return false
        end,
        connect_sides = { left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1 },
        return_input_invref = function(pos, node, dir, owner)
            local meta = core.get_meta(pos)
            if meta:get_int("output_mode") == 1 then
                return meta:get_inventory()
            end
            return nil -- explicit specifically so you KNOW its intentional
        end,
    },
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("storage", 16)
        inv:set_size("pattern", 16)

        meta:set_string("formspec",
            string.format([[
formspec_version[7]
size[8.6,10]
style_type[list;spacing=0.2;size=0.8]

hypertext[0.2,0.6;4.2,0.8;;<center>Storage</center>]
hypertext[4.2,0.6;4.2,0.8;;<center>Pattern</center>]

list[context;storage;0.2,1.2;4,4;]
list[context;pattern;4.6,1.2;4,4;]

style_type[list;spacing=0.2;size=.8]
list[current_player;main;0.2,6;8,4;]
listring[]
]]
            ))
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "main" then return stack:get_count() end -- case: player
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        if listname == "pattern" then
            local stack_copy = ItemStack(stack) -- i saw this in item sorters soo, yeah im doing that too
            local stack_at_index = inv:get_stack("pattern", index)
            stack_at_index:add_item(stack_copy)
            inv:set_stack("pattern", index, stack_at_index)
            return 0
        elseif listname == "storage" then
            local stack_copy = ItemStack(stack)
            local stack_at_index_storage = inv:get_stack("storage", index)
            local stack_at_index_pattern = inv:get_stack("pattern", index)
            stack_at_index_storage:add_item(stack_copy)
            if stack_at_index_storage:get_name() ~= stack_at_index_pattern:get_name() then
                return 0
            end
            if stack_at_index_storage:get_count() <= stack_at_index_pattern:get_count() then
                return stack:get_count()
            else
                local count_diff = stack_at_index_storage:get_count() - stack_at_index_pattern:get_count()
                return stack:get_count() - count_diff
            end
        end
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        check_and_act_if_filled(pos, meta, inv)
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if listname == "main" then return stack:get_count() end -- case: player
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        if listname == "pattern" then
            local stack_copy = ItemStack(stack) -- i saw this in item sorters soo, yeah im doing that too
            local stack_at_index = inv:get_stack("pattern", index)
            stack_at_index:take_item(stack_copy:get_count())
            inv:set_stack("pattern", index, stack_at_index)
            return 0
        elseif listname == "storage" then
            return stack:get_count()
        end
    end
})

core.register_craft {
    output = "pipeworks:pattern_storinator",
    recipe = {
        { "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit" },
        { "sbz_resources:storinator",        "sbz_resources:storinator",        "pipeworks:automatic_filter_injector" },
        { "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit" }
    }
}
