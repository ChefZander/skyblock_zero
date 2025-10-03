---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Logging

--[[
WIPDOC
]]
---@alias core.LoggingLevel
--- | "none"
--- | "error"
--- | "warning"
--- | "action"
--- | "info"
--- | "verbose"

--[[
Unofficial note: I made it deprecated because this should NOT be in any production code, and you should use something better tbh, like dbg.pp (from lars's dbg mod)
* Equivalent to `core.log(table.concat({...}, "\t"))`
]]
---@deprecated
---@param ... any
function core.debug(...) end

--[[
WIPDOC
]]
---@param loglevel core.LoggingLevel
---@param text string
function core.log(loglevel, text) end

--[[
WIPDOC
]]
---@param text string
function core.log(text) end