# Schema

Place a file `schema.lua` in your mod, returning a schema table.

## Non-string entries and `minetest.conf`

Suppose you have the following schema:

```lua
return {
	type = "table",
	entries = {
		[42] = {
			type = "boolean",
			description = "The Answer"
			default = true
		}
	}
}
```

And a user sets the following config:

```conf
mod.42 = false
```

It won't work, as the resulting table will be `{["42"] = false}` instead of `{[42] = false}`. In order to make this work, you have to convert the keys yourself:

```lua
return {
	type = "table",
	keys = {
		-- this will convert all keys to numbers
		type = "number"
	},
	entries = {
		[42] = {
			type = "boolean",
			description = "The Answer"
			default = true
		}
	}
}
```

This is best left explicit. First, you shouldn't be using numbered field keys if you want decent `minetest.conf` support, and second, `modlib`'s schema module could only guess in this case, attempting conversion to number / boolean. What if both number and string field were set as possible entries? Should the string field be deleted? And so on.
