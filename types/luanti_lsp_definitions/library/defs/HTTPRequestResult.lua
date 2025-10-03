---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Definition tables > `HTTPRequestResult` definition

--[[
WIPDOC
]]
---@class core.HTTPRequestResultDef
--[[
If true, the request has finished (either succeeded, failed or timed
out)
]]
---@field  completed boolean?
--[[
If true, the request was successful
]]
---@field  succeeded boolean?
--[[
If true, the request timed out
]]
---@field  timeout boolean?
--[[
HTTP status code
]]
---@field  code integer?
--[[
Response body
]]
---@field  data string?
