minetest.log("action", "sbz progression: init")
local modpath = minetest.get_modpath("sbz_progression")

dofile(modpath .. "/questbook.lua")
dofile(modpath .. "/annoy.lua")

function displayDialougeLine(player_name, text)
    minetest.chat_send_player(player_name, "⌠ " .. text .. " ⌡")
    minetest.sound_play("dialouge", {
        to_player = player_name,
        gain = 1.0,
    })
end

function displayGlobalDialougeLine(text)
    minetest.chat_send_all("⌠ " .. text .. " ⌡")
    minetest.sound_play("dialouge", {
        gain = 1.0,
    })
end

minetest.register_chatcommand("cheat_hacker", {
    description = "Cheat haguh",
    privs = {},
    func = function(name, param)
        if not name == "zander" then return end -- if youre a modder, change this to your name to allow for easier testing
        if param == "all" then
            for _, q in ipairs(quests) do
                unlock_achievement(name, q.title)
            end
            return
        end
        unlock_achievement(name, param)
        displayDialougeLine(name, "Cheat haguh")
    end,
})

local achievment_table = {
    ["sbz_resources:matter_blob"] = "A bigger platform",
    ["sbz_resources:matter_stair"] = "Matter Stairs",
    ["sbz_resources:antimatter_dust"] = "Antimatter",
    ["sbz_resources:matter_annihilator"] = "Annihilator",
    ["sbz_power:simple_charged_field"] = "Charged Field",
    ["sbz_power:simple_matter_extractor"] = "Automation",
    ["sbz_power:advanced_matter_extractor"] = "Advanced Extractors",
    ["sbz_resources:simple_circuit"] = "Circuitry",
    ["sbz_power:simple_charge_generator"] = "Generators",
    ["sbz_resources:matter_plate"] = "Matter Plates",
    ["sbz_resources:retaining_circuit"] = "Retaining Circuits",
    ["sbz_resources:storinator"] = "Storinators",
	["sbz_resources:antimatter_blob"] = "More Antimatter",
    ["sbz_resources:emitter_imitator"] = "Emitter Immitators",
    ["sbz_resources:pebble"] = "Pretty Pebbles",
    ["sbz_resources:stone"] = "Concrete Plan",
    ["sbz_decor:photonlamp"] = "Photon Lamps",
    ["sbz_resources:emittrium_circuit"] = "Emittrium Circuits",
    ["sbz_resources:angels_wing"] = "Angel's Wing",
    ["sbz_power:battery"] = "Batteries",
    ["sbz_power:advanced_battery"] = "Advanced Batteries",
    ["sbz_power:connector_off"] = "Connectors",
    ["sbz_power:phosphor_off"] = "Phosphor",
    ["sbz_power:power_pipe"] = "Power Pipes",
    ["sbz_power:starlight_collector"] = "Starlight Collectors",
    ["sbz_resources:reinforced_matter"] = "Reinforced Matter",
    ["sbz_power:switching_station"] = "Switching Station",
    ["sbz_power:infinite_storinator"] = "Infinite Storinators",
    ["sbz_chem:crusher"] = "Crusher",
    ["sbz_chem:simple_alloy_furnace"] = "Simple Alloy Furnace",
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
    ["sbz_bio:emittrium_glass"] = "Emittrium Glass",
    ["sbz_bio:dirt"] = "Dirt",
    ["sbz_bio:fertilizer"] = "Sprouting Plants",
    ["sbz_bio:burner"] = "Carbon Dioxide",
    ["sbz_bio:airlock"] = "Airlocks"
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