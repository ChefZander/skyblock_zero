-- sbz_progression = {}

local S = core.get_translator('sbz_progression')
local modpath = core.get_modpath 'sbz_progression'

dofile(modpath .. '/quest_parser.lua')
dofile(modpath .. '/quests.lua')
dofile(modpath .. '/questbook.lua')
dofile(modpath .. '/annoy.lua')

-- Do this if you want to make a unified quests.md for whatever reason
--assert(io.open(modpath .. "/quests/quests.md", "w+")):write(sbz_api.quest_parser.encode(quests))

-- local mod_storage = core.get_mod_storage()
-- sbz_progression.lowest_node = mod_storage:get_int("lowest_node") or 0

function sbz_api.displayDialogLine(player_name, text)
    core.chat_send_player(player_name, '⌠ ' .. text .. ' ⌡')
end

-- it will be funny if we all added quest items in the order of recency, not where they are placed on the questbook

-- Maps craftable item IDs to their quest IDs.
-- The qids are found on the `### ID:` line in the corresponding markdown quest.
-- No titles as values; qid slugs are the permanent, not-to-be-localized keys, present as identifiers.
local achievement_table = {
    ['sbz_resources:matter_blob'] = 'qid_a_bigger_platform',
    ['sbz_resources:matter_stair'] = 'qid_matter_stairs',
    ['sbz_resources:antimatter_dust'] = 'qid_antimatter',
    ['sbz_resources:matter_annihilator'] = 'qid_annihilator',
    ['sbz_power:simple_charged_field'] = 'qid_charged_field',
    ['sbz_power:simple_matter_extractor'] = 'qid_automation',
    ['sbz_power:advanced_matter_extractor'] = 'qid_advanced_extractors',
    ['sbz_resources:simple_circuit'] = 'qid_circuitry',
    ['sbz_power:simple_charge_generator_off'] = 'qid_generators',
    ['sbz_resources:matter_plate'] = 'qid_matter_plates',
    ['sbz_resources:retaining_circuit'] = 'qid_retaining_circuits',
    ['sbz_resources:storinator'] = 'qid_storinators',
    ['sbz_resources:pebble'] = 'qid_pretty_pebbles',
    ['sbz_resources:stone'] = 'qid_concrete_plan',

    ['sbz_resources:compressed_core_dust'] = 'qid_compressed_core_dust',
    ['sbz_decor:photonlamp'] = 'qid_photon_lamps',
    ['sbz_resources:antimatter_blob'] = 'qid_more_antimatter',
    ['sbz_resources:antimatter_annihilator'] = 'qid_anti_annihilator',
    ['sbz_resources:emitter_imitator'] = 'qid_emitter_imitators',

    ['sbz_decor:factory_floor'] = 'qid_factory_flooring',
    ['sbz_decor:factory_floor_tiling'] = 'qid_tiled_factory_flooring',
    ['sbz_decor:factory_ventilator'] = 'qid_factory_ventilator',

    ['sbz_resources:emittrium_circuit'] = 'qid_emittrium_circuits',
    ['sbz_resources:angels_wing'] = 'qid_angels_wing',
    ['sbz_power:battery'] = 'qid_batteries',
    ['sbz_power:advanced_battery'] = 'qid_advanced_batteries',
    ['sbz_power:connector_off'] = 'qid_connectors',
    ['sbz_power:phosphor_off'] = 'qid_phosphor',
    ['sbz_power:power_pipe'] = 'qid_power_cables',
    ['sbz_power:starlight_collector'] = 'qid_starlight_collectors',
    ['sbz_resources:reinforced_matter'] = 'qid_reinforced_matter',
    ['sbz_power:switching_station'] = 'qid_switching_station',
    ['sbz_power:infinite_storinator'] = 'qid_infinite_storinators',
    ['sbz_chem:crusher_off'] = 'qid_crusher',
    ['sbz_chem:simple_alloy_furnace_off'] = 'qid_simple_alloy_furnace',
    ['sbz_meteorites:meteorite_radar'] = 'qid_meteorites',
    ['sbz_meteorites:gravitational_attractor'] = 'qid_neutronium',
    ['sbz_meteorites:gravitational_repulsor'] = 'qid_neutronium',
    ['sbz_resources:robotic_arm'] = 'qid_bear_arms',
    ['pipeworks:automatic_filter_injector'] = 'qid_automatic_filter_injectors',
    ['pipeworks:tube_1'] = 'qid_tubes',
    ['pipeworks:one_direction_tube_1'] = 'qid_one_direction_tubes',
    ['pipeworks:nodebreaker'] = 'qid_node_breakers',
    ['pipeworks:deployer'] = 'qid_deployers',
    ['pipeworks:puncher'] = 'qid_punchers',
    ['pipeworks:autocrafter'] = 'qid_autocrafters',
    ['sbz_resources:simple_crafting_processor'] = 'qid_simple_crafting_processors',
    ['pipeworks:item_void'] = 'qid_item_voids',
    ['sbz_power:item_vacuum'] = 'qid_item_vacuums',
    ['screwdriver:screwdriver'] = 'qid_screwdriver',
    ['sbz_chem:high_power_electric_furnace_off'] = 'qid_furnace',
    ['areasprotector:protector_small'] = 'qid_small_protectors',
    ['areasprotector:protector_large'] = 'qid_big_protectors',
    ['sbz_power:antimatter_generator_off'] = 'qid_antimatter_generators',
    ['sbz_resources:storinator_public'] = 'qid_public_storinators',

    ['sbz_resources:emittrium_glass'] = 'qid_emittrium_glass',
    ['sbz_bio:dirt'] = 'qid_dirt',
    ['sbz_bio:fertilizer'] = 'qid_sprouting_plants',
    ['sbz_bio:burner'] = 'qid_carbon_dioxide',
    ['sbz_bio:airlock'] = 'qid_airlocks',
    ['sbz_power:fluid_pipe'] = 'qid_fluid_pipes',
    ['sbz_power:pump_off'] = 'qid_fluid_pumps',
    ['sbz_power:fluid_capturer_off'] = 'qid_fluid_capturers',
    ['sbz_power:fluid_tank'] = 'qid_fluid_storage_tanks',
    ['sbz_power:fluid_cell_filler'] = 'qid_fluid_cell_fillers',

    ['sbz_power:reactor_shell'] = 'qid_reactor_shells',
    ['sbz_power:reactor_glass'] = 'qid_reactor_glass',
    ['sbz_power:reactor_infoscreen'] = 'qid_reactor_infoscreens',
    ['sbz_power:reactor_power_port'] = 'qid_reactor_power_ports',
    ['sbz_power:reactor_coolant_port'] = 'qid_reactor_coolant_ports',
    ['sbz_power:reactor_item_input'] = 'qid_reactor_emittrium_input',
    ['sbz_power:reactor_core_off'] = 'qid_reactor_core',

    ['sbz_power:ele_fab_off'] = 'qid_ele_fabs',
    ['sbz_logic:knowledge_station'] = 'qid_knowledge_stations',

    ['sbz_decor:matter_sign'] = 'qid_signs',
    ['sbz_decor:antimatter_sign'] = 'qid_signs',
    ['sbz_decor:cnc'] = 'qid_cnc_machines',
    ['sbz_power:powered_lamp_off'] = 'qid_powered_lights',
    ['sbz_power:super_powered_lamp_off'] = 'qid_powered_lights',
    ['unifieddyes:coloring_tool'] = 'qid_coloring_tool',
    ['sbz_decor:mystery_terrarium'] = 'qid_mystery_terrarium',
    ['sbz_decor:large_server_rack'] = 'qid_large_server_rack',
    ['unifieddyes:colorium_ground_line'] = 'qid_ground_line',
    ['unifieddyes:power_ground_line'] = 'qid_power_ground_line',
    ['unifieddyes:antiblock'] = 'qid_antiblocks',
    ['sbz_resources:jetpack'] = 'qid_jetpack',
    ['sbz_resources:drill'] = 'qid_electric_drill',
    ['sbz_meteorites:meteorite_maker_off'] = 'qid_meteorite_maker',
    ['sbz_resources:strange_cleaner'] = 'qid_strange_blob_cleaner',
    ['sbz_bio:fertilized_dirt'] = 'qid_fertilized_dirt',
    ['sbz_resources:laser_weapon'] = 'qid_laser',

    ['sbz_resources:storinator_bronze'] = 'qid_better_storinators',
    ['sbz_resources:storinator_neutronium'] = 'qid_best_storinators',
    ['drawers:drawer1'] = 'qid_drawers',
    ['drawers:drawer2'] = 'qid_drawers',
    ['drawers:drawer4'] = 'qid_drawers',
    ['drawers:upgrade_template'] = 'qid_drawer_upgrades',
    ['drawers:controller'] = 'qid_drawer_controller',
    ['sbz_chem:compressor_off'] = 'qid_compressor',
    ['sbz_chem:crystal_grower_off'] = 'qid_crystal_grower',
    ['sbz_power:very_advanced_battery'] = 'qid_very_advanced_batteries',

    ['jumpdrive:backbone'] = 'qid_jumpdrive_backbone',
    ['jumpdrive:fleet_controller'] = 'qid_jumpdrive_fleet_controller',
    ['jumpdrive:engine'] = 'qid_the_jumpdrive_engine',
    ['jumpdrive:warp_device'] = 'qid_warp_device',
    ['jumpdrive:station'] = 'qid_jumpdrive_stations',

    ['sbz_bio:dna_extractor_off'] = 'qid_dna_extractor',
    ['sbz_chem:centrifuge_off'] = 'qid_centrifuge',
    ['sbz_power:phlogiston_fuser_off'] = 'qid_phlogiston_fuser',
    ['sbz_planets:planet_teleporter'] = 'qid_planet_teleporter',
    ['sbz_chem:pebble_enhancer_off'] = 'qid_pebble_enhancer',
    ['sbz_chem:nuclear_reactor_off'] = 'qid_nuclear_reactor',
    ['pipeworks:teleport_tube_1'] = 'qid_teleport_tubes',
    ['sbz_chem:decay_accel_off'] = 'qid_decay_accelerator',
    ['sbz_power:turret'] = 'qid_automatic_turrets',
    ['sbz_bio:co2_compactor'] = 'qid_co2_compactors',
    ['sbz_wrench:wrench'] = 'qid_node_preserver',
    ['replacer:replacer'] = 'qid_bulk_placer_tool',
    ['metatool:copytool'] = 'qid_copy_tool',
    ['sbz_bio:neutron_emitter_off'] = 'qid_basic_neutron_emitter',
    ['sbz_bio:electric_soil_off'] = 'qid_electric_soil',
    ['sbz_chem:engraver_off'] = 'qid_engraver',
    ['sbz_multiblocks:blast_furnace_controller'] = 'qid_blast_furnace',
    ['sbz_instatube:instant_tube'] = 'qid_instatubes',
    ['sbz_power:teleport_battery'] = 'qid_teleport_battery',
    ['pipeworks:pattern_storinator'] = 'qid_pattern_storinator',
    ['sbz_power:starlight_catcher'] = 'qid_starlight_catchers',

    ['sbz_resources:gravitational_lens'] = 'qid_gravitational_lens',

    ['sbz_power:sensor_linker'] = 'qid_sensor_linker',
    ['sbz_power:lgate_buffer_off'] = 'qid_logic_gates',
    ['sbz_power:delayer_off'] = 'qid_delayer',
    ['sbz_power:light_sensor_off'] = 'qid_light_sensor',
    ['sbz_power:node_sensor_off'] = 'qid_node_sensor',
    ['sbz_power:item_sensor_off'] = 'qid_item_sensor',
    ['sbz_power:switch_private_off'] = 'qid_switches',

    ['sbz_power:manual_crafter'] = 'qid_manual_crafters',
    ['sbz_resources:nuclear_crafting_processor'] = 'qid_craftageddon',
    ['sbz_area_containers:room_container'] = 'qid_room_containers',
}

core.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    local achievement_name = achievement_table[itemstack:get_name()]
    if achievement_name then
        unlock_achievement(player:get_player_name(), achievement_name)
    end
end)

-- overridden by sbz later
---@diagnostic disable-next-line: duplicate-set-field
function sbz_api.activate_safetynet(player_name, pos)
    return true
end

core.register_globalstep(function(dtime)
    for _, player in ipairs(core.get_connected_players()) do
        local pos = player:get_pos()
        local safetynet_low = 0
        if pos.y < safetynet_low - 100 then unlock_achievement(player:get_player_name(), 'qid_emptiness') end
        if pos.y < safetynet_low - 300 then
            if sbz_api.activate_safetynet(player:get_player_name(), pos) then
                sbz_api.displayDialogLine(player:get_player_name(), S('You fell off the platform.'))
                player:set_pos { x = 0, y = 1, z = 0 }

                -- Singularity Rune drop
                if math.random(1, 50000) == 1 then -- 1/50k
                    local rune = ItemStack("sbz_runes:singularity_rune")
                    local inv = player:get_inventory()
                    local rune_leftover = inv:add_item("main", rune)

                    if not rune_leftover:is_empty() then
                        core.add_item(pos, rune_leftover)
                    end

                    core.chat_send_all(S('⌠ Crazy Rare Drop: @1 just dropped a Singularity Rune! ⌡',
                        player:get_player_name()))
                end
            end
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
    ['sbz_chem:gold_powder'] = 'qid_its_fake',
    ['sbz_chem:bronze_powder'] = 'qid_bronze_age',
    ['sbz_chem:water_fluid_cell'] = 'qid_liquid_water',
    ['sbz_bio:stemfruit'] = 'qid_stemfruit',
    ['sbz_bio:warpshroom'] = 'qid_warpshrooms',
    ['sbz_chem:uranium_powder'] = 'qid_planet_ores',
    ['sbz_chem:thorium_powder'] = 'qid_planet_ores',
    ['sbz_resources:movable_emitter'] = 'qid_movable_emitters',
    ['sbz_bio:colorium_emitter'] = 'qid_colorium_emitters',
    ['sbz_power:solid_charged_field'] = 'qid_radiation_shielding',
    ['sbz_resources:bomb'] = 'qid_tnt',
    ['sbz_chem:lead_block'] = 'qid_radiation_shielding',
    ['sbz_resources:strange_blob'] = 'qid_its_strange',
    ['sbz_bio:cleargrass'] = 'qid_cleargrass',
    ['sbz_bio:razorgrass'] = 'qid_razorgrass',
    ['sbz_bio:shockshroom'] = 'qid_shockshrooms',

    ['sbz_resources:dust'] = 'qid_dust',
    -- ['sbz_resources:clay'] = 'qid_clay', This was removed from the QB
    ['sbz_resources:bricks'] = 'qid_bricks',

    ['sbz_resources:unrefined_firmament'] = 'qid_firmament',
    ['sbz_resources:refined_firmament'] = 'qid_refined_firmament',
    ['sbz_resources:wormhole'] = 'qid_wormhole',
}

local achievement_on_dig_table = {
    ['sbz_meteorites:antineutronium'] = 'qid_antineutronium',
    ['sbz_resources:strange_blob'] = 'qid_its_strange',
    ['sbz_resources:movable_emitter'] = 'qid_movable_emitters',
    ['sbz_bio:colorium_emitter'] = 'qid_colorium_emitters',
    ['sbz_power:solid_charged_field'] = 'qid_radiation_shielding',
    ['sbz_resources:bomb'] = 'qid_tnt',
    ['sbz_bio:cleargrass_4'] = 'qid_cleargrass',
    ['sbz_bio:razorgrass_4'] = 'qid_razorgrass',
    ['sbz_bio:shockshroom_4'] = 'qid_shockshrooms',
}

-- TODO: Make quest entry for 'Clay' (ID: qid_clay)  ...but only if that's an intended quest at some point.

-- TODO: Remove requirement of Clay (ID: qid_clay) from Bricks (ID: qid_bricks) if Clay won't be a quest.

-- TODO: Make a condition to trigger the Obtain Emittrium (ID: qid_obtain_emittrium) quest

core.register_on_player_inventory_action(function(player, action, inv, inv_info)
    local itemstack
    if action == 'move' then
        itemstack = inv:get_stack(inv_info.to_list, inv_info.to_index)
    else
        itemstack = inv_info.stack
    end
    local player_name = player:get_player_name()
    local itemname = itemstack:get_name()
    local achievement_name = achievement_in_inventory_table[itemname]
    if achievement_name then
        unlock_achievement(player_name, achievement_name)
    end
end)

core.register_on_dignode(function(pos, oldnode, digger)
    if digger ~= nil and digger:is_valid() then
        local player_name = digger:get_player_name()
        local itemname = oldnode.name
        local achievement_name = achievement_on_dig_table[itemname]
        if achievement_name then
            unlock_achievement(player_name, achievement_name)
        end
    end
end)

-- core.register_on_placenode(function(pos, newnode, _, _, _, _)
--     if newnode.name == "sbz_resources:emitter" then return end
-- if pos.y >= sbz_progression.lowest_node then return end
-- sbz_progression.lowest_node = pos.y
-- mod_storage:set_int("lowest_node", pos.y)
-- end)
