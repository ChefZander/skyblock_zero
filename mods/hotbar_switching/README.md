# Hotbar Switching

Implements a way to switch your hotbar to another row. Inspired by [better than adventure](https://www.betterthanadventure.net/) (it has a feature where if you press `tab`, it will change the hotbar like this mod, but doesn't change your inventory).

## Defaults - requires the `controls` mod
- `sneak` + `aux1` + `left mouse button` - cycle
- `sneak` + `aux1` + `right mouse button` - cycle backwards

## Mobile

I believe this would be best done with a custom button, which i think isn't possible in luanti, or there should at least something in the inventory menu.  
There are a lot of inventory mods, i think it would be very difficult to support them all.

## How does it work?

There is no way to actually decide which slots are part of your hotbar in luanti. So this just shifts items items in your inventory.

The width of the inventory is assumed to be your hotbar size.

## Why `controls` mod isn't optional

ContentDB doesn't allow you to have some sort of "strongly suggested dependancies", so i think it would be best for this mod to work out of the box, instead of not doing anything by default like a library. You may change this in games that use this mod.

Also i didn't want to reinvent the wheel again.

## API
- `hotbar_switching` - a table, contains everything
- `hotbar_switching.default_controls = true` - enable default controls
- `hotbar_switching.can_player_switch(player)` - Can the player switch their hotbar to another row
    - `player` is an ObjectRef (player)
    - returns a boolean, by default always returns `true`
    - Override the function if you need to decide
- `hotbar_switching.switch(player, row)` - Actually perform the action of switching the hotbar to that row
    - `player` - ObjectRef (player)
    - `row` - integer (Usually `-1` or `1`)
    - The inventory list being manipulated will be from `player:get_wield_list()`
    - You may override this function to change what happens at the end of it (example: sending a message saying you did that action)
