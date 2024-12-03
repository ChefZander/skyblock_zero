-- adds info for sbz_power and sbz_pipeworks
core.register_on_mods_loaded(function()
    for k, v in pairs(core.registered_items) do
        local overrides = {}
        if v.type == "node" then
            local old_after_dig = v.after_dig_node or function(...) end
            overrides.after_dig_node = function(pos, oldnode, oldmetadata, digger)
                if oldmetadata.inventory then
                    -- i dont want duping with filter injectors
                    local input_list = v.input_inv or ""
                    local output_list = v.output_inv or ""
                    if input_list == output_list then output_list = "" end
                    local real_inp_list = oldmetadata.inventory[input_list]
                    local real_out_list = oldmetadata.inventory[output_list]
                    if real_inp_list then
                        for _, stack in pairs(real_inp_list) do
                            minetest.item_drop(stack, nil, pos)
                        end
                    end
                    if real_out_list then
                        for _, stack in pairs(real_out_list) do
                            minetest.item_drop(stack, nil, pos)
                        end
                    end
                end
                return old_after_dig(pos, oldnode, oldmetadata, digger)
            end
        end
        core.override_item(k, overrides)
    end
end)
