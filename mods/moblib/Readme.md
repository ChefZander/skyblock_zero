# Entity Library (`moblib`)

Low-level high-performance entity library

## About

Depends on [`modlib`](https://github.com/appgurueu/modlib). Licensed under the MIT License. Written by Lars Mueller aka LMD or appguru(eu).

## Links

* [GitHub](https://github.com/appgurueu/moblib) - sources, issue tracking, contributing
* [Discord](https://discordapp.com/invite/ysP74by) - discussion, chatting
* [Minetest Forum](https://forum.minetest.net/viewtopic.php?t=24671) - (more organized) discussion
* [ContentDB](https://content.minetest.net/packages/LMD/moblib) - releases (cloning from GitHub is recommended)

## API

Mostly self-documenting code. Mod namespace is `moblib`, containing all variables & functions.

### `vector get_rotation(vector direction)`

Returns rotation required to rotate a z-facing model in direction.

### `vector get_wield_rotation(vector direction)`

Same as `get_rotation` but for wield_images.

### `vector get_direction(vector rotation)`

Inverse of `get_rotation`.

### `register_entity(name, def)`

### `register_entity(text name, table def)`

```lua
moblib.register_entity(name, {
    initial_properties = {...},
    lua_properties = {
        moveresult = {
            collisions = nil,
            axes = nil,
            old_velocity = nil,
            acceleration_dependent = nil
        },
        staticdata = "json" or "lua"
    },
    on_step = ...,
    ...
})
```