minetest.log("action", "sbz progression: init")
local modpath = minetest.get_modpath("sbz_progression")

dofile(modpath .. "/questbook.lua")
dofile(modpath .. "/annoy.lua")

function displayDialogueLine(player_name, text)
    minetest.chat_send_player(player_name, "⌠ " .. text .. " ⌡")
    minetest.sound_play("dialouge", {
        to_player = player_name,
        gain = 1.0,
    })
end

function displayGlobalDialogueLine(text)
    minetest.chat_send_all("⌠ " .. text .. " ⌡")
    minetest.sound_play("dialouge", {
        gain = 1.0,
    })
end

displayDialougeLine = displayDialogueLine
displayGlobalDialougeLine = displayGlobalDialogueLine


local achievment_table = {
    ["sbz_resources:matter_blob"] = "A bigger platform",
    ["sbz_resources:matter_stair"] = "Matter Stairs",
    ["sbz_resources:antimatter_dust"] = "Antimatter",
    ["sbz_resources:matter_annihilator"] = "Annihilator",
    ["sbz_power:simple_charged_field"] = "Charged Field",
    ["sbz_power:simple_matter_extractor"] = "Automation",
    ["sbz_power:advanced_matter_extractor"] = "Advanced Extractors",
    ["sbz_resources:simple_circuit"] = "Circuitry",
    ["sbz_power:simple_charge_generator_off"] = "Generators",
    ["sbz_resources:matter_plate"] = "Matter Plates",
    ["sbz_resources:retaining_circuit"] = "Retaining Circuits",
    ["sbz_resources:storinator"] = "Storinators",
    ["sbz_resources:pebble"] = "Pretty Pebbles",
    ["sbz_resources:stone"] = "Concrete Plan",

    ["sbz_resources:compressed_core_dust"] = "Compressed Core Dust",
<<<<<<< HEAD
=======
    ["sbz_decor:photonlamp"] = "Photon Lamps",
>>>>>>> 4ea54be (merge)
    ["sbz_resources:antimatter_blob"] = "More Antimatter",
    ["sbz_resources:antimatter_annihilator"] = "Anti-Annihilator",
    ["sbz_resources:emitter_imitator"] = "Emitter Immitators",

    ["sbz_decor:factory_floor"] = "Factory Flooring",
    ["sbz_decor:factory_floor_tiling"] = "Tiled Factory Flooring",
    ["sbz_decor:factory_ventilator"] = "Factory Ventilator",

    ["sbz_resources:emittrium_circuit"] = "Emittrium Circuits",
    ["sbz_resources:angels_wing"] = "Angel's Wing",
    ["sbz_power:battery"] = "Batteries",
    ["sbz_power:advanced_battery"] = "Advanced Batteries",
    ["sbz_power:connector_off"] = "Connectors",
    ["sbz_power:phosphor_off"] = "Phosphor",
    ["sbz_power:power_pipe"] = "Power Cables",
    ["sbz_power:starlight_collector"] = "Starlight Collectors",
    ["sbz_resources:reinforced_matter"] = "Reinforced Matter",
    ["sbz_power:switching_station"] = "Switching Station",
    ["sbz_power:infinite_storinator"] = "Infinite Storinators",
    ["sbz_chem:crusher_off"] = "Crusher",
    ["sbz_chem:simple_alloy_furnace_off"] = "Simple Alloy Furnace",
    ["sbz_meteorites:meteorite_radar"] = "Meteorites",
    ["sbz_meteorites:gravitational_attractor"] = "Neutronium",
    ["sbz_meteorites:gravitational_repulsor"] = "Neutronium",
    ["sbz_resources:robotic_arm"] = "Bear Arms",
    ["pipeworks:automatic_filter_injector"] = "Automatic Filter-Injectors",
    ["pipeworks:tube_1"] = "Tubes",
    ["pipeworks:node_breaker"] = "Node Breakers",
    ["pipeworks:deployer"] = "Deployers",
    ["pipeworks:puncher"] = "Punchers",
    ["pipeworks:autocrafter"] = "Autocrafters",
    ["pipeworks:item_void"] = "Item Voids",
    ["pipeworks:item_vacuum"] = "Item Vacuums",
    ["screwdriver:screwdriver"] = "Screwdriver",
    ["sbz_chem:high_power_electric_furnace_off"] = "Furnace",
    ["areasprotector:protector_small"] = "Small Protectors",
    ["areasprotector:protector_large"] = "Big Protectors",
    ["sbz_power:antimatter_generator_off"] = "Antimatter Generators",
    ["sbz_resources:storinator_public"] = "Public Storinators",

    ["sbz_resources:emittrium_glass"] = "Emittrium Glass",
    ["sbz_bio:dirt"] = "Dirt",
    ["sbz_bio:fertilizer"] = "Sprouting Plants",
    ["sbz_bio:burner"] = "Carbon Dioxide",
    ["sbz_bio:airlock"] = "Airlocks",
    ["sbz_power:fluid_pipe"] = "Fluid Pipes",
    ["sbz_power:pump_off"] = "Fluid Pumps",
    ["sbz_power:fluid_capturer_off"] = "Fluid Capturers",
    ["sbz_power:fluid_tank"] = "Fluid Storage Tanks",
    ["sbz_power:fluid_cell_filler"] = "Fluid Cell Fillers",

    ["sbz_power:reactor_shell"] = "Reactor Shells",
    ["sbz_power:reactor_glass"] = "Reactor Glass",
    ["sbz_power:reactor_infoscreen"] = "Reactor Infoscreens",
    ["sbz_power:reactor_power_port"] = "Reactor Power Ports",
    ["sbz_power:reactor_coolant_port"] = "Reactor Coolant Ports",
    ["sbz_power:reactor_item_input"] = "Reactor Emittrium Input",
    ["sbz_power:reactor_core_off"] = "Reactor Core",

    ["sbz_power:ele_fab_off"] = "Ele Fabs",
    ["sbz_logic:knowledge_station"] = "Knowledge Stations"
}

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    if achievment_table[itemstack:get_name()] then
        unlock_achievement(player:get_player_name(), achievment_table[itemstack:get_name()])
    end
end)

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        -- pos stuff
        local pos = player:get_pos()
        if pos.y < -100 then
            unlock_achievement(player:get_player_name(), "Emptiness")
        end
        if pos.y < -110 then
            displayDialougeLine(player:get_player_name(), "You fell off the platform.")
            player:set_pos({ x = 0, y = 1, z = 0 })
        end
    end
end)

minetest.register_on_player_inventory_action(function(player, action, inv, inv_info)
    local itemstack
    if action == "move" then
        itemstack = inv:get_stack(inv_info.to_list, inv_info.to_index)
    else
        itemstack = inv_info.stack
    end
    local player_name = player:get_player_name()
    local itemname = itemstack:get_name()
    if itemname == "sbz_chem:gold_powder" then
        unlock_achievement(player_name, "It's fake")
    elseif itemname == "sbz_chem:bronze_powder" then
        unlock_achievement(player_name, "Bronze Age")
    elseif itemstack:get_name() == "sbz_meteorites:antineutronium" then
        unlock_achievement(player_name, "Antineutronium")
    elseif itemname == "sbz_chem:water_fluid_cell" then
        unlock_achievement(player_name, "Liquid Water")
    elseif itemname == "sbz_bio:stemfruit" then
        unlock_achievement(player_name, "Stemfruit")
    end
end)
