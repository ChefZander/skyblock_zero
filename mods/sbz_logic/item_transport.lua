--[[

    one_filter = { -- all values are optional, if all are empty, it dumps everything
        name = "a", -- if missing, it doesn't care about the name

        -- if missing, won't care about groups
        -- if it's a string[], it just has to have one group in the list
        -- if it's a { group = int }, it has to exactly match that
        groups = string | string[] | table<string,integer> ,

        count = 0, -- if missing, assumes max stack size
        slot_index = 3, -- if missing, tries to find the slot
        wear = 0,
        count_exact_match = false,
    }

    filter = one_filter[] | one_filter

    Also, by the code, this should immiadedly be obvious that it is a horrible idea to grab items from a infinite storinator with this, lol
]]

local function get_take_from(pos)
    return function(pos_array, filters, inventory_list)
        assert(type(pos_array) == "table")
        assert(type(filters) == "table")
        assert(type(inventory_list) == "string" or inventory_list == nil)
        table.foreach(pos_array, function(v) assert(libox.type_vector(v)) end, true)
        if not filters[1] then
            filters = { [1] = filters }
        end
        table.foreach(filters, function(v) assert(libox.type("table")(v)) end, true)
        assert(#filters < 20, "You may not have more than 20 filters")

        for k, v in pairs(pos_array) do
            pos_array[k] = vector.add(pos, v)
            assert(logic.range_check(pos, pos_array[k]),
                ("Position %s at index %s is out of range"):format(vector.to_string(pos_array[k]), k))
        end

        local items = {}
        table.foreachi(pos_array, function(v)
            local node = core.get_node(v)
            if not node then return end
            local node_def = minetest.registered_nodes[node.name]
            if not node_def then return end
            local meta = minetest.get_meta(v)
            local inv = meta:get_inventory()
            local list = inventory_list or node_def.output_inv
            if not list then return end
            local inv_list = inv:get_list(list)
            if inv_list == nil then return end

            -- great, now the fun begins
            -- "fun"
            -- O(blocks*items in block's inventory*filters)
            -- basically a nightmare for the luacontroller
            -- This is ran on each stack
            ---@param stack table
            table.foreach(inv_list, function(stack, slot_index)
                local stack_name = stack:get_name()

                if stack:is_empty() == true then return end
                if stack:is_known() == false then return end

                ---@param filter table
                table.foreachi(filters, function(filter)
                    if filter.slot_index then
                        if slot_index ~= filter.slot_index then return end
                    end

                    if filter.name then
                        if stack_name ~= filter.name then return end
                    end

                    if filter.groups then
                        if type(filter.groups) == "string" then
                            if minetest.get_item_group(stack_name, filter.groups) == 0 then return end
                        elseif type(filter.groups) == "table" then
                            for _, group in ipairs(filter.groups) do
                                assert(type(group) == "string",
                                    "Group must be string if in format {\"group1\", \"group2\", ... ,\"groupn\"}")
                                if minetest.get_item_group(stack_name, group) == 0 then return end
                            end
                            for group, value in pairs(filter.groups) do
                                if type(group) == "string" then
                                    assert(type(value) == "number",
                                        "Value must be a number if groups are in format of {['group_1'] = 3, ['group_n'] = 5}")
                                    if minetest.get_item_group(stack_name, group) ~= value then return end
                                end
                            end
                        end
                    end

                    if filter.wear then
                        if stack:get_wear() ~= filter.wear then return end
                    end

                    -- ok, filters passed
                    local count = filter.count or stack:get_stack_max()
                    if not filter.count_exact_match then
                        count = math.min(stack:get_count(), count)
                    end
                    if count > stack:get_count() then return end

                    local taken = stack:take_item(count)
                    -- re-uses the fakeplayer
                    local take_out_and_put_to = function(fakeplayer, other_inv, other_inventory_list)
                        local inventory_take = node_def.allow_metadata_inventory_take

                        if not node_def.allow_metadata_inventory_put_was_nop then
                            return taken
                        end

                        fakeplayer:set_wielded_item(taken)
                        local amount_allowed = inventory_take(v, inv_list, slot_index, taken, fakeplayer)
                        node_def.on_metadata_inventory_put(v, inv_list, slot_index, taken, fakeplayer)

                        local stack_to_put
                        if stack_to_put == -1 then
                            stack_to_put = ItemStack(taken)
                        else
                            stack_to_put = taken:take_item(amount_allowed)
                        end

                        local leftover = other_inv:add_item(other_inventory_list, stack_to_put)

                        if leftover and stack_to_put ~= -1 then
                            taken:add_item(leftover)
                        end

                        -- issue: the user can just hold the stack, and yea inv:remove_item doesnt like
                        -- basically, you can take out the items before they get removed

                        if stack_to_put ~= -1 then
                            inv:set_stack(list, slot_index, taken)
                        end
                        -- resulting stack is the stack left
                        return taken
                    end

                    items[#items + 1] = {
                        taken, take_out_and_put_to
                    }
                end, true)
                --
            end, true)
        end, true)


        local return_metatable = {
            is_item_handle = true,
            filters = filters,

            items = items,
            __newindex = {},
            __index = {},
            __tostring = function() return "a handle :D, its a table with a funny metatable under the hood" end
        }

        return setmetatable({}, return_metatable)
    end
end

--- Puts the items in the handle into the pos_array, if there isn't an inventory list specified, it will just insert it as if pipeworks did it
local function get_put_to(pos)
    return function(pos_array, handle, inventory_list)
        assert(type(handle) == "table")
        local handle_meta = getmetatable(handle)
        assert(handle_meta.is_item_handle, "Not a handle")

        assert(type(pos_array) == "table")
        assert(type(inventory_list) == "string" or inventory_list == nil)

        table.foreach(pos_array, function(v) assert(libox.type_vector(v)) end, true)

        for k, v in pairs(pos_array) do
            pos_array[k] = vector.add(pos, v)
            assert(logic.range_check(pos, pos_array[k]), ("Position at index %s is out of range"):format(k))
        end

        local items = handle_meta.items
        local fakeplayer = fakelib.create_player(minetest.get_meta(pos):get_string("owner"))

        -- by default, tries to distribute all the items evenly accross containers
        -- and thats the only like default yea


        local position_index = 1
        local cache = {}
        local hash = minetest.hash_node_position

        while true do
            local v = pos_array[position_index]
            if v == nil then
                position_index = 1
                v = pos_array[position_index]
            end
            if #items == 0 then return end
            local target_item = items[#items]
            if target_item[1]:is_empty() then
                target_item = table.remove(items)
            end


            if cache[hash(v)] == nil then
                local node = core.get_node(v)
                local node_def = minetest.registered_nodes[node.name]
                if node_def == nil then return end
                local inv = core.get_meta(v):get_inventory()
                cache[hash(v)] = {
                    node_def = node_def,
                    inv = inv
                }
            end
            local cache_hit = cache[hash(v)]
            local node_def, inv = cache_hit.node_def, cache_hit.inv

            local inventory_list_to_use = inventory_list or node_def.input_inv
            local list = inv:get_list(inventory_list_to_use)
            if list == nil then return end

            target_item[2](fakeplayer, inv, inventory_list_to_use)
            position_index = position_index + 1
        end
    end
end

local function transport_items(original_pos, t)
    -- the reason its like this is because it was made for luacs but yea its better as a yield thing
    local ok, errmsg = pcall(function()
        local handle = get_take_from(original_pos)(table.copy(t.from), t.filters, t.inv_list_inputs)
        get_put_to(original_pos)(table.copy(t.to), handle, t.inv_list_outputs)
    end)
    if errmsg then minetest.log(dump(errmsg)) end
end


return transport_items --, get_take_from, get_put_to
