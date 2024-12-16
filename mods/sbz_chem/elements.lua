unified_inventory.register_craft_type("crushing", {
    description = "Crushing",
    icon = "crusher_top.png^[verticalframe:4:1",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
})

unified_inventory.register_craft_type("alloying", {
    description = "Alloying",
    icon = "simple_alloy_furnace.png^[verticalframe:13:1",
    width = 2,
    height = 1,
    uses_crafting_grid = false,
})

unified_inventory.register_craft_type("compressing", {
    description = "Compressing",
    icon = "compressor.png^[verticalframe:11:1",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
})

unified_inventory.register_craft_type("crystal_growing", {
    description = "(Crystal) Growing",
    icon = "crystal_grower.png^[verticalframe:17:1",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
})

sbz_api.crusher_drops = {}
sbz_api.unused_chem = {}

sbz_api.register_element = function(name, color, description, disabled, part_of_crusher_drops)
    if disabled == nil then disabled = false end
    local disabled_group = disabled and 1 or nil
    minetest.register_craftitem("sbz_chem:" .. name .. "_powder", {
        groups = { chem_element = 1, powder = 1, not_in_creative_inventory = disabled_group, chem_disabled = disabled_group },
        description = string.format(description, "Powder"),
        inventory_image = "powder.png^[colorize:" .. color .. ":150"
    })
    minetest.register_craftitem("sbz_chem:" .. name .. "_ingot", {
        groups = { chem_element = 1, ingot = 1, not_in_creative_inventory = disabled_group, chem_disabled = disabled_group },
        description = string.format(description, "Ingot"),
        inventory_image = "ingot.png^[colorize:" .. color .. ":150",

    })
    minetest.register_node("sbz_chem:" .. name .. "_block", unifieddyes.def {
        groups = {
            chem_element = 1,
            chem_block = 1,
            not_in_creative_inventory = disabled_group,
            chem_disabled = disabled_group,
            matter = 1,
            level = 2,
            explody = 100
        },
        description = string.format(description, "Block"),
        tiles = { "block.png^[colorize:" .. color .. ":150" },
        sounds = sbz_api.sounds.metal()

    })
    if not disabled then
        stairs.register("sbz_chem:" .. name .. "_block")
        minetest.register_craft({
            type = "cooking",
            output = "sbz_chem:" .. name .. "_ingot",
            recipe = "sbz_chem:" .. name .. "_powder",
        })
        unified_inventory.register_craft {
            type = "crushing",
            output = "sbz_chem:" .. name .. "_powder",
            items = { "sbz_chem:" .. name .. "_ingot" }
        }

        unified_inventory.register_craft {
            type = "compressing",
            output = "sbz_chem:" .. name .. "_block",
            items = { "sbz_chem:" .. name .. "_powder 9" }
        }
        unified_inventory.register_craft {
            type = "compressing",
            output = "sbz_chem:" .. name .. "_block",
            items = { "sbz_chem:" .. name .. "_ingot 9" }
        }

        unified_inventory.register_craft {
            type = "crushing",
            output = "sbz_chem:" .. name .. "_powder 9",
            items = { "sbz_chem:" .. name .. "_block" }
        }

        if part_of_crusher_drops == nil or part_of_crusher_drops == true then
            sbz_api.crusher_drops[#sbz_api.crusher_drops + 1] = "sbz_chem:" .. name .. "_powder"
        end
    else
        sbz_api.unused_chem[#sbz_api.unused_chem + 1] = "sbz_chem:" .. name
    end
end

minetest.after(0, function()
    for k, v in pairs(sbz_api.unused_chem) do
        local powder = v .. "_powder"
        local ingot = v .. "_ingot"
        if unified_inventory.get_recipe_list(powder) then
            minetest.log(
                "This chemical: " ..
                powder ..
                " is disabled, and shouldn't have any use.. right... but it has!!! \n details: " ..
                dump(unified_inventory.get_recipe_list(powder)))
        end
        if unified_inventory.get_recipe_list(ingot) then
            minetest.log(
                "This chemical: " ..
                ingot ..
                " is disabled, and shouldn't have any use.. right... but it has!!! \n details: " ..
                dump(unified_inventory.get_recipe_list(ingot)))
        end
    end
end)

sbz_api.register_element("gold", "#FFD700", "Gold %s (Au)")
sbz_api.register_element("silver", "#C0C0C0", "Silver %s (Ag)", true)
sbz_api.register_element("iron", "#B7410E", "Iron %s (Fe)")
sbz_api.register_element("copper", "#B87333", "Copper %s (Cu)")
sbz_api.register_element("aluminum", "#A9A9A9", "Aluminum %s (Al)")
sbz_api.register_element("lead", "#6E6E6E", "Lead %s (Pb)", true)
sbz_api.register_element("zinc", "#7F7F7F", "Zinc %s (Zn)", true)
sbz_api.register_element("tin", "#D2B48C", "Tin %s (Sn)")
sbz_api.register_element("nickel", "#88c6cc", "Nickel %s (Ni)")
sbz_api.register_element("platinum", "#E5E4E2", "Platinum %s (Pt)", true)
sbz_api.register_element("mercury", "#B5B5B5", "Mercury %s (Hg)", true)
sbz_api.register_element("cobalt", "#0047AB", "Cobalt %s (Co)")
sbz_api.register_element("titanium", "#4A2A2A", "Titanium %s (Ti)")
sbz_api.register_element("magnesium", "#DADADA", "Magnesium %s (Mg)", true)
sbz_api.register_element("calcium", "#F5F5DC", "Calcium %s (Ca)", true)
sbz_api.register_element("sodium", "#F4F4F4", "Sodium %s (Na)", true)
sbz_api.register_element("lithium", "#c8a4db", "Lithium %s (Li)")
sbz_api.register_element("silicon", "#5ba082", "Silicon %s (Si)")
-- sbz_api.register_element("uranium", "#00FF00", "Uranium %s (0.7% U-238)") -- this is a todo, someone pls make technic style uranium, with 3-6% being for reactors, 70-90% being for weapons

-- alloys

sbz_api.register_element("bronze", "#CD7F32", "Bronze %s (CuSn)", false, false)
sbz_api.register_element("brass", "#B5A642", "Brass %s (CuZn)", true, false)
sbz_api.register_element("invar", "#808080", "Invar %s (FeNi)", false, false)
sbz_api.register_element("titanium_alloy", "#B0C4DE", "Titanium Alloy %s (TiAl)", false, false)
sbz_api.register_element("white_gold", "#E5E4E2", "White Gold %s (AuNi)", true, false)
