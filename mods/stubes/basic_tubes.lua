--- FIXME: Unified dyes support
stube.register_tube('stubes:basic_tube', {
    paramtype2 = 'color',
    description = 'Basic Item Tube',
    use_texture_alpha = 'blend',
    groups = { matter = 1 },
    after_dig_node = stube.update_placement,
    on_punch = stube.default_tube_punch,

    -- Needed or it will be buggy
    drawtype = 'nodebox',
    sunlight_propagates = true,
    paramtype = 'light',
}, {
    textures = stube.make_tube_textures_from 'stube_basic_tube.png',
    speed = 1, -- seconds/stack
    should_update = stube.default_should_update_tube,
    get_next_pos_and_node = stube.default_get_next_pos_and_node,
})

--- Game design: This tube should be a lot more expensive than the basic tube
--- Because it's basically 3 basic tubes in one node
stube.register_tube('stubes:fast_tube', {
    paramtype2 = 'color',
    description = 'Fast Item Tube',
    use_texture_alpha = 'blend',
    groups = { matter = 1 },
    after_dig_node = stube.update_placement,
    on_punch = stube.default_tube_punch,

    drawtype = 'nodebox',
    sunlight_propagates = true,
    paramtype = 'light',
}, {
    textures = stube.make_tube_textures_from 'stube_fast_tube.png',
    speed = 1 / 3, -- 3x faster!!
    should_update = stube.default_should_update_tube,
    get_next_pos_and_node = stube.default_get_next_pos_and_node,
})

--- Game design: Let the player have some fun, at a huge cost
--- Actually just kidding it's just 2x faster than pipeworks, and as fast as accelerator tubes
--- so not that fun
stube.register_tube('stubes:very_fast_tube', {
    description = core.colorize('cyan', 'Very ') .. 'Fast Item Tube',
    use_texture_alpha = 'blend',
    groups = { matter = 1 },
    after_dig_node = stube.update_placement,
    on_punch = stube.default_tube_punch,

    drawtype = 'nodebox',
    sunlight_propagates = true,
    paramtype = 'light',
}, {
    textures = stube.make_tube_textures_from 'stube_very_fast_tube.png',
    speed = 1 / 10,
    should_update = stube.default_should_update_tube,
    get_next_pos_and_node = stube.default_get_next_pos_and_node,
})

-- Excercise for the viewer: You can make your own TRULY FAST TUBE
-- Copy the definition for very_fast_tube, change the speed to zero, and change the name
