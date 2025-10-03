---@meta _
-- Helper functions in the global namespace or extends Lua's stdlib
-- luanti/doc/lua_api.md: Helper functions

-- NOTE: core.* helpers are in library/core/utilities/helpers.lua

--[[
Returns `obj` as a human-readable string assigned to `name`. Handles reference
loops. Table format resembles flattened JSON representation.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@param obj any
---@param name string? #@default(`"_"`)
---@param dumped table? #@default(`{}`)
---@return string
function dump2(obj, name, dumped) end

--[[
Returns `value` as a human-readable string. Handles reference loops. Table
format resembles JSON.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@param value any
---@param indent string?
---@return string
function dump(value, indent) end

-- ---------------------------------- math ---------------------------------- --

--[[
Returns hypotenuse of a triangle with legs x and y. Useful to obtain distance.

* @see luanti/builtin/common/math.lua
]]
---@nodiscard
---@param x number
---@param y number
---@return number
function math.hypot(x, y) end

--[[
Returns the sign of a number.

* @see luanti/builtin/common/math.lua
]]
---@nodiscard
---@param x number
---@param tolerance number? #@default(`0`) anchor where the zero would be
---@return -1|0|1 #@hint(`[-1, 1]`)
function math.sign(x, tolerance) end

--[[
Returns factorial of `x`

* @see luanti/builtin/common/math.lua
]]
---@nodiscard
---@param x integer #@hint(`[0,171]`)
---@return integer
function math.factorial(x) end

--[[
Returns `x` rounded to the nearest integer

* @see luanti/builtin/common/math.lua
]]
---@nodiscard
---@param x number
---@return integer
function math.round(x) end

-- --------------------------------- string --------------------------------- --

--[[
Splits given string into a list.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@nodiscard
---@param str string
---@param separator string? #@default(`","`) @hint(`not empty`)
---@param include_empty boolean? #@default(`false`)
---@param max_splits integer? #@default(`-1`) Unlimited if negative
---@param sep_is_pattern boolean? #@default(`false`) `separator` is lua pattern or plain string
---@return string[]
function string.split(str, separator, include_empty, max_splits, sep_is_pattern) end

--[[
Trim whitespace out of given string at beginning and end. Uses the `%s` lua
pattern item.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@nodiscard
---@param str string
---@return string
function string.trim(str) end

-- ---------------------------------- table --------------------------------- --

-- NOTE: SparseList doesn't work here because these list operations work on
-- #list or ipairs(list)

--[[
Returns a deep copy of given table. Metatables are ignored.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@nodiscard
---@generic T : table
---@param table `T`
---@return T
function table.copy(table) end

--[[
Returns a deep copy of given table. Metatables are included.

* @added 5.12
* @see luanti/builtin/common/misc_helpers.lua
]]
---@nodiscard
---@generic T : table
---@param table `T`
---@return T
function table.copy_with_metatables(table) end

--[[
Returns first smallest index of `val` in given list. Ignores non-array part of
list. List must not have negative indices.

If not found, returns -1 instead.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@nodiscard
---@generic T
---@param val T
---@param list T[]
---@return integer
function table.indexof(list, val) end

--[[
Returns a key of `val` in given table. Not specified which key is returned if
many has `val`

If not found, returns `nil` instead

* @see luanti/builtin/common/misc_helpers.lua
]]
---@nodiscard
---@generic T
---@param table table<T, any>
---@param val any
---@return T?
function table.keyof(table, val) end

--[[
Inserts all values from `other_list` into `list`. Returns `list`.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@nodiscard
---@generic T
---@param list T[]
---@param other_list T[]
---@return T[]
function table.insert_all(list, other_list) end

--[[
Returns a table with keys and values of given table swapped. Not specified
value would map to which keys if many keys has the same value.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@nodiscard
---@param t table
---@return table
function table.key_value_swap(t) end

--[[
Function accepts two positive integers and must return a value inclusively
between the integers.

* @hint int1 `0`
* @hint int2 `>=1`
* @hint return `[int1,int2]`
* @see luanti/builtin/common/misc_helpers.lua
]]
---@alias table.random_func fun(int1:integer, int2:integer): integer

--[[
Shuffles elements in given list from `from` to `to` in place.

* @see luanti/builtin/common/misc_helpers.lua
]]
---@generic T
---@param list T[]
---@param from integer? #@default(`1`)
---@param to integer? #@default(`#list`)
---@param random_func table.random_func? #@default(`math.random`)
function table.shuffle(list, from, to, random_func) end