# Skyblock: Zero Forked Mod

Currently synchronized with commit 5d5dfc0f2127bb8d257bd4e518acc2aeafba26df from upstream: <https://github.com/SwissalpS/replacer>. Removed/Replaced a lot of things from the original mod.

See `COPYRIGHT.md` for up-to-date copyright information. README contents below is preserved from the original mod.

Replacement tool for creative building (Mod for Minetest)
=========================================================

This tool is helpful for creative purposes (e.g. build a wall and "paint" windows into it).
It replaces nodes with a previously selected other type of node (i.e. places said windows
into a brick wall).

# Crafting

Availability of recipes can be configured with server settings.
Basic replacer:
```
      | chest       |               | gold ingot |
      |             | mese fragment |            |
      | steel ingot |               | chest      |
```
Or `/giveme replacer:replacer`

Technic replacer as upgrade to basic tool:
```
      | replacer:replacer | green energy crystal |        |
      |                   |                      |        |
      |                   |                      |        |
```
Or `/giveme replacer:replacer_technic`

Technic replacer directly crafted:
```
      | chest       | green energy crystal | gold ingot |
      |             | mese fragment        |            |
      | steel ingot |                      | chest      |
```
Or `/giveme replacer:replacer_technic`

# Usage

Sneak-right-click on a node of which type you want to replace other nodes with.
       Left-click (normal usage) on any nodes you want to replace with that type.
       Right-click to place a node of that type onto clicked node.

When in creative mode, the node will just be replaced. Your inventory will not be changed.

When *not* in creative mode, digging will be simulated and you will get what was there.<br>
In return, the replacement node will be taken from your inventory.

If technic mod is installed, modes are available and use depletes charge.<br>
This is true for users without "give" privs and also on servers not running in creative mode.

# Modes (Major)

Special+Place or Special+Use anywhere to change the mode.<br>
The first informs you in chat about the mode change while the second opens a formspec.<br>
Single-mode does not need any charge. The other modes do.<br>
For a description of the modes with pictures, refer to:
* [Single Mode (doc/usageSingle.md)](doc/usageSingle.md)
* [Field Mode (doc/usageField.md)](doc/usageField.md)
* [Crust Mode (doc/usageCrust.md)](doc/usageCrust.md)

# Modes (Minor)

Using the formspec or Sneak+Special+Place to change the minor mode.
* Both (standard)
* Node: Replaces the node using rotation of dug node.
* Rotation: Basically a screwdriver with set rotation. Doesn't dig the clicked node, only applies the stored rotation.
In Field and Crust Modes this will apply to multiple nodes according to respective search pattern.<br>
When Place-button is pressed, Rotation Mode does not make much sense as mostly air is being rotated. This can lead to confusion for beginners.

# Chat Commands

* /replacer (audio|chat) (1|0) toggles chat messages for advanced users. Also allows muting sounds. This command also accepts variants of "on"/"off" words in several languages.
* /place_all [dry-run][ move_player][ no_support_node][ [<include pattern1>] ... [ <include patternN>]]
  This is only available to players with **priv** priv and only in development mode. [Read the comments in (test.lua)](test.lua)

# Privelages

**creative** priv allows setting to more node-types and **give** priv allows to set to any. They both
unlock modes even for basic replacer and allow using without charge constrain.<br>
They both also allow user to use unlimited amounts of items without checking inventory.<br>
The configurable priv allows using history.

# Inspection tool

The third tool included in this mod is the inspection tool.

Crafting:
```
      | torch |      |     |
      | stick |      |     |
      |       |      |     |
```
Punch (dig/use on) any node or entity you want to know more about.<br>
Right-click (place) on any node to get information of the adjacent node. The node that would be placed if you were weilding something placeable.<br>
This is useful to inspect a node that is otherwise unclickable. E.g. airlight or activated stealthnodes.<br>
Apart from node name and description, light value and a limited craft-guide is included.<br>
Compatibility to many mods with special use cases have been added. Read [Customization (doc/customization.md)]((doc/customization.md)) for more information.

# Settings

* **replacer.max_nodes** max allowed nodes to replace per action (default: 3168)
* **replacer.hide_recipe_basic** hide the basic recipe (default: 0)<br>
These two require technic to be installed, if not, the recipes are hidden.
* **replacer.hide_recipe_technic_upgrade** hide the upgrade recipe (default: 0)
* **replacer.hide_recipe_technic_direct** hide the direct technic recipe (default: 1)
* **replacer.history_priv** priv needed for using history (default: creative)
[All settings with medium length description in (settingtypes.txt)](settingtypes.txt)
Lengthy information about settings and customization can be found in the [Customization Guide (doc/customization.md)](doc/customization.md)

# Contributors

* Sokomine
* coil0
* HybridDog
* SwissalpS
* OgelGames
* BuckarooBanzay
* S-S-X

# License


    Copyright (C) 2013,2014,2015 Sokomine

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

