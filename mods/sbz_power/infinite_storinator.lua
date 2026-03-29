local S = core.get_translator(core.get_current_modname())

sbz_api.register_machine('sbz_power:infinite_storinator', {
    description = S("Infinite Storinator (deprecated)"),
    sounds = sbz_audio.wood_planks(),
    paramtype2 = 'facedir',
    groups = { matter = 1, not_in_creative_inventory = 1 },
    drop = '',
    action = function(pos, node, meta, supply, demand)
        return 0
    end,
    disallow_pipeworks = true,
})
