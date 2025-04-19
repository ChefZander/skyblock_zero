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

core.register_craft {
    output = "sbz_instatube:instant_tube 6",
    recipe = {
        { "sbz_instatube:instantinium", "", "sbz_instatube:instantinium" },
        { "",                           "", "" },
        { "sbz_instatube:instantinium", "", "sbz_instatube:instantinium" }
    }
}

core.register_craft {
    output = "sbz_instatube:one_way_instatube 6",
    recipe = {
        { "", "",                           "sbz_instatube:instantinium" },
        { "", "sbz_instatube:instantinium", "sbz_instatube:instantinium" },
        { "", "",                           "sbz_instatube:instantinium" }
    }
}

core.register_craft {
    output = "sbz_instatube:item_filter 6",
    recipe = {
        { "",                           "sbz_instatube:instantinium",      "" },
        { "sbz_instatube:instantinium", "sbz_resources:emittrium_circuit", "sbz_instatube:instantinium" },
        { "",                           "sbz_instatube:instantinium",      "" }
    }
}

core.register_craft {
    output = "sbz_instatube:high_priority_instant_tube 6",
    recipe = {
        { "sbz_instatube:instantinium", "",                          "sbz_instatube:instantinium" },
        { "",                           "sbz_resources:matter_blob", "" },
        { "sbz_instatube:instantinium", "",                          "sbz_instatube:instantinium" }
    }
}

core.register_craft {
    output = "sbz_instatube:low_priority_instant_tube 6",
    recipe = {
        { "sbz_instatube:instantinium", "",                              "sbz_instatube:instantinium" },
        { "",                           "sbz_resources:antimatter_blob", "" },
        { "sbz_instatube:instantinium", "",                              "sbz_instatube:instantinium" }
    }
}

core.register_craft {
    output = "sbz_instatube:teleport_instant_tube",
    recipe = {
        { "sbz_instatube:instantinium", "sbz_instatube:instantinium", "sbz_instatube:instantinium" },
        { "sbz_instatube:instantinium", "sbz_resources:warp_crystal", "sbz_instatube:instantinium" },
        { "sbz_instatube:instantinium", "sbz_instatube:instantinium", "sbz_instatube:instantinium" }
    }
}

core.register_craft {
    output = "sbz_instatube:randomized_input_instant_tube",
    recipe = {
        { "sbz_instatube:instantinium",          "sbz_instatube:instantinium", "sbz_instatube:instantinium" },
        { "pipeworks:automatic_filter_injector", "sbz_resources:matter_blob",  "" },
        { "sbz_instatube:instantinium",          "sbz_instatube:instantinium", "sbz_instatube:instantinium" },
    }
}

core.register_craft {
    output = "sbz_instatube:cycling_input_instant_tube",
    recipe = {
        { "sbz_instatube:instantinium",          "sbz_instatube:instantinium",    "sbz_instatube:instantinium" },
        { "pipeworks:automatic_filter_injector", "sbz_resources:antimatter_blob", "" },
        { "sbz_instatube:instantinium",          "sbz_instatube:instantinium",    "sbz_instatube:instantinium" },
    }
}
