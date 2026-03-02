-- instantinium
core.register_craftitem("sbz_instatube:instantinium", {
    description = "Instantinium",
    inventory_image = "instantinium.png",
    info_extra = "Takes a bit of time to cook up in the blast furnace",
})

for _, v in pairs { "powder", "ingot" } do
    sbz_api.recipe.register_craft {
        output = "sbz_instatube:instantinium 12",
        type = "blast_furnace",
        items = {
            "sbz_chem:silver_" .. v,
            "sbz_chem:aluminum_" .. v .. " 8",
            "sbz_chem:silicon_" .. v .. " 3"
        },
    }
end

do -- Instatube recipe scope
    local Instatube = 'sbz_instatube:instant_tube'
    local amount = 6
    local In = 'sbz_instatube:instantinium'
    core.register_craft({
        output = Instatube .. ' ' .. tostring(amount),
        recipe = {
            { In, '', In },
            { '', '', '' },
            { In, '', In },
        }
    })
end

do -- One Way Instatube recipe scope
    local One_Way_Instatube = 'sbz_instatube:one_way_instatube'
    local amount = 6
    local In = 'sbz_instatube:instantinium'
    core.register_craft({
        output = One_Way_Instatube .. ' ' .. tostring(amount),
        recipe = {
            { '', '', In },
            { '', In, In },
            { '', '', In },
        }
    })
end

do -- Instatube Item Filter recipe scope
    local Item_Filter = 'sbz_instatube:item_filter'
    local amount = 6
    local In = 'sbz_instatube:instantinium'
    local EC = 'sbz_resources:emittrium_circuit'
    core.register_craft({
        output = Item_Filter .. ' ' .. tostring(amount),
        recipe = {
            { '', In, '' },
            { In, EC, In },
            { '', In, '' },
        }
    })
end

do -- High Priority Instatube recipe scope
    local High_Priority_Instatube = 'sbz_instatube:high_priority_instant_tube'
    local amount = 6
    local In = 'sbz_instatube:instantinium'
    local MB = 'sbz_resources:matter_blob'
    core.register_craft({
        output = High_Priority_Instatube .. ' ' .. tostring(amount),
        recipe = {
            { In, '', In },
            { '', MB, '' },
            { In, '', In },
        }
    })
end

do -- Low Priority Instatube recipe scope
    local Low_Priority_Instatube = 'sbz_instatube:low_priority_instant_tube'
    local amount = 6
    local In = 'sbz_instatube:instantinium'
    local AB = 'sbz_resources:antimatter_blob'
    core.register_craft({
        output = Low_Priority_Instatube .. ' ' .. tostring(amount),
        recipe = {
            { In, '', In },
            { '', AB, '' },
            { In, '', In },
        }
    })
end

do -- Teleport Instatube recipe scope
    local Teleport_Instatube = 'sbz_instatube:teleport_instant_tube'
    local In = 'sbz_instatube:instantinium'
    local WC = 'sbz_resources:warp_crystal'
    core.register_craft({
        output = Teleport_Instatube,
        recipe = {
            { In, In, In },
            { In, WC, In },
            { In, In, In },
        }
    })
end

do -- Randomized Input Instatube recipe scope
    local Randomized_Input_Instatube = 'sbz_instatube:randomized_input_instant_tube'
    local In = 'sbz_instatube:instantinium'
    local AF = 'pipeworks:automatic_filter_injector'
    local MB = 'sbz_resources:matter_blob'
    core.register_craft({
        output = Randomized_Input_Instatube,
        recipe = {
            { In, In, In },
            { AF, MB, '' },
            { In, In, In },
        }
    })
end

do -- Cycling Input Instatube recipe scope
    local Cycling_Input_Instatube = 'sbz_instatube:cycling_input_instant_tube'
    local In = 'sbz_instatube:instantinium'
    local AF = 'pipeworks:automatic_filter_injector'
    local AB = 'sbz_resources:antimatter_blob'
    core.register_craft({
        output = Cycling_Input_Instatube,
        recipe = {
            { In, In, In },
            { AF, AB, '' },
            { In, In, In },
        }
    })
end
