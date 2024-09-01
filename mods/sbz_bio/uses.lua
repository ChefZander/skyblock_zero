minetest.register_node("sbz_bio:rope", {
    description = "Rope",
    drawtype = "plantlike",
    tiles = {"rope.png"},
    selection_box = {type="fixed", fixed={-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    climbable = true,
    inventory_image = "rope_inventory.png",
    wield_image = "rope_inventory.png",
    groups = {matter=3, burn=1, habitat_conducts=1, transparent=1},
    node_placement_prediction = "",
    on_place = function (itemstack, user, pointed)
        if pointed.type ~= "node" then return end
        if pointed.above.y < pointed.under.y then
            minetest.set_node(pointed.above, {name="sbz_bio:rope"})
        elseif minetest.get_node(pointed.under).name == "sbz_bio:rope" then
            local pos = pointed.under
            local nodename
            repeat
                pos.y = pos.y-1
                nodename = minetest.get_node(pos).name
            until nodename ~= "sbz_bio:rope"
            if minetest.registered_nodes[nodename].buildable_to then
                minetest.set_node(pos, {name="sbz_bio:rope"})
            else return end
        else return end
        itemstack:take_item()
        return itemstack
    end,
    after_dig_node = function (pos, node, meta, user)
        while true do
            pos.y = pos.y-1
            node = minetest.get_node(pos)
            if node.name == "sbz_bio:rope" then
                minetest.node_dig(pos, node, user)
            else return end
        end
    end
})

minetest.register_craft({
    output = "sbz_bio:rope 2",
    recipe = {
        {"sbz_bio:fiberweed"},
        {"sbz_resources:matter_dust"},
        {"sbz_bio:fiberweed"}
    }
})