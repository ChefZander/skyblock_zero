core.register_node("jumpdrive:station", {
    description = "Jumpdrive Station",
    tiles = {
        "jumpdrive_station.png",
    },
    groups = { matter = 1 },
    sounds = {
        footstep = { name = 'gen_muffled_boop_hit', gain = 0.3, pitch = 0.5, fade = 0.0 },
        dig      = { name = 'gen_simple_tap_low', gain = 0.7, pitch = 1.0, fade = 0.0 },
        dug      = { name = 'mix_explode_puffy_metallic', gain = 1.0, pitch = 1.0, fade = 0.0 },
        place    = { name = 'gen_metallic_hit', gain = 1.0, pitch = 1.0, fade = 0.0 },
    },
})

do -- Station recipe scope
    local Jumpdrive_Station = 'jumpdrive:station'
    local amount = 2
    local JB = 'jumpdrive:backbone'
    local AB = 'sbz_chem:aluminum_block'
    local JE = 'jumpdrive:engine'
    core.register_craft({
        output = Jumpdrive_Station .. ' ' .. tostring(amount),
        recipe = {
            { JB, AB, JB },
            { AB, JE, AB },
            { JB, AB, JB },
        }
    })
end
