local nop1 = function(pos, from_list, from_index, to_list, to_index, count, player)
    return count
end
local nop2 = function(pos, listname, index, stack, player)
    return stack:get_count()
end

local function prot(pos, player)
    if minetest.check_player_privs(player:get_player_name(), "protection_bypass") then
        return false
    elseif minetest.is_protected(pos, player:get_player_name()) then
        minetest.record_protection_violation(pos, player:get_player_name())
        return true
    end
    return false
end

minetest.register_on_mods_loaded(function()
    for k, v in pairs(minetest.registered_nodes) do
        if minetest.get_item_group(k, "public") < 1 then
            local move, put, take, receive_fields = v.allow_metadata_inventory_move or nop1,
                v.allow_metadata_inventory_put or nop2,
                v.allow_metadata_inventory_take or nop2, v.on_receive_fields or function(...) end

            local is_put_nop = v.allow_metadata_inventory_put == nil
            minetest.override_item(k, {
                allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
                    if prot(pos, player) then
                        return 0
                    else
                        return move(pos, from_list, from_index, to_list, to_index, count, player)
                    end
                end,
                allow_metadata_inventory_put = function(pos, listname, index, stack, player)
                    if prot(pos, player) then
                        return 0
                    else
                        return put(pos, listname, index, stack, player)
                    end
                end,
                allow_metadata_inventory_put_was_nop = is_put_nop,
                allow_metadata_inventory_take = function(pos, listname, index, stack, player)
                    if prot(pos, player) then
                        return 0
                    else
                        return take(pos, listname, index, stack, player)
                    end
                end,
                on_receive_fields = function(pos, formname, fields, sender)
                    if prot(pos, sender) then
                        return
                    else
                        return receive_fields(pos, formname, fields, sender)
                    end
                end
            })
        else
            minetest.override_item(k, {
                allow_metadata_inventory_put_was_nop = v.allow_metadata_inventory_put == nil,
            })
        end
    end
end)
