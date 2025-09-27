sbz_api.register_machine('sbz_power:infinite_storinator', {
    description = 'Infinite Storinator (deprecated)',
    paramtype2 = 'facedir',
    groups = { matter = 1, not_in_creative_inventory = 1 },
    drop = '',
    action = function(pos, node, meta, supply, demand)
        return 0
    end,
    disallow_pipeworks = true,
})
