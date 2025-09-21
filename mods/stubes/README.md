# Stubes

Attempting to be luanti's best tubes.  
Though, they are in a weird stage of still being dependant on pipeworks.

I am using 32x32 textures for the tubes, because i could not fit a recognizable arrow into a 32x32 texture without making the node bigger.

A lot of the aproaches were from pipeworks.

# Docs
## Groups
- `stube=1` - if it's an stube
- `stube_input=1` - if it can input into an stube
- `tubedevice`/`tubedevice_receiver` - these are groups from pipeworks
## Functions
### Registration
- `stube.register_tube(name, def)`
    - It's the same as `core.register_node`, but there are a few special fields you need to put:
    - `tube_textures` - a table of `{ plain = <texture>, noctr = <texture>, ends = <texture>, plain_up = <texture>, noctr_up = <texture> }`
        - You can use `stube.make_tube_textures_from(filename)` to generate this, it needs to be a 3x2 texture sheet, check `textures/` directory for examples
### Placement
- `stube.place_tube(pos, dir)` - places a tube properly
- `stube.update_placement(pos)` - Use with `after_dig`/`after_place`, it updates the tube connections, useful if something got removed/placed
    - Does not get rid of connections that were manually removed/made by a user
### Weird internals
- `stube.parse_tube_name(tube_name)` - Parses the `<modname>:<stube>_<blabla>` into `{ dir (0 to 5), xc, yc, zc, nxc, nyc, nzc }` where, for example `xc` means if it's connected to the west, and `nxc` means if it's connected to the east (-X direction), and for the dir, see wallmounted param2
