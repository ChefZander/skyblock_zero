# Controls [controls]

[![luacheck](https://github.com/mt-mods/controls/workflows/luacheck/badge.svg)](https://github.com/mt-mods/controls/actions)
[![ContentDB](https://content.minetest.net/packages/mt-mods/controls/shields/downloads/)](https://content.minetest.net/packages/mt-mods/controls/)

Utility library for control press/hold/release events.

Rewritten and maintained version of [Arcelmi/minetest-controls](https://github.com/Arcelmi/minetest-controls).


## API

Callbacks are supported for all keys in `player:get_player_control()`.

```lua
controls.register_on_press(function(player, key)
	-- Called when a key is pressed
	-- player: player object
	-- key: key pressed
end)

controls.register_on_hold(function(player, key, length)
	-- Called every globalstep while a key is held
	-- player: player object
	-- key: key pressed
	-- length: length of time key has been held in seconds
end)

controls.register_on_release(function(player, key, length)
	-- Called when a key is released
	-- player: player object
	-- key: key pressed
	-- length: length of time key was held in seconds
end)
```
