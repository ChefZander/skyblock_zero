--- Configuration in init.lua
---@class stube
stube = {
    -- The debug mode for STubes
    -- Currently, it just pollutes the creative inventory with tube variants
    debug = false,

    -- This is mostly an option for testing, there is no actual reason to disable them (You can just set entity_radius to something low if you don't like them)
    enable_entities = true,

    -- Item Entities will be shown when the player is this many nodes near to them
    -- Set to a huge value to almost always have item entities (Why would you do that?)
    -- This feature has been shown to help, as it skips laggy entity move_to calls
    entity_radius = 16,

    -- The globalstep for creating/removing entities will be run every <that value> seconds
    entity_creation_globalstep_time = 1,

    -- For simplicity, each tube must be the same size (simplicity in: each tubed item has to be the same size)
    tube_size = 3 / 16,
}

--- Creating a utils file is silly, so i am putting it here
--- ALSO: This is a trick from the mt-mods/technic luanti mod
---@param pos ivec
---@return core.Node.get
stube.get_or_load_node = function(pos)
    local get_or_load_node_node = core.get_node_or_nil(pos)
    if get_or_load_node_node then return get_or_load_node_node end
    core.load_area(pos)
    return core.get_node(pos)
end

local mp = core.get_modpath(core.get_current_modname())

--- Library:
dofile(mp .. '/place.lua') -- Placement of tubes (kinda complicated)
dofile(mp .. '/register.lua') -- Registering all the variants
dofile(mp .. '/stube_transport.lua') -- Moving tubed items and their entities, named "stube_transport.lua" for easier debugging (As there may be multiple transpurt.luas)
dofile(mp .. '/entity.lua') -- Only for defining the entity, and spawning/despawning them when needed
dofile(mp .. '/hud.lua') -- When hovering over a tube with items you can see the counts
dofile(mp .. '/register_routing_blocks.lua')

--- Content:
dofile(mp .. '/basic_tubes.lua')
dofile(mp .. '/basic_routing_blocks.lua')
