-- Here should be anything related to parkour
-- Like even ladders
-- but they are in sbz_decor
-- so im not bringing them here

-- what should sbz_resources even be responsible for... should it have all the nodedefs/machine defs?
-- I think yes! but idk

core.register_node(
    'sbz_resources:emittrium_block',
    unifieddyes.def {
        description = 'Emittrium Block',
        info_extra = 'You should punch it, and place some close to eachother.',
        paramtype2 = 'color',
        groups = { matter = 1 },
        tiles = { 'emittrium_block.png' },

        -- imagine if someone punches it 30 times/the same globalstep
        -- now imagine me caring
        on_punch = function(pos, node, puncher, _)
            if not puncher:is_player() then return end
            local dir = puncher:get_pos() - pos

            -- okay, so the punching strength is multiplied by how many emittrium blocks are nearby
            -- could do some stupid search but i dont want to
            -- so instead..
            local strength = 2 + (sbz_api.count_nodes_within_radius(pos, 'sbz_resources:emittrium_block', 1) * 2)
            core.add_particlespawner {
                amount = strength * 8,
                time = 0.01,
                texture = { name = 'star.png^[colorize:cyan', alpha = 2, scale_tween = { 1.5, 0 }, blend = 'add' },
                exptime = 2,
                glow = 14,
                pos = pos,
                radius = 0.5,
                vel = vector.multiply(dir, strength / 2),
                attract = {
                    kind = 'point',
                    strength = -5,
                    origin = pos,
                },
            }
            puncher:add_velocity(vector.multiply(dir, strength))
        end,
    }
)

core.register_craft {
    type = 'shaped',
    output = 'sbz_resources:emittrium_block',
    recipe = {
        { 'sbz_resources:raw_emittrium', 'sbz_resources:raw_emittrium', 'sbz_resources:raw_emittrium' },
        { 'sbz_resources:raw_emittrium', 'sbz_resources:raw_emittrium', 'sbz_resources:raw_emittrium' },
        { 'sbz_resources:raw_emittrium', 'sbz_resources:raw_emittrium', 'sbz_resources:raw_emittrium' },
    },
}
