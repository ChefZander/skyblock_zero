---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > HTTP Requests

-- ------------------------------ HTTPApiTable ------------------------------ --

--[[
WIPDOC
]]
---@alias core.HTTPApiTable.fetch.fn fun(res:core.HTTPRequestDef)

--[[
WIPDOC
]]
---@alias core.HTTPApiTable.fetch fun(req:core.HTTPRequestDef, callback:core.HTTPApiTable.fetch.fn)

--[[
WIPDOC
]]
---@class core.HTTPFetchAsyncID : integer

--[[
WIPDOC
]]
---@alias core.HTTPApiTable.fetch_async fun(req:core.HTTPRequestDef)

--[[
WIPDOC
]]
---@alias core.HTTPApiTable.fetch_async_get fun(handle:core.HTTPFetchAsyncID):core.HTTPRequestResultDef

--[[
WIPDOC
]]
---@class core.HTTPApiTable
--[[
WIPDOC
]]
---@field fetch core.HTTPApiTable.fetch
--[[
WIPDOC
]]
---@field fetch_async core.HTTPApiTable.fetch_async
--[[
WIPDOC
]]
---@field fetch_async_get core.HTTPApiTable.fetch_async_get

-- ---------------------------- core.* functions ---------------------------- --

--[[
* `core.request_http_api()`:
    * returns `HTTPApiTable` containing http functions if the calling mod has
      been granted access by being listed in the `secure.http_mods` or
      `secure.trusted_mods` setting, otherwise returns `nil`.
    * The returned table contains the functions `fetch`, `fetch_async` and
      `fetch_async_get` described below.
    * Only works at init time and must be called from the mod's main scope
      (not from a function).
    * Function only exists if Luanti server was built with cURL support.
    * **DO NOT ALLOW ANY OTHER MODS TO ACCESS THE RETURNED TABLE, STORE IT IN
      A LOCAL VARIABLE!**
]]
---@nodiscard
---@return core.HTTPApiTable?
function core.request_http_api() end
