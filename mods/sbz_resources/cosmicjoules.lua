CJ_machines_max_power = {

}

function cj_addnode(node_name, max_power)
    CJ_machines_max_power[node_name] = max_power
end
function cj_getmaxpower(pos)
    local node = minetest.get_node(pos)
    local node_name = node.name

    -- Check if the node name exists in the CJ_machines_max_power table
    if CJ_machines_max_power[node_name] then
        return CJ_machines_max_power[node_name]
    else
        return 0
    end
end
function cj_getpower(pos)
    local meta = minetest.get_meta(pos)
    if meta then
        return meta:get_int("cj") -- will be 0 if not set
    end
end
function cj_setpower(pos, new_power)
    local meta = minetest.get_meta(pos)
    if meta then
        meta:set_int("cj", new_power)
    end
end

-- helper methods
function cj_addpower(pos, add_power)
    local new_power = cj_getpower(pos) + add_power
    if new_power > cj_getmaxpower(pos) then 
        cj_setpower(pos, cj_getmaxpower(pos))
    else 
        cj_setpower(pos, new_power)
    end
end
function cj_removepower(pos, remove_power)
    local new_power = cj_getpower(pos) - remove_power
    if new_power < 0 then
        return false
    else
        cj_setpower(pos, new_power)
        return true
    end
end

-- Joulecounter Item
minetest.register_craftitem("sbz_resources:joulecounter", {
    description = "Joulecounter",
    inventory_image = "joulecounter.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        -- Check if the pointed thing is a node
        if pointed_thing and pointed_thing.type == "node" then
            local pos = pointed_thing.under
            -- Get power information
            local current_power = cj_getpower(pos)
            local max_power = cj_getmaxpower(pos)
            local player_name = user:get_player_name()
            
            -- Send information to the player
            local message = "Current Power: " .. current_power .. " / " .. max_power .. " J"
            minetest.chat_send_player(player_name, message)
        end
        
        return itemstack
    end
})
minetest.register_craft({
    output = "sbz_resources:joulecounter",
    recipe = {
        {"sbz_resources:antimatter_dust", "sbz_resources:matter_plate", "sbz_resources:antimatter_dust"},
        {"sbz_resources:matter_plate", "sbz_resources:emittirum_circuit", "sbz_resources:matter_plate"},
        {"sbz_resources:antimatter_dust", "sbz_resources:matter_plate", "sbz_resources:antimatter_dust"}
    }
})