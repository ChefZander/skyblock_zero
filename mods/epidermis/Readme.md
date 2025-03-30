# Epidermis ![Logo](logo.png)
> the surface epithelium of the skin, overlying the dermis

The only ~~outer skin~~ epidermis mod you'll ever need.  
(modified in skyblock zero)

## About

`epidermis` is a feature-fledged Minetest skin mod, featuring 3d skin painting and excellent SkinDB support.

### Requirements

`epidermis` requires at least Minetest 5.4 for the server and at least 5.3 (dynamic media support) for the client.

#### Dependencies

* [`modlib`](https://github.com/appgurueu/modlib)
* [`moblib`](https://github.com/appgurueu/moblib)

### Licensing

All code written by [appgurueu](github.com/appgurueu/) and licensed under the MIT license.

The textures have been created by Dragoni and appgurueu and are all licensed under CC BY-SA 3.0. Attribution is given below. 

The following tool textures (within the `textures/tools` folder) have been created by Dragoni:

* `epidermis_book.png`
* `epidermis_eraser.png`
* `epidermis_filling_bucket.png`
* `epidermis_filling_paint.png`
* `epidermis_palette.png`
* `epidermis_pen_handle.png`
* `epidermis_pen_tip.png`
* `epidermis_undo_redo.png`

`logo.png` in the root folder was also created by Dragoni. Everything else was created by appgurueu and is also licensed under CC BY-SA 3.0. `screenshot.png` uses `character.png` by Jordach which is licensed under [CC BY-SA 3.0](https://github.com/minetest/minetest_game/tree/master/mods/player_api/README.txt) as well.

### Links

* [GitHub](https://github.com/appgurueu/epidermis) - sources, issue tracking, contributing
* [Discord](https://discord.gg/ysP74by) - discussion, chatting
* [Minetest Forum](https://forum.minetest.net/viewtopic.php?f=9&t=27670) - (more organized) discussion
* [ContentDB](https://content.minetest.net/packages/LMD/epidermis/) - releases (downloading from GitHub is recommended)

## Features

* Per-player skins
  * Just drop them in `<worldpath>/data/epidermis/textures/players/epidermis_player_<playername>.png`
* 3D Epidermis painting
  * Model- and texture-agnostic. Full B3D and PNG support.
  * HSV & RGB colorpickers, named color support
  * Arbitrary rotation & backface culling support
* [SkinDB](http://minetest.fensta.bplaced.net/) support
  * Real-time syncing with SkinDB (uploaded textures immediately become usable without a restart); no external scripts required
  * Picking SkinDB skins for yourself or as Epidermis base textures
  * Upload to SkinDB

## Supported Games

* [x] [Minetest Game](https://github.com/minetest/minetest_game) and most derivatives (`player_api` support)
* [x] [NodeCore](https://gitlab.com/sztest/nodecore)

Other games are likely to work too. Try it and see.

## Comparison

### 2D Texture Painting Mods

* [Painted 3D armor](https://content.minetest.net/packages/Beerholder/painted_3d_armor/): A mod supporting paintings on armor. Painting still happens in 2D space and is rather limited through the use of texture modifiers; a rather old mod.
* [skinmaker](https://github.com/GreenXenith/skinmaker), a well-done mod limited to the scope of 2-dimensional creation of skins in-game using only texture modifiers. Good support for older MT versions without dynamic media, not entirely texture- and model-agnostic. Experimental.

### Clothing Mods

* [Clothing 2](https://content.minetest.net/packages/SFENCE/clothing/): Adds wearable clothing items

### Skin Mods

* [Wardrobe](https://content.minetest.net/packages/AntumDeluge/wardrobe_ad/) and [Wardrobe Outfits](https://content.minetest.net/packages/AntumDeluge/wardrobe_outfits/): A few "selected" skins; the former provides an API for other mods to register more
* [Simple Skins](https://content.minetest.net/packages/TenPlus1/simple_skins/): A different set of available skins, excellent support for ancient MT versions
* [SkinsDB](https://content.minetest.net/packages/bell07/skinsdb/) and [SkinsDB for Hades Revisited](https://content.minetest.net/packages/SFENCE/hades_skinsdb/): Proper SkinDB support using an update command which shuts down the server, support for user-added skins, decent skin selection dialog including a search feature

Epidermis beats most currently available skin mods through better SkinDB support (including **uploading**) and is the first mod to provide 3-dimensional skin painting (which may however not be considered generally superior to 2-dimensional painting).

## Engine Limitations

### Memory Usage

You can expect each active entity to consume memory proportional to the texture pixel count. Skins sized 64x32 should stay in the kilobyte range. There is however a [clientside memory leak](https://github.com/minetest/minetest/issues/11531) which causes textures to not be dropped from texture cache. This means that every time the texture is changed, the client will store it in memory until the session ends. For 64x32, roughly 8 KB will be stored per update/action. That means a thousand actions will roughly take 8 MB; a million actions would take 8 GB. **Therefore, it is not recommended to try using higher resolution textures, even though they are perfectly supported by the mod.**

### Disk Usage

The dynamic media API allows marking media as `ephemeral`, which means it isn't cached clientside *and* not sent to new clients. Unfortunately this means that joining players don't receive the media, which would result in undefined behavior. Therefore, this fills up client & server disk space in it's current form. Server disk space is automatically cleared on startup; client cache must be cleared manually.

### Texture Packs

As Epidermis runs fully serverside, it can't support clientside texture packs. Serverside texture packs aren't supported either, as Epidermis (modlib actually) only has access to mod folders. A serverside texture pack [can be implemented using a mod](https://github.com/appgurueu/ghosts#server-side-texture-packs) however.

## Mod Limitations

### [`wield3d`](https://github.com/stujones11/wield3d)

Does not display the colors of wielded items. Use [`visible_wielditem`](https://github.com/appgurueu/visible_wielditem) instead.

### [`3d_armor`](https://github.com/minetest-mods/3d_armor)

3D Armor currently completely breaks Epidermis as it changes the player model and makes armor part of the texture.
No proper alternatives to 3D Armor exist. Attachment-based armor mods like [`equippable_accessories`](https://content.minetest.net/packages/davidthecreator/equippable_accessories/) work fine.

## Hints

If you want to be able to accurately paint, don't use cinematic camera smoothing or view bobbing. Both will make your look direction inaccurate in certain cases. Alternatively to disabling view bobbing, rest while painting (and use the newest Minetest version).

As you might have noticed, there is no kind of palette. That is no issue however: Simply abuse a second entity (or a portion of the epidermis) as palette.

## Instructions

The in-game guide item contains these instructions as well.

### Tools

#### Guide

The in-game guide provides instructions for these tools.

#### Spawners

##### Paintable spawner

Spawns a paintable epidermis with your current texture.

##### HSV colorpicker spawner

Spawns a "wallmounted" HSV colorpicker.

#### Painting Tools

Tools which work much like those found in common painting programs.

Pen, line, rectangle and filling bucket all require a color. There are three ways to pick a color:

* You can pick a color from the paintable epidermis by right-clicking it.
* You can open a RGB color picker dialog by right clicking while pointing at nothing.
* You can spawn a HSV color picker in-world by placing it against a node. Right-click to pick a color, punch the hue to change the hue of the saturation & value field.

##### Pen

The pen is the most basic tool. It is used to place single pixels (left-click).

##### Line

The line tool draws, duh, a line. Use it by "dragging": keep the left mouse button down. You will be shown a preview. Dragging stops when you change your wield item or point at a different entity.

##### Rectangle

Works like the line tool but draws a filled rectangle.

##### Filling Bucket

Floodfills adjacent pixels of exactly the same color, swapping out their color for the color of the filling bucket.

##### Undo-redo

Left-click to undo, right-click to redo. Undo-redo log size is limited due to [Memory Usage] constraints.

##### Eraser

Left-click to mark a pixel as transparent, right-click to restore opacity of the first transparent pixel above the pointed pixel.

## Configuration

`epidermis` must be added to `secure.http_mods` for SkinDB uploading & downloading (including syncing) to be enabled;
otherwise epidermis will be limited to the local (offline, cached) SkinDB copy

<!--modlib:conf:2-->
### `skindb`

#### `autosync`

Automatically sync with SkinDB at startup, continue syncing during game

* Type: boolean
* Default: `true`

<!--modlib:conf-->

## Possible future features

* [ ] 3D armor support
* [ ] Restart server if a certain amount of dynamic texture data has been reached (100 MB?)
* [ ] Paintable transportability (as items?) & trashability
* [ ] Better icons (play button for animation?)
* [ ] Skinmaker support to add 2-dimensional texture painting
* [ ] Semi-transparency painting support
  * Pointless as long as Minetest doesn't properly support semitransparency for CAOs
* [ ] Survival mode
  * [ ] Obtaining paintable epidermi through skinning
  * [ ] Dye rewrite with color mixing and limited color supply
* [ ] SkinDB replacement server
