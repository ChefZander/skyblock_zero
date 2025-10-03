---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Async environment

--[[
WIPDOC
]]
---@nodiscard
---@param f function
---@param callback function
---@param ... any
---@return core.AsyncJob
function core.handle_async(f, callback, ...) end

--[[
* `core.register_async_dofile(path)`:
    * Register a path to a Lua file to be imported when an async environment
      is initialized. You can use this to preload code which you can then call
      later using `core.handle_async()`.
]]
---@param path core.Path
function core.register_async_dofile(path) end

--[[
WIPDOC
]]
---@class corelib.async
local async = {
    settings = core.settings,

-- TODO async registered_* has functions and userdata set to true instead
    registered_items = core.registered_items,
    registered_nodes = core.registered_nodes,
    registered_tools = core.registered_tools,
    registered_craftitems = core.registered_craftitems,
    registered_aliases = core.registered_aliases,
-- TODO ... and more. WHY THE FUCK DON'T THEY JUST LIST THE GODDAMN FUNCTIONS
}