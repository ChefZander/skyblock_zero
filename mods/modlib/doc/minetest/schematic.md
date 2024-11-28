# Schematic

A schematic format with support for metadata and baked light data.

## Table Format

The table format uses a table with the following mandatory fields:

* `size`: Size of the schematic in nodes, vector
* `node_names`: List of node names
* `nodes`: List of node indices (into the `node_names` table)
* `param2s`: List of node `param2` values (numbers)

and the following optional fields:

* `light_values`: List of node `param1` (light) values (numbers)
* `metas`: Map from indices in the cuboid to metadata tables as produced by `minetest.get_meta(pos):to_table()`

A "vector" is a table with fields `x`, `y`, `z` for the 3 coordinates.

The `nodes`, `param2s` and `light_values` lists are in the order dictated by `VoxelArea:iterp` (Z-Y-X).

The cuboid indices for the `metas` table are calculated as `(z * size.y) + y * size.x + x` where `x`, `y`, `z` are relative to the min pos of the cuboid.

## Binary Format

The binary format uses modlib's Bluon to write the table format.

Since `param2s` (and optionally `light_values`) are all bytes, they are converted from lists of numbers to (byte)strings before writing.

For uncompressed files, it uses `MLBS` (short for "ModLib Bluon Schematic") for the magic bytes, 
followed by the raw Bluon binary data.

For compressed files, it uses `MLZS` (short for "ModLib Zlib-compressed Schematic") for the magic bytes,
followed by the zlib-compressed Bluon binary data.

## API

### `schematic.setmetatable(obj)`

Sets the metatable of a table `obj` to the schematic metatable.
Useful if you've deserialized a schematic or want to create a schematic from the table format.

### `schematic.create(params, pos_min, pos_max)`

Creates a schematic from a map cuboid

* `params`: Table with fields
	* `metas` (default `true`): Whether to store metadata
	* `light_values`: Whether to bake light values (`param1`).
	  Usually not recommended, default `false`.
* `pos_min`: Minimum position of the cuboid, inclusive
* `pos_max`: Maximum position of the cuboid, inclusive

### `schematic:place(pos_min)`

"Inverse" to `schematic.create`: Places the schematic `self` starting at `pos_min`.

Content IDs (nodes), param1s, param2s, and metadata in the area will be completely erased and replaced; if light data is present, param1s will simply be set, otherwise they will be recalculated.

### `schematic:write_zlib_bluon(path)`

Write a binary file containing the schematic in *zlib-compressed* binary format to `path`.
**You should generally prefer this over `schematic:write_bluon`: zlib compression comes with massive size reductions.**

### `schematic.read_zlib_bluon(path)`

"Inverse": Read a binary file containing a schematic in *zlib-compressed* binary format from `path`, returning a `schematic` instance.
**You should generally prefer this over `schematic.read_bluon`: zlib compression comes with massive size reductions.**

### `schematic:write_bluon(path)`

Write a binary file containing the schematic in uncompressed binary format to `path`.
Useful only if you want to eliminate the time spent compressing.

### `schematic.read_bluon(path)`

"Inverse": Read a binary file containing a schematic in uncompressed binary format from `path`, returning a `schematic` instance.
Useful only if you want to eliminate the time spent decompressing.
