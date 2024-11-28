# Configuration

## Legacy

1. Configuration is loaded from `<worldpath>/config/<modname>.<extension>`, the following extensions are supported and loaded (in the given order), with loaded configurations overriding properties of previous ones:
   1. [`json`](https://json.org)
   2. [`lua`](https://lua.org)
   3. [`luon`](https://github.com/appgurueu/luon), Lua but without the `return`
   4. [`conf`](https://github.com/minetest/minetest/blob/master/doc/lua_api.txt)
2. Settings are loaded from `minetest.conf` and override configuration values

## Locations

0. Default configuration: `<modfolder>/conf.lua`
1. World configuration: `config/<modname>.<format>`
2. Mod configuration: `<modfolder>/conf.<format>`
3. Minetest configuration: `minetest.conf`

## Formats

1. [`lua`](https://lua.org)
   * Lua, with the environment being the configuration object
   * `field = value` works
   * Return new configuration object to replace
2. [`luon`](https://github.com/appgurueu/luon)
   * Single Lua literal
   * Booleans, numbers, strings and tables
3. [`conf`](https://github.com/minetest/minetest/blob/master/doc/lua_api.txt)
   * Minetest-like configuration files
4. [`json`](https://json.org)
   * Not recommended
