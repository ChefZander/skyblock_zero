-- Common problem: "I want to have this node in my hand right now"
-- Alternative: Hotbar switching (implemented)
--
-- Keys: zoom+rmb/lmb to pick

local function get_pointed_node_type(player)
    local lookdir = player:get_look_dir()
    local eyepos = sbz_api.get_pos_with_eye_height(player)
    local ray = core.raycast(eyepos, vector.add(eyepos, vector.multiply(lookdir, 30)), false, false)
    for pointed_thing in ray do
        if pointed_thing.type == 'node' then
            local node = core.get_node(pointed_thing.under)
            local def = core.registered_nodes[node.name]
            if def then return node.name end
        end
    end
    return nil
end

local function pick_block(player, node_name)
    local inv = player:get_inventory()
    if not inv:contains_item('main', node_name) then return end

    local item_index

    local list = inv:get_list 'main'
    for i = 1, #list do
        local stack = list[i]
        if stack:get_name() == node_name then
            item_index = i
            break
        end
    end

    if not item_index then return end
    local wielded_item = player:get_wielded_item()
    local wield_index = player:get_wield_index()
    list[wield_index] = list[item_index]
    list[item_index] = wielded_item
    inv:set_list('main', list)
    core.chat_send_player(
        player:get_player_name(),
        '[sbz] Picked ' .. node_name .. ' to wielded slot. (Use zoom+rmb/lmb to pick a node.)'
    )
end

controls.register_on_press(function(player, key)
    if not (key == 'LMB' or key == 'RMB') then return end
    local node_name = get_pointed_node_type(player)
    if node_name then pick_block(player, node_name) end
end)
