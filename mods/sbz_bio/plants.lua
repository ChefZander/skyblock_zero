local sprouts = {
    "sbz_bio:stemfruit_plant_1"
    --more to be added later
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

function sbz_api.register_plant(name, desc, drop)
    minetest.register_node("sbz_bio:"..name.."_1", {
        description = desc,
        drawtype = "plantlike",
        tiles = {name.."_1.png"},
        inventory_image = name.."_1.png",
        selection_box = {type="fixed", fixed={-0.125, -0.5, -0.125, 0.125, -0.25, 0.125}},
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        buildable_to = true,
        groups = {dig_immediate=3, attached_node=1, not_in_creative_inventory=1},
        drop = {}
    })
    minetest.register_node("sbz_bio:"..name.."_2", {
        description = desc,
        drawtype = "plantlike",
        tiles = {name.."_2.png"},
        inventory_image = name.."_2.png",
        selection_box = {type="fixed", fixed={-0.125, -0.5, -0.125, 0.125, 0, 0.125}},
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        buildable_to = true,
        groups = {dig_immediate=3, attached_node=1, not_in_creative_inventory=1},
        drop = {}
    })
    minetest.register_node("sbz_bio:"..name.."_3", {
        description = desc,
        drawtype = "plantlike",
        tiles = {name.."_3.png"},
        inventory_image = name.."_3.png",
        selection_box = {type="fixed", fixed={-0.125, -0.5, -0.125, 0.125, 0.25, 0.125}},
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        buildable_to = true,
        groups = {dig_immediate=3, attached_node=1, not_in_creative_inventory=1},
        drop = {}
    })
    minetest.register_node("sbz_bio:"..name.."_4", {
        description = desc,
        drawtype = "plantlike",
        tiles = {name.."_4.png"},
        inventory_image = name.."_4.png",
        selection_box = {type="fixed", fixed={-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}},
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        buildable_to = true,
        groups = {matter=3, cracky=3, attached_node=1, not_in_creative_inventory=1},
        drop = drop
    })
end

sbz_api.register_plant("stemfruit_plant", "Stemfruit Plant", "sbz_bio:stemfruit 3")
minetest.register_craftitem("sbz_bio:stemfruit", {
    description = "Stemfruit",
    inventory_image = "stemfruit.png",
    on_place = function (itemstack, user, pointed)
        local _, pos = minetest.item_place_node(ItemStack("sbz_bio:stemfruit_plant_1"), user, pointed)
        if pos then
            itemstack:take_item()
            return itemstack
        end
    end
})