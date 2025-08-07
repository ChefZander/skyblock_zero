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

function chunkloader.config_exists()
    local f = io.open(chunkloader.config_path, "rb")
    if f then f:close() end
    return f ~= nil
end

function chunkloader.create_config()
    file = io.open(chunkloader.config_path, "w")
    local default_config = {
        chunkloaders_per_player = 10
    }
    file:write(core.serialize(default_config))
    file:close()
end

function chunkloader.read_config()
    return core.deserialize(io.open(chunkloader.config_path, "r"):read())
end

chunkloader.log("Version: " .. chunkloader.version)
