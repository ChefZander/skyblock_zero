local function check_and_act_if_filled(pos, meta, storage_or_inv, pattern)
    local storage
    if type(storage_or_inv) == 'userdata' then
        local inv = storage_or_inv
        pattern = inv:get_list 'pattern'
        storage = inv:get_list 'storage'
    else
        storage = storage_or_inv
    end
    local filled = true

    for index = 1, #pattern do
        if storage[index]:get_count() ~= pattern[index]:get_count() then
            filled = false
            break
        end
    end
    if filled then meta:set_int('output_mode', 1) end
    return filled
end

local inv_cache = sbz_api.make_cache('pattern_storinator', 0, true)
local h = core.hash_node_position

core.register_node(
    'pipeworks:pattern_storinator',
    unifieddyes.def {
        description = 'Pattern Storinator',
        info_extra = '16 slots',
        groups = {
            tubedevice = 1,
            tubedevice_receiver = 1,
            matter = 1,
        },
        after_place_node = function(pos, placer)
            minetest.get_meta(pos):set_string('owner', placer:get_player_name())
            local node = minetest.get_node(pos)
            node.param2 = node.param2 + 1
            minetest.swap_node(pos, node)
            pipeworks.after_place(pos)
        end,
        after_dig_node = pipeworks.after_dig,
        paramtype2 = 'colorfacedir',
        paramtype = 'light',
        tiles = {
            { name = 'pattern_storinator_side.png^[transformFX', animation = { type = 'vertical_frames', length = 3 } },
            { name = 'pattern_storinator_side.png^[transformFX', animation = { type = 'vertical_frames', length = 3 } },
            'pattern_storinator_back.png',
            'pattern_storinator_back.png',
            { name = 'pattern_storinator_side.png', animation = { type = 'vertical_frames', length = 3 } },
            { name = 'pattern_storinator_side.png^[transformFX', animation = { type = 'vertical_frames', length = 3 } },
        },
        tube = {
            input_inventory = 'storage',
            insert_object = function(pos, _, stack, _) -- Optimized to be fast
                local cache = inv_cache.data[h(pos)] or {}
                if not cache.inv then
                    cache.meta = core.get_meta(pos)
                    cache.inv = cache.meta:get_inventory()
                end -- originally: 1.6%

                local meta, inv = cache.meta, cache.inv
                local can_insert = true

                if not cache.storage then
                    cache.storage = inv:get_list 'storage'
                    cache.pattern = inv:get_list 'pattern'
                end
                inv_cache.data[h(pos)] = cache
                local storage, pattern = cache.storage, cache.pattern

                if meta:get_int 'output_mode' == 1 then
                    local is_storage_empty = inv:is_empty 'storage'
                    if is_storage_empty == true then
                        meta:set_int('output_mode', 0)
                    else
                        can_insert = false
                    end
                end
                local stack_name = stack:get_name()
                local stack_count = stack:get_count()
                if can_insert then
                    local pattern_stack, storage_stack, storage_stack_count, pattern_stack_count
                    for index = 1, #pattern do
                        pattern_stack = pattern[index]
                        if pattern_stack:get_name() == stack_name then
                            storage_stack = storage[index]
                            storage_stack_count = storage_stack:get_count()
                            pattern_stack_count = pattern_stack:get_count()

                            if (storage_stack_count + stack_count) <= pattern_stack_count then
                                storage_stack:set_count(storage_stack_count + stack_count)
                                storage_stack:set_name(stack_name)
                                inv:set_stack('storage', index, storage_stack)
                                check_and_act_if_filled(pos, meta, storage, pattern)
                                return ItemStack()
                            elseif storage_stack_count < pattern_stack_count then
                                local diffcount = (storage_stack_count + stack_count) - pattern_stack_count
                                storage_stack:set_count(pattern_stack_count)
                                storage_stack:set_name(stack_name)
                                inv:set_stack('storage', index, storage_stack)
                                check_and_act_if_filled(pos, meta, storage, pattern)
                                storage_stack:set_count(diffcount)
                                return storage_stack
                            end
                        end
                        check_and_act_if_filled(pos, meta, storage, pattern)
                    end
                end
                return stack
            end,
            can_insert = function(pos, node, stack, direction)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()

                local storage = inv:get_list 'storage'
                local pattern = inv:get_list 'pattern'

                if meta:get_int 'output_mode' == 1 then
                    local is_storage_empty = true
                    for index = 1, #pattern do
                        local sstack = storage[index]
                        if not sstack:is_empty() then
                            is_storage_empty = false
                            break
                        end
                    end
                    if is_storage_empty == true then
                        meta:set_int('output_mode', 0)
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
                if meta:get_int 'output_mode' == 1 then return meta:get_inventory() end
                return nil -- explicit specifically so you KNOW its intentional
            end,
            before_filter = function(pos) -- remove the cache entry, makes stuff work:tm:
                inv_cache.data[h(pos)] = nil
            end,
        },
        on_construct = function(pos)
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            inv:set_size('storage', 16)
            inv:set_size('pattern', 16)

            meta:set_string(
                'formspec',
                string.format [[
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
            )
        end,
        allow_metadata_inventory_put = function(pos, listname, index, stack, player)
            if listname == 'main' then return stack:get_count() end -- case: player
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            if listname == 'pattern' then
                local stack_copy = ItemStack(stack) -- i saw this in item sorters soo, yeah im doing that too
                local stack_at_index = inv:get_stack('pattern', index)
                stack_at_index:add_item(stack_copy)
                inv:set_stack('pattern', index, stack_at_index)
                return 0
            elseif listname == 'storage' then
                local stack_copy = ItemStack(stack)
                local stack_at_index_storage = inv:get_stack('storage', index)
                local stack_at_index_pattern = inv:get_stack('pattern', index)
                stack_at_index_storage:add_item(stack_copy)
                if stack_at_index_storage:get_name() ~= stack_at_index_pattern:get_name() then return 0 end
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
            if listname == 'main' then return stack:get_count() end -- case: player
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            if listname == 'pattern' then
                local stack_copy = ItemStack(stack) -- i saw this in item sorters soo, yeah im doing that too
                local stack_at_index = inv:get_stack('pattern', index)
                stack_at_index:take_item(stack_copy:get_count())
                inv:set_stack('pattern', index, stack_at_index)
                return 0
            elseif listname == 'storage' then
                return stack:get_count()
            end
        end,
    }
)

core.register_craft {
    output = 'pipeworks:pattern_storinator',
    recipe = {
        { 'sbz_resources:emittrium_circuit', 'sbz_resources:emittrium_circuit', 'sbz_resources:emittrium_circuit' },
        { 'sbz_resources:storinator', 'sbz_resources:storinator', 'pipeworks:automatic_filter_injector' },
        { 'sbz_resources:emittrium_circuit', 'sbz_resources:emittrium_circuit', 'sbz_resources:emittrium_circuit' },
    },
}
