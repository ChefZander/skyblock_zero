--[[
    basically, to take out stuff:
    use filters and loop over the `tube.input_inventory`
    to put stuff:
    check tube.can_insert, then tube.insert_object
]]

local function transport_items_inner(pos, e) -- e=event
    -- defs
    local lcpos = pos
    local take_from = e.from
    local put_to = e.to
    local filters = e.filters or {}
    local direction = e.direction or vector.zero()

    -- CHECK EVERYTHING
    assert(type(take_from) == "table", "`from` must be table")
    assert(type(put_to) == "table", "`to` must be table")
    assert(type(filters) == "table", "`filters` must be table")

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
    assert(libox.type_vector(direction), "Invalid direction")

    local vel = setmetatable(table.copy(direction), {}) -- make it not be a vector
    vel.speed = 1

    -- THE STUFFFFFF
    local items = {}

    table.foreachi(take_from, function(v)
        -- i bet you WILL NOT LIKE this way of doing checks but it sure looks good, no?
        local node = sbz_api.get_node_force(v); if not node then return end
        local node_def = minetest.registered_nodes[node.name]; if not node_def then return end
        if not node_def.tube then return end
        local meta = minetest.get_meta(v)
        local inv = meta:get_inventory()
        local list = node_def.tube.input_inventory; if not list then return end
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
            local continue_filters = true
            table.foreachi(filters, function(filter)
                if not continue_filters then return end
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
                count = math.abs(count)
                local original_count = stack:get_count()
                if not filter.count_exact_match then
                    count = math.min(original_count, count)
                end

                if count > original_count then return end
                local taken = stack:take_item(count)

                items[#items + 1] = {
                    ndef = node_def,
                    taken_stack = taken,
                    listname = list,
                    inv = inv,
                    index = slot_index,
                    add_count = original_count - taken:get_count(),
                }
                continue_filters = false
            end, true)
            --
        end, true)
    end, true)

    -- great, now that we have all the items colected, we can transfer them

    local position_index = 1
    local cache = {}
    local hash = minetest.hash_node_position

    local take_out_and_put_to = function(
        put_pos, put_ndef, put_node, velocity, taken_stack, take_slot_index, take_inv, take_listname, add_count)
        if not put_ndef.tube then return end
        local can_insert = true
        local can_insert_f = put_ndef.tube.can_insert
        if can_insert_f then can_insert = can_insert_f(put_pos, put_node, taken_stack, velocity) end --else can_insert = true end
        if can_insert == false then return end
        local insert_object = put_ndef.tube.insert_object
        if insert_object == nil then return end -- no way to insert yknowww?
        local leftover = insert_object(put_pos, put_node, taken_stack, velocity)
        if not leftover:get_count() == 0 then
            taken_stack:replace(leftover)

            local set_stack = ItemStack(taken_stack)
            set_stack:set_count(set_stack:get_count() + add_count)
            take_inv:set_stack(take_listname, take_slot_index, set_stack)
        else
            local set_stack = ItemStack(taken_stack)
            set_stack:set_count(add_count)
            take_inv:set_stack(take_listname, take_slot_index, set_stack)
            taken_stack:replace(leftover)
            if taken_stack:get_count() == 0 then taken_stack:clear() end
        end
        -- ok... now set the taken stack in the inventory it came from
    end

    local iterations_max = 2000
    local iterations = 0
    while true do
        iterations = iterations + 1
        if iterations > iterations_max then
            return
        end -- everything is filled, cant do anything
        local put_pos = put_to[position_index]
        if put_pos == nil then
            position_index = 1
            put_pos = put_to[position_index]
        end
        if #items == 0 then
            return
        end -- COMPLETE!

        local target_item = items[#items]
        if target_item.taken_stack:is_empty() then
            while true do
                target_item = table.remove(items)
                if not target_item then return end
                if not target_item.taken_stack:is_empty() then break end
            end
        end
        if target_item == nil then
            return -- complete
        end

        if cache[hash(put_pos)] == nil then
            local node = core.get_node(put_pos)
            local node_def = minetest.registered_nodes[node.name]; if node_def == nil then
                error("Detected an unknown node");
                return
            end
            local inv = core.get_meta(put_pos):get_inventory()
            cache[hash(put_pos)] = {
                inv = inv,
                ndef = node_def,
                node = node
            }
        end

        local cache_hit = cache[hash(put_pos)]
        take_out_and_put_to(put_pos, cache_hit.ndef, cache_hit.node, vel, target_item.taken_stack, target_item.index,
            target_item.inv, target_item.listname, target_item.add_count)
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
