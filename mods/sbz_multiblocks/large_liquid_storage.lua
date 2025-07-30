local storage_per_node = 200 -- 5x5x5 25000 liquid sources
-- That's a lot, and that's okay

local function get_llsc_formspec(pos)
    local meta = core.get_meta(pos)
    local storage_size = meta:get_int("storage_size")
    if storage_size == 0 then
        storage_size = 2
        meta:set_int("storage_size", 2)
    end
    if meta:get_int("set_up") == 1 then
        core.registered_nodes[sbz_api.get_node_force(pos).name].on_liquid_inv_update(pos,
            core.deserialize(meta:get_string("liquid_inv")))
        return ""
    else
        local fs = ([[
        formspec_version[7]
size[8,6]
button[0.5,0.5;3,1;form_multiblock;Form Multiblock]
button[4.5,0.5;3,1;show_ghosts;Show Build Plan]
label[0.5,2;Storage Size:]
scrollbaroptions[min=2;max=5;smallstep=1;largestep=4;arrows=default]
scrollbar[0.5,2.5;7,0.5;horizontal;storage_size;%s]
label[1.6,3.3;2]
label[3.2,3.3;3]
label[4.7,3.3;4]
label[6.25,3.3;5]
    ]]):format(storage_size)
        if #meta:get_string("errmsg") ~= 0 then
            fs = fs ..
                string.format("textarea[0.5,4;8,2;;Error message when trying to form multiblock:;%s]",
                    meta:get_string("errmsg"))
        else
            fs = fs .. ("label[0.5,4;=> %s liquid source(s)]"):format(storage_size ^ 3 * storage_per_node)
        end
        return fs
    end
end

local cached_schems = {}
local h = core.hash_node_position
local function make_schem(pos, meta, node)
    local storage_size = (meta and meta.storage_size) or core.get_meta(pos):get_int("storage_size")
    local param2 = (node and node.param2) or sbz_api.get_or_load_node(pos).param2
    local orientation = core.facedir_to_dir(param2 - (core.strip_param2_color(param2, "colorfacedir") or 0))
    if cached_schems[storage_size] and cached_schems[storage_size][h(orientation)] then
        return cached_schems[storage_size][h(orientation)]
    end
    local schemdata = {}
    local schem = {
        data = schemdata,
        categories = {},
        limits = {},
    }

    -- most boring code ever

    local vn = vector.new
    local edge = "sbz_multiblocks:large_liquid_storage_casing_edge"

    -- there is at least 1 redundant loop here definitely xD
    for _, x in ipairs({ 0, storage_size + 1 }) do
        for _, y in ipairs({ 0, storage_size + 1 }) do
            for z = 0, storage_size + 1 do
                if not (y == 0 and z == 0 and x == 0) then
                    schemdata[h(vn(x, y, z))] = edge
                end
            end
        end
    end
    for _, y in ipairs({ 0, storage_size + 1 }) do
        for _, z in ipairs({ 0, storage_size + 1 }) do
            for x = 0, storage_size + 1 do
                if not (y == 0 and z == 0 and x == 0) then
                    schemdata[h(vn(x, y, z))] = edge
                end
            end
        end
    end
    for _, z in ipairs({ 0, storage_size + 1 }) do
        for _, y in ipairs({ 0, storage_size + 1 }) do
            for x = 0, storage_size + 1 do
                if not (y == 0 and z == 0 and x == 0) then
                    schemdata[h(vn(x, y, z))] = edge
                end
            end
        end
    end
    for _, z in ipairs({ 0, storage_size + 1 }) do
        for _, x in ipairs({ 0, storage_size + 1 }) do
            for y = 0, storage_size + 1 do
                if not (y == 0 and z == 0 and x == 0) then
                    schemdata[h(vn(x, y, z))] = edge
                end
            end
        end
    end
    for _, x in ipairs({ 0, storage_size + 1 }) do
        for _, z in ipairs({ 0, storage_size + 1 }) do
            for y = 0, storage_size + 1 do
                if not (y == 0 and z == 0 and x == 0) then
                    schemdata[h(vn(x, y, z))] = edge
                end
            end
        end
    end


    local side = "sbz_multiblocks:large_liquid_storage_casing"
    for _, z in ipairs({ 0, storage_size + 1 }) do
        for x = 1, storage_size do
            for y = 1, storage_size do
                schemdata[h(vn(x, y, z))] = side
            end
        end
    end

    for _, x in ipairs({ 0, storage_size + 1 }) do
        for z = 1, storage_size do
            for y = 1, storage_size do
                schemdata[h(vn(x, y, z))] = side
            end
        end
    end

    for _, y in ipairs({ 0, storage_size + 1 }) do
        for z = 1, storage_size do
            for x = 1, storage_size do
                schemdata[h(vn(x, y, z))] = side
            end
        end
    end

    schem = sbz_api.multiblocks.rotate_schematic(schem, orientation)
    if not cached_schems[storage_size] then
        cached_schems[storage_size] = {}
    end
    cached_schems[storage_size][h(orientation)] = schem
    return schem
end

local default_inv = minetest.serialize({
    max_count_in_each_stack = 0,
    [1] = {
        name = "any",
        count = 0,
        can_change_name = true,
    },
})

core.register_node("sbz_multiblocks:large_liquid_storage_controller", unifieddyes.def {
    description = "Large Liquid Storage Controller",
    groups = {
        matter = 1,
        multiblock_controller = 1,
        fluid_pipe_connects = 1, fluid_pipe_stores = 1, ui_fluid = 1
    },
    paramtype2 = "colorfacedir",
    tiles = {
        "large_liquid_storage_controller_top.png",
        "large_liquid_storage_controller_top.png",
        "large_liquid_storage_controller_sides.png",
        "large_liquid_storage_controller_sides.png",
        "large_liquid_storage_controller_sides.png",
        "large_liquid_storage_controller_back.png",
    },
    light_source = 3,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", get_llsc_formspec(pos))
        meta:set_string("liquid_inv", default_inv)
    end,
    on_receive_fields = function(pos, _, fields, sender)
        local meta = core.get_meta(pos)
        local is_multiblock = meta:get_int("set_up") == 1
        if not is_multiblock then
            if fields.storage_size then
                local scrollbar_event = core.explode_scrollbar_event(fields.storage_size)
                if scrollbar_event.type == "CHG" and scrollbar_event.value <= 5 and scrollbar_event.value >= 2 then
                    meta:set_int("storage_size", scrollbar_event.value)
                end
            end
            if fields.show_ghosts then
                local default_expiration = 8
                local last_used = meta:get_int("last_used_build_helper")
                if os.difftime(os.time(), last_used) >= default_expiration then
                    local schem = make_schem(pos)
                    sbz_api.multiblocks.draw_schematic(pos, schem)
                    meta:set_int("last_used_build_helper", os.time())
                else
                    core.chat_send_player(sender:get_player_name(),
                        "You need to wait " ..
                        (default_expiration - os.difftime(os.time(), last_used)) ..
                        " seconds before showing build plan again.")
                end
            end
            if fields.form_multiblock then
                local schem = make_schem(pos)
                local result = sbz_api.multiblocks.form_multiblock(pos, schem)
                if result.success == false then
                    meta:set_string("errmsg", result.errmsg)
                else
                    meta:set_int("set_up", 1)
                    meta:set_string("liquid_inv", core.serialize {
                        max_count_in_each_stack = meta:get_int("storage_size") ^ 3 * storage_per_node,
                        [1] = {
                            name = "any",
                            count = 0,
                            can_change_name = true,
                        }
                    })
                    meta:set_string("infotext", "Waiting for a liquid...")
                end
            end
        end
        local newfs = get_llsc_formspec(pos)
        if newfs ~= "" then
            meta:set_string("formspec", newfs)
        end
    end,
    on_multiblock_break = function(pos, meta)
        meta:set_int("set_up", 0)
        meta:set_string("formspec", get_llsc_formspec(pos))
        meta:set_string("liquid_inv", default_inv)
        core.debug(dump(debug.traceback()))
    end,
    get_schematic = make_schem,
    after_dig_node = sbz_api.multiblocks.after_dig_controller("sbz_multiblocks:large_liquid_storage_controller"),
    before_movenode = sbz_api.multiblocks.before_movenode,
    on_liquid_inv_update = function(pos, lqinv)
        local meta = minetest.get_meta(pos)
        if lqinv[1].name == "any" then
            meta:set_string("infotext", "Waiting for a liquid...")
            return;
        end
        local def = minetest.registered_nodes[lqinv[1].name]
        local desc = string.gsub(def.short_description or def.description or lqinv[1].name, " Source", "")
        meta:set_string("infotext", ("Storing %s : %s/%s"):format(desc, lqinv[1].count, lqinv.max_count_in_each_stack))
        meta:set_string("formspec", sbz_api.liquid_storage_fs(lqinv[1].count, lqinv.max_count_in_each_stack))
    end,
})

core.register_node("sbz_multiblocks:large_liquid_storage_casing", unifieddyes.def {
    description = "Large Liquid Storage Casing",
    groups = {
        matter = 1,
        wallsharing = 1,
        ui_fluid = 1,
    },
    info_extra = "Or \"Dark Stained Colorium Glass\" If you are into decorating",
    drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "color",
    tiles = {
        "large_liquid_storage_casing.png",
        "large_liquid_storage_casing_inner.png",
    },
    use_texture_alpha = "blend",
    light_source = 3,
    after_dig_node = sbz_api.multiblocks.after_dig,
    before_movenode = sbz_api.multiblocks.before_movenode,
})

core.register_node("sbz_multiblocks:large_liquid_storage_casing_edge", unifieddyes.def {
    description = "Large Liquid Storage Edge Casing ",
    groups = {
        matter = 1,
        wallsharing = 1,
        ui_fluid = 1
    },
    drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "color",
    tiles = {
        "large_liquid_storage_casing_edge.png",
        "large_liquid_storage_casing_edge_inner.png",
    },
    light_source = 3,
    after_dig_node = sbz_api.multiblocks.after_dig,
    before_movenode = sbz_api.multiblocks.before_movenode,
})
