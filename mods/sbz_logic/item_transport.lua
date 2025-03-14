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

local function transport_items_inner(pos, e) -- e=event
    error("Temporarily disabled")
    -- defs
    local lcpos = pos
    local take_from = e.from
    local put_to = e.to
    local invlist_inputs = e.inv_list_inputs
    local invlist_outputs = e.inv_list_outputs
    local filters = e.filters
    -- CHECK EVERYTHING
    assert(type(take_from) == "table", "`from` must be table")
    assert(type(put_to) == "table", "`to` must be table")
    assert(type(filters) == "table", "`filters` must be table")
    assert(invlist_inputs == nil or type(invlist_inputs) == "string",
        "invlist_inputs can be nil or string, nothing else")
    assert(invlist_outputs == nil or type(invlist_outputs) == "string",
        "invlist_outputs can be nil or string, nothing else")

    if not filters[1] then
        filters = { [1] = filters }
    end
    table.foreach(filters, function(v) assert(libox.type("table")(v)) end, true)
    table.foreach(take_from, function(k, v)
        assert(libox.type_vector(v))
        take_from[k] = vector.add(lcpos, v)
    end)
    table.foreach(put_to, function(k, v)
        assert(libox.type_vector(v)); put_to[k] = vector.add(lcpos, v)
    end)
    assert(#filters < 20, "You may not have more than 20 filters")

    table.foreach(take_from,
        function(k, v) assert(logic.range_check(lcpos, v), "Node out of range, at key: " .. dump(k)) end)
    table.foreach(put_to,
        function(k, v) assert(logic.range_check(lcpos, v), "Node out of range, at key: " .. dump(k)) end)
    -- THE STUFFFFFF
    local items = {}

    table.foreachi(take_from, function(v)
        -- i bet you WILL NOT LIKE this way of doing checks but it sure looks good, no?
        local node = sbz_api.get_node_force(v); if not node then return end
        local node_def = minetest.registered_nodes[node.name]; if not node_def then return end
        local meta = minetest.get_meta(v)
        local inv = meta:get_inventory()
        local list = invlist_inputs or node_def.output_inv; if not list then return end
        local inv_list = inv:get_list(list); if inv_list == nil then return end
        -- great, now the fun begins
        -- "fun"
        -- O(blocks*items in block's inventory*filters)
        -- This is ran on each stack
        ---@param stack table
        table.foreach(inv_list, function(stack, slot_index)
            local stack_name = stack:get_name()

            if stack:is_empty() == true then return end
            if stack:is_known() == false then return end

            -- filtering
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
                        for _, group in ipairs(filter.groups) do -- ipairs only does array keys
                            assert(type(group) == "string",
                                "Individual group must be string if in format {\"group1\", \"group2\", ... ,\"groupn\"}")
                            if minetest.get_item_group(stack_name, group) == 0 then return end
                        end
                        for group, value in pairs(filter.groups) do -- does all keys
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

                items[#items + 1] = {
                    pos = v,
                    ndef = node_def,
                    taken_stack = taken,
                    inv_list = inv_list,
                    listname = list,
                    inv = inv,
                    index = slot_index,
                }
            end, true)
            --
        end, true)
    end, true)
    -- great, now that we have all the items colected, we can transfer them
    local fakeplayer = fakelib.create_player(minetest.get_meta(pos):get_string("owner"))
    local position_index = 1
    local cache = {}
    local hash = minetest.hash_node_position

    local take_out_and_put_to = function(
        take_pos, put_pos, put_ndef, take_ndef, taken_stack, take_slot_index, take_inv, put_inv, take_listname,
        put_listname, put_list
    )
        -- need to get put_slot_index
        local put_slot_index
        local put_stack = ItemStack(taken_stack)
        local taken_stack_name = taken_stack:get_name()
        for index, stack in ipairs(put_list) do
            if (stack:get_name() == taken_stack_name and stack:get_count() < stack:get_stack_max()) or stack:get_name() == "" then
                local compare_stack = ItemStack(stack); compare_stack:set_count(1)
                local copmare_stack2 = ItemStack(taken_stack); copmare_stack2:set_count(1)
                if compare_stack:equals(copmare_stack2) or stack:get_name() == "" then
                    put_slot_index = index
                    put_stack:set_count(math.min(taken_stack:get_count(), stack:get_stack_max() - stack:get_count()))
                end
            end
        end
        if put_slot_index == nil then return end
        -- TODO: call allow_metadata_inventory_put and allow_metadata_inventory_move
        fakeplayer:set_wielded_item(taken_stack)
        local allow_take = take_ndef.allow_metadata_inventory_take and
            take_ndef.allow_metadata_inventory_take(take_pos, take_listname, take_slot_index,
                ItemStack(put_stack), fakeplayer) or put_stack:get_count()
        allow_put = math.min(allow_take, put_stack:get_count())
        if allow_take == -1 then
            put_stack = ItemStack(taken_stack)
        else
            put_stack = taken_stack:take_item(allow_take)
        end

        local allow_put = put_ndef.allow_metadata_inventory_put and put_ndef.allow_metadata_inventory_put(put_pos,
            put_listname, put_slot_index, ItemStack(put_stack), fakeplayer) or put_stack:get_count()

        allow_put = math.min(allow_put, put_stack:get_count())
        if allow_put == -1 then -- inf items sure lol
            local add = put_stack:get_count()
            taken_stack:add_item(add)
        else
            local add = allow_put - put_stack:get_count()
            put_stack = put_stack:take_item(allow_take)
            taken_stack:add_item(add)
        end

        local set_stack = ItemStack(put_stack)
        set_stack:add_item(put_list[put_slot_index])
        put_inv:set_stack(put_listname, put_slot_index, set_stack)
        if put_ndef.on_metadata_inventory_put then
            put_ndef.on_metadata_inventory_put(put_pos, put_listname, put_slot_index, put_stack, fakeplayer)
        end
        local took_stack = take_inv:get_stack(take_listname, take_slot_index)
        took_stack:set_count(took_stack:get_count() - put_stack:get_count())

        take_inv:set_stack(take_listname, take_slot_index, taken_stack)
        if take_ndef.on_metadata_inventory_take then
            take_ndef.on_metadata_inventory_take(take_pos, take_listname, take_slot_index, ItemStack(took_stack),
                fakeplayer)
        end
    end

    local iterations_max = 200
    local iterations = 0
    while true do
        iterations = iterations + 1
        core.debug("iter: " .. iterations)
        if iterations > iterations_max then return end -- everything is filled, cant do anything
        local v = put_to[position_index]
        if v == nil then
            position_index = 1
            v = put_to[position_index]
        end
        if #items == 0 then return end -- COMPLETE!

        local target_item = items[#items]
        if target_item.taken_stack:is_empty() then
            target_item = table.remove(items)
        end

        if cache[hash(v)] == nil then
            local node = core.get_node(v)
            local node_def = minetest.registered_nodes[node.name]; if node_def == nil then return end
            local inv = core.get_meta(v):get_inventory()
            cache[hash(v)] = {
                inv = inv,
                ndef = node_def,
                listname = invlist_outputs or node_def.input_inv,
                list = inv:get_list(invlist_outputs or node_def.input_inv)
            }
        end

        local cache_hit = cache[hash(v)]
        local inv = cache_hit.inv
        local listname = cache_hit.listname
        local list = cache_hit.list
        if list == nil then return end

        take_out_and_put_to(target_item.pos, v, cache_hit.ndef, target_item.ndef, target_item.taken_stack,
            target_item.index,
            target_item.inv, inv, target_item.listname, listname, list)
        position_index = position_index + 1
    end
end

local function transport_items(pos, e)
    local ok, errmsg = pcall(transport_items_inner, pos, e)
    if not ok then
        sbz_api.logic.send_event_to_sandbox(pos, {
            type = "error",
            error_type = "yield_error",
            errmsg = errmsg,
        })
    end
end

return transport_items
