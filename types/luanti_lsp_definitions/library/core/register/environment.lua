---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Registration functions > Environment

--[[
* Note: you must pass a clean table that hasn't already been used for
  another registration to this function, as it will be modified.
]]
---@param name string
---@param node_def core.NodeDef
function core.register_node(name, node_def) end

--[[
* Note: you must pass a clean table that hasn't already been used for
  another registration to this function, as it will be modified.
]]
---@param name string
---@param itemdef core.ItemDef
function core.register_craftitem(name, itemdef) end

--[[
* Note: you must pass a clean table that hasn't already been used for
  another registration to this function, as it will be modified.
]]
---@param name string
---@param itemdef core.ItemDef
function core.register_tool(name, itemdef) end

--[[
* `core.override_item(name, redefinition, del_fields)`
    * `redefinition` is a table of fields `[name] = new_value`,
      overwriting fields of or adding fields to the existing definition.
    * `del_fields` is a list of field names to be set
      to `nil` ("deleted from") the original definition.
    * Overrides fields of an item registered with register_node/tool/craftitem.
    * Note: Item must already be defined.
    * Example: `core.override_item("default:mese",
      {light_source=core.LIGHT_MAX}, {"sounds"})`:
      Overwrites the `light_source` field,
      removes the sounds from the definition of the mese block.
]]
---@param name string
---@param redefinition core.ItemDef|core.NodeDef
---@param del_fields core.ItemDef.keys|core.NodeDef.keys
function core.override_item(name, redefinition, del_fields) end

--[[
WIPDOC
]]
---@param name string
function core.unregister_item(name) end

--[[
WIPDOC
]]
---@param name string
---@param entity_def core.EntityDef
function core.register_entity(name, entity_def) end

--[[
WIPDOC
]]
---@param abmdef core.ABMDef
function core.register_abm(abmdef) end

--[[
WIPDOC
]]
---@param lbmdef core.LBMDef
function core.register_lbm(lbmdef) end

--[[
Also use this to set the 'mapgen aliases' needed in a game for the code mapgens.
]]
---@param alias core.Alias
---@param original_name core.Item.name
function core.register_alias(alias, original_name) end

--[[
WIPDOC
]]
---@param alias core.Alias
---@param original_name core.Item.name
function core.register_alias_force(alias, original_name) end

--[[
WIPDOC
]]
---@nodiscard
---@param def core.OreDef
---@return core.OreID?
function core.register_ore(def) end

--[[
WIPDOC
]]
---@nodiscard
---@param biome_def core.BiomeDef
---@return core.BiomeID?
function core.register_biome(biome_def) end

--[[
* Unregisters the biome from the engine, and deletes the entry with key
  `name` from `core.registered_biomes`.
* Warning: This alters the biome to biome ID correspondences, so any
  decorations or ores using the 'biomes' field must afterwards be cleared
  and re-registered.
]]
---@param name string
function core.unregister_biome(name) end

--[[
WIPDOC
]]
---@nodiscard
---@param decoration_def core.DecorationDef
---@return core.DecorationID?
function core.register_decoration(decoration_def) end

--[[
WIPDOC
]]
---@nodiscard
---@param schem_def core.SchematicDef
---@return core.SchematicID
function core.register_schematic(schem_def) end

--[[
* `core.clear_registered_biomes()`
    * Clears all biomes currently registered.
    * Warning: Clearing and re-registering biomes alters the biome to biome ID
      correspondences, so any decorations or ores using the 'biomes' field must
      afterwards be cleared and re-registered.
]]
function core.clear_registered_biomes() end

--[[
WIPDOC
]]
function core.clear_registered_decorations() end

--[[
WIPDOC
]]
function core.clear_registered_ores() end

--[[
WIPDOC
]]
function core.clear_registered_schematics() end
