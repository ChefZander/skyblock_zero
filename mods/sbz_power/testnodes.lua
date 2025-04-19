local times = {}
local h = core.hash_node_position
sbz_api.register_machine("sbz_power:testmach", {
    description = "Test machine",
    action = function(pos, node, meta, supply, demand)
        local t = times[core.hash_node_position(pos)] or 0
        meta:set_string("infotext", "DTIME: " .. math.floor((minetest.get_us_time() - t) / 1000) .. "ms")
        times[h(pos)] = minetest.get_us_time()
        return 0
    end,
    groups = { matter = 1, not_in_creative_inventory = 1 }
})
