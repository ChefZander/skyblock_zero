-- The "subscribe" meta field compat
-- We need it to like... change when the thingy moves, you knowwww

mesecon.register_on_mvps_move(function(moved_nodes)
    for i = 1, #moved_nodes do
        local moved_node = moved_nodes[i]
        if core.get_item_group(moved_node.node.name, "ui_logic") then
            local meta = core.get_meta(moved_node.pos)
            local subscribed = vector.from_string(meta:get_string("subscribed"))
            if subscribed then
                subscribed = vector.add(vector.subtract(subscribed, moved_node.oldpos), moved_node.pos)
                meta:set_string("subscribed", vector.to_string(subscribed))
            end
        end
    end
end)
