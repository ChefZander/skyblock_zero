local sprouts = {
    "sbz_bio:stemfruit_sprout"
}

local up = vector.new(0, 1, 0)

minetest.register_craftitem("sbz_bio:fertilizer", {
    description = "Fertilizer",
    inventory_image = "fertilizer.png",
    on_place = function (itemstack, user, pointed)
        if pointed.type == "node" and minetest.get_item_group(minetest.get_node(pointed.under).name, "fertilizable")
        and minetest.registered_nodes[minetest.get_node(pointed.under+up).name].buildable_to then
            minetest.set_node(pointed.under+up, {name=sprouts[math.random(#sprouts)]})
            itemstack:take_item()
            return itemstack
        end
    end
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_bio:fertilizer",
    recipe = {"sbz_bio:algae", "sbz_bio:algae", "sbz_bio:algae"}
})

minetest.register_node("sbz_bio:stemfruit_sprout", {
    description = "Stemfruit Sprout",
    drawtype = "plantlike",
    walkable = false,
    buildable_to = true,
    groups = {matter=3, cracky=3},
    drop = {}
})