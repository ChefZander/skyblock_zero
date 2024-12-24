sbz_progression = {}

local modpath = minetest.get_modpath("sbz_progression")

dofile(modpath .. "/quests.lua")
dofile(modpath .. "/questbook.lua")
dofile(modpath .. "/annoy.lua")

local mod_storage = core.get_mod_storage()
sbz_progression.lowest_node = mod_storage:get_int("lowest_node") or 0

function displayDialogueLine(player_name, text)
    minetest.chat_send_player(player_name, "⌠ " .. text .. " ⌡")
    minetest.sound_play("dialouge", {
        to_player = player_name,
        gain = 1,
    })
end

function displayGlobalDialogueLine(text)
    minetest.chat_send_all("⌠ " .. text .. " ⌡")
    minetest.sound_play("dialouge", {
        gain = 1,
    })
end

displayDialougeLine = displayDialogueLine
displayGlobalDialougeLine = displayGlobalDialogueLine


-- it will be funny if we all added quest items in the order of recency, not where they are placed on the questbook
local achievement_table = {
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
    ["sbz_decor:photonlamp"] = "Photon Lamps",
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
    ["sbz_logic:knowledge_station"] = "Knowledge Stations",

    ["sbz_decor:matter_sign"] = "Signs",
    ["sbz_decor:antimatter_sign"] = "Signs",
    ["sbz_decor:cnc"] = "CNC Machines",
    ["sbz_power:powered_lamp_off"] = "Powered Lights",
    ["sbz_power:super_powered_lamp_off"] = "Powered Lights",
    ["unifieddyes:coloring_tool"] = "Coloring Tool",
    ["sbz_resources:jetpack"] = "Jetpack",
    ["sbz_resources:drill"] = "Electric Drill",
    ["sbz_meteorites:meteorite_maker_off"] = "Meteorite Maker",
    ["sbz_resources:strange_cleaner"] = "Strange Blob Cleaner",
    ["sbz_bio:fertilized_dirt"] = "Fertilized Dirt",
    ["sbz_resources:laser_weapon"] = "Laser",

    ["sbz_resources:storinator_bronze"] = "Better Storinators",
    ["sbz_resources:storinator_neutronium"] = "Best Storinators",
    ["drawers:drawer1"] = "Drawers",
    ["drawers:drawer2"] = "Drawers",
    ["drawers:drawer4"] = "Drawers",
    ["drawers:upgrade_template"] = "Drawer Upgrades",
    ["drawers:controller"] = "Drawer Controller",
    ["sbz_chem:compressor_off"] = "Compressor",
    ["sbz_chem:crystal_grower_off"] = "Crystal Grower",
    ["sbz_power:very_advanced_battery"] = "Very Advanced Batteries",

    ["jumpdrive:backbone"] = "Jumpdrive Backbone",
    ["jumpdrive:fleet_controller"] = "Jumpdrive Fleet Controller",
    ["jumpdrive:engine"] = "The Jumpdrive (engine)",
    ["jumpdrive:warp_device"] = "Warp Device",
    ["jumpdrive:station"] = "Jumpdrive Stations"
}

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    if achievement_table[itemstack:get_name()] then
        unlock_achievement(player:get_player_name(), achievement_table[itemstack:get_name()])
    end
end)

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        -- pos stuff
        local pos = player:get_pos()
        local safetynet_low = (player:get_meta():get_int("dynamic_safetynet") == 1) and sbz_progression.lowest_node or 0
        if pos.y < safetynet_low - 100 then
            unlock_achievement(player:get_player_name(), "Emptiness")
        end
        if pos.y < safetynet_low - 110 then
            displayDialougeLine(player:get_player_name(), "You fell off the platform.")
            player:set_pos({ x = 0, y = 1, z = 0 })
        end
    end
end)

--[[
core.register_chatcommand("dynamic_safetynet", {

    params = "static | dynamic",

    description =
    "Define threshold for teleporting to core\n(static: y < 110m below core, dynamic: y < 110m below lowest placed node)",

    func = function(name, params)
        local meta = core.get_player_by_name(name):get_meta()
        if params == "dynamic" then
            meta:set_int("dynamic_safetynet", 1); return true,
                "Successfully changed return threshold.\nYou can reverse this behavior with \"/dynamic_safetynet static\"."
        end
        if params == "static" then
            meta:set_int("dynamic_safetynet", 0); return true, "Successfully changed return threshold."
        end
        return false
    end,
})--]]

local achievement_in_inventory_table = {
    ["sbz_chem:gold_powder"] = "It's fake",
    ["sbz_chem:bronze_powder"] = "Bronze Age",
    ["sbz_chem:water_fluid_cell"] = "Liquid Water",
    ["sbz_bio:stemfruit"] = "Stemfruit",
}
local achievement_on_dig_table = {
    ["sbz_meteorites:antineutronium"] = "Antineutronium",
    ["sbz_resources:strange_blob"] = "It's strange..."
}

minetest.register_on_player_inventory_action(function(player, action, inv, inv_info)
    local itemstack
    if action == "move" then
        itemstack = inv:get_stack(inv_info.to_list, inv_info.to_index)
    else
        itemstack = inv_info.stack
    end
    local player_name = player:get_player_name()
    local itemname = itemstack:get_name()
    if achievement_in_inventory_table[itemname] then
        unlock_achievement(player_name, achievement_in_inventory_table[itemname])
    end
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
    local player_name = digger:get_player_name()
    local itemname = oldnode.name
    if achievement_on_dig_table[itemname] then
        unlock_achievement(player_name, achievement_on_dig_table[itemname])
    end
end)

core.register_on_placenode(function(pos, newnode, _, _, _, _)
    if newnode.name == "sbz_resources:emitter" then return end
    if pos.y >= sbz_progression.lowest_node then return end
    sbz_progression.lowest_node = pos.y
    mod_storage:set_int("lowest_node", pos.y)
end)
