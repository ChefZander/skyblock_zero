Minetest jumpdrive (modified in sbz)
======

![](https://github.com/mt-mods/jumpdrive/workflows/luacheck/badge.svg)
![](https://github.com/mt-mods/jumpdrive/workflows/integration-test/badge.svg)


A simple [Jumpdrive](https://en.wikipedia.org/wiki/Jump_drive) for minetest

Take your buildings with you on your journey

* Github: [https://github.com/thomasrudin-mt/jumpdrive](https://github.com/thomasrudin-mt/jumpdrive)
* Forum topic: [https://forum.minetest.net/viewtopic.php?f=9&t=20073](https://forum.minetest.net/viewtopic.php?f=9&t=20073)

# Operation

* Place a 'jumpdrive:engine' into the center of your creation.
* Connect the engine to a technic HV network
* Let the engine charge
* Choose your target coordinates (should be air or ignore blocks)
* Select your cube-radius
* Click "show" and check the green (source) and red (target) destination markers if everything is in range
* Click "jump"

Example setup with technic:

![](screenshots/screenshot_20220305_161502.png?raw=true)


# Compatibility

Optional dependencies:
* Mesecon interaction (execute jump on signal)
* Technic rechargeable (HV)
* Travelnet box (gets rewired after jump)
* Elevator (on_place gets called after jump)
* Locator (gets removed and added after each jump)
* Pipeworks teleport tubes (with a patch to pipeworks)
* Beds (thx to @tuedel)
* Ropes (thx to @tuedel)
* Mission-wand as coordinate bookmark (thx to @SwissalpS)
* Compass as coordinate bookmark (thx to @SwissalpS)
* Areas
* Drawers

# Fuel

The engine can be connected to a technic HV network or fuelled with power items.
Power items are one of the following
* `default:mese_crystal_fragment`
* `default:mese_crystal`
* `default:mese`

# Energy requirements

The energy requirements formula looks like this: **radius^2 x distance**

For example:
* Distance: 100 blocks
* Radius: 5 blocks
* Required energy: 5^2 x 100 = 2500

# Upgrades

If the `technic` mod is installed the following items can be used in the upgrade slot:
* `technic:red_energy_crystal` increases power storage
* `technic:green_energy_crystal` increases power storage
* `technic:blue_energy_crystal` increases power storage
* `technic:control_logic_unit` increases power recharge rate

# Protection

The source and destination areas are checked for protection so you can't remove and jump into someone else's buildings.


# Screenshots

Interface:

![](screenshots/screenshot_20180507_200309.png?raw=true)

Example:

![](screenshots/screenshot_20180507_200203.png?raw=true)

# Advanced operation

## Coordinate bookmarking

You can place empty books into the drive inventory and write the coordinates to them with the "Write to book" button.
The "Read from bookmark" button reads the coordinates from the next valid bookmark item in the inventory. From right to left.
A used bookmark item is placed in the first free slot from the left.
Bookmark items are:
* Written books saved by jumpdrive (or correctly by hand)
* Mission position wands
* Compasses

## Diglines

* See: [Digilines](doc/digiline.md)

# Settings

Settings in minetest.conf:

* **jumpdrive.max_radius** max radius of the jumpdrive (default: *15*)
* **jumpdrive.max_area_radius** max radius of the area jumpdrive (default: *25*)
* **jumpdrive.powerstorage** power storage of the drive (default: *1000000*)
* **jumpdrive.power_requirement** power requirement for charging (default: *2500*)

# Lua api

## Preflight check

The preflight check can be overriden to execute additional checks:

```lua
jumpdrive.preflight_check = function(source, destination, radius, player)
	-- check for height limit, only space travel allowed
	if destination.y < 1000 then
		return { success=false, message="Atmospheric travel not allowed!" }
	end

	-- everything ok
	return { success=true }
end
```

## Fuel calc

The default fuel calc can be overwritten by a depending mod:

```lua
-- calculates the power requirements for a jump
jumpdrive.calculate_power = function(radius, distance, sourcePos, targetPos)
	return 10 * distance * radius
end
```

## Movenode compatibility

Nodes can be made aware of a changing position if they implement a `on_movenode` function
on the node-definition:

```lua
-- example with an override
minetest.override_item("travelnet:travelnet", {
  on_movenode = function(from_pos, to_pos, additional_info)
    -- additional_info = { edge = { x=0, y=0, z=0 } }
    -- magic!
  end
})
```

* `additional_info.edge` is the vector to the nearest edge if any


## Hooks

```lua
-- register a callback that is called upon jump completion
-- can also be used if the `on_movenode` above needs a kind of "commit" to write the changed state to files
jumpdrive.register_after_jump(function(from_area, to_area)
	-- from_area/to_area = { pos1, pos2 }
end)
```


# Sources

* jumprive_engine.ogg: https://freesound.org/people/kaboose102/sounds/340257/

# Contributors

* @tuedel
* @SwissalpS
* @Panquesito7
* @OgelGames
* @S-S-X
* Jeremy#2233
* Purple#2916

# License
* Code: `MIT`
* Textures `CC BY-SA 4.0`

# Attributions
* `textures/jumpdrive.png`/`textures/jumpdrive_backbone.png`/`textures/jumpdrive_fleet_controller.png`/`textures/jumpdrive_warpdevice.png`
 * Jeremy#2233 / Purple#2916
 * Modified by frogTheSecond
