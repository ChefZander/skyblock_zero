# fmod

flux's mod boilerplate

## what?

i use this to create a common basic API that all of my mods share. it grabs a lot of mod metadata from e.g. mod.conf
and settingtypes.txt and automatically makes those values available.

this mod is primarily for my own use, but i'd be elated if other people find it useful. suggestions are welcome, but
note that my own patterns come first in any suggested changes. the more mods i create which depend on this (there's
over 70 and counting, though only 50 or 60 are released), the harder it will be to change fundamental features. but
if i've made major mistake somehow, please let me know sooner rather than later!

## public API

* `modname = fmod.create(fork)`

  creates the boilerplate.

  `fork` is an optional parameter for other people to use if they fork a mod.

the api which is created looks like this:

```lua
local f = string.format
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)
local mod_conf = Settings(modpath .. DIR_DELIM .. "settingtypes.txt")

modname = {
		modname = modname,
		modpath = modpath,
		title = mod_conf:get("title") or modname,
		description = mod_conf:get("description"),
		author = mod_conf:get("author"),
		license = mod_conf:get("license"),
		version = mod_conf:get("version"),
		fork = fork or "flux",  -- fork is the argument to `fmod.create(fork)`

		S = S,

		has = build_has(mod_conf),  -- this reads mod.conf and creates a set from optional_depends
		settings = get_settings(modname),  -- this reads and parses settingtypes.txt, and populates w/ values from
                                           -- minetest.conf, or otherwise the defaults specified in settingtypes.txt

		check_version = function(required)
			assert(mod_conf:get("version") >= required, f("%s requires a newer version of %s; please update it", minetest.get_current_modname(), modname))
		end,

        check_minetest_version = function(major, minor, patch, other, reason)
            assert(..., "check that the required version of the game engine is present. \"other\" is reserved for " ..
                "future use, once i figure out how to deal w/ engine forks."
            )
        end,

		log = function(level, messagefmt, ...)
			return minetest.log(level, f("[%s] %s", modname, f(messagefmt, ...)))
		end,

        chat_send_player = function(player, messagefmt, ...)
            minetest.chat_send_player(player, f("[%s] %s", modname, S(messagefmt, ...)))
        end,

        chat_send_all = function(message, ...)
            minetest.chat_send_all(f("[%s] %s", modname, S(message, ...)))
        end,

		dofile = function(...)
			return dofile(table.concat({modpath, ...}, DIR_DELIM) .. ".lua")
		end,

        async_dofile = function(...) -- load a file into the async environment
			return minetest.register_async_dofile(table.concat({ modpath, ... }, DIR_DELIM) .. ".lua")
        end,
}
```

note that fmod itself is created w/ this same boilerplate; therefore, i can indicate that certain mods require an
up-to-date version of fmod to operate.
