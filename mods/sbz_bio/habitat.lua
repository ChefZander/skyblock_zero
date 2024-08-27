local hash = minetest.hash_node_position
local touched_nodes = {}

function sbz_api.assemble_habitat(start_pos, seen)
    local checking = {start_pos}
    seen = seen or {}
    local size = 0
    local plants = {}
    local co2_sources = {}
    sbz_api.vm_begin()

    while #checking > 0 and size < 4096 do
        local pos = table.remove(checking, 1)
        if not seen[hash(pos)] then
            local node = sbz_api.vm_get_node(pos) or {name="ignore"}
            if minetest.get_item_group(node.name, "plant") > 0 then
                table.insert(plants, {pos, node})
            elseif minetest.get_item_group(node.name, "co2_source") > 0 then
                table.insert(co2_sources, {pos, node})
            elseif node.name == "air" or pos == start_pos then
                for i = 0, 5 do
                    table.insert(checking, pos+minetest.wallmounted_to_dir(i))
                end
            else
                size = size-1
            end
            seen[hash(pos)] = true
            size = size+1
        end
    end

    if #checking > 0 then return end
    return {plants=plants, co2_sources=co2_sources, size=size}
end

function sbz_api.habitat_tick(start_pos, meta)
    local time = os.time()
    local habitat = sbz_api.assemble_habitat(start_pos)
    if not habitat then
        meta:set_string("infotext", "Habitat unenclosed or too large\nMake sure the habitat is fully sealed")
        return
    end

    local co2 = 0
    for _, v in ipairs(habitat.co2_sources) do
        local pos, node = unpack(v)
        co2 = co2+minetest.registered_nodes[node.name].co2_action(pos, node)
        touched_nodes[hash(pos)] = time
    end

    for i = 1, math.min(co2, #habitat.plants) do
        local pos, node = unpack(habitat.plants[i])
        local growth_tick = minetest.registered_nodes[node.name].growth_tick or function(...) end
        if growth_tick(pos, node) then touched_nodes[hash(pos)] = time end
    end

    meta:set_string("infotext", table.concat({
        "CO2 supply: ", co2,
        "\nCO2 demand: ", #habitat.plants,
        "\nHabitat size: ", habitat.size
    }))
end

sbz_api.register_machine("sbz_bio:habitat_regulator", {
    description = "Habitat Regulator",
    tiles = {"habitat_regulator.png"},
    groups = {matter=1},
    control_action_raw = true,
    action = function (pos, node, meta, supply, demand)
        if demand+20 > supply then
            meta:set_string("infotext", "Not enough power, needs: 20")
        else
            local count = meta:get_int("count")
            if count >= 10 then
                sbz_api.habitat_tick(pos, meta)
                meta:set_int("count", 0)
            else
                meta:set_int("count", count+1)
            end
        end
        return 20
    end
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_bio:habitat_regulator",
    recipe = {"sbz_power:switching_station", "sbz_bio:moss"}
})

minetest.register_abm({
    interval = 10,
    chance = 20,
    nodenames = {"group:plant"},
    action = function (pos, node)
        local touched = touched_nodes[hash(pos)]
        local time = os.time()
        if not touched or time-touched >= 60 then
            local wilt = minetest.registered_nodes[node.name].wilt or function(...) end
            wilt(pos, node)
            touched_nodes[hash(pos)] = time
        end
    end
})