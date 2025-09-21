local mp = core.get_modpath(core.get_current_modname())

---@diagnostic disable-next-line: lowercase-global
---@class stube
stube = {
    debug = true, -- pollutes the creative inventory

    get_or_load_node = function(pos)
        local get_or_load_node_node = core.get_node_or_nil(pos)
        if get_or_load_node_node then return get_or_load_node_node end
        core.load_area(pos)
        return core.get_node(pos)
    end,
}

dofile(mp .. '/place.lua')
dofile(mp .. '/register.lua')
dofile(mp .. '/transport.lua')
dofile(mp .. '/entity.lua')
dofile(mp .. '/basic_tubes.lua')
