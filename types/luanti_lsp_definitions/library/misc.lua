---@meta _
-- Miscellaneous. No cohesive grouping
-- luanti/doc/lua_api.md: Definition tables > Bit Library

--[[
Called on uncaught errors to transform error objects into string to display.

By default this is a backtrace from `debug.traceback`. Error object is first
converted with `tostring` if it's not a string. This means that you can use
tables as error objects so long as you give them `__tostring` metamethods.

* @overrideable
* @see luanti/builtin/init.lua
]]
---@nodiscard
---@param err any
---@param level integer #@hint(`>=0`)
---@return string
function core.error_handler(err, level) end

--[[
Path separator

* @deprecated 5.X Recommended to use the forward slash `/` instead
* @see
]]
---@deprecated
---@type "/"|"\\"
DIR_DELIM = nil

--[[
Luanti provids the bitop library. Avoid using this unless you really need bit
manipulation as it's not faster than JIT traced arithmetic operations.

* @see <http://bitop.luajit.org/> for more information about the specifics in LuaJIT
* @see luanti/lib/bitop/ for its implementation
]]
---@type bitlib
bit = bit

--[[
Full absolute path to a file or directory.
]]
---@alias core.Path string

--[[
Partial path or filename corresponding to a file within the current mod.
]]
---@alias core.ModAsset string

--[[
Serializable types
]]
---@alias core.Serializable nil|boolean|number|string|table

--[[
Helper type: `T` or a list of `T`
]]
---@generic T
---@alias OneOrMany T|T[]

--[[
Helper type: accepts a sparse list of `T` with holes
]]
---@generic T
---@alias SparseList {[integer]:T}|T[]