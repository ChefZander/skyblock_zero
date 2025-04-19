# Visible Wielditem

Shows wielded items in-world.

## Features

Modern alternative to [`wield3d`](https://github.com/stujones11/wield3d):

* Relies less on deprecated engine APIs, doesn't aim to support older MT versions
* Supports colored items. Works well with [`epidermis`](https://github.com/appgurueu/epidermis).
* Supports glow (for environmental lighting use a wielded light mod)
* Indicates size of stacks
* Provides a proper API for mods to use
* Rotates the model instead of the texture

## License

Code written by [appgurueu](https://github.com/appgurueu) and licensed under the MIT license.

The screenshot (`screenshot.png`) uses [Hugues Ross'](https://content.minetest.net/users/Hugues%20Ross/) [RPG16](https://content.minetest.net/packages/Hugues%20Ross/rpg16/) texture pack, which is licensed under CC-BY-SA-4.0, and is therefore licensed under CC-BY-SA-4.0 as well.

## Links

* [GitHub](https://github.com/appgurueu/visible_wielditem) - sources, issue tracking, contributing
* [Discord](https://discord.gg/ysP74by) - discussion, chatting
* [Minetest Forum](https://forum.minetest.net/viewtopic.php?f=9&t=27714) - (more organized) discussion
* [ContentDB](https://content.minetest.net/packages/LMD/visible_wielditem/) - releases (downloading from GitHub is recommended)

## API

All within the `visible_wielditem` global variable.

### `get_attachment(modelname, itemname)`

Returns a table with fields `bonename`, `position` (unit: metric/nodes), `rotation` (unit: degrees) and `scale` (number, unit: metric/nodes) based on model attachments and item tweaks.

### `model_attachments`

Table. Keys are model media (file) names, values are tables with field `bonename`, `position`, `rotation` and `scale`. The special field `default` is used for default attachment settings based on `character.b3d` if no model attachments are specified for a player model or if the specified attachment settings are incomplete.

### `item_tweaks`

Table of tweaks applied based on the item. Subtable entries have strings as keys and tweak tables with fields `position`, `rotation` and `scale` as values. `position`s are added up, `rotation`s are properly composed, `scale` is multiplied.

#### `types`

Applies tweaks based on item type. Possible keys are `unknown`, `node`, `tool` and `craftitem`.

#### `groups`

Tweaks for a key are applied if the item has an item group with that name.

#### `names`

Tweaks for a single item, by full item name.
