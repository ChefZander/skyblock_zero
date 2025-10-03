---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Registration functions > Gameplay

--[[
WIPDOC
]]
---@param craft_recipe core.CraftingRecipeDef
function core.register_craft(craft_recipe) end

--[[
WIPDOC
]]
---@param recipe core.CraftingRecipeDef.clear?
function core.clear_craft(recipe) end

--[[
WIPDOC
]]
---@param name string
---@param chatcommand_def core.ChatCommandDef
function core.register_chatcommand(name, chatcommand_def) end

--[[
WIPDOC
]]
---@param name string
---@param redef core.ChatCommandDef.override
function core.override_chatcommand(name, redef) end

--[[
WIPDOC
]]
---@param name string
function core.unregister_chatcommand(name) end

--[[
WIPDOC
]]
---@param name string
---@param def core.PrivilegeDef
function core.register_privilege(name, def) end

--[[
* Registers an auth handler that overrides the builtin one.
* This function can be called by a single mod once only.
]]
---@param auth_handler_def core.AuthenticationHandlerDef
function core.register_authentication_handler(auth_handler_def) end