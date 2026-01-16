local function add_or_drop_item(user_inv, item, drop_pos)
    local leftover = user_inv:add_item('main', item)
    if leftover and not leftover:is_empty() then core.item_drop(leftover, nil, drop_pos) end
end

core.register_on_mods_loaded(function()
    for k, v in pairs(core.registered_items) do
        local overrides = {}
        if v.type == 'node' and v._after_dig_drop ~= false and v.groups and (v.groups.drawer or 0) == 0 then
            -- use _after_dig_drop in node defs, in cases like the CNC machine
            local old_after_dig = v.after_dig_node or function(...) end
            overrides.after_dig_node = function(pos, oldnode, oldmetadata, digger)
                if oldmetadata.inventory then
                    -- I don't want duping with pipeworks filter injectors, so any inventory that can't be used with them probably shouldn't be dumped to the ground
                    local input_list = v.input_inv or ''
                    local output_list = v.output_inv or ''
                    if input_list == output_list then output_list = '' end
                    local real_inp_list = oldmetadata.inventory[input_list]
                    local real_out_list = oldmetadata.inventory[output_list]
                    local user_inv = digger:get_inventory()
                    if real_inp_list then
                        for _, stack in pairs(real_inp_list) do
                            add_or_drop_item(user_inv, stack, pos)
                        end
                    end
                    if real_out_list then
                        for _, stack in pairs(real_out_list) do
                            add_or_drop_item(user_inv, stack, pos)
                        end
                    end
                end
                return old_after_dig(pos, oldnode, oldmetadata, digger)
            end
        end
        if v.groups and v.groups.eat then
            if not v.on_use then overrides.on_use = core.item_eat(v.groups.eat) end
        end
        core.override_item(k, overrides)
    end
end)
