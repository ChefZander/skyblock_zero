# Minetest Visulization Library [vizlib]

[![luacheck](https://github.com/OgelGames/vizlib/workflows/luacheck/badge.svg)](https://github.com/OgelGames/vizlib/actions)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)
[![Minetest](https://img.shields.io/badge/Minetest-5.0+-blue.svg)](https://www.minetest.net)
[![ContentDB](https://content.minetest.net/packages/OgelGames/vizlib/shields/downloads/)](https://content.minetest.net/packages/OgelGames/vizlib/)
 
## Overview

This mod is a code library for visualizing basic shapes in-game. You can draw lines, circles, cubes, spheres and more.

It's ideal for showing the working area or range of functional nodes, and a better alternative to using entities.

![Overview](overview.gif?raw=true "Overview") 

## Usage

Simply add `vizlib` to your mod's dependencies, and call any of the API functions from your code.

See [API.md](API.md) for detailed documentation.

## Examples

Drawing a line between two points.

```lua
local pos1 = vector.new(-2, 0, -2)
local pos2 = vector.new(2, 2, 2)
vizlib.draw_line(pos1, pos2)
```

Drawing a blue sphere for the player Sam and removing it after 60 seconds.

```lua
local pos = vector.new(0, 5, 0)
local options = {
	color = "#0000ff",
	player = "Sam",
	infinite = true,
}
local shape = vizlib.draw_sphere(pos, 3, options)
minetest.after(60, vizlib.erase_shape, shape)
```

Showing a working range when punching a node with an empty hand.

```lua
on_punch = function(pos, _, player)
	if not player or player:get_wielded_item():get_name() ~= "" then
		-- Only show range when using an empty hand
		return
	end
	local radius = minetest.get_meta(pos):get_int("radius") + 0.5
	vizlib.draw_cube(pos, radius, {player = player})
end
```

## Installation

Download the [master branch](https://github.com/OgelGames/vizlib/archive/master.zip) or the [latest release](https://github.com/OgelGames/vizlib/releases), and follow [the usual installation steps](https://wiki.minetest.net/Installing_Mods).

Alternatively, you can download and install the mod from [ContentDB](https://content.minetest.net/packages/OgelGames/vizlib) or the online content tab in Minetest.

## License

All code is licensed under the [MIT License](LICENSE).

`vizlib_particle.png` is licensed as [CC0](https://creativecommons.org/publicdomain/zero/1.0/).