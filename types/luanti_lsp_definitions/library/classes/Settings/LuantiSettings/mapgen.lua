---@meta _
-- DRAFT 1 DONE
-- builtin/settingtypes.txt
-- minetest.conf.example

-- Section context mapping:
-- * [Mapgen]: [world_creation]

---@alias _.LuantiSettings.mapgen.keys.noise_params.2d
--- | "mg_biome_np_heat"
--- | "mg_biome_np_heat_blend"
--- | "mg_biome_np_humidity"
--- | "mg_biome_np_humidity_blend"
--- | "mgv5_np_filler_depth"
--- | "mgv5_np_factor"
--- | "mgv5_np_height"
--- | "mgv6_np_terrain_base"
--- | "mgv6_np_terrain_higher"
--- | "mgv6_np_steepness"
--- | "mgv6_np_height_select"
--- | "mgv6_np_mud"
--- | "mgv6_np_beach"
--- | "mgv6_np_biome"
--- | "mgv6_np_cave"
--- | "mgv6_np_humidity"
--- | "mgv6_np_trees"
--- | "mgv6_np_apple_trees"
--- | "mgv7_np_terrain_base"
--- | "mgv7_np_terrain_alt"
--- | "mgv7_np_terrain_persist"
--- | "mgv7_np_height_select"
--- | "mgv7_np_filler_depth"
--- | "mgv7_np_mount_height"
--- | "mgv7_np_ridge_uwater"
--- | "mgcarpathian_np_filler_depth"
--- | "mgcarpathian_np_height1"
--- | "mgcarpathian_np_height2"
--- | "mgcarpathian_np_height3"
--- | "mgcarpathian_np_height4"
--- | "mgcarpathian_np_hills_terrain"
--- | "mgcarpathian_np_ridge_terrain"
--- | "mgcarpathian_np_step_terrain"
--- | "mgcarpathian_np_hills"
--- | "mgcarpathian_np_ridge_mnt"
--- | "mgcarpathian_np_step_mnt"
--- | "mgcarpathian_np_rivers"
--- | "mgflat_np_terrain"
--- | "mgflat_np_filler_depth"
--- | "mgfractal_np_seabed"
--- | "mgfractal_np_filler_depth"
--- | "mgvalleys_np_filler_depth"
--- | "mgvalleys_np_rivers"
--- | "mgvalleys_np_terrain_height"
--- | "mgvalleys_np_valley_depth"
--- | "mgvalleys_np_valley_profile"
--- | "mgvalleys_np_inter_valley_slope"

---@alias _.LuantiSettings.mapgen.keys.noise_params.3d
--- | "mgv5_np_cave1"
--- | "mgv5_np_cave2"
--- | "mgv5_np_cavern"
--- | "mgv5_np_ground"
--- | "mgv5_np_dungeons"
--- | "mgv7_np_mountain"
--- | "mgv7_np_ridge"
--- | "mgv7_np_floatland"
--- | "mgv7_np_cavern"
--- | "mgv7_np_cave1"
--- | "mgv7_np_cave2"
--- | "mgv7_np_dungeons"
--- | "mgcarpathian_np_mnt_var"
--- | "mgcarpathian_np_cave1"
--- | "mgcarpathian_np_cave2"
--- | "mgcarpathian_np_cavern"
--- | "mgcarpathian_np_dungeons"
--- | "mgflat_np_cave1"
--- | "mgflat_np_cave2"
--- | "mgflat_np_cavern"
--- | "mgflat_np_dungeons"
--- | "mgfractal_np_cave1"
--- | "mgfractal_np_cave2"
--- | "mgfractal_np_dungeons"
--- | "mgvalleys_np_cave1"
--- | "mgvalleys_np_cave2"
--- | "mgvalleys_np_cavern"
--- | "mgvalleys_np_inter_valley_fill"
--- | "mgvalleys_np_dungeons"

---@alias _.LuantiSettings.mapgen.keys.vector
--- | "mgfractal_scale"
--- | "mgfractal_offset"

---@alias _.LuantiSettings.mapgen.keys
--- | "fixed_map_seed"
--- | "mg_name"
--- | "water_level"
--- | "max_block_generate_distance"
--- | "mapgen_limit"
--- | "mg_flags"
--- | "mg_biome_np_heat"
--- | "mg_biome_np_heat_blend"
--- | "mg_biome_np_humidity"
--- | "mg_biome_np_humidity_blend"
--- | "mgv5_spflags"
--- | "mgv5_cave_width"
--- | "mgv5_large_cave_depth"
--- | "mgv5_small_cave_num_min"
--- | "mgv5_small_cave_num_max"
--- | "mgv5_large_cave_num_min"
--- | "mgv5_large_cave_num_max"
--- | "mgv5_large_cave_flooded"
--- | "mgv5_cavern_limit"
--- | "mgv5_cavern_taper"
--- | "mgv5_cavern_threshold"
--- | "mgv5_dungeon_ymin"
--- | "mgv5_dungeon_ymax"
--- | "mgv5_np_filler_depth"
--- | "mgv5_np_factor"
--- | "mgv5_np_height"
--- | "mgv5_np_cave1"
--- | "mgv5_np_cave2"
--- | "mgv5_np_cavern"
--- | "mgv5_np_ground"
--- | "mgv5_np_dungeons"
--- | "mgv6_spflags"
--- | "mgv6_freq_desert"
--- | "mgv6_freq_beach"
--- | "mgv6_dungeon_ymin"
--- | "mgv6_dungeon_ymax"
--- | "mgv6_np_terrain_base"
--- | "mgv6_np_terrain_higher"
--- | "mgv6_np_steepness"
--- | "mgv6_np_height_select"
--- | "mgv6_np_mud"
--- | "mgv6_np_beach"
--- | "mgv6_np_biome"
--- | "mgv6_np_cave"
--- | "mgv6_np_humidity"
--- | "mgv6_np_trees"
--- | "mgv6_np_apple_trees"
--- | "mgv7_spflags"
--- | "mgv7_mount_zero_level"
--- | "mgv7_floatland_ymin"
--- | "mgv7_floatland_ymax"
--- | "mgv7_floatland_taper"
--- | "mgv7_float_taper_exp"
--- | "mgv7_floatland_density"
--- | "mgv7_floatland_ywater"
--- | "mgv7_cave_width"
--- | "mgv7_large_cave_depth"
--- | "mgv7_small_cave_num_min"
--- | "mgv7_small_cave_num_max"
--- | "mgv7_large_cave_num_min"
--- | "mgv7_large_cave_num_max"
--- | "mgv7_large_cave_flooded"
--- | "mgv7_cavern_limit"
--- | "mgv7_cavern_taper"
--- | "mgv7_cavern_threshold"
--- | "mgv7_dungeon_ymin"
--- | "mgv7_dungeon_ymax"
--- | "mgv7_np_terrain_base"
--- | "mgv7_np_terrain_alt"
--- | "mgv7_np_terrain_persist"
--- | "mgv7_np_height_select"
--- | "mgv7_np_filler_depth"
--- | "mgv7_np_mount_height"
--- | "mgv7_np_ridge_uwater"
--- | "mgv7_np_mountain"
--- | "mgv7_np_ridge"
--- | "mgv7_np_floatland"
--- | "mgv7_np_cavern"
--- | "mgv7_np_cave1"
--- | "mgv7_np_cave2"
--- | "mgv7_np_dungeons"
--- | "mgcarpathian_spflags"
--- | "mgcarpathian_base_level"
--- | "mgcarpathian_river_width"
--- | "mgcarpathian_river_depth"
--- | "mgcarpathian_valley_width"
--- | "mgcarpathian_cave_width"
--- | "mgcarpathian_large_cave_depth"
--- | "mgcarpathian_small_cave_num_min"
--- | "mgcarpathian_small_cave_num_max"
--- | "mgcarpathian_large_cave_num_min"
--- | "mgcarpathian_large_cave_num_max"
--- | "mgcarpathian_large_cave_flooded"
--- | "mgcarpathian_cavern_limit"
--- | "mgcarpathian_cavern_taper"
--- | "mgcarpathian_cavern_threshold"
--- | "mgcarpathian_dungeon_ymin"
--- | "mgcarpathian_dungeon_ymax"
--- | "mgcarpathian_np_filler_depth"
--- | "mgcarpathian_np_height1"
--- | "mgcarpathian_np_height2"
--- | "mgcarpathian_np_height3"
--- | "mgcarpathian_np_height4"
--- | "mgcarpathian_np_hills_terrain"
--- | "mgcarpathian_np_ridge_terrain"
--- | "mgcarpathian_np_step_terrain"
--- | "mgcarpathian_np_hills"
--- | "mgcarpathian_np_ridge_mnt"
--- | "mgcarpathian_np_step_mnt"
--- | "mgcarpathian_np_rivers"
--- | "mgcarpathian_np_mnt_var"
--- | "mgcarpathian_np_cave1"
--- | "mgcarpathian_np_cave2"
--- | "mgcarpathian_np_cavern"
--- | "mgcarpathian_np_dungeons"
--- | "mgflat_spflags"
--- | "mgflat_ground_level"
--- | "mgflat_large_cave_depth"
--- | "mgflat_small_cave_num_min"
--- | "mgflat_small_cave_num_max"
--- | "mgflat_large_cave_num_min"
--- | "mgflat_large_cave_num_max"
--- | "mgflat_large_cave_flooded"
--- | "mgflat_cave_width"
--- | "mgflat_lake_threshold"
--- | "mgflat_lake_steepness"
--- | "mgflat_hill_threshold"
--- | "mgflat_hill_steepness"
--- | "mgflat_cavern_limit"
--- | "mgflat_cavern_taper"
--- | "mgflat_cavern_threshold"
--- | "mgflat_dungeon_ymin"
--- | "mgflat_dungeon_ymax"
--- | "mgflat_np_terrain"
--- | "mgflat_np_filler_depth"
--- | "mgflat_np_cave1"
--- | "mgflat_np_cave2"
--- | "mgflat_np_cavern"
--- | "mgflat_np_dungeons"
--- | "mgfractal_spflags"
--- | "mgfractal_cave_width"
--- | "mgfractal_large_cave_depth"
--- | "mgfractal_small_cave_num_min"
--- | "mgfractal_small_cave_num_max"
--- | "mgfractal_large_cave_num_min"
--- | "mgfractal_large_cave_num_max"
--- | "mgfractal_large_cave_flooded"
--- | "mgfractal_dungeon_ymin"
--- | "mgfractal_dungeon_ymax"
--- | "mgfractal_fractal"
--- | "mgfractal_iterations"
--- | "mgfractal_scale"
--- | "mgfractal_offset"
--- | "mgfractal_slice_w"
--- | "mgfractal_julia_x"
--- | "mgfractal_julia_y"
--- | "mgfractal_julia_z"
--- | "mgfractal_julia_w"
--- | "mgfractal_np_seabed"
--- | "mgfractal_np_filler_depth"
--- | "mgfractal_np_cave1"
--- | "mgfractal_np_cave2"
--- | "mgfractal_np_dungeons"
--- | "mgvalleys_spflags"
--- | "mgvalleys_altitude_chill"
--- | "mgvalleys_large_cave_depth"
--- | "mgvalleys_small_cave_num_min"
--- | "mgvalleys_small_cave_num_max"
--- | "mgvalleys_large_cave_num_min"
--- | "mgvalleys_large_cave_num_max"
--- | "mgvalleys_large_cave_flooded"
--- | "mgvalleys_cavern_limit"
--- | "mgvalleys_cavern_taper"
--- | "mgvalleys_cavern_threshold"
--- | "mgvalleys_river_depth"
--- | "mgvalleys_river_size"
--- | "mgvalleys_cave_width"
--- | "mgvalleys_dungeon_ymin"
--- | "mgvalleys_dungeon_ymax"
--- | "mgvalleys_np_cave1"
--- | "mgvalleys_np_cave2"
--- | "mgvalleys_np_filler_depth"
--- | "mgvalleys_np_cavern"
--- | "mgvalleys_np_rivers"
--- | "mgvalleys_np_terrain_height"
--- | "mgvalleys_np_valley_depth"
--- | "mgvalleys_np_inter_valley_fill"
--- | "mgvalleys_np_valley_profile"
--- | "mgvalleys_np_inter_valley_slope"
--- | "mgvalleys_np_dungeons"

---@class _.LuantiSettings.mapgen.tablefmt : _.LuantiSettings.mapgen, _.LuantiSettings.mapgen.biome_api, _.LuantiSettings.mapgen.mapgen_v5, _.LuantiSettings.mapgen.mapgen_v5.noises, _.LuantiSettings.mapgen.mapgen_v6, _.LuantiSettings.mapgen.mapgen_v6.noises, _.LuantiSettings.mapgen.mapgen_v7, _.LuantiSettings.mapgen.mapgen_v7.noises, _.LuantiSettings.mapgen.mapgen_carpathian, _.LuantiSettings.mapgen.mapgen_carpathian.noises, _.LuantiSettings.mapgen.mapgen_flat, _.LuantiSettings.mapgen.mapgen_flat.noises, _.LuantiSettings.mapgen.mapgen_fractal, _.LuantiSettings.mapgen.mapgen_fractal.noises, _.LuantiSettings.mapgen.mapgen_valleys, _.LuantiSettings.mapgen.mapgen_valleys.noises

-- -------------------------------- [Mapgen] -------------------------------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.mg_name
--- | "v7"
--- | "valleys"
--- | "carpathian"
--- | "v5"
--- | "flat"
--- | "fractal"
--- | "singlenode"
--- | "v6"

---@class _.LuantiSettings.mapgen
--[[
#    A chosen map seed for a new map, leave empty for random.
#    Will be overridden when creating a new world in the main menu.
[world_creation]
(Fixed map seed)
]]
---@field fixed_map_seed string?
--[[
#    Name of map generator to be used when creating a new world.
#    Creating a world in the main menu will override this.
#    Current mapgens in a highly unstable state:
#    -    The optional floatlands of v7 (disabled by default).
[world_creation]
(Mapgen name) v7 v7,valleys,carpathian,v5,flat,fractal,singlenode,v6
]]
---@field mg_name core.LuantiSettings.enums.mg_name?
--[[
#    Water surface level of the world.
[world_creation]
(Water level) 1 -31000 31000
]]
---@field water_level integer?
--[[
#    From how far blocks are generated for clients, stated in mapblocks (16 nodes).
[world_creation]
(Max block generate distance) [server] 10 1 32767
]]
---@field max_block_generate_distance integer?
--[[
#    Limit of map generation, in nodes, in all 6 directions from (0, 0, 0).
#    Only mapchunks completely within the mapgen limit are generated.
#    Value is stored per-world.
[world_creation]
(Map generation limit) 31007 0 31007
]]
---@field mapgen_limit integer?

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.mg_flags
--[[
WIPDOC
]]
---@field caves boolean?
--[[
WIPDOC
]]
---@field nocaves boolean?
--[[
WIPDOC
]]
---@field dungeons boolean?
--[[
WIPDOC
]]
---@field nodungeons boolean?
--[[
WIPDOC
]]
---@field light boolean?
--[[
WIPDOC
]]
---@field nolight boolean?
--[[
WIPDOC
]]
---@field decorations boolean?
--[[
WIPDOC
]]
---@field nodecorations boolean?
--[[
WIPDOC
]]
---@field biomes boolean?
--[[
WIPDOC
]]
---@field nobiomes boolean?
--[[
WIPDOC
]]
---@field ores boolean?
--[[
WIPDOC
]]
---@field noores boolean?

---@class _.LuantiSettings.mapgen
--[[
#    Global map generation attributes.
#    In Mapgen v6 the 'decorations' flag controls all decorations except trees
#    and jungle grass, in all other mapgens this flag controls all decorations.
[world_creation]
(Mapgen flags) caves,dungeons,light,decorations,biomes,ores caves,dungeons,light,decorations,biomes,ores
]]
---@field mg_flags core.LuantiSettings.flags?

-- -------------------------- [Mapgen] [*Biome API] ------------------------- --

---@class _.LuantiSettings.mapgen.biome_api
--[[
#    Temperature variation for biomes.
[world_creation]
(Heat noise) 50, 50, (1000, 1000, 1000), 5349, 3, 0.5, 2.0, eased
]]
---@field mg_biome_np_heat core.NoiseParams.2d?
--[[
#    Small-scale temperature variation for blending biomes on borders.
[world_creation]
(Heat blend noise) 0, 1.5, (8, 8, 8), 13, 2, 1.0, 2.0, eased
]]
---@field mg_biome_np_heat_blend core.NoiseParams.2d?
--[[
#    Humidity variation for biomes.
[world_creation]
(Humidity noise) 50, 50, (1000, 1000, 1000), 842, 3, 0.5, 2.0, eased
]]
---@field mg_biome_np_humidity core.NoiseParams.2d?
--[[
#    Small-scale humidity variation for blending biomes on borders.
[world_creation]
(Humidity blend noise) 0, 1.5, (8, 8, 8), 90003, 2, 1.0, 2.0, eased
]]
---@field mg_biome_np_humidity_blend core.NoiseParams.2d?

-- -------------------------- [Mapgen] [*Mapgen V5] ------------------------- --

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.mgv5_spflags
--[[
WIPDOC
]]
---@field caverns boolean?
--[[
WIPDOC
]]
---@field nocaverns boolean?

---@class _.LuantiSettings.mapgen.mapgen_v5
--[[
#    Map generation attributes specific to Mapgen v5.
[world_creation]
(Mapgen V5 specific flags) caverns caverns
]]
---@field mgv5_spflags core.LuantiSettings.flags?
--[[
#    Controls width of tunnels, a smaller value creates wider tunnels.
#    Value >= 10.0 completely disables generation of tunnels and avoids the
#    intensive noise calculations.
[world_creation]
(Cave width) 0.09
]]
---@field mgv5_cave_width number?
--[[
#    Y of upper limit of large caves.
[world_creation]
(Large cave depth) -256 -31000 31000
]]
---@field mgv5_large_cave_depth integer?
--[[
#    Minimum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave minimum number) 0 0 256
]]
---@field mgv5_small_cave_num_min integer?
--[[
#    Maximum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave maximum number) 0 0 256
]]
---@field mgv5_small_cave_num_max integer?
--[[
#    Minimum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave minimum number) 0 0 64
]]
---@field mgv5_large_cave_num_min integer?
--[[
#    Maximum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave maximum number) 2 0 64
]]
---@field mgv5_large_cave_num_max integer?
--[[
#    Proportion of large caves that contain liquid.
[world_creation]
(Large cave proportion flooded) 0.5 0.0 1.0
]]
---@field mgv5_large_cave_flooded number?
--[[
#    Y-level of cavern upper limit.
[world_creation]
(Cavern limit) -256 -31000 31000
]]
---@field mgv5_cavern_limit integer?
--[[
#    Y-distance over which caverns expand to full size.
[world_creation]
(Cavern taper) 256 0 32767
]]
---@field mgv5_cavern_taper integer?
--[[
#    Defines full size of caverns, smaller values create larger caverns.
[world_creation]
(Cavern threshold) 0.7
]]
---@field mgv5_cavern_threshold number?
--[[
#    Lower Y limit of dungeons.
[world_creation]
(Dungeon minimum Y) -31000 -31000 31000
]]
---@field mgv5_dungeon_ymin integer?
--[[
#    Upper Y limit of dungeons.
[world_creation]
(Dungeon maximum Y) 31000 -31000 31000
]]
---@field mgv5_dungeon_ymax integer?

-- -------------------- [Mapgen] [*Mapgen V5] [**Noises] -------------------- --

---@class _.LuantiSettings.mapgen.mapgen_v5.noises
--[[
#    Variation of biome filler depth.
[world_creation]
(Filler depth noise) 0, 1, (150, 150, 150), 261, 4, 0.7, 2.0, eased
]]
---@field mgv5_np_filler_depth core.NoiseParams.2d?
--[[
#    Variation of terrain vertical scale.
#    When noise is < -0.55 terrain is near-flat.
[world_creation]
(Factor noise) 0, 1, (250, 250, 250), 920381, 3, 0.45, 2.0, eased
]]
---@field mgv5_np_factor core.NoiseParams.2d?
--[[
#    Y-level of average terrain surface.
[world_creation]
(Height noise) 0, 10, (250, 250, 250), 84174, 4, 0.5, 2.0, eased
]]
---@field mgv5_np_height core.NoiseParams.2d?
--[[
#    First of two 3D noises that together define tunnels.
[world_creation]
(Cave1 noise) 0, 12, (61, 61, 61), 52534, 3, 0.5, 2.0
]]
---@field mgv5_np_cave1 core.NoiseParams.3d?
--[[
#    Second of two 3D noises that together define tunnels.
[world_creation]
(Cave2 noise) 0, 12, (67, 67, 67), 10325, 3, 0.5, 2.0
]]
---@field mgv5_np_cave2 core.NoiseParams.3d?
--[[
#    3D noise defining giant caverns.
[world_creation]
(Cavern noise) 0, 1, (384, 128, 384), 723, 5, 0.63, 2.0
]]
---@field mgv5_np_cavern core.NoiseParams.3d?
--[[
#    3D noise defining terrain.
[world_creation]
(Ground noise) 0, 40, (80, 80, 80), 983240, 4, 0.55, 2.0, eased
]]
---@field mgv5_np_ground core.NoiseParams.3d?
--[[
#    3D noise that determines number of dungeons per mapchunk.
[world_creation]
(Dungeon noise) 0.9, 0.5, (500, 500, 500), 0, 2, 0.8, 2.0
]]
---@field mgv5_np_dungeons core.NoiseParams.3d?

-- -------------------------- [Mapgen] [*Mapgen V6] ------------------------- --

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.mgv6_spflags
--[[
WIPDOC
]]
---@field jungles boolean?
--[[
WIPDOC
]]
---@field nojungles boolean?
--[[
WIPDOC
]]
---@field biomeblend boolean?
--[[
WIPDOC
]]
---@field nobiomeblend boolean?
--[[
WIPDOC
]]
---@field mudflow boolean?
--[[
WIPDOC
]]
---@field nomudflow boolean?
--[[
WIPDOC
]]
---@field snowbiomes boolean?
--[[
WIPDOC
]]
---@field nosnowbiomes boolean?
--[[
WIPDOC
]]
---@field flat boolean?
--[[
WIPDOC
]]
---@field noflat boolean?
--[[
WIPDOC
]]
---@field trees boolean?
--[[
WIPDOC
]]
---@field notrees boolean?
--[[
WIPDOC
]]
---@field temples boolean?
--[[
WIPDOC
]]
---@field notemples boolean?

---@class _.LuantiSettings.mapgen.mapgen_v6
--[[
#    Map generation attributes specific to Mapgen v6.
#    The 'snowbiomes' flag enables the new 5 biome system.
#    When the 'snowbiomes' flag is enabled jungles are automatically enabled and
#    the 'jungles' flag is ignored.
#    The 'temples' flag disables generation of desert temples. Normal dungeons will appear instead.
[world_creation]
(Mapgen V6 specific flags) jungles,biomeblend,mudflow,snowbiomes,noflat,trees,temples jungles,biomeblend,mudflow,snowbiomes,flat,trees,temples
]]
---@field mgv6_spflags core.LuantiSettings.flags?
--[[
#    Deserts occur when np_biome exceeds this value.
#    When the 'snowbiomes' flag is enabled, this is ignored.
[world_creation]
(Desert noise threshold) 0.45
]]
---@field mgv6_freq_desert number?
--[[
#    Sandy beaches occur when np_beach exceeds this value.
[world_creation]
(Beach noise threshold) 0.15
]]
---@field mgv6_freq_beach number?
--[[
#    Lower Y limit of dungeons.
[world_creation]
(Dungeon minimum Y) -31000 -31000 31000
]]
---@field mgv6_dungeon_ymin integer?
--[[
#    Upper Y limit of dungeons.
[world_creation]
(Dungeon maximum Y) 31000 -31000 31000
]]
---@field mgv6_dungeon_ymax integer?

-- -------------------- [Mapgen] [*Mapgen V6] [**Noises] -------------------- --

---@class _.LuantiSettings.mapgen.mapgen_v6.noises
--[[
#    Y-level of lower terrain and seabed.
[world_creation]
(Terrain base noise) -4, 20, (250, 250, 250), 82341, 5, 0.6, 2.0, eased
]]
---@field mgv6_np_terrain_base core.NoiseParams.2d?
--[[
#    Y-level of higher terrain that creates cliffs.
[world_creation]
(Terrain higher noise) 20, 16, (500, 500, 500), 85039, 5, 0.6, 2.0, eased
]]
---@field mgv6_np_terrain_higher core.NoiseParams.2d?
--[[
#    Varies steepness of cliffs.
[world_creation]
(Steepness noise) 0.85, 0.5, (125, 125, 125), -932, 5, 0.7, 2.0, eased
]]
---@field mgv6_np_steepness core.NoiseParams.2d?
--[[
#    Defines distribution of higher terrain.
[world_creation]
(Height select noise) 0.5, 1, (250, 250, 250), 4213, 5, 0.69, 2.0, eased
]]
---@field mgv6_np_height_select core.NoiseParams.2d?
--[[
#    Varies depth of biome surface nodes.
[world_creation]
(Mud noise) 4, 2, (200, 200, 200), 91013, 3, 0.55, 2.0, eased
]]
---@field mgv6_np_mud core.NoiseParams.2d?
--[[
#    Defines areas with sandy beaches.
[world_creation]
(Beach noise) 0, 1, (250, 250, 250), 59420, 3, 0.50, 2.0, eased
]]
---@field mgv6_np_beach core.NoiseParams.2d?
--[[
#    Temperature variation for biomes.
[world_creation]
(Biome noise) 0, 1, (500, 500, 500), 9130, 3, 0.50, 2.0, eased
]]
---@field mgv6_np_biome core.NoiseParams.2d?
--[[
#    Variation of number of caves.
[world_creation]
(Cave noise) 6, 6, (250, 250, 250), 34329, 3, 0.50, 2.0, eased
]]
---@field mgv6_np_cave core.NoiseParams.2d?
--[[
#    Humidity variation for biomes.
[world_creation]
(Humidity noise) 0.5, 0.5, (500, 500, 500), 72384, 3, 0.50, 2.0, eased
]]
---@field mgv6_np_humidity core.NoiseParams.2d?
--[[
#    Defines tree areas and tree density.
[world_creation]
(Trees noise) 0, 1, (125, 125, 125), 2, 4, 0.66, 2.0, eased
]]
---@field mgv6_np_trees core.NoiseParams.2d?
--[[
#    Defines areas where trees have apples.
[world_creation]
(Apple trees noise) 0, 1, (100, 100, 100), 342902, 3, 0.45, 2.0, eased
]]
---@field mgv6_np_apple_trees core.NoiseParams.2d?

-- -------------------------- [Mapgen] [*Mapgen V7] ------------------------- --

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.mgv7_spflags
--[[
WIPDOC
]]
---@field mountains boolean?
--[[
WIPDOC
]]
---@field nomountains boolean?
--[[
WIPDOC
]]
---@field ridges boolean?
--[[
WIPDOC
]]
---@field noridges boolean?
--[[
WIPDOC
]]
---@field floatlands boolean?
--[[
WIPDOC
]]
---@field nofloatlands boolean?
--[[
WIPDOC
]]
---@field caverns boolean?
--[[
WIPDOC
]]
---@field nocaverns boolean?

---@class _.LuantiSettings.mapgen.mapgen_v7
--[[
#    Map generation attributes specific to Mapgen v7.
#    'ridges': Rivers.
#    'floatlands': Floating land masses in the atmosphere.
#    'caverns': Giant caves deep underground.
[world_creation]
(Mapgen V7 specific flags) mountains,ridges,nofloatlands,caverns mountains,ridges,floatlands,caverns
]]
---@field mgv7_spflags core.LuantiSettings.flags?
--[[
#    Y of mountain density gradient zero level. Used to shift mountains vertically.
[world_creation]
(Mountain zero level) 0 -31000 31000
]]
---@field mgv7_mount_zero_level integer?
--[[
#    Lower Y limit of floatlands.
[world_creation]
(Floatland minimum Y) 1024 -31000 31000
]]
---@field mgv7_floatland_ymin integer?
--[[
#    Upper Y limit of floatlands.
[world_creation]
(Floatland maximum Y) 4096 -31000 31000
]]
---@field mgv7_floatland_ymax integer?
--[[
#    Y-distance over which floatlands taper from full density to nothing.
#    Tapering starts at this distance from the Y limit.
#    For a solid floatland layer, this controls the height of hills/mountains.
#    Must be less than or equal to half the distance between the Y limits.
[world_creation]
(Floatland tapering distance) 256 0 32767
]]
---@field mgv7_floatland_taper integer?
--[[
#    Exponent of the floatland tapering. Alters the tapering behavior.
#    Value = 1.0 creates a uniform, linear tapering.
#    Values > 1.0 create a smooth tapering suitable for the default separated
#    floatlands.
#    Values < 1.0 (for example 0.25) create a more defined surface level with
#    flatter lowlands, suitable for a solid floatland layer.
[world_creation]
(Floatland taper exponent) 2.0
]]
---@field mgv7_float_taper_exp number?
--[[
#    Adjusts the density of the floatland layer.
#    Increase value to increase density. Can be positive or negative.
#    Value = 0.0: 50% of volume is floatland.
#    Value = 2.0 (can be higher depending on 'mgv7_np_floatland', always test
#    to be sure) creates a solid floatland layer.
[world_creation]
(Floatland density) -0.6
]]
---@field mgv7_floatland_density number?
--[[
#    Surface level of optional water placed on a solid floatland layer.
#    Water is disabled by default and will only be placed if this value is set
#    to above 'mgv7_floatland_ymax' - 'mgv7_floatland_taper' (the start of the
#    upper tapering).
#    ***WARNING, POTENTIAL DANGER TO WORLDS AND SERVER PERFORMANCE***:
#    When enabling water placement, floatlands must be configured and tested
#    to be a solid layer by setting 'mgv7_floatland_density' to 2.0 (or other
#    required value depending on 'mgv7_np_floatland'), to avoid
#    server-intensive extreme water flow and to avoid vast flooding of the
#    world surface below.
[world_creation]
(Floatland water level) -31000 -31000 31000
]]
---@field mgv7_floatland_ywater integer?
--[[
#    Controls width of tunnels, a smaller value creates wider tunnels.
#    Value >= 10.0 completely disables generation of tunnels and avoids the
#    intensive noise calculations.
[world_creation]
(Cave width) 0.09
]]
---@field mgv7_cave_width number?
--[[
#    Y of upper limit of large caves.
[world_creation]
(Large cave depth) -33 -31000 31000
]]
---@field mgv7_large_cave_depth integer?
--[[
#    Minimum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave minimum number) 0 0 256
]]
---@field mgv7_small_cave_num_min integer?
--[[
#    Maximum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave maximum number) 0 0 256
]]
---@field mgv7_small_cave_num_max integer?
--[[
#    Minimum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave minimum number) 0 0 64
]]
---@field mgv7_large_cave_num_min integer?
--[[
#    Maximum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave maximum number) 2 0 64
]]
---@field mgv7_large_cave_num_max integer?
--[[
#    Proportion of large caves that contain liquid.
[world_creation]
(Large cave proportion flooded) 0.5 0.0 1.0
]]
---@field mgv7_large_cave_flooded number?
--[[
#    Y-level of cavern upper limit.
[world_creation]
(Cavern limit) -256 -31000 31000
]]
---@field mgv7_cavern_limit integer?
--[[
#    Y-distance over which caverns expand to full size.
[world_creation]
(Cavern taper) 256 0 32767
]]
---@field mgv7_cavern_taper integer?
--[[
#    Defines full size of caverns, smaller values create larger caverns.
[world_creation]
(Cavern threshold) 0.7
]]
---@field mgv7_cavern_threshold number?
--[[
#    Lower Y limit of dungeons.
[world_creation]
(Dungeon minimum Y) -31000 -31000 31000
]]
---@field mgv7_dungeon_ymin integer?
--[[
#    Upper Y limit of dungeons.
[world_creation]
(Dungeon maximum Y) 31000 -31000 31000
]]
---@field mgv7_dungeon_ymax integer?

-- -------------------- [Mapgen] [*Mapgen V7] [**Noises] -------------------- --

---@class _.LuantiSettings.mapgen.mapgen_v7.noises
--[[
#    Y-level of higher terrain that creates cliffs.
[world_creation]
(Terrain base noise) 4, 70, (600, 600, 600), 82341, 5, 0.6, 2.0, eased
]]
---@field mgv7_np_terrain_base core.NoiseParams.2d?
--[[
#    Y-level of lower terrain and seabed.
[world_creation]
(Terrain alternative noise) 4, 25, (600, 600, 600), 5934, 5, 0.6, 2.0, eased
]]
---@field mgv7_np_terrain_alt core.NoiseParams.2d?
--[[
#    Varies roughness of terrain.
#    Defines the 'persistence' value for terrain_base and terrain_alt noises.
[world_creation]
(Terrain persistence noise) 0.6, 0.1, (2000, 2000, 2000), 539, 3, 0.6, 2.0, eased
]]
---@field mgv7_np_terrain_persist core.NoiseParams.2d?
--[[
#    Defines distribution of higher terrain and steepness of cliffs.
[world_creation]
(Height select noise) -8, 16, (500, 500, 500), 4213, 6, 0.7, 2.0, eased
]]
---@field mgv7_np_height_select core.NoiseParams.2d?
--[[
#    Variation of biome filler depth.
[world_creation]
(Filler depth noise) 0, 1.2, (150, 150, 150), 261, 3, 0.7, 2.0, eased
]]
---@field mgv7_np_filler_depth core.NoiseParams.2d?
--[[
#    Variation of maximum mountain height (in nodes).
[world_creation]
(Mountain height noise) 256, 112, (1000, 1000, 1000), 72449, 3, 0.6, 2.0, eased
]]
---@field mgv7_np_mount_height core.NoiseParams.2d?
--[[
#    Defines large-scale river channel structure.
[world_creation]
(Ridge underwater noise) 0, 1, (1000, 1000, 1000), 85039, 5, 0.6, 2.0, eased
]]
---@field mgv7_np_ridge_uwater core.NoiseParams.2d?
--[[
#    3D noise defining mountain structure and height.
#    Also defines structure of floatland mountain terrain.
[world_creation]
(Mountain noise) -0.6, 1, (250, 350, 250), 5333, 5, 0.63, 2.0
]]
---@field mgv7_np_mountain core.NoiseParams.3d?
--[[
#    3D noise defining structure of river canyon walls.
[world_creation]
(Ridge noise) 0, 1, (100, 100, 100), 6467, 4, 0.75, 2.0
]]
---@field mgv7_np_ridge core.NoiseParams.3d?
--[[
#    3D noise defining structure of floatlands.
#    If altered from the default, the noise 'scale' (0.7 by default) may need
#    to be adjusted, as floatland tapering functions best when this noise has
#    a value range of approximately -2.0 to 2.0.
[world_creation]
(Floatland noise) 0, 0.7, (384, 96, 384), 1009, 4, 0.75, 1.618
]]
---@field mgv7_np_floatland core.NoiseParams.3d?
--[[
#    3D noise defining giant caverns.
[world_creation]
(Cavern noise) 0, 1, (384, 128, 384), 723, 5, 0.63, 2.0
]]
---@field mgv7_np_cavern core.NoiseParams.3d?
--[[
#    First of two 3D noises that together define tunnels.
[world_creation]
(Cave1 noise) 0, 12, (61, 61, 61), 52534, 3, 0.5, 2.0
]]
---@field mgv7_np_cave1 core.NoiseParams.3d?
--[[
#    Second of two 3D noises that together define tunnels.
[world_creation]
(Cave2 noise) 0, 12, (67, 67, 67), 10325, 3, 0.5, 2.0
]]
---@field mgv7_np_cave2 core.NoiseParams.3d?
--[[
#    3D noise that determines number of dungeons per mapchunk.
[world_creation]
(Dungeon noise) 0.9, 0.5, (500, 500, 500), 0, 2, 0.8, 2.0
]]
---@field mgv7_np_dungeons core.NoiseParams.3d?

-- ---------------------- [Mapgen] [*Mapgen Carpathian] --------------------- --

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.mgcarpathian_spflags
--[[
WIPDOC
]]
---@field caverns boolean?
--[[
WIPDOC
]]
---@field nocaverns boolean?
--[[
WIPDOC
]]
---@field rivers boolean?
--[[
WIPDOC
]]
---@field norivers boolean?

---@class _.LuantiSettings.mapgen.mapgen_carpathian
--[[
#    Map generation attributes specific to Mapgen Carpathian.
[world_creation]
(Mapgen Carpathian specific flags) caverns,norivers caverns,rivers
]]
---@field mgcarpathian_spflags core.LuantiSettings.flags?
--[[
#    Defines the base ground level.
[world_creation]
(Base ground level) 12.0
]]
---@field mgcarpathian_base_level number?
--[[
#    Defines the width of the river channel.
[world_creation]
(River channel width) 0.05
]]
---@field mgcarpathian_river_width number?
--[[
#    Defines the depth of the river channel.
[world_creation]
(River channel depth) 24.0
]]
---@field mgcarpathian_river_depth number?
--[[
#    Defines the width of the river valley.
[world_creation]
(River valley width) 0.25
]]
---@field mgcarpathian_valley_width number?
--[[
#    Controls width of tunnels, a smaller value creates wider tunnels.
#    Value >= 10.0 completely disables generation of tunnels and avoids the
#    intensive noise calculations.
[world_creation]
(Cave width) 0.09
]]
---@field mgcarpathian_cave_width number?
--[[
#    Y of upper limit of large caves.
[world_creation]
(Large cave depth) -33 -31000 31000
]]
---@field mgcarpathian_large_cave_depth integer?
--[[
#    Minimum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave minimum number) 0 0 256
]]
---@field mgcarpathian_small_cave_num_min integer?
--[[
#    Maximum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave maximum number) 0 0 256
]]
---@field mgcarpathian_small_cave_num_max integer?
--[[
#    Minimum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave minimum number) 0 0 64
]]
---@field mgcarpathian_large_cave_num_min integer?
--[[
#    Maximum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave maximum number) 2 0 64
]]
---@field mgcarpathian_large_cave_num_max integer?
--[[
#    Proportion of large caves that contain liquid.
[world_creation]
(Large cave proportion flooded) 0.5 0.0 1.0
]]
---@field mgcarpathian_large_cave_flooded number?
--[[
#    Y-level of cavern upper limit.
[world_creation]
(Cavern limit) -256 -31000 31000
]]
---@field mgcarpathian_cavern_limit integer?
--[[
#    Y-distance over which caverns expand to full size.
[world_creation]
(Cavern taper) 256 0 32767
]]
---@field mgcarpathian_cavern_taper integer?
--[[
#    Defines full size of caverns, smaller values create larger caverns.
[world_creation]
(Cavern threshold) 0.7
]]
---@field mgcarpathian_cavern_threshold number?
--[[
#    Lower Y limit of dungeons.
[world_creation]
(Dungeon minimum Y) -31000 -31000 31000
]]
---@field mgcarpathian_dungeon_ymin integer?
--[[
#    Upper Y limit of dungeons.
[world_creation]
(Dungeon maximum Y) 31000 -31000 31000
]]
---@field mgcarpathian_dungeon_ymax integer?

-- ---------------- [Mapgen] [*Mapgen Carpathian] [**Noises] ---------------- --

---@class _.LuantiSettings.mapgen.mapgen_carpathian.noises
--[[
#    Variation of biome filler depth.
[world_creation]
(Filler depth noise) 0, 1, (128, 128, 128), 261, 3, 0.7, 2.0, eased
]]
---@field mgcarpathian_np_filler_depth core.NoiseParams.2d?
--[[
#    First of 4 2D noises that together define hill/mountain range height.
[world_creation]
(Hilliness1 noise) 0, 5, (251, 251, 251), 9613, 5, 0.5, 2.0, eased
]]
---@field mgcarpathian_np_height1 core.NoiseParams.2d?
--[[
#    Second of 4 2D noises that together define hill/mountain range height.
[world_creation]
(Hilliness2 noise) 0, 5, (383, 383, 383), 1949, 5, 0.5, 2.0, eased
]]
---@field mgcarpathian_np_height2 core.NoiseParams.2d?
--[[
#    Third of 4 2D noises that together define hill/mountain range height.
[world_creation]
(Hilliness3 noise) 0, 5, (509, 509, 509), 3211, 5, 0.5, 2.0, eased
]]
---@field mgcarpathian_np_height3 core.NoiseParams.2d?
--[[
#    Fourth of 4 2D noises that together define hill/mountain range height.
[world_creation]
(Hilliness4 noise) 0, 5, (631, 631, 631), 1583, 5, 0.5, 2.0, eased
]]
---@field mgcarpathian_np_height4 core.NoiseParams.2d?
--[[
#    2D noise that controls the size/occurrence of rolling hills.
[world_creation]
(Rolling hills spread noise) 1, 1, (1301, 1301, 1301), 1692, 3, 0.5, 2.0, eased
]]
---@field mgcarpathian_np_hills_terrain core.NoiseParams.2d?
--[[
#    2D noise that controls the size/occurrence of ridged mountain ranges.
[world_creation]
(Ridge mountain spread noise) 1, 1, (1889, 1889, 1889), 3568, 3, 0.5, 2.0, eased
]]
---@field mgcarpathian_np_ridge_terrain core.NoiseParams.2d?
--[[
#    2D noise that controls the size/occurrence of step mountain ranges.
[world_creation]
(Step mountain spread noise) 1, 1, (1889, 1889, 1889), 4157, 3, 0.5, 2.0, eased
]]
---@field mgcarpathian_np_step_terrain core.NoiseParams.2d?
--[[
#    2D noise that controls the shape/size of rolling hills.
[world_creation]
(Rolling hill size noise) 0, 3, (257, 257, 257), 6604, 6, 0.5, 2.0, eased
]]
---@field mgcarpathian_np_hills core.NoiseParams.2d?
--[[
#    2D noise that controls the shape/size of ridged mountains.
[world_creation]
(Ridged mountain size noise) 0, 12, (743, 743, 743), 5520, 6, 0.7, 2.0, eased
]]
---@field mgcarpathian_np_ridge_mnt core.NoiseParams.2d?
--[[
#    2D noise that controls the shape/size of step mountains.
[world_creation]
(Step mountain size noise) 0, 8, (509, 509, 509), 2590, 6, 0.6, 2.0, eased
]]
---@field mgcarpathian_np_step_mnt core.NoiseParams.2d?
--[[
#    2D noise that locates the river valleys and channels.
[world_creation]
(River noise) 0, 1, (1000, 1000, 1000), 85039, 5, 0.6, 2.0, eased
]]
---@field mgcarpathian_np_rivers core.NoiseParams.2d?
--[[
#    3D noise for mountain overhangs, cliffs, etc. Usually small variations.
[world_creation]
(Mountain variation noise) 0, 1, (499, 499, 499), 2490, 5, 0.55, 2.0
]]
---@field mgcarpathian_np_mnt_var core.NoiseParams.3d?
--[[
#    First of two 3D noises that together define tunnels.
[world_creation]
(Cave1 noise) 0, 12, (61, 61, 61), 52534, 3, 0.5, 2.0
]]
---@field mgcarpathian_np_cave1 core.NoiseParams.3d?
--[[
#    Second of two 3D noises that together define tunnels.
[world_creation]
(Cave2 noise) 0, 12, (67, 67, 67), 10325, 3, 0.5, 2.0
]]
---@field mgcarpathian_np_cave2 core.NoiseParams.3d?
--[[
#    3D noise defining giant caverns.
[world_creation]
(Cavern noise) 0, 1, (384, 128, 384), 723, 5, 0.63, 2.0
]]
---@field mgcarpathian_np_cavern core.NoiseParams.3d?
--[[
#    3D noise that determines number of dungeons per mapchunk.
[world_creation]
(Dungeon noise) 0.9, 0.5, (500, 500, 500), 0, 2, 0.8, 2.0
]]
---@field mgcarpathian_np_dungeons core.NoiseParams.3d?

-- ------------------------- [Mapgen] [*Mapgen Flat] ------------------------ --

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.mgflat_spflags
--[[
WIPDOC
]]
---@field lakes boolean?
--[[
WIPDOC
]]
---@field nolakes boolean?
--[[
WIPDOC
]]
---@field hills boolean?
--[[
WIPDOC
]]
---@field nohills boolean?
--[[
WIPDOC
]]
---@field caverns boolean?
--[[
WIPDOC
]]
---@field nocaverns boolean?

---@class _.LuantiSettings.mapgen.mapgen_flat
--[[
#    Map generation attributes specific to Mapgen Flat.
#    Occasional lakes and hills can be added to the flat world.
[world_creation]
(Mapgen Flat specific flags) nolakes,nohills,nocaverns lakes,hills,caverns
]]
---@field mgflat_spflags core.LuantiSettings.flags?
--[[
#    Y of flat ground.
[world_creation]
(Ground level) 8 -31000 31000
]]
---@field mgflat_ground_level integer?
--[[
#    Y of upper limit of large caves.
[world_creation]
(Large cave depth) -33 -31000 31000
]]
---@field mgflat_large_cave_depth integer?
--[[
#    Minimum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave minimum number) 0 0 256
]]
---@field mgflat_small_cave_num_min integer?
--[[
#    Maximum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave maximum number) 0 0 256
]]
---@field mgflat_small_cave_num_max integer?
--[[
#    Minimum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave minimum number) 0 0 64
]]
---@field mgflat_large_cave_num_min integer?
--[[
#    Maximum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave maximum number) 2 0 64
]]
---@field mgflat_large_cave_num_max integer?
--[[
#    Proportion of large caves that contain liquid.
[world_creation]
(Large cave proportion flooded) 0.5 0.0 1.0
]]
---@field mgflat_large_cave_flooded number?
--[[
#    Controls width of tunnels, a smaller value creates wider tunnels.
#    Value >= 10.0 completely disables generation of tunnels and avoids the
#    intensive noise calculations.
[world_creation]
(Cave width) 0.09
]]
---@field mgflat_cave_width number?
--[[
#    Terrain noise threshold for lakes.
#    Controls proportion of world area covered by lakes.
#    Adjust towards 0.0 for a larger proportion.
[world_creation]
(Lake threshold) -0.45
]]
---@field mgflat_lake_threshold number?
--[[
#    Controls steepness/depth of lake depressions.
[world_creation]
(Lake steepness) 48.0
]]
---@field mgflat_lake_steepness number?
--[[
#    Terrain noise threshold for hills.
#    Controls proportion of world area covered by hills.
#    Adjust towards 0.0 for a larger proportion.
[world_creation]
(Hill threshold) 0.45
]]
---@field mgflat_hill_threshold number?
--[[
#    Controls steepness/height of hills.
[world_creation]
(Hill steepness) 64.0
]]
---@field mgflat_hill_steepness number?
--[[
#    Y-level of cavern upper limit.
[world_creation]
(Cavern limit) -256 -31000 31000
]]
---@field mgflat_cavern_limit integer?
--[[
#    Y-distance over which caverns expand to full size.
[world_creation]
(Cavern taper) 256 0 32767
]]
---@field mgflat_cavern_taper integer?
--[[
#    Defines full size of caverns, smaller values create larger caverns.
[world_creation]
(Cavern threshold) 0.7
]]
---@field mgflat_cavern_threshold number?
--[[
#    Lower Y limit of dungeons.
[world_creation]
(Dungeon minimum Y) -31000 -31000 31000
]]
---@field mgflat_dungeon_ymin integer?
--[[
#    Upper Y limit of dungeons.
[world_creation]
(Dungeon maximum Y) 31000 -31000 31000
]]
---@field mgflat_dungeon_ymax integer?

-- ------------------- [Mapgen] [*Mapgen Flat] [**Noises] ------------------- --

---@class _.LuantiSettings.mapgen.mapgen_flat.noises
--[[
#    Defines location and terrain of optional hills and lakes.
[world_creation]
(Terrain noise) 0, 1, (600, 600, 600), 7244, 5, 0.6, 2.0, eased
]]
---@field mgflat_np_terrain core.NoiseParams.2d?
--[[
#    Variation of biome filler depth.
[world_creation]
(Filler depth noise) 0, 1.2, (150, 150, 150), 261, 3, 0.7, 2.0, eased
]]
---@field mgflat_np_filler_depth core.NoiseParams.2d?
--[[
#    First of two 3D noises that together define tunnels.
[world_creation]
(Cave1 noise) 0, 12, (61, 61, 61), 52534, 3, 0.5, 2.0
]]
---@field mgflat_np_cave1 core.NoiseParams.3d?
--[[
#    Second of two 3D noises that together define tunnels.
[world_creation]
(Cave2 noise) 0, 12, (67, 67, 67), 10325, 3, 0.5, 2.0
]]
---@field mgflat_np_cave2 core.NoiseParams.3d?
--[[
#    3D noise defining giant caverns.
[world_creation]
(Cavern noise) 0, 1, (384, 128, 384), 723, 5, 0.63, 2.0
]]
---@field mgflat_np_cavern core.NoiseParams.3d?
--[[
#    3D noise that determines number of dungeons per mapchunk.
[world_creation]
(Dungeon noise) 0.9, 0.5, (500, 500, 500), 0, 2, 0.8, 2.0
]]
---@field mgflat_np_dungeons core.NoiseParams.3d?

-- ----------------------- [Mapgen] [*Mapgen Fractal] ----------------------- --

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.mgfractal_spflags
--[[
WIPDOC
]]
---@field terrain boolean?
--[[
WIPDOC
]]
---@field noterrain boolean?

---@class _.LuantiSettings.mapgen.mapgen_fractal
--[[
#    Map generation attributes specific to Mapgen Fractal.
#    'terrain' enables the generation of non-fractal terrain:
#    ocean, islands and underground.
[world_creation]
(Mapgen Fractal specific flags) terrain terrain
]]
---@field mgfractal_spflags core.LuantiSettings.flags?
--[[
#    Controls width of tunnels, a smaller value creates wider tunnels.
#    Value >= 10.0 completely disables generation of tunnels and avoids the
#    intensive noise calculations.
[world_creation]
(Cave width) 0.09
]]
---@field mgfractal_cave_width number?
--[[
#    Y of upper limit of large caves.
[world_creation]
(Large cave depth) -33 -31000 31000
]]
---@field mgfractal_large_cave_depth integer?
--[[
#    Minimum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave minimum number) 0 0 256
]]
---@field mgfractal_small_cave_num_min integer?
--[[
#    Maximum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave maximum number) 0 0 256
]]
---@field mgfractal_small_cave_num_max integer?
--[[
#    Minimum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave minimum number) 0 0 64
]]
---@field mgfractal_large_cave_num_min integer?
--[[
#    Maximum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave maximum number) 2 0 64
]]
---@field mgfractal_large_cave_num_max integer?
--[[
#    Proportion of large caves that contain liquid.
[world_creation]
(Large cave proportion flooded) 0.5 0.0 1.0
]]
---@field mgfractal_large_cave_flooded number?
--[[
#    Lower Y limit of dungeons.
[world_creation]
(Dungeon minimum Y) -31000 -31000 31000
]]
---@field mgfractal_dungeon_ymin integer?
--[[
#    Upper Y limit of dungeons.
[world_creation]
(Dungeon maximum Y) 31000 -31000 31000
]]
---@field mgfractal_dungeon_ymax integer?
--[[
#    Selects one of 18 fractal types.
#    1 = 4D "Roundy" Mandelbrot set.
#    2 = 4D "Roundy" Julia set.
#    3 = 4D "Squarry" Mandelbrot set.
#    4 = 4D "Squarry" Julia set.
#    5 = 4D "Mandy Cousin" Mandelbrot set.
#    6 = 4D "Mandy Cousin" Julia set.
#    7 = 4D "Variation" Mandelbrot set.
#    8 = 4D "Variation" Julia set.
#    9 = 3D "Mandelbrot/Mandelbar" Mandelbrot set.
#    10 = 3D "Mandelbrot/Mandelbar" Julia set.
#    11 = 3D "Christmas Tree" Mandelbrot set.
#    12 = 3D "Christmas Tree" Julia set.
#    13 = 3D "Mandelbulb" Mandelbrot set.
#    14 = 3D "Mandelbulb" Julia set.
#    15 = 3D "Cosine Mandelbulb" Mandelbrot set.
#    16 = 3D "Cosine Mandelbulb" Julia set.
#    17 = 4D "Mandelbulb" Mandelbrot set.
#    18 = 4D "Mandelbulb" Julia set.
[world_creation]
(Fractal type) 1 1 18
]]
---@field mgfractal_fractal integer?
--[[
#    Iterations of the recursive function.
#    Increasing this increases the amount of fine detail, but also
#    increases processing load.
#    At iterations = 20 this mapgen has a similar load to mapgen V7.
[world_creation]
(Iterations) 11 1 65535
]]
---@field mgfractal_iterations integer?
--[[
#    (X,Y,Z) scale of fractal in nodes.
#    Actual fractal size will be 2 to 3 times larger.
#    These numbers can be made very large, the fractal does
#    not have to fit inside the world.
#    Increase these to 'zoom' into the detail of the fractal.
#    Default is for a vertically-squashed shape suitable for
#    an island, set all 3 numbers equal for the raw shape.
[world_creation]
(Scale) (4096.0, 1024.0, 4096.0)
]]
---@field mgfractal_scale vec?
--[[
#    (X,Y,Z) offset of fractal from world center in units of 'scale'.
#    Can be used to move a desired point to (0, 0) to create a
#    suitable spawn point, or to allow 'zooming in' on a desired
#    point by increasing 'scale'.
#    The default is tuned for a suitable spawn point for Mandelbrot
#    sets with default parameters, it may need altering in other
#    situations.
#    Range roughly -2 to 2. Multiply by 'scale' for offset in nodes.
[world_creation]
(Offset) (1.79, 0.0, 0.0)
]]
---@field mgfractal_offset vec?
--[[
#    W coordinate of the generated 3D slice of a 4D fractal.
#    Determines which 3D slice of the 4D shape is generated.
#    Alters the shape of the fractal.
#    Has no effect on 3D fractals.
#    Range roughly -2 to 2.
[world_creation]
(Slice w) 0.0
]]
---@field mgfractal_slice_w number?
--[[
#    Julia set only.
#    X component of hypercomplex constant.
#    Alters the shape of the fractal.
#    Range roughly -2 to 2.
[world_creation]
(Julia x) 0.33
]]
---@field mgfractal_julia_x number?
--[[
#    Julia set only.
#    Y component of hypercomplex constant.
#    Alters the shape of the fractal.
#    Range roughly -2 to 2.
[world_creation]
(Julia y) 0.33
]]
---@field mgfractal_julia_y number?
--[[
#    Julia set only.
#    Z component of hypercomplex constant.
#    Alters the shape of the fractal.
#    Range roughly -2 to 2.
[world_creation]
(Julia z) 0.33
]]
---@field mgfractal_julia_z number?
--[[
#    Julia set only.
#    W component of hypercomplex constant.
#    Alters the shape of the fractal.
#    Has no effect on 3D fractals.
#    Range roughly -2 to 2.
[world_creation]
(Julia w) 0.33
]]
---@field mgfractal_julia_w number?

-- ------------------ [Mapgen] [*Mapgen Fractal] [**Noises] ----------------- --

---@class _.LuantiSettings.mapgen.mapgen_fractal.noises
--[[
#    Y-level of seabed.
[world_creation]
(Seabed noise) -14, 9, (600, 600, 600), 41900, 5, 0.6, 2.0, eased
]]
---@field mgfractal_np_seabed core.NoiseParams.2d?
--[[
#    Variation of biome filler depth.
[world_creation]
(Filler depth noise) 0, 1.2, (150, 150, 150), 261, 3, 0.7, 2.0, eased
]]
---@field mgfractal_np_filler_depth core.NoiseParams.2d?
--[[
#    First of two 3D noises that together define tunnels.
[world_creation]
(Cave1 noise) 0, 12, (61, 61, 61), 52534, 3, 0.5, 2.0
]]
---@field mgfractal_np_cave1 core.NoiseParams.3d?
--[[
#    Second of two 3D noises that together define tunnels.
[world_creation]
(Cave2 noise) 0, 12, (67, 67, 67), 10325, 3, 0.5, 2.0
]]
---@field mgfractal_np_cave2 core.NoiseParams.3d?
--[[
#    3D noise that determines number of dungeons per mapchunk.
[world_creation]
(Dungeon noise) 0.9, 0.5, (500, 500, 500), 0, 2, 0.8, 2.0
]]
---@field mgfractal_np_dungeons core.NoiseParams.3d?

-- ----------------------- [Mapgen] [*Mapgen Valleys] ----------------------- --

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.mgvalleys_spflags
--[[
WIPDOC
]]
---@field altitude_chill boolean?
--[[
WIPDOC
]]
---@field noaltitude_chill boolean?
--[[
WIPDOC
]]
---@field humid_rivers boolean?
--[[
WIPDOC
]]
---@field nohumid_rivers boolean?
--[[
WIPDOC
]]
---@field vary_river_depth boolean?
--[[
WIPDOC
]]
---@field novary_river_depth boolean?
--[[
WIPDOC
]]
---@field altitude_dry boolean?
--[[
WIPDOC
]]
---@field noaltitude_dry boolean?

---@class _.LuantiSettings.mapgen.mapgen_valleys
--[[
#    Map generation attributes specific to Mapgen Valleys.
#    'altitude_chill': Reduces heat with altitude.
#    'humid_rivers': Increases humidity around rivers.
#    'vary_river_depth': If enabled, low humidity and high heat causes rivers
#    to become shallower and occasionally dry.
#    'altitude_dry': Reduces humidity with altitude.
[world_creation]
(Mapgen Valleys specific flags) altitude_chill,humid_rivers,vary_river_depth,altitude_dry altitude_chill,humid_rivers,vary_river_depth,altitude_dry
]]
---@field mgvalleys_spflags core.LuantiSettings.flags?
--[[
#    The vertical distance over which heat drops by 20 if 'altitude_chill' is
#    enabled. Also, the vertical distance over which humidity drops by 10 if
#    'altitude_dry' is enabled.
[world_creation]
(Altitude chill) 90 0 65535
]]
---@field mgvalleys_altitude_chill integer?
--[[
#    Depth below which you'll find large caves.
[world_creation]
(Large cave depth) -33 -31000 31000
]]
---@field mgvalleys_large_cave_depth integer?
--[[
#    Minimum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave minimum number) 0 0 256
]]
---@field mgvalleys_small_cave_num_min integer?
--[[
#    Maximum limit of random number of small caves per mapchunk.
[world_creation]
(Small cave maximum number) 0 0 256
]]
---@field mgvalleys_small_cave_num_max integer?
--[[
#    Minimum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave minimum number) 0 0 64
]]
---@field mgvalleys_large_cave_num_min integer?
--[[
#    Maximum limit of random number of large caves per mapchunk.
[world_creation]
(Large cave maximum number) 2 0 64
]]
---@field mgvalleys_large_cave_num_max integer?
--[[
#    Proportion of large caves that contain liquid.
[world_creation]
(Large cave proportion flooded) 0.5 0.0 1.0
]]
---@field mgvalleys_large_cave_flooded number?
--[[
#    Depth below which you'll find giant caverns.
[world_creation]
(Cavern upper limit) -256 -31000 31000
]]
---@field mgvalleys_cavern_limit integer?
--[[
#    Y-distance over which caverns expand to full size.
[world_creation]
(Cavern taper) 192 0 32767
]]
---@field mgvalleys_cavern_taper integer?
--[[
#    Defines full size of caverns, smaller values create larger caverns.
[world_creation]
(Cavern threshold) 0.6
]]
---@field mgvalleys_cavern_threshold number?
--[[
#    How deep to make rivers.
[world_creation]
(River depth) 4 0 65535
]]
---@field mgvalleys_river_depth integer?
--[[
#    How wide to make rivers.
[world_creation]
(River size) 5 0 65535
]]
---@field mgvalleys_river_size integer?
--[[
#    Controls width of tunnels, a smaller value creates wider tunnels.
#    Value >= 10.0 completely disables generation of tunnels and avoids the
#    intensive noise calculations.
[world_creation]
(Cave width) 0.09
]]
---@field mgvalleys_cave_width number?
--[[
#    Lower Y limit of dungeons.
[world_creation]
(Dungeon minimum Y) -31000 -31000 31000
]]
---@field mgvalleys_dungeon_ymin integer?
--[[
#    Upper Y limit of dungeons.
[world_creation]
(Dungeon maximum Y) 63 -31000 31000
]]
---@field mgvalleys_dungeon_ymax integer?

-- ------------------ [Mapgen] [*Mapgen Valleys] [**Noises] ----------------- --

---@class _.LuantiSettings.mapgen.mapgen_valleys.noises
--[[
#    First of two 3D noises that together define tunnels.
[world_creation]
(Cave noise #1) 0, 12, (61, 61, 61), 52534, 3, 0.5, 2.0
]]
---@field mgvalleys_np_cave1 core.NoiseParams.3d?
--[[
#    Second of two 3D noises that together define tunnels.
[world_creation]
(Cave noise #2) 0, 12, (67, 67, 67), 10325, 3, 0.5, 2.0
]]
---@field mgvalleys_np_cave2 core.NoiseParams.3d?
--[[
#    Variation of biome filler depth.
[world_creation]
(Filler depth) 0, 1.2, (256, 256, 256), 1605, 3, 0.5, 2.0, eased
]]
---@field mgvalleys_np_filler_depth core.NoiseParams.2d?
--[[
#    3D noise defining giant caverns.
[world_creation]
(Cavern noise) 0, 1, (768, 256, 768), 59033, 6, 0.63, 2.0
]]
---@field mgvalleys_np_cavern core.NoiseParams.3d?
--[[
#    Defines large-scale river channel structure.
[world_creation]
(River noise) 0, 1, (256, 256, 256), -6050, 5, 0.6, 2.0, eased
]]
---@field mgvalleys_np_rivers core.NoiseParams.2d?
--[[
#    Base terrain height.
[world_creation]
(Terrain height) -10, 50, (1024, 1024, 1024), 5202, 6, 0.4, 2.0, eased
]]
---@field mgvalleys_np_terrain_height core.NoiseParams.2d?
--[[
#    Raises terrain to make valleys around the rivers.
[world_creation]
(Valley depth) 5, 4, (512, 512, 512), -1914, 1, 1.0, 2.0, eased
]]
---@field mgvalleys_np_valley_depth core.NoiseParams.2d?
--[[
#    Slope and fill work together to modify the heights.
[world_creation]
(Valley fill) 0, 1, (256, 512, 256), 1993, 6, 0.8, 2.0
]]
---@field mgvalleys_np_inter_valley_fill core.NoiseParams.3d?
--[[
#    Amplifies the valleys.
[world_creation]
(Valley profile) 0.6, 0.5, (512, 512, 512), 777, 1, 1.0, 2.0, eased
]]
---@field mgvalleys_np_valley_profile core.NoiseParams.2d?
--[[
#    Slope and fill work together to modify the heights.
[world_creation]
(Valley slope) 0.5, 0.5, (128, 128, 128), 746, 1, 1.0, 2.0, eased
]]
---@field mgvalleys_np_inter_valley_slope core.NoiseParams.2d?
--[[
#    3D noise that determines number of dungeons per mapchunk.
[world_creation]
(Dungeon noise) 0.9, 0.5, (500, 500, 500), 0, 2, 0.8, 2.0
]]
---@field mgvalleys_np_dungeons core.NoiseParams.3d?