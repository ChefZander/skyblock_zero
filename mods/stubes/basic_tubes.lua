stube.register_tube('stubes:test_tube', {
    description = 'Test Tube',
    drawtype = 'nodebox',
    sunlight_propagates = true,
    use_texture_alpha = 'blend',
    groups = { matter = 1 },
    after_dig_node = stube.update_placement,
    on_punch = stube.default_tube_punch,
}, {
    textures = stube.make_tube_textures_from 'stube_basic_tube.png',
    speed = 1, -- speed*capacity stacks/s
    capacity = 3,
    should_update = stube.default_should_update_tube,
    get_next_pos_and_node = function(tube_hpos, tube_state, tube_dir)
        local cdir = core.wallmounted_to_dir(tube_dir)
        local pos = core.get_position_from_hash(tube_hpos) + cdir
        return pos, stube.get_or_load_node(pos)
    end,
})
