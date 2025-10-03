---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Utilities

-- ---------------------------- core.FeatureFlags --------------------------- --

--[[
WIPDOC
]]
---@alias core.FeatureFlags.keys
--- | "glasslike_framed"
--- | "nodebox_as_selectionbox"
--- | "get_all_craft_recipes_works"
--- | "use_texture_alpha"
--- | "no_legacy_abms"
--- | "texture_names_parens"
--- | "area_store_custom_ids"
--- | "add_entity_with_staticdata"
--- | "no_chat_message_prediction"
--- | "object_use_texture_alpha"
--- | "object_independent_selectionbox"
--- | "httpfetch_binary_data"
--- | "formspec_version_element"
--- | "area_store_persistent_ids"
--- | "pathfinder_works"
--- | "object_step_has_moveresult"
--- | "direct_velocity_on_players"
--- | "use_texture_alpha_string_modes"
--- | "degrotate_240_steps"
--- | "abm_min_max_y"
--- | "dynamic_add_media_table"
--- | "particlespawner_tweenable"
--- | "get_sky_as_table"
--- | "get_light_data_buffer"
--- | "mod_storage_on_disk"
--- | "compress_zstd"
--- | "sound_params_start_time"
--- | "physics_overrides_v2"
--- | "hud_def_type_field"
--- | "random_state_restore"
--- | "after_order_expiry_registration"
--- | "wallmounted_rotate"
--- | "item_specific_pointabilities"
--- | "blocking_pointability_type"
--- | "dynamic_add_media_startup"
--- | "dynamic_add_media_filepath"
--- | "lsystem_decoration_type"
--- | "item_meta_range"
--- | "node_interaction_actor"
--- | "moveresult_new_pos"
--- | "override_item_remove_fields"
--- | "hotbar_hud_element"
--- | "bulk_lbms"
--- | "abm_without_neighbors"
--- | "biome_weights"
--- | "particle_blend_clip"
--- | "remove_item_match_meta"
--- | "httpfetch_additional_methods"
--- | "object_guids"
--- | "on_timer_four_args"
--- | "particlespawner_exclude_player"
--- | "generate_decorations_biomes"

--[[
WIPDOC
]]
---@class core.FeatureFlags
core.features = {}

---@class core.FeatureFlags
--[[
0.4.7
]]
---@field   glasslike_framed boolean?
--[[
0.4.7
]]
---@field   nodebox_as_selectionbox boolean?
--[[
0.4.7
]]
---@field   get_all_craft_recipes_works boolean?
--[[
The transparency channel of textures can optionally be used on
nodes (0.4.7)
]]
---@field   use_texture_alpha boolean?
--[[
Tree and grass ABMs are no longer done from C++ (0.4.8)
]]
---@field   no_legacy_abms boolean?
--[[
Texture grouping is possible using parentheses (0.4.11)
]]
---@field   texture_names_parens boolean?
--[[
Unique Area ID for AreaStoreinsert_area (0.4.14)
]]
---@field   area_store_custom_ids boolean?
--[[
add_entity supports passing initial staticdata to on_activate
-- (0.4.16)
]]
---@field   add_entity_with_staticdata boolean?
--[[
Chat messages are no longer predicted (0.4.16)
]]
---@field   no_chat_message_prediction boolean?
--[[
The transparency channel of textures can optionally be used on
objects (ie players and lua entities) (5.0.0)
]]
---@field   object_use_texture_alpha boolean?
--[[
Object selectionbox is settable independently from collisionbox
(5.0.0)
]]
---@field   object_independent_selectionbox boolean?
--[[
SpeeldQcifies whether binary data can be uploaded or downloaded using
the HTTP API (5.1.0)
]]
---@field   httpfetch_binary_data boolean?
--[[
Whether formspec_version[<version>] may be used (5.1.0)
]]
---@field   formspec_version_element boolean?
--[[
Whether AreaStore's IDs are kept on save/load (5.1.0)
]]
---@field   area_store_persistent_ids boolean?
--[[
Whether core.find_path is functional (5.2.0)
]]
---@field   pathfinder_works boolean?
--[[
Whether Collision info is available to an objects' on_step (5.3.0)
]]
---@field   object_step_has_moveresult boolean?
--[[
Whether get_velocity() and add_velocity() can be used on players (5.4.0)
]]
---@field   direct_velocity_on_players boolean?
--[[
nodedef's use_texture_alpha accepts new string modes (5.4.0)
]]
---@field   use_texture_alpha_string_modes boolean?
--[[
degrotate param2 rotates in units of 1.5° instead of 2°
thus changing the range of values from 0-179 to 0-240 (5.5.0)
]]
---@field   degrotate_240_steps boolean?
--[[
ABM supports min_y and max_y fields in definition (5.5.0)
]]
---@field   abm_min_max_y boolean?
--[[
dynamic_add_media supports passing a table with options (5.5.0)
]]
---@field   dynamic_add_media_table boolean?
--[[
particlespawners support texpools and animation of properties,
particle textures support smooth fade and scale animations, and
sprite-sheet particle animations can by synced to the lifetime
of individual particles (5.6.0)
]]
---@field   particlespawner_tweenable boolean?
--[[
allows get_sky to return a table instead of separate values (5.6.0)
]]
---@field   get_sky_as_table boolean?
--[[
VoxelManipget_light_data accepts an optional buffer argument (5.7.0)
]]
---@field   get_light_data_buffer boolean?
--[[
When using a mod storage backend that is not "files" or "dummy",
the amount of data in mod storage is not constrained by
the amount of RAM available. (5.7.0)
]]
---@field   mod_storage_on_disk boolean?
--[[
"zstd" method for compress/decompress (5.7.0)
]]
---@field   compress_zstd boolean?
--[[
Sound parameter tables support start_time (5.8.0)
]]
---@field   sound_params_start_time boolean?
--[[
New fields for set_physics_override speed_climb, speed_crouch,
liquid_fluidity, liquid_fluidity_smooth, liquid_sink,
acceleration_default, acceleration_air (5.8.0)
]]
---@field   physics_overrides_v2 boolean?
--[[
In HUD definitions the field `type` is used and `hud_elem_type` is deprecated (5.9.0)
]]
---@field   hud_def_type_field boolean?
--[[
PseudoRandom and PcgRandom state is restorable
PseudoRandom has get_state method
PcgRandom has get_state and set_state methods (5.9.0)
]]
---@field   random_state_restore boolean?
--[[
core.after guarantees that coexisting jobs are executed primarily
in order of expiry and secondarily in order of registration (5.9.0)
]]
---@field   after_order_expiry_registration boolean?
--[[
wallmounted nodes mounted at floor or ceiling may additionally
be rotated by 90° with special param2 values (5.9.0)
]]
---@field   wallmounted_rotate boolean?
--[[
Availability of the `pointabilities` property in the item definition (5.9.0)
]]
---@field   item_specific_pointabilities boolean?
--[[
Nodes `pointable` property can be `"blocking"` (5.9.0)
]]
---@field   blocking_pointability_type boolean?
--[[
dynamic_add_media can be called at startup when leaving callback as `nil` (5.9.0)
]]
---@field   dynamic_add_media_startup boolean?
--[[
dynamic_add_media supports `filename` and `filedata` parameters (5.9.0)
]]
---@field   dynamic_add_media_filepath boolean?
--[[
L-system decoration type (5.9.0)
]]
---@field   lsystem_decoration_type boolean?
--[[
Overridable pointing range using the itemstack meta key `"range"` (5.9.0)
]]
---@field   item_meta_range boolean?
--[[
Allow passing an optional "actor" ObjectRef to the following functions
core.place_node, core.dig_node, core.punch_node (5.9.0)
]]
---@field   node_interaction_actor boolean?
--[[
"new_pos" field in entity moveresult (5.9.0)
]]
---@field   moveresult_new_pos boolean?
--[[
Allow removing definition fields in `core.override_item` (5.9.0)
]]
---@field   override_item_remove_fields boolean?
--[[
The predefined hotbar is a Lua HUD element of type `hotbar` (5.10.0)
]]
---@field   hotbar_hud_element boolean?
--[[
Bulk LBM support (5.10.0)
]]
---@field   bulk_lbms boolean?
--[[
ABM supports field without_neighbors (5.10.0)
]]
---@field   abm_without_neighbors boolean?
--[[
biomes have a weight parameter (5.11.0)
]]
---@field   biome_weights boolean?
--[[
Particles can specify a "clip" blend mode (5.11.0)
]]
---@field   particle_blend_clip boolean?
--[[
The `match_meta` optional parameter is available for `InvRefremove_item()` (5.12.0)
]]
---@field   remove_item_match_meta boolean?
--[[
The HTTP API supports the HEAD and PATCH methods (5.12.0)
]]
---@field   httpfetch_additional_methods boolean?
--[[
WIPDOC
]]
---@field object_guids boolean?
--[[
The NodeTimer `on_timer` callback is passed additional `node` and `timeout` args (5.14.0)
]]
---@field on_timer_four_args boolean?
--[[
`ParticleSpawner` definition supports `exclude_player` field (5.14.0)
]]
---@field particlespawner_exclude_player boolean?
--[[
core.generate_decorations() supports `use_mapgen_biomes` parameter (5.14.0)
]]
---@field generate_decorations_biomes boolean?

-- ---------------------------- core.* functions ---------------------------- --

--[[
WIPDOC
]]
---@nodiscard
---@param arg core.FeatureFlags
---@return boolean, {}? missing_features
function core.has_feature(arg) end

--[[
WIPDOC
]]
---@nodiscard
---@param arg core.FeatureFlags[]
---@return boolean, core.FeatureFlags missing_features
function core.has_feature(arg) end