---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Translations

--[[
WIPDOC
]]
---@alias core.fn.translate_singular fun(str:string, ...:string):string

--[[
WIPDOC
]]
---@alias core.fn.translate_plural fun(str:string, str_plural:string, n:integer, ...:string):string

--[[
`core.get_translator(textdomain)` is a simple wrapper around
`core.translate` and `core.translate_n`.
After `local S, PS = core.get_translator(textdomain)`, we have
`S(str, ...)` equivalent to `core.translate(textdomain, str, ...)`, and
`PS(str, str_plural, n, ...)` to `core.translate_n(textdomain, str, str_plural, n, ...)`.
It is intended to be used in the following way, so that it avoids verbose
repetitions of `core.translate`:

```lua
local S, PS = core.get_translator(textdomain)
S(str, ...)
```

As an extra commodity, if `textdomain` is nil, it is assumed to be "" instead.
]]
---@nodiscard
---@param textdomain string?
---@return core.fn.translate_singular S, core.fn.translate_plural PS
function core.get_translator(textdomain) end

--[[
* `core.translate(textdomain, str, ...)` translates the string `str` with
  the given `textdomain` for disambiguation. The textdomain must match the
  textdomain specified in the translation file in order to get the string
  translated. This can be used so that a string is translated differently in
  different contexts.
  It is advised to use the name of the mod as textdomain whenever possible, to
  avoid clashes with other mods.
  This function must be given a number of arguments equal to the number of
  arguments the translated string expects.
  Arguments are literal strings -- they will not be translated.
]]
---@nodiscard
---@param textdomain string
---@param str string
---@param ... string
---@return string
function core.translate(textdomain, str, ...) end

--[[
WIPDOC
]]
---@nodiscard
---@param textdomain string
---@param str string
---@param str_plural string
---@param n integer
---@param ... string
---@return string
function core.translate_n(textdomain, str, str_plural, n, ...) end

--[[
On some specific cases, server translation could be useful. For example, filter
a list on labels and send results to client. A method is supplied to achieve
that:

`core.get_translated_string(lang_code, string)`: resolves translations in
the given string just like the client would, using the translation files for
`lang_code`. For this to have any effect, the string needs to contain translation
markup, e.g. `core.get_translated_string("fr", S("Hello"))`.

The `lang_code` to use for a given player can be retrieved from
the table returned by `core.get_player_information(name)`.

IMPORTANT: This functionality should only be used for sorting, filtering or similar purposes.
You do not need to use this to get translated strings to show up on the client.
]]
---@nodiscard
---@param lang_code core.LuantiSettings.enums.language
---@param str string
---@return string
function core.get_translated_string(lang_code, str) end