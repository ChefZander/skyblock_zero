quests = {}
local S = core.get_translator('sbz_progression')
-- Index for faster lookups when patching-in the translations
local quest_id_index = {}

function sbz_api.register_quest(def)
    quests[#quests + 1] = def
    quest_id_index[def.id] = #quests
end

local quest_files = {
    'Introduction',
    'Emittrium',
    'Chemistry',
    'Storage',
    'Meteorites',
    'Organics',
    'Decorator',
    'Pipeworks_and_fluid_transport',
    'Reactor',
    'Jumpdrive',
    'Sensors',
    'Secrets',
    'Status_Effects',
}

--- Use markdown instead!
--- So sbz_api.quests_from_file_md
---@deprecated
function sbz_api.quests_from_file(path)
    table.foreach(assert(loadfile(path))(), sbz_api.register_quest, true)
end

-- Parses a markdown file and returns the quest list, or nil if the file doesn't exist.
local function parse_md_file(path)
    local file = io.open(path)
    if not file then return nil end
    local qdata = sbz_api.quest_parser.decode(file:read '*a')
    file:close()
    return qdata
end

local modpath = core.get_modpath('sbz_progression')
local t0 = core.get_us_time()

-- Load the canonical English files first.
-- These establish all quest IDs — every other language patches on top of this.
table.foreach(quest_files, function(name)
    local path = modpath .. '/quests/en/' .. name .. '.md'
    local qdata = parse_md_file(path)
    assert(qdata, '[sbz_progression] Missing required English quest file: ' .. path)
    table.foreach(qdata, sbz_api.register_quest, true)
end, true)

-- The Credits quest is hardcoded so that developer names and quotes can be
-- handled carefully. Only the surrounding prose is wrapped in S().
sbz_api.register_quest({
    id         = 'qid_credits',
    type       = 'secret',
    istoplevel = true,
    title      = 'Credits',
    text       =
        S('Thank you for playing Skyblock: Zero. '
            ..
            'You demonstrated extreme logical thinking skills, planning skills, and invested probably at least a couple of hours into our game. '
            .. 'We hope you enjoyed this current version, because there will be more coming.')
        .. '\n- Zander\n'
        .. '\n'
        ..
        S(
            'Below is a list of all the people who helped work on the game, optionally, along with a quote by the respective developer.')
        .. '\n\n'
        -- Note to developers: Feel free to add yourself to the list if you're new, along with a quote.
        -- If you're already on the list, feel free to edit your quote as well. (But not other people's)
        .. S("Developers & Contributors") .. "\n"
        .. "- Zander \"Removing Global Power is the worst thing to have happened to Skyblock: Zero\"\n"
        .. "- frogTheSecond\n"
        .. "- theidealist\n"
        .. "- birdlover32767\n"
        .. "- ACorp \"0 coolant - not great, not terrible\"\n"
        .. "- lnee\n"
        .. "- The4codeblocks\n"
        .. "- watilin\n"
        .. "- Aredron\n"
        .. "- 0je\n"
        .. "- JustAPotota\n"
        .. "- Kycilak\n"
        .. "- cx384\n"
        .. "- AbbyRead\n"
        .. "- jack-obrien\n"
        .. "- gamefreq0\n"
        .. "\n"
        .. S("Submodule Contributors") .. "\n"
        .. "- SmallJoker\n"
        .. "- SwissalpS\n"
        .. "- lumberjackgames\n"
        .. "- Emojigit\n"
        .. "\n"
        .. S("Translators") .. "\n"
        .. S(
            "There's not been any work to translate the game outside of English. Maybe your name will one day show up here?")
        .. '\n\n'
        .. S("Menu & In-Game Music") .. "\n"
        .. "- 'Tragic ambient main menu' by Brandon Morris (Menu Music)\n"
        .. "- 'Cave Theme' by Brandon Morris\n"
        .. "- 'Background space track' by yd\n"
        .. "- 'Bleeding Out' by Brandon Morris\n"
        .. "- 'Factory Ambiance' by yd\n"
        .. "- 'Galactic Temple' by yd\n"
        .. "- 'A Choice With Many Regrets' by Tsorthan Grove\n"
        .. "\n"
        .. S("Skybox was made by StumpyStrust.") .. "\n"
        .. "\n"
        .. S("You've finished the Questbook, but the game has only just begun.")
        .. "\n",
})

-- Load translations for all supported languages.
-- Translated title and text are stored in .title_localized[lang] and .text_localized[lang],
--  so all languages coexist on the quest object; the display code picks the right one at runtime.
-- Logic fields (.id, .requires, .type) are never touched.
-- Add new language codes here as translators contribute files.
-- `x-` prefix marks a private use language code (must be specified in minetest.conf, e.g.: language = x-pirate)
local supported_languages = { 'x-pirate', 'x-pig-latin' }

for _, lang in ipairs(supported_languages) do
    for _, name in ipairs(quest_files) do
        local path = modpath .. '/quests/' .. lang .. '/' .. name .. '.md'
        local qdata = parse_md_file(path)

        if qdata == nil then
            core.log('warning',
                ('[sbz_progression] No %s translation found for %s.md — falling back to English'):format(lang, name)
            )
        else
            for _, translated_quest in ipairs(qdata) do
                local idx = quest_id_index[translated_quest.id]
                if idx then
                    -- Patch display fields only. Logic fields (.id, .requires, .type) are untouched.
                    quests[idx].title_localized = quests[idx].title_localized or {}
                    quests[idx].title_localized[lang] = translated_quest.title

                    quests[idx].text_localized = quests[idx].text_localized or {}
                    quests[idx].text_localized[lang] = translated_quest.text
                else
                    core.log('warning',
                        ('[sbz_progression] Translation references unknown quest ID "%s" in %s/%s.md — skipped'):format(
                            translated_quest.id, lang, name
                        )
                    )
                end
            end
        end
    end
end

core.log('action', 'Loading quests from markdown took: ' .. ((core.get_us_time() - t0) / 1000) .. 'ms')

-- ============================================================
-- One-time migration: old metadata keys were English display
-- titles (e.g. "Jumpdrive Backbone"). New keys are qid_ slugs
-- (e.g. "qid_jumpdrive_backbone"). This block runs once per
-- player on join and rewrites any old-format keys it finds.
--
-- This table and the register_on_joinplayer block below may be
-- removed once all live players have been migrated.
-- ============================================================
local legacy_key_map = {
    ['A bigger platform']          = 'qid_a_bigger_platform',
    ['Matter Stairs']              = 'qid_matter_stairs',
    ['Antimatter']                 = 'qid_antimatter',
    ['Annihilator']                = 'qid_annihilator',
    ['Charged Field']              = 'qid_charged_field',
    ['Automation']                 = 'qid_automation',
    ['Advanced Extractors']        = 'qid_advanced_extractors',
    ['Circuitry']                  = 'qid_circuitry',
    ['Generators']                 = 'qid_generators',
    ['Matter Plates']              = 'qid_matter_plates',
    ['Retaining Circuits']         = 'qid_retaining_circuits',
    ['Storinators']                = 'qid_storinators',
    ['Pretty Pebbles']             = 'qid_pretty_pebbles',
    ['Concrete Plan']              = 'qid_concrete_plan',
    ['Compressed Core Dust']       = 'qid_compressed_core_dust',
    ['Photon Lamps']               = 'qid_photon_lamps',
    ['More Antimatter']            = 'qid_more_antimatter',
    ['Anti-Annihilator']           = 'qid_anti_annihilator',
    ['Emitter Imitators']          = 'qid_emitter_imitators',
    ['Factory Flooring']           = 'qid_factory_flooring',
    ['Tiled Factory Flooring']     = 'qid_tiled_factory_flooring',
    ['Factory Ventilator']         = 'qid_factory_ventilator',
    ['Emittrium Circuits']         = 'qid_emittrium_circuits',
    ["Angel's Wing"]               = 'qid_angels_wing',
    ['Batteries']                  = 'qid_batteries',
    ['Advanced Batteries']         = 'qid_advanced_batteries',
    ['Connectors']                 = 'qid_connectors',
    ['Phosphor']                   = 'qid_phosphor',
    ['Power Cables']               = 'qid_power_cables',
    ['Starlight Collectors']       = 'qid_starlight_collectors',
    ['Reinforced Matter']          = 'qid_reinforced_matter',
    ['Switching Station']          = 'qid_switching_station',
    ['Infinite Storinators']       = 'qid_infinite_storinators',
    ['Crusher']                    = 'qid_crusher',
    ['Simple Alloy Furnace']       = 'qid_simple_alloy_furnace',
    ['Meteorites']                 = 'qid_meteorites',
    ['Neutronium']                 = 'qid_neutronium',
    ['Bear Arms']                  = 'qid_bear_arms',
    ['Automatic Filter-Injectors'] = 'qid_automatic_filter_injectors',
    ['Tubes']                      = 'qid_tubes',
    ['One Direction Tubes']        = 'qid_one_direction_tubes',
    ['Node Breakers']              = 'qid_node_breakers',
    ['Deployers']                  = 'qid_deployers',
    ['Punchers']                   = 'qid_punchers',
    ['Autocrafters']               = 'qid_autocrafters',
    ['Simple Crafting Processors'] = 'qid_simple_crafting_processors',
    ['Item Voids']                 = 'qid_item_voids',
    ['Item Vacuums']               = 'qid_item_vacuums',
    ['Screwdriver']                = 'qid_screwdriver',
    ['Furnace']                    = 'qid_furnace',
    ['Small Protectors']           = 'qid_small_protectors',
    ['Big Protectors']             = 'qid_big_protectors',
    ['Antimatter Generators']      = 'qid_antimatter_generators',
    ['Public Storinators']         = 'qid_public_storinators',
    ['Emittrium Glass']            = 'qid_emittrium_glass',
    ['Dirt']                       = 'qid_dirt',
    ['Sprouting Plants']           = 'qid_sprouting_plants',
    ['Carbon Dioxide']             = 'qid_carbon_dioxide',
    ['Airlocks']                   = 'qid_airlocks',
    ['Fluid Pipes']                = 'qid_fluid_pipes',
    ['Fluid Pumps']                = 'qid_fluid_pumps',
    ['Fluid Capturers']            = 'qid_fluid_capturers',
    ['Fluid Storage Tanks']        = 'qid_fluid_storage_tanks',
    ['Fluid Cell Fillers']         = 'qid_fluid_cell_fillers',
    ['Reactor Shells']             = 'qid_reactor_shells',
    ['Reactor Glass']              = 'qid_reactor_glass',
    ['Reactor Infoscreens']        = 'qid_reactor_infoscreens',
    ['Reactor Power Ports']        = 'qid_reactor_power_ports',
    ['Reactor Coolant Ports']      = 'qid_reactor_coolant_ports',
    ['Reactor Emittrium Input']    = 'qid_reactor_emittrium_input',
    ['Reactor Core']               = 'qid_reactor_core',
    ['Ele Fabs']                   = 'qid_ele_fabs',
    ['Knowledge Stations']         = 'qid_knowledge_stations',
    ['Signs']                      = 'qid_signs',
    ['CNC Machines']               = 'qid_cnc_machines',
    ['Powered Lights']             = 'qid_powered_lights',
    ['Coloring Tool']              = 'qid_coloring_tool',
    ['Mystery Terrarium']          = 'qid_mystery_terrarium',
    ['Large Server Rack']          = 'qid_large_server_rack',
    ['Ground Line']                = 'qid_ground_line',
    ['Power Ground Line']          = 'qid_power_ground_line',
    ['Antiblocks']                 = 'qid_antiblocks',
    ['Jetpack']                    = 'qid_jetpack',
    ['Electric Drill']             = 'qid_electric_drill',
    ['Meteorite Maker']            = 'qid_meteorite_maker',
    ['Strange Blob Cleaner']       = 'qid_strange_blob_cleaner',
    ['Fertilized Dirt']            = 'qid_fertilized_dirt',
    ['Laser']                      = 'qid_laser',
    ['Better Storinators']         = 'qid_better_storinators',
    ['Best Storinators']           = 'qid_best_storinators',
    ['Drawers']                    = 'qid_drawers',
    ['Drawer Upgrades']            = 'qid_drawer_upgrades',
    ['Drawer Controller']          = 'qid_drawer_controller',
    ['Compressor']                 = 'qid_compressor',
    ['Crystal Grower']             = 'qid_crystal_grower',
    ['Very Advanced Batteries']    = 'qid_very_advanced_batteries',
    ['Jumpdrive Backbone']         = 'qid_jumpdrive_backbone',
    ['Jumpdrive Fleet Controller'] = 'qid_jumpdrive_fleet_controller',
    ['The Jumpdrive (engine)']     = 'qid_the_jumpdrive_engine',
    ['Warp Device']                = 'qid_warp_device',
    ['Jumpdrive Stations']         = 'qid_jumpdrive_stations',
    ['Dna Extractor']              = 'qid_dna_extractor',
    ['Centrifuge']                 = 'qid_centrifuge',
    ['Phlogiston Fuser']           = 'qid_phlogiston_fuser',
    ['Planet Teleporter']          = 'qid_planet_teleporter',
    ['Pebble Enhancer']            = 'qid_pebble_enhancer',
    ['Nuclear Reactor']            = 'qid_nuclear_reactor',
    ['Teleport Tubes']             = 'qid_teleport_tubes',
    ['Decay Accelerator']          = 'qid_decay_accelerator',
    ['Automatic Turrets']          = 'qid_automatic_turrets',
    ['CO2 Compactors']             = 'qid_co2_compactors',
    ['Node Preserver']             = 'qid_node_preserver',
    ['Bulk Placer Tool']           = 'qid_bulk_placer_tool',
    ['Copy Tool']                  = 'qid_copy_tool',
    ['Basic Neutron Emitter']      = 'qid_basic_neutron_emitter',
    ['Electric Soil']              = 'qid_electric_soil',
    ['Engraver']                   = 'qid_engraver',
    ['Blast Furnace']              = 'qid_blast_furnace',
    ['Instatubes']                 = 'qid_instatubes',
    ['Teleport Battery']           = 'qid_teleport_battery',
    ['Pattern Storinator']         = 'qid_pattern_storinator',
    ['Starlight Catchers']         = 'qid_starlight_catchers',
    ['Gravitational Lens']         = 'qid_gravitational_lens',
    ['Sensor Linker']              = 'qid_sensor_linker',
    ['Logic Gates']                = 'qid_logic_gates',
    ['Delayer']                    = 'qid_delayer',
    ['Light Sensor']               = 'qid_light_sensor',
    ['Node Sensor']                = 'qid_node_sensor',
    ['Item Sensor']                = 'qid_item_sensor',
    ['Switches']                   = 'qid_switches',
    ['Manual Crafters']            = 'qid_manual_crafters',
    ['Craftageddon']               = 'qid_craftageddon',
    ['Room Containers']            = 'qid_room_containers',
    -- achievement_in_inventory_table
    ["It's fake"]                  = 'qid_its_fake',
    ['Bronze Age']                 = 'qid_bronze_age',
    ['Liquid Water']               = 'qid_liquid_water',
    ['Stemfruit']                  = 'qid_stemfruit',
    ['Warpshrooms']                = 'qid_warpshrooms',
    ['Planet Ores']                = 'qid_planet_ores',
    ['Movable Emitters']           = 'qid_movable_emitters',
    ['Colorium Emitters']          = 'qid_colorium_emitters',
    ['Radiation Shielding']        = 'qid_radiation_shielding',
    ['TNT']                        = 'qid_tnt',
    ["It's strange..."]            = 'qid_its_strange',
    ['Cleargrass']                 = 'qid_cleargrass',
    ['Razorgrass']                 = 'qid_razorgrass',
    ['Shockshrooms']               = 'qid_shockshrooms',
    ['Dust']                       = 'qid_dust',
    ['Bricks']                     = 'qid_bricks',
    ['Firmament']                  = 'qid_firmament',
    ['Refined Firmament']          = 'qid_refined_firmament',
    ['Wormhole']                   = 'qid_wormhole',
    -- achievement_on_dig_table
    ['Antineutronium']             = 'qid_antineutronium',
    -- special
    ['Emptiness']                  = 'qid_emptiness',
    ['Credits']                    = 'qid_credits',
}

core.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    local migrated = 0
    for old_key, new_key in pairs(legacy_key_map) do
        if meta:get_string(old_key) == 'true' then
            meta:set_string(new_key, 'true')
            meta:set_string(old_key, '')
            migrated = migrated + 1
        end
    end
    if migrated > 0 then
        core.log('action',
            ('[sbz_progression] Migrated %d legacy quest key(s) for player "%s"')
            :format(migrated, player:get_player_name())
        )
    end
end)
