core.register_node("jumpdrive:station", {
    description = "Jumpdrive Station",
    tiles = {
        "jumpdrive_station.png",
    },
    groups = { matter = 1 },
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
