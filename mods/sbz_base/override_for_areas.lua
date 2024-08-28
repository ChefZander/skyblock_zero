local nop1 = function(_, _, _, _, _, count)
    return count
end
local nop2 = function(_, _, _, stack, _)
    return stack:get_count()
end

local function prot(pos, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        minetest.record_protection_violation(pos, player:get_player_name())
        return true
    end
    return false
end

minetest.register_on_mods_loaded(function()
    for k, v in pairs(minetest.registered_nodes) do
        if minetest.get_item_group(k, "public") < 1 then
            local move, put, take = v.allow_metadata_inventory_move or nop, v.allow_metadata_inventory_put or nop,
                v.allow_metadata_inventory_take or nop
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
                        put(pos, listname, index, stack, player)
                    end
                end,
                allow_metadata_inventory_take = function(pos, listname, index, stack, player)
                    if prot(pos, player) then
                        return 0
                    else
                        take(pos, listname, index, stack, player)
                    end
                end,
            })
        end
    end
end)
