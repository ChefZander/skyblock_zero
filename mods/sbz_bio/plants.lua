local sprouts = {
    "sbz_bio:pyrograss_1",
    "sbz_bio:stemfruit_plant_1"
}

local up = vector.new(0, 1, 0)

minetest.register_craftitem("sbz_bio:fertilizer", {
    description = "Fertilizer",
    inventory_image = "fertilizer.png",
    on_place = function (itemstack, user, pointed)
        if pointed.type == "node" and minetest.get_item_group(minetest.get_node(pointed.under).name, "soil") > 0
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

function sbz_api.plant_growth_tick(num_ticks, next_stage)
    return function (pos, node)
        if sbz_api.get_node_heat(pos) > 7 and sbz_api.is_sky_exposed(pos) and sbz_api.is_hydrated(pos) then
            local meta = minetest.get_meta(pos)
            local count = meta:get_int("count")+1
            if count >= num_ticks then
                count = 0
                if node.param2 > 0 then
                    node.param2 = node.param2-1
                else node.name = next_stage end
                minetest.swap_node(pos, node)
            end
            meta:set_int("count", count)
            return true
        end
    end
end

function sbz_api.plant_wilt(stages)
    return function (pos, node)
        node.param2 = node.param2+1
        minetest.swap_node(pos, node.param2 >= stages and {name="air"} or node)
    end
end

function sbz_api.plant_plant(plant)
    return function (itemstack, user, pointed)
        if minetest.get_item_group(minetest.get_node(pointed.above-up).name, "soil") <= 0 then return end
        local _, pos = minetest.item_place_node(ItemStack(plant), user, pointed)
        if pos then
            itemstack:take_item()
            return itemstack
        end
    end
end

function sbz_api.register_plant(name, defs)
    defs.description = defs.description or ""
    defs.drop = defs.drop
    defs.growth_rate = defs.growth_rate or 1
    defs.width = defs.width or 0.5
    defs.height_min = defs.height_min or 0.5
    defs.height_max = defs.height_max or 0.5
    defs.stages = defs.stages or 4

    for i = 1, defs.stages-1 do
        local interpolant = (i-1)/(defs.stages-1)
        local height = defs.height_min*(1-interpolant)+defs.height_max*interpolant
        minetest.register_node("sbz_bio:"..name.."_"..i, {
            description = defs.description,
            drawtype = "plantlike",
            tiles = {name.."_"..i..".png"},
            inventory_image = name.."_"..i..".png",
            selection_box = {type="fixed", fixed={-defs.width, -0.5, -defs.width, defs.width, height, defs.width}},
            paramtype = "light",
            sunlight_propagates = true,
            paramtype2 = "color",
            palette = "wilting_palette.png",
            walkable = false,
            groups = {dig_immediate=3, attached_node=1, plant=1, habitat_conducts=1, not_in_creative_inventory=1},
            drop = {},
            growth_tick = sbz_api.plant_growth_tick(defs.growth_rate, "sbz_bio:"..name.."_"..(i+1)),
            wilt = sbz_api.plant_wilt(2)
        })
    end
    minetest.register_node("sbz_bio:"..name.."_"..defs.stages, {
        description = defs.description,
        drawtype = "plantlike",
        tiles = {name.."_"..defs.stages..".png"},
        inventory_image = name.."_"..defs.stages..".png",
        selection_box = {type="fixed", fixed={-defs.width, -0.5, -defs.width, defs.width, defs.height_max, defs.width}},
        paramtype = "light",
        sunlight_propagates = true,
        paramtype2 = "color",
        palette = "wilting_palette.png",
        walkable = false,
        groups = {matter=3, oddly_breakable_by_hand=3, attached_node=1, habitat_conducts=1, not_in_creative_inventory=1},
        drop = defs.drop
    })
end

sbz_api.register_plant("pyrograss", {
    description = "Pyrograss",
    drop = "sbz_bio:pyrograss",
    growth_rate = 4,
    width = 0.25,
    height_min = -0.375,
    height_max = 0
})

minetest.register_craftitem("sbz_bio:pyrograss", {
    description = "Pyrograss",
    inventory_image = "pyrograss_4.png",
    groups = {burn=5},
    on_place = sbz_api.plant_plant("sbz_bio:pyrograss_1")
})

sbz_api.register_plant("stemfruit_plant", {
    description = "Stemfruit Plant",
    drop = "sbz_bio:stemfruit",
    growth_rate = 8,
    width = 0.125,
    height_min = -0.25,
    height_max = 0.5
})

minetest.register_craftitem("sbz_bio:stemfruit", {
    description = "Stemfruit",
    inventory_image = "stemfruit.png",
    groups = {burn=3},
    on_place = sbz_api.plant_plant("sbz_bio:stemfruit_plant_1")
})