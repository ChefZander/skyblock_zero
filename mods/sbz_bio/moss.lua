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
    groups = {matter=3, cracky=3, attached_node=1}
})