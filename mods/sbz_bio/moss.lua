minetest.register_node("sbz_bio:moss", {
    description = "Moss",
    drawtype = "signlike",
    tiles = {"moss.png"},
    inventory_image = "moss.png",
    selection_box = {type="fixed", fixed={-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}},
    paramtype = "light",
    sunlight_propagates = true,
    paramtype2 = "wallmounted",
    walkable = false,
    buildable_to = true,
    groups = {matter=3, cracky=3, attached_node=1}
})

minetest.register_node("sbz_bio:algae", {
    description = "Algae",
    drawtype = "signlike",
    tiles = {"algae.png"},
    inventory_image = "algae.png",
    selection_box = {type="fixed", fixed={-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}},
    paramtype = "light",
    sunlight_propagates = true,
    paramtype2 = "wallmounted",
    walkable = false,
    buildable_to = true,
    groups = {matter=3, cracky=3}
})

minetest.register_abm({
    interval = 10,
    chance = 20,
    nodenames = {"sbz_resources:matter_blob", "group:moss_growable"},
    neighbors = {"sbz_resources:water_source", "sbz_resources:water_flowing"},
    action = function (pos, node)
        local i = math.random(0, 5)
        local dir = minetest.wallmounted_to_dir(i)
        if sbz_api.get_node_heat(pos-dir) > 7 then
            local defs = minetest.registered_nodes[minetest.get_node(pos-dir).name]
            if defs.liquidtype == "none" and defs.buildable_to then
                minetest.set_node(pos-dir, {name="sbz_bio:moss", param2=i})
            end
        end
    end
})

minetest.register_abm({
    interval = 10,
    chance = 20,
    nodenames = {"sbz_resources:water_source"},
    action = function (pos, node)
        pos.y = pos.y+1
        if sbz_api.get_node_heat(pos) > 7 then
            local defs = minetest.registered_nodes[minetest.get_node(pos).name]
            if defs.liquidtype == "none" and defs.buildable_to then
                minetest.set_node(pos, {name="sbz_bio:algae", param2=1})
            end
        end
    end
})

minetest.register_node("sbz_bio:dirt", {
    description = "Dirt",
    tiles = {"dirt.png"},
    groups = {matter=1, cracky=3, moss_growable=1, soil=1}
})

minetest.register_craft({
    output = "sbz_bio:dirt",
    recipe = {
        {"sbz_bio:moss", "sbz_bio:moss", "sbz_bio:moss"},
        {"sbz_bio:moss", "sbz_bio:moss", "sbz_bio:moss"},
        {"sbz_bio:moss", "sbz_bio:moss", "sbz_bio:moss"}
    }
})