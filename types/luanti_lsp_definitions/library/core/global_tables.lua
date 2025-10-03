---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Global tables
--[=[
NOTE: manually searched from output log of below in a minimal game:
core.log(dump2(core, 'core'))
]=]

--[[
WIPDOC
]]
---@type core.fn.on_mods_loaded[]
core.registered_on_mods_loaded = {}

--[[
WIPDOC
]]
---@type core.fn.on_shutdown[]
core.registered_on_shutdown = {}

--[[
WIPDOC
]]
---@type core.fn.on_generated[]
core.registered_on_generateds = {}

--[[
WIPDOC
]]
---@type core.fn.on_newplayer[]
core.registered_on_newplayers = {}

--[[
WIPDOC
]]
---@type core.fn.on_dieplayer[]
core.registered_on_dieplayers = {}

--[[
WIPDOC
]]
---@type core.fn.on_respawnplayer[]
core.registered_on_respawnplayers = {}

--[[
WIPDOC
]]
---@type core.fn.on_prejoinplayer[]
core.registered_on_prejoinplayers = {}

--[[
WIPDOC
]]
---@type core.fn.on_joinplayer[]
core.registered_on_joinplayers = {}

--[[
WIPDOC
]]
---@type core.fn.on_leaveplayer[]
core.registered_on_leaveplayers = {}

--[[
WIPDOC
]]
---@type core.fn.on_player_receive_fields[]
core.registered_on_player_receive_fields = {}

--[[
WIPDOC
]]
---@type core.fn.on_cheat[]
core.registered_on_cheats = {}

--[[
WIPDOC
]]
---@type core.fn.on_protection_violation[]
core.registered_on_protection_violation = {}

--[[
WIPDOC
]]
---@type core.fn.on_punchplayer[]
core.registered_on_punchplayers = {}

--[[
WIPDOC
]]
---@type core.fn.on_priv_grant[]
core.registered_on_priv_grant = {}

--[[
WIPDOC
]]
---@type core.fn.on_priv_revoke[]
core.registered_on_priv_revoke = {}

--[[
WIPDOC
]]
---@type core.fn.on_authplayer[]
core.registered_on_authplayers = {}

--[[
WIPDOC
]]
---@type core.fn.can_bypass_userlimit[]
core.registered_can_bypass_userlimit = {}

--[[
WIPDOC
]]
---@type core.fn.on_modchannel_message[]
core.registered_on_modchannel_message = {}

--[[
WIPDOC
]]
---@type core.fn.on_player_inventory_action[]
core.registered_on_player_inventory_actions = {}

--[[
WIPDOC
]]
---@type core.fn.allow_player_inventory_action[]
core.registered_allow_player_inventory_actions = {}

--[[
WIPDOC
]]
---@type core.fn.on_rightclickplayer[]
core.registered_on_rightclickplayers = {}

--[[
WIPDOC
]]
---@type core.fn.on_liquid_transform[]
core.registered_on_liquid_transformed = {}

--[[
WIPDOC
]]
---@type core.fn.on_mapblocks_changed[]
core.registered_on_mapblocks_changed = {}

--[[
WIPDOC
]]
---@type table<core.PrivilegeSet.keys, core.PrivilegeDef>
core.registered_privileges = {}

--[[
WIPDOC
]]
---@type table<core.ChatCommandDef.keys, core.ChatCommandDef>
core.registered_chatcommands = {}

--[[
WIPDOC
]]
---@type table<core.Node.name, core.NodeDef>
core.registered_nodes = {}

--[[
WIPDOC
]]
---@type core.fn.on_craft[]
core.registered_on_crafts = {}

--[[
WIPDOC
]]
---@type core.fn.craft_predict[]
core.registered_craft_predicts = {}

--[[
WIPDOC
]]
---@type core.fn.on_item_pickup[]
core.registered_on_item_pickups = {}

--[[
WIPDOC
]]
---@type core.fn.on_item_eat[]
core.registered_on_item_eats = {}

--[[
WIPDOC
]]
---@type core.fn.on_dignode[]
core.registered_on_dignodes = {}

--[[
WIPDOC
]]
---@type core.fn.on_placenode[]
core.registered_on_placenodes = {}

--[[
WIPDOC
]]
---@type core.fn.on_punchnode[]
core.registered_on_punchnodes = {}

--[[
WIPDOC
]]
---@type table<string, core.ObjectRef>
core.objects_by_guid = {}

--[[
WIPDOC
]]
---@deprecated
---@type table<integer, core.ObjectRef>
core.object_refs = {}

--[[
WIPDOC
]]
---@type table<integer, core.EntityRef>
core.luaentities = {}

--[[
WIPDOC
]]
---@type table<core.Alias, core.Item.name>
core.registered_aliases = {}

--[[
WIPDOC
]]
---@type table<core.Tool.name, core.ToolDef>
core.registered_tools = {}

--[[
WIPDOC
]]
---@type table<core.Item.name, core.ItemDef>
core.registered_craftitems = {}

--[[
WIPDOC
]]
---@type table<core.Item.name, core.ItemDef>
core.registered_items = {}

--[[
WIPDOC
]]
---@type table<string, core.EntityDef>
core.registered_entities = {}

--[[
WIPDOC
]]
---@type core.LBMDef[]
core.registered_lbms = {}

--[[
WIPDOC
]]
---@type core.ABMDef[]
core.registered_abms = {}

--[[
WIPDOC
]]
---@class core.reg.on_player_hpchanges
core.registered_on_player_hpchanges = {}

--[[
WIPDOC
]]
---@type core.fn.on_player_hpchange.modifier[]
core.registered_on_player_hpchanges.modifiers = {}

--[[
WIPDOC
]]
---@type core.fn.on_player_hpchange.logger[]
core.registered_on_player_hpchanges.loggers = {}

--[[
WIPDOC
]]
---@type table<string|core.BiomeID, core.BiomeDef>
core.registered_biomes = {}

--[[
WIPDOC
]]
---@type table<string|core.OreID, core.OreDef>
core.registered_ores = {}

--[[
WIPDOC
]]
---@type table<string|core.DecorationID, core.DecorationDef>
core.registered_decorations = {}

--[[
WIPDOC
]]
---@type core.fn.on_chat_message[]
core.registered_on_chat_messages = {}

--[[
WIPDOC
]]
---@type core.fn.on_chatcommand[]
core.registered_on_chatcommands = {}

--[[
WIPDOC
]]
---@type core.fn.globalstep[]
core.registered_globalsteps = {}

--[[
WIPDOC
]]
---@type core.fn.playerevent[]
core.registered_playerevents = {}

--[[
WIPDOC
]]
---@type table<string, core.DetachedInventoryCallbacks>
core.detached_inventories = {}