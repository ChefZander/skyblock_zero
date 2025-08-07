function chunkloader.img(name)
    return "chunkloader_" .. name .. ".png"
end

function chunkloader.log(msg)
    if type(msg) == "table" then
        msg = core.serialize(msg)
    elseif type(msg) ~= "string" then
        msg = tostring(msg)
    end
    core.log("action", "[chunkloader] " .. msg)
end

function chunkloader.player_online(username)
    for _, player in pairs(core.get_connected_players()) do
        local player_name = player:get_player_name()
        if player_name == username then
            return true
        end
    end
    return false
end

chunkloader.log("Version: " .. chunkloader.version)
