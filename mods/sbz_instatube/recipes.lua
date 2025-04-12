-- instantinium
core.register_craftitem("sbz_instatube:instantinium", {
    description = "Instantinium",
    inventory_image = "instantinium.png",
    info_extra = "Takes a bit of time to cook up in the blast furnace",
})

for _, v in pairs { "powder", "ingot" } do
    unified_inventory.register_craft {
        output = "sbz_instatube:instantinium 12",
        type = "blast_furnace",
        items = {
            "sbz_chem:silver_" .. v,
            "sbz_chem:aluminum_" .. v .. " 8",
            "sbz_chem:silicon_" .. v .. " 3"
        },
    }

    sbz_api.blast_furnace_recipes[#sbz_api.blast_furnace_recipes + 1] = {
        recipe = {
            "sbz_chem:silver_" .. v,
            "sbz_chem:aluminum_" .. v .. " 8",
            "sbz_chem:silicon_" .. v .. " 3"
        },
        names = {
            "sbz_chem:silver_" .. v,
            "sbz_chem:aluminum_" .. v,
            "sbz_chem:silicon_" .. v
        },
        output = "sbz_instatube:instantinium 12",
        chance = 1 / (9 * 2)
    }
end
