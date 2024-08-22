# API Documentation

## Quick Links

- [`fakelib.is_player(x)`](#fakelibis_playerx)
- [`fakelib.is_metadata(x)`](#fakelibis_metadatax)
- [`fakelib.is_inventory(x)`](#fakelibis_inventoryx)
- [`fakelib.is_vector(x, [add_metatable])`](#fakelibis_vectorx-add_metatable)
- [`fakelib.create_player([options])`](#fakelibcreate_playeroptions)
- [`fakelib.create_inventory([sizes])`](#fakelibcreate_inventorysizes)
- [`fakelib.create_metadata([data])`](#fakelibcreate_metadatadata)


## Type checks

#### **`fakelib.is_player(x)`**

Checks if a value is a player. Only returns true for real players and `fakelib`'s fake players.

**Arguments**

- `x` - Any value. The value to be checked.

#### **`fakelib.is_inventory(x)`**

Checks if a value is an inventory. Only returns true for real inventories and `fakelib`'s fake inventories.

**Arguments**

- `x` - Any value. The value to be checked.

#### **`fakelib.is_metadata(x)`**

Checks if a value is metadata. Only returns true for real metadata and `fakelib`'s fake metadata.

**Arguments**

- `x` - Any value. The value to be checked.

#### **`fakelib.is_vector(x, [add_metatable])`**

Checks if a value is a vector. Returns true for any table with `x`, `y`, and `z` values that are numbers.

**Arguments**

- `x` - Any value. The value to be checked.
- `add_metatable` - Boolean, optional. Add the vector metatable to basic vectors.


## Creation

#### **`fakelib.create_player([options])`**

Creates a new fake player.

**Arguments**

- `options` - Definition table, optional. Specifies player data. See [`options`](#options) below. Can also be a string as shorthand to set the player name only.

#### **`fakelib.create_inventory([sizes])`**

Creates a new fake player.

**Arguments**

- `sizes` - Definition table, optional. Specifies list names and sizes. See [`sizes`](#sizes) below.

#### **`fakelib.create_metadata([data])`**

Creates a new fake player.

**Arguments**

- `data` - Definition table, optional. Specifies metadata keys and values. See [`data`](#data) below.


## Definition tables.


#### **`options`**

Specifies player data. Used by [`fakelib.create_player([options])`](#fakelibcreate_playeroptions).

All values are optional.

- `name` - String. Player name. Unlike real player names, this can contain any characters.
- `position` - Vector. Player position.
- `direction` - Vector. Player look direction.
- `controls` - Table. Player controls. Uses the same format returned by `player:get_player_controls()`.
- `metadata` - Metadata. Player metadata. Can be fake metadata or a reference to real metadata.
- `inventory` - Inventory. Player inventory. Can be a fake inventory or a reference to a real inventory.
- `wield_list` - String. Selected inventory list. Must be a list that exists in the player's inventory.
- `wield_index` - Number. Selected list index. Must be an index that exists in the selected list.

Example:
```lua
local options = {
	name = "sam",
	position = vector.new(1, 5, 3),
	direction = vector(1, 0, 0),
	controls = {sneak = true},
}
local player = fakelib.create_player(options)
```

#### **`sizes`**

Specifies list names and sizes. Used by [`fakelib.create_inventory([sizes])`](#fakelibcreate_inventorysizes).

List names must be strings, and list sizes must be numbers greater than zero.

Example:
```lua
local sizes = {
	main = 32,
	craft = 9,
	craftpreview = 1,
	craftresult = 1,
}
local inv = fakelib.create_inventory(sizes)

```

#### **`data`**

Specifies metadata keys and values. Used by [`fakelib.create_metadata([data])`](#fakelibcreate_metadatadata).

Keys must be strings, and values must be strings or numbers.

Example:
```lua
local data = {
	enabled = "true",
	energy = 300,
}
local meta = fakelib.create_metadata(data)
```