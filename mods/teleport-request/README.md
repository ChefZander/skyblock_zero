# Teleport Request

[![LuaCheck status](https://github.com/minetest-mods/teleport-request/workflows/luacheck/badge.svg)](https://github.com/minetest-mods/teleport-request/actions)
[![ContentDB](https://content.minetest.net/packages/Traxie21/tpr/shields/downloads/)](https://content.minetest.net/packages/Traxie21/tpr/)

Allows players to send a request to other players to teleport to them. Includes many more teleporting features.

## Installation

- Unzip the archive, rename the folder to `tpr` and
place it in `.. minetest/mods/`

- GNU/Linux: If you use a system-wide installation place
    it in `~/.minetest/mods/`.

- If you only want this to be used in a single world, place
    the folder in `.. worldmods/` in your world directory.

For further information or help, see:\
<https://wiki.minetest.net/Installing_Mods>

## Privileges

Each command needs a privilege. These are the following privileges:

- `tp` is required in order to use all commands.
- `tp_tpc` is required in order to use `/tpc`.
- `tp_tpc` is required in order to use `/tpe`.
- `tp_tpc` is required in order to use `/tpj`.
- `interact` is required to use all commands.
- `tp_admin` gives more control to admins:

  - Admins can teleport to players even when they haven't decided to accept, or not.
  - Admins can teleport players to him/her, if the `enable_immediate_teleport` setting is enabled.
  - Admins can teleport to protected coordinates.

Players can also teleport to coordinates, however, if the area is protected, the teleport will be denied.

## How to use

Each command does a function. "**Example usage**" is an example of how to use the command.\
Note there must be 2 players in order to make the commands to work: a player must send a request to another player.

There are two ways of sending a request:

1. A request which teleports you to the specified player (command `/tpr <player>`).
2. A request which teleports the specified player to you (command `/tphr <player>`).

To accept a request some sent you, you must use `/tpy`.\
These are the following commands available in-game:

``` /tpr [playername] ```

- **Name:** Teleport Request
- **Description:** Requests permission to teleport to another player, where [playername] is their exact name.
- **Required privileges:** `interact, tp`
- **Example usage:** `/tpr RobbieF` requests permission from RobbieF to teleport to them.
- **Notes:** Usernames are case-sensitive. If you have the `tp_admin` privilege, you will immediately teleport to the specificed player (does not apply if `enable_immediate_teleport` setting is disabled, enabled by default).

``` /tphr [playername] ```

- **Name:** Teleport Here Request
- **Description:** Request permission to teleport another player to you.
- **Required privileges:** `interact, tp`
- **Example usage:** `/tphr RobbieF` requests RobbieF to teleport to you.
- **Notes:** Usernames are case-sensitive. If you have the `tp_admin` privilege, RobbieF will teleport to you immediately (does not apply if `enable_immediate_teleport` setting is disabled, enabled by default).

``` /tpc [x,y,z] ```

- **Name:** Teleport to Coordinates
- **Description:** Teleport to coordinates.
- **Required privileges:** `interact, tp_tpc, tp`
- **Notes:** Honors area protection. If the area is protected, it must be owned by you in order to teleport to it, or you must have the `areas` privilege in order to teleport to those coordinates.

``` /tpj [axis] [distance] ```

- **Name:** Teleport Jump
- **Description:** Teleport a specified distance along a single specified axis.
- **Required privilege:** `interact", tp, tp_tpc`
- **Available options for *axis*:** x, y, z
- **Example usage:** `/tpj y 10` teleport 10 nodes into the air.

``` /tpe ```

- **Name:** Teleport Evade
- **Description:** In a sticky situation? Evade your enemy by teleporting to several nearby coordinates in random pattern. There's no knowing where you'll end up.
- **Required privileges:** `interact, tp_tpc, tp`
- **Example usage:** `/tpe` teleports you to a random number of random coordinates in an evasive pattern.

``` /tpy ```

- **Description:** Accept a user's request to teleport to you or teleport you to them.
- **Required privileges:** `interact, tp`

``` /tpn ```

- **Description:** Deny a user's request to teleport to you or teleport you to them.
- **Required privileges:** `interact, tp`

## Configuring the mod

Open your `minetest.conf` located in your Minetest directory.\
Set the values of the settings you'd like to.

Available options are:

```conf
tp.timeout_delay = 60
tp.enable_immediate_teleport = true
tp_enable_tpp_command = false
```

Those values are the default values of the mod.\
You can also go to your Minetest, Settings tab, All settings, Mods, and you'll find `tpr` there.\
Or another way to do it, is changing the values in `settingtypes.txt`.

## TODO

- Add limitations to /tpc which only allow a user to teleport X number of blocks. Prevents users from teleporting to the edge of the world.
- Assess value in changing all tpr-based chat commands to one global command such as /tp to reduce the chance of confusion between tps_admin and the original mod (and also make it so people don't have to remember so many commands).
- Rewrite to place all chat commands into one single command much like how /teleport works.
- Make evade respect land: no teleporting inside land, but instead make sure player is standing on surface or in water.

If you think something else should be added to this list, [submit an issue](https://github.com/minetest-mods/teleport-request/issues/new).

## License

See [`LICENSE.txt`](LICENSE.txt) for full license information and [`AUTHORS.md`](AUTHORS.md) for all the contributors.
