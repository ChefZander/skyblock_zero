core.register_tool("sbz_resources:wormhole", {
    description = "Wormhole",
    info_extra = "Left Click: Link, Right Click: Rightclick linked node",
    inventory_image = "wormhole.png",
    stack_max = 1,

    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        
        local pos = pointed_thing.under
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()

        local item_meta = itemstack:get_meta()
        item_meta:set_string("target_pos", core.serialize(pos))
        item_meta:set_string("description", "Wormhole (Linked to " .. core.pos_to_string(pos) .. ")")
        
        core.chat_send_player(user:get_player_name(), "Wormhole linked to " .. core.pos_to_string(pos))
        return itemstack
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
        local pos_str = itemstack:get_meta():get_string("target_pos")
        if pos_str == "" then
            minetest.chat_send_player(user:get_player_name(), "Not linked!")
            return itemstack
        end

        local target_pos = minetest.deserialize(pos_str)
        local node = minetest.get_node_or_nil(target_pos)
        
        if not node or node.name == "ignore" then
            minetest.chat_send_player(user:get_player_name(), "Target area is not loaded!")
            return itemstack
        end

        local def = minetest.registered_nodes[node.name]
        local player_name = user:get_player_name()

        if def and def.on_rightclick then
            local fake_pointed = {type="node", under=target_pos, above=target_pos}
            def.on_rightclick(target_pos, node, user, itemstack, fake_pointed)
        end

        local meta = minetest.get_meta(target_pos)
        local formspec = meta:get_string("formspec")

        minetest.show_formspec(player_name, "remote_linker:remote", formspec)
        
        return itemstack
    end,

    on_place = function(itemstack, user, pointed_thing)
        return minetest.registered_tools["sbz_resources:wormhole"].on_secondary_use(itemstack, user, pointed_thing)
    end,
})