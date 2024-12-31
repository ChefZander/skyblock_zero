# Biomegen

Biome generator mod for Minetest, reproducing closely the biome generator provided by Minetest's core, but in Lua. Also includes an optional elevation adjustment parameter.

It allows to use the biome systems on Lua mapgens (that do no allow to use core biome system). Since it reads registered biomes and decorations, it is compatible with all mods adding biomes/decos.

Created by gaelysam (Gaël de Sailly) in November 2020, licensed under LGPLv3.0.

Version 2.0 (February 2024)

# Include it in your mapgen

`biomegen` should be triggered during mapgen function, after the loop, but before writing to the map.

Your mapgen should generate only these 4 nodes:
- Stone (`mapgen_stone` / `default:stone`)
- Water (`mapgen_water_source` / `default:water_source`)
- River water (`mapgen_river_water_source` / `default:river_water_source`)
- Air (`air`)

All other nodes will be ignored, no biome will be placed ontop of them.

You should add `biomegen` as a dependancy of your mod (optional or mandatory).

## API
Description of usual function parameters:
- `data`: Data containing the generated mapchunk
- `area`: VoxelArea helper object for data. `area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})`
- `vm`: VoxelManip object
- `minp`: minimal coordinates of the chunk being generated, e.g. `{x=48, y=-32, z=208}`
- `maxp`: maximal coordinates of the chunk being generated, e.g. `{x=127, y=47, z=287}`
- `seed`: world-specific seed

### `biomegen.generate_all(data, area, vm, minp, maxp, seed)`
All-in-one function to generate *biomes*, *decorations*, *ores* and *dust*. Includes a call to `vm:set_data` so no need to do it again. Using core function `minetest.generate_ores` for ores, so does not support biome-specific ores.

### `biomegen.generate_biomes(data, area, minp, maxp)`
Generates biomes in `data`, according to biomes that have been registered using `minetest.register_biome`.

### `biomegen.place_all_decos(data, area, vm, minp, maxp, seed)`
Generates decorations directly in `vm` (but reads `data` to know where to place them), according to decorations that have been registered using `minetest.register_decoration`.

### `biomegen.dust_top_nodes(data, area, vm, minp, maxp)`
Drops 'dust' (usually snow) on biomes that require it. Like above, generates directly in `vm` but reads from `data`. If you used `place_all_decos` to generate decorations, you should update `data` from the `vm`:

```lua
vm:get_data(data)
```

### `biomegen.gennotify(feature, pos)`
Adds an entry in gen notify in the field `feature` (`dungeon`, `cave_begin`, ..., also `decoration#id`). No effect if the feature is not requested in `minetest.set_gen_notify`.

### `biomegen.set_elevation_chill(ec)`
Sets elevation chill coefficient. `0` means temperature does not depend on elevation (behaviour of core's biomegen). Usual values `0`-`0.5`.

### `biomegen.skip_chunk(minp, maxp)`
Does not generate biomes but updates mapgen objects (`biomemap`, `heatmap`, `humiditymap`, `heightmap` and `gennotify`) so that other mods can use them without crashing. Use this function in the mapgen loop when skipping an empty chunk.

### `minetest.get_mapgen_object(objname)`
The following objects are updated to take into account what Biomegen generates:
- `biomemap`
- `heatmap`
- `humiditymap`
- `heightmap`
- `gennotify`

The behaviour of the function is otherwise unchanged.

### `minetest.get_biome_data(pos)
Takes into account elevation if elevation chill coefficient is non-zero. The behaviour of the function is otherwise unchanged.

## Examples
### Using `biomegen.generate_all`
```lua
local data = {}

minetest.register_on_generated(function(minp, maxp, seed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	vm:get_data(data)

	------------------------
	-- [MAPGEN LOOP HERE] --
	------------------------

	-- Generate biomes, decorations, ores and dust
	biomegen.generate_all(data, area, vm, minp, maxp, seed)

	-- Calculate lighting for what has been created.
	vm:calc_lighting()
	-- Write what has been created to the world.
	vm:write_to_map()
	-- Liquid nodes were placed so set them flowing.
	vm:update_liquids()
end)
```

### Equivalent with all functions
```lua
local data = {}

minetest.register_on_generated(function(minp, maxp, seed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	vm:get_data(data)

	------------------------
	-- [MAPGEN LOOP HERE] --
	------------------------

	-- Generate biomes in 'data', using biomegen mod
	biomegen.generate_biomes(data, area, minp, maxp)

	-- Write content ID data back to the voxelmanip.
	vm:set_data(data)
	-- Generate ores using core's function
	minetest.generate_ores(vm, minp, maxp)
	-- Generate decorations in VM (needs 'data' for reading)
	biomegen.place_all_decos(data, area, vm, minp, maxp, seed)
	-- Update data array to have ores/decorations
	vm:get_data(data)
	-- Add biome dust in VM (needs 'data' for reading)
	biomegen.dust_top_nodes(data, area, vm, minp, maxp)

	-- Calculate lighting for what has been created.
	vm:calc_lighting()
	-- Write what has been created to the world.
	vm:write_to_map()
	-- Liquid nodes were placed so set them flowing.
	vm:update_liquids()
end)
```

### Mapgen example
I have made a [modified version of `lvm_example`](https://github.com/Gael-de-Sailly/lvm_example/tree/biomegen) (mod originally by Paramat) to provide a minimal working example of a mapgen using `biomegen`. Try it!
