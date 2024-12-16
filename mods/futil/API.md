# WARNING

this is *VERY OUT OF DATE*. this is a mod for my (flux's) personal use, and maintaining documentation outside the code
isn't worth the time. if other people start using this, i'll reconsider that position.

## classes

* `futil.class1(super)`
  a simple class w/ optional inheritance
* `futil.class(...)`
  a less simple class w/ multiple inheritance and `is_a` support

## data structures

* `futil.Deque`

  a [deque](https://en.wikipedia.org/wiki/Double-ended_queue). supported methods:
  * `Deque:size()`
  * `Deque:push_front(value)`
  * `Deque:push_back(value)`
  * `Deque:pop_front()`
  * `Deque:pop_back()`

* `futil.PairingHeap`

  a [pairing heap](https://en.wikipedia.org/wiki/Pairing_heap). supported methods:
  * `PairingHeap:size()`
  * `PairingHeap:peek_max()`
  * `PairingHeap:delete(value)`
  * `PairingHeap:delete_max()`
  * `PairingHeap:get_priority(value)`
  * `PairingHeap:set_priority(value, priority)`

* `futil.DefaultTable`

  a table in which missing keys are automatically filled in. example usage:
  ```lua
  local default_table = futil.DefaultTable(function(key) return {} end)
  default_table.foo.bar = 100 -- foo is automatically created as a table
  ```

## general routines

* `futil.check_call(func)`

  wraps `func` in a pcall. if no error occurs, returns the results. otherwise, logs and returns nil.

* `futil.memoize1(f)`

  memoize a single-argument function

* `futil.memoize_dumpable(f)`

  memoize a function if the arguments produce a unique result when `dump()`-ed

* `futil.memoize1_modstorage(id, func)`

  memoize a function and store the results in modstorage, so they persist between sessions.

* `futil.truncate(s, max_length, suffix)`

  if the string is longer than max_length, truncate it and append suffix. suffix is optional, defaults to "..."

* `futil.lc_cmp(a, b)`

  case-insensitive comparator

* `futil.table.set_all(t1, t2)`

  sets all key/value pairs of t2 in t1

* `futil.table.pairs_by_value(t, sort_function)`

  iterator which returns key/value pairs, sorted by value

* `futil.table.pairs_by_key(t, sort_function)`

  iterator which returns key/value pairs, sorted by key

* `futil.table.size(t)`

  gets the size of a table

* `futil.table.is_empty(t)`

  returns true if the table is empty

* `futil.equals(a, b)`

  returns true if the tables (or other values) are equivalent. do not use w/ recursive structures.
  currently does not inspect metatables.

* `futil.table.count_elements(t)`

  given a table in which some values may repeat, returns a table mapping values to their count.

* `futil.table.sets_intersect(set1, set2)`

  returns true if `set1` and `set2` have any keys in common.

* `futil.table.iterate(t)`

  iterates the values of an array-like table

* `futil.table.reversed(t)`

  returns a reversed copy of the table.

* `futil.table.contains(t, value)`

  returns `true` if value is in table

* `futil.table.keys(t)`

  returns a table of the keys in the given tables.

* `futil.table.values(t)`

  returns a table of the values in the given tables.

* `futil.table.sort_keys(t, sort_function)`

  returns a table of the sorted keys of the given table.

* `futil.wait(n)`

  busy-waits n microseconds

* `futil.file_exists(path)`

  returns true if the path points to a file that can be opened

* `futil.load_file(filename)`

  returns the contents of the file if it exists, otherwise nil.

* `futil.write_file(filename, contents)`

  writes to a file. returns true if success, false if not.

* `futil.path_concat(...)`

  concatenates part of a file path.

* `futil.path_split(path)`

  splits a path into parts.

* `futil.string.truncate(s, max_length, suffix)`

  truncate a string if it is longer than max_length, adding suffix (default "...").

* `futil.string.lc_cmp(a, b)`

  compares the lower-case values of strings a and b.

* `futil.seconds_to_interval(time)`

  transforms a time (in seconds) to a format like "\[\[\[\[<years>:]<days>:]<hours>:]<minutes>:]<seconds>"p

* `futil.format_utc(timestamp)`

  formats a timestamp in UTC.

### predicates

* `futil.is_nil(v)`

  true if v is `nil`

* `futil.is_boolean(v)`

  true if `v` is a boolean.

* `futil.is_number(v)`

  true if `v` is a number.

* `futil.is_string(v)`

  true if `v` is a string.

* `futil.is_userdata(v)`

  true if `v` is userdata.

* `futil.is_function(v)`

  true if `v` is a function.

* `futil.is_thread(v)`

  true if `v` is a thread.

* `futil.is_table(v)`

  true if `v` is a table.

### functional

* `futil.functional.noop()`

  the NOTHING function does nothing.

* `futil.functional.identity(x)`

  returns x

* `futil.functional.izip(...)`

  [zips](https://docs.python.org/3/library/functions.html#zip) iterators.

* `futil.functional.zip(...)`

  [zips](https://docs.python.org/3/library/functions.html#zip) tables.

* `futil.functional.imap(func, ...)`

  maps a function to a sequence of iterators. the first arg to func is the first element of each iterator, etc.

* `futil.functional.map(func, ...)`

  maps a function to a sequence of tables. the first arg to func is the first element of each table, etc.

* `futil.functional.apply(func, t)`

  for all keys `k`, set `t[k] = func(t[k])`

* `futil.functional.reduce(func, t, initial)`

  applies binary function `func` to successive elements in t and a "total". supply `initial` if possibly `#t == 0`.
  e.g. `local sum = function(values) return reduce(function(a, b) return a + b end, values, 0) end`.

* `futil.functional.partial(func, ...)`

  curries `func`. `partial(func, a, b, c)(d, e, f) == func(a, b, c, d, e, f)

* `futil.functional.compose(a, b)`

  binary operator which composes two functions. `compose(a, b)(x) == a(b(x))`

* `futil.functional.ifilter(pred, i)`

  returns an interator which returns the values of iterator `i` which match predicate `pred`

* `futil.functional.filter(pred, t)`

  returns an interator which returns the values of table `t` which match predicate `pred`

* `futil.functional.iall(i)`

  given an iterator, returns true if all non-nil values of the iterator are not false.

* `futil.functional.all(t)`

  given a table, returns true if the table doesn't contain any `false` values

* `futil.functional.iany(i)`

  given an iterator, returns true if the iterator produces any non-false values.

* `futil.functional.any(t)`

  given a table, returns true if it contains any non-false values.

### iterators

* `futil.iterators.range(...)`

  * one arg: return an iterator from 1 to x.
  * two args: return an iterator from x to y
  * three args: return an iterator from x to y, incrementing by z

* `iterators.repeat_(value, times)`

  * times = nil: return `value` forever
  * times = positive number: return `value` `times` times

* `futil.iterators.chain(...)`

  given a sequence of iterators, return an iterator which will return the values from each in turn.

* `futil.iterators.count(start, step)`

  returns an infinite iterator which counts from start by step. if step is not specified, counts by 1.

* `futil.iterators.values(t)`

  returns an iterator of the values in the table.

* `futil.list(iterator)`

  given an iterator, returns a table of the values of the iterator.

* `futil.list_multiple(iterator)`

  given an iterator which returns multiple values on each step, create a table of tables of those values.

### math

* `futil.math.idiv(a, b)`

  returns the whole part of a division and the remainder, e.g. `math.floor(a/b), a%b`.

* futil.math.bound(m, v, M)

  if v is less than m, return m. if v is greater than M, return M. else return v.

* futil.math.in_bounds(m, v, M)

  return true if m <= v and v <= M

* futil.math.is_integer(v)

  returns true if v is an integer.

* futil.math.is_u8(i)

  returns true if i is a valid unsigned 8 bit value.

* futil.math.is_u16(i)

  returns true if i is an unsigned 16 bit value.

* `futil.math.sum(t, initial)`

  given a table, get the sum of the values in the table. initial is the value from which to start counting.
  if initial is nil and the table is empty, will return nil.

* `futil.math.isum(i, initial)`

  like the above, but given an iterator.

## minetest-specific routines

* `futil.add_groups(itemstring, new_groups)`

  `new_groups` should be a table of groups to add to the item's existing groups

* `futil.remove_groups(itemstring, ...)`

  `...` should be a list of groups to remove from the item's existing groups

* `futil.get_items_with_group(group)`

  returns a list of itemstrings which belong to the specified group

* `futil.get_location_string(inv)`

  given an `InvRef`, get a location string suitable for use in formspec

* `futil.resolve_item(item)`

  given an itemstring or `ItemStack`, follows aliases until it finds the real item.
  returns an itemstring.

* `futil.items_equals(item1, item2)`

  returns true if two itemstrings/stacks represent identical stacks.

* `futil.get_blockpos(pos)`

  converts a position vector into a blockpos

* `futil.get_block_bounds(blockpos)`

  gets the bound vectors of a blockpos

* `futil.formspec_pos(pos)`

  convert a position into a string suitable for use in formspecs

* `futil.iterate_area(minp, maxp)`

  creates an iterator for every point in the volume between minp and maxp

* `futil.iterate_volume(pos, radius)`

  like the above, given a position and radius (L∞ metric)

* `futil.serialize(x)`

  turns a simple lua data structure (e.g. a table no userdata or functions) into a string

* `futil.deserialize(data)`

  the reverse of the above. not safe; do not use w/ untrusted data

* `futil.strip_translation(msg)`

  strips minetest's translation escape sequences from a message

* `futil.get_safe_short_description(item)`

  gets a short description which won't contain unmatched translation escapes

* `futil.escape_texture(texturestring)`

  escapes a texture modifier, for use within another modifier

* `futil.get_horizontal_speed(player)`

  get's a player's horizontal speed.

* `futil.is_on_ground(player)`

  returns true if a player is standing on the ground.
  NOTE: this is currently unfinished, and doesn't report correctly if a player is standing on things with complex
        collision boxes which are rotated via `paramtype2="facedir"` or similar.

### fake inventory
this is useful for testing multiple actions on an inventory without having to worry about changing the inventory or
reverting it. this is a better solution than a detached inventory, as actions on a detached inventory are still sent
to clients. fake inventories support all the regular methods of a
[minetest inventory object](https://github.com/minetest/minetest/blob/master/doc/lua_api.md#invref),
with some additions.

* `futil.FakeInventory()`

  create a fake inventory.

* `futil.FakeInventory.create_copy(inv)`

  copy all the inventory lists from inv into a new fake inventory. will also create a copy of another fake inventory.

* `futil.FakeInventory.room_for_all(inv, listname, items)`

  create a copy of inv, then tests if all items in the list `items` can be inserted into listname.

### globalstep

implements common boilerplate for globalsteps which are intended to execute every so often.

```lua
futil.register_globalstep({
    period = 1,  -- the globalstep should be run every <period> seconds
    catchup = "single", -- whether to "catch up" if lag prevents the callback from running
                        -- if not specified, no catchup will be attempted.
                        -- if "single", the callback will be run at most once per server-step until we've caught up.
                        -- if "full", will re-run the callback within the current step until we've caught up.
    func = function(dtime) end,  -- code to execute
})
```

### hud manager

code to manage HUDs

```lua
local hud = futil.define_hud("my_hud", {
    period = nil,  -- if a number is given, will automatically update the hud for all players every <period> seconds.
    name_field = nil, -- which hud field to use to store an identifier. this should be a field not used by the given
                      -- hud_elem_type. defaults to "name", which is good for most types. waypoints are an exception.
    get_hud_def = function(player) return {} end,  -- return the expected hud definition for the player.
                                                   -- if nil is returned, the hud will be removed.
    enabled_by_default = false, -- whether the hud should be enabled by default.
})

local player = minetest.get_player_by_name("flux")
if hud:toggle_enabled(player) then
    print("hud now enabled")
else
    print("hud now disabled")
end

print("hud is " .. (hud:is_enabled(player) and "enabled" or "disabled"))

hud:update(player)  -- calls hud.get_hud_def(player) and updates the players hud
```
