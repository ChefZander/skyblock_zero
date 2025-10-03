---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Mapgen environment

--[[
WIPDOC
]]
---@param path core.Path
function core.register_mapgen_script(path) end

--[[
WIPDOC
]]
---@class corelib.mapgen : corelib.async
local mapgen = {
    get_biome_id = core.get_biome_id,
    get_biome_name = core.get_biome_name,
    get_heat = core.get_heat,
    get_humidity = core.get_humidity,
    get_biome_data = core.get_biome_data,
    get_mapgen_object = core.get_mapgen_object,
    ---@diagnostic disable-next-line: deprecated
    get_mapgen_params = core.get_mapgen_params,
    get_mapgen_edges = core.get_mapgen_edges,
    get_mapgen_setting = core.get_mapgen_setting,
    get_noiseparams = core.get_noiseparams,
    get_decoration_id = core.get_decoration_id,
-- TODO ... and more. WHY THE FUCK DON'T THEY JUST LIST THE GODDAMN FUNCTIONS

    -- TODO each needs a disclaimer that it operates only in the current chunk. separate this later
    get_node = core.get_node,
    set_node = core.set_node,
    find_node_near = core.find_node_near,
    find_nodes_in_area = core.find_nodes_in_area,
    spawn_tree = core.spawn_tree,
-- TODO ... and more. WHY THE FUCK DON'T THEY JUST LIST THE GODDAMN FUNCTIONS

    settings = core.settings,

-- TODO async registered_* has functions and userdata set to true instead
    registered_items = core.registered_items,
    registered_nodes = core.registered_nodes,
    registered_tools = core.registered_tools,
    registered_craftitems = core.registered_craftitems,
    registered_aliases = core.registered_aliases,
-- TODO ... and more. WHY THE FUCK DON'T THEY JUST LIST THE GODDAMN FUNCTIONS
    registered_biomes = core.registered_biomes,
    registered_ores = core.registered_ores,
    registered_decorations = core.registered_decorations,
}

--[[
WIPDOC
]]
---@alias mapgen.fn.on_generated fun(vmanip:core.VoxelManip, minp:ivec, maxp:ivec, blockseed:integer)

--[[
WIPDOC
]]
---@param f mapgen.fn.on_generated
function mapgen.register_on_generated(f) end

--[[
WIPDOC
]]
---@nodiscard
---@param id string
---@param data core.Serializable
---@return true?
function mapgen.register_on_generated(id, data) end
