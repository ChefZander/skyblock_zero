# B3D Reader & Writer

## `b3d.read(file)`

Reads from `file`, which is expected to provide `file:read(nbytes)`. `file` is not closed.

Returns a B3D model object.

## `:write(file)`

Writes the B3D model object `self` to `file`.

`file` must provide `file:write(bytestr)`. It should be in binary mode.
It is not closed after writing.

## `:write_string()`

Writes the B3D model object to a bytestring, which is returned.

## `:to_gltf()`

Returns a glTF JSON representation of `self` in Lua table format.

## `:write_gltf(file)`

Convenience function to write the glTF representation to `file` using modlib's `json` writer.

`file` must provide `file:write(str)`. It is not closed afterwards.

## Examples

### Converting B3D to glTF

This example loops over all files in `dir_path`, converting them to glTFs which are stored in `out_dir_path`.

```lua
local modpath = minetest.get_modpath(minetest.get_current_modname())
local dir_path = modpath .. "/b3d"
local out_dir_path = modpath .. "/gltf"
for _, filename in ipairs(minetest.get_dir_list(dir_path, false --[[only files]])) do
	-- First read the B3D
	local in_file = assert(io.open(dir_path .. "/" .. filename, "rb"))
	local model = assert(b3d.read(in_file))
	in_file:close()
	-- Then write the glTF
	local out_file = io.open(out_dir_path .. "/" .. filename .. ".gltf", "wb")
	model:write_gltf(out_file)
	out_file:close()
end
```

### [Round-trip (minifying B3Ds)](https://github.com/appgurueu/modlib_test/blob/f11c8e580e90454bc1adaa11a58e0c0217217d90/b3d.lua)

This example from [`modlib_test`](https://github.com/appgurueu/modlib_test) reads, writes, and then reads again,
in order to verify that no data is lost through writing.

Simply re-writing a model using modlib's B3D writer often reduces model sizes,
since for example modlib does not write `0` weights for bones.

Keep in mind to use the `rb` and `wb` modes for I/O operations
to force Windows systems to not perform a line feed normalization.

### [Extracting triangle sets](https://github.com/appgurueu/ghosts/blob/42a9eb9ee81fc6760a0278d23e4c47bc68bb4919/init.lua#L41-L79)

The [Ghosts](https://github.com/appgurueu/ghosts/) mod extracts triangle sets using the B3D module
to then approximate the player shape using particles picked from these triangles.

### [Animating the player](https://github.com/appgurueu/character_anim/blob/c48b282c0b42b32294ec2fddc03aa93141cbd894/init.lua#L213)

[`character_anim`](https://github.com/appgurueu/character_anim/) uses the B3D module to determine the bone overrides required
for animating the player entirely Lua-side using bone overrides.

### [Generating a Go board](https://github.com/appgurueu/go/blob/997ce85260d232a05dd668c32c6854bf34e3d5be/build/generate_models.lua)

This example from the [Go](https://github.com/appgurueu/go) mod generates a Go board
where for each spot on the board there are two pieces (black and white),
both of which can be moved out of the board using a bone.

It demonstrates how to use the writer (and how the table structure roughly looks like).
