local definition = {
    name = 'luacontroller',
    nodes = {
        "sbz_logic:lua_controller_off",
        "sbz_logic:lua_controller_on",
    },
    group = 'luacontroller',
    protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    -- return data required for replicating this autocrafter configuration
    return {
        description = core.registered_nodes[node.name].short_description,
        editor_code = meta:get_string("editor_code"),
        code = meta:get_string("code"),
        formspec = meta:get_string("formspec"),
        mem = meta:get_string("mem"),
        links = meta:get_string("links"),
        oldpos = vector.copy(pos),
    }
end

function definition:paste(node, pos, player, data)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    meta:set_string("editor_code", data.editor_code)
    meta:set_string("code", data.code)
    meta:set_string("formspec", data.formspec)
    meta:set_string("mem", data.mem)
    -- port over links
    local links = core.deserialize(data.links or core.serialize({}))
    if type(links) == "table" then
        for name, pos_arr in pairs(links) do
            for pos_index, pos_in_arr in ipairs(pos_arr) do
                pos_arr[pos_index] = vector.add(vector.subtract(pos_in_arr, data.oldpos), pos)
            end
        end
        meta:set_string("links", core.serialize(links))
    end
end

return definition
