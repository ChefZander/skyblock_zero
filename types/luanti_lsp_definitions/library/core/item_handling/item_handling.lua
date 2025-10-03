---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Item handling

--[[
WIPDOC
]]
---@nodiscard
---@param img1 core.Texture
---@param img2 core.Texture
---@param img3 core.Texture
---@return core.Texture
function core.inventorycube(img1, img2, img3) end

--[[
* `core.get_pointed_thing_position(pointed_thing, above)`
    * Returns the position of a `pointed_thing` or `nil` if the `pointed_thing`
      does not refer to a node or entity.
    * If the optional `above` parameter is true and the `pointed_thing` refers
      to a node, then it will return the `above` position of the `pointed_thing`.
]]
---@nodiscard
---@param pointed_thing core.PointedThing
---@param above boolean?
---@return vec?
function core.get_pointed_thing_position(pointed_thing, above) end

--[[
WIPDOC
]]
---@nodiscard
---@param dir vector
---@param is6d boolean?
---@return core.Param2.facedir
function core.dir_to_facedir(dir, is6d) end

--[[
WIPDOC
]]
---@nodiscard
---@param facedir core.Param2.facedir
---@return ivec
function core.facedir_to_dir(facedir) end

--[[
WIPDOC
]]
---@nodiscard
---@param dir vector
---@return core.Param2.4dir
function core.dir_to_fourdir(dir) end

--[[
WIPDOC
]]
---@nodiscard
---@param fourdir core.Param2.4dir
---@return ivec
function core.fourdir_to_dir(fourdir) end

--[[
WIPDOC
]]
---@nodiscard
---@param dir vector
---@return core.Param2.wallmounted
function core.dir_to_wallmounted(dir) end

--[[
WIPDOC
]]
---@nodiscard
---@param wallmounted core.Param2.wallmounted
---@return ivec
function core.wallmounted_to_dir(wallmounted) end

--[[
WIPDOC
]]
---@nodiscard
---@param dir vector
---@return number
function core.dir_to_yaw(dir) end

--[[
WIPDOC
]]
---@nodiscard
---@param yaw number
---@return vec
function core.yaw_to_dir(yaw) end

--[[
WIPDOC
]]
---@nodiscard
---@param param2 core.Param2
---@param paramtype2 core.NodeDef.paramtype2.color
---@return core.Param2
function core.strip_param2_color(param2, paramtype2) end

--[[
WIPDOC
]]
---@nodiscard
---@param param2 core.Param2
---@param paramtype2 string
---@return nil
function core.strip_param2_color(param2, paramtype2) end

--[[
WIPDOC
]]
---@nodiscard
---@param node core.Node.name|core.Node.set
---@param toolname core.Tool.name?
---@param tool core.ItemStack?
---@param digger core.ObjectRef?
---@param pos ivector?
---@return core.Item.stringfmt[]
function core.get_node_drops(node, toolname, tool, digger, pos) end

--[[ core.get_craft_result() .. core.get_all_craft_recipes() split off into ./craft_result.lua ]]--

--[[
* `core.handle_node_drops(pos, drops, digger)`
    * `drops`: list of itemstrings
    * Handles drops from nodes after digging: Default action is to put them
      into digger's inventory.
    * Can be overridden to get different functionality (e.g. dropping items on
      ground)
]]
---@param pos ivector
---@param drops core.Item.stringfmt[]
---@param digger core.ObjectRef
function core.handle_node_drops(pos, drops, digger) end

--[[
* `core.itemstring_with_palette(item, palette_index)`: returns an item
  string.
    * Creates an item string which contains palette index information
      for hardware colorization. You can use the returned string
      as an output in a craft recipe.
    * `item`: the item stack which becomes colored. Can be in string,
      table and native form.
    * `palette_index`: this index is added to the item stack
]]
---@nodiscard
---@param item core.Item
---@param palette_index integer
---@return core.Item.stringfmt
function core.itemstring_with_palette(item, palette_index) end

--[[
* `core.itemstring_with_color(item, colorstring)`: returns an item string
    * Creates an item string which contains static color information
      for hardware colorization. Use this method if you wish to colorize
      an item that does not own a palette. You can use the returned string
      as an output in a craft recipe.
    * `item`: the item stack which becomes colored. Can be in string,
      table and native form.
    * `colorstring`: the new color of the item stack
]]
---@param item core.Item
---@param colorstring core.ColorString
---@return core.Item.stringfmt
function core.itemstring_with_color(item, colorstring) end