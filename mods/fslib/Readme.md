# Formspec Library (`fslib`)

A tiny Minetest library mod to facilitate managing formspecs.

Written by Lars Müller alias [appgurueu](https://github.com/appgurueu) and licensed under the terms of the MIT license.

Links:

* [GitHub](https://github.com/appgurueu/fslib)
* [ContentDB](https://content.minetest.net/packages/LMD/fslib/)
* [Minetest Forums](https://forum.minetest.net/viewtopic.php?f=9&t=28261)

## API

### `fslib.build_formspec(formspec_table)`

Builds a formspec string out of a table of S-expressions; purely a string building helper
entirely unaware of formspec semantics: Everything must properly use the table formats no matter the context.

Subtables of formspec tables take the form `{"element_name", ...}`, where `...` may consist of:

* Strings to be escaped;
* Numbers to be formatted using `%d` (integers) or `%f` (floats);
* Booleans to be formatted as `true` or `false`;
* A subtable:
	* An options table `{[option] = value}`
	* A sublist to which the same formatting rules apply but which will use `,` instead of `;` as delimiter (e.g. coordinates);
	* A hypertext table created by through the use of `fslib.hypertext_root{fslib.hypertext_tags.tag{attr = value, child_1, child_2, "text", ...}}`
		* **Tip:** Localize `local tags = fslib.hypertext_tags`

### `formspec_name = fslib.show_formspec(player, formspec, handler)`

* `player`: PlayerRef (ObjectRef)
* `formspec`: Formspec in string or table format (see `fslib.build_formspec`)
* `handler`: `function(fields) return next_formspec` which is called as the form is submitted
	* `fields`: Submitted formspec fields as provided by the engine
	* `next_formspec`: If returned, the formspec will be reshown by sending the `next_formspec`; `player` & `handler` stay the same
	* **Tip:** Use upvalues of `handler` - including the `player` - as context!
* Returns an ID `formspec_name` which can be used to reshow the formspec
	* **Tip:** If you don't need to reshow the formspec with the same name or can reshow it by returning a new formspec inside the handler you should not use this.

### `fslib.reshow_formspec(player, formspec_name, formspec)`

Reshows ("updates") the formspec reusing the name. `formspec` may be a `formspec_table`.

### `fslib.close_formspec(player)`

Closes whichever formspec was last shown to `player` using `fslib`.

**Tip:** If possible use `exit` elements in the formspec instead for a better user experience and to [work around a bug](https://github.com/minetest/minetest/issues/11907).

### Example

```lua
local delete_confirmation_fs = fslib.build_formspec{
	{"size", {6, 1, false}},
	{"real_coordinates", true},
	{"label", {0.25, 0.5}; "Irreversably delete paintable?"},
	{"image_button_exit", {4.75, 0.25}; {0.5, 0.5}; "epidermis_check.png"; "confirm"; ""},
	{"tooltip", "confirm", "Confirm"},
	{"image_button_exit", {5.25, 0.25}; {0.5, 0.5}; "epidermis_cross.png"; "close"; ""},
	{"tooltip", "close", "Close"},
}
function entity_def:_show_delete_formspec(player)
	fslib.show_formspec(player, delete_confirmation_fs, function(fields)
		if fields.confirm then
			self:_delete()
		end
	end)
end
```

(from [`epidermis`](https://github.com/appgurueu/epidermis), slightly modified)

Note:

* The (static) formspec is built at load time to improve performance
* The formspec field handler obtains `self` - in this case an entity - as context
