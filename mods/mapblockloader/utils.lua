function mapblockloader.img(name)
    return "mapblockloader_" .. name .. ".png"
end

function mapblockloader.log(msg)
    if type(msg) == "table" then
        msg = core.serialize(msg)
    elseif type(msg) ~= "string" then
        msg = tostring(msg)
    end
    core.log("action", "[mapblockloader] " .. msg)
end

function mapblockloader.player_online(username)
    for _, player in pairs(core.get_connected_players()) do
        local player_name = player:get_player_name()
        if player_name == username then
            return true
        end
    end
    return false
end

function mapblockloader.config_exists()
    local f = io.open(mapblockloader.config_path, "rb")
    if f then f:close() end
    return f ~= nil
end

function mapblockloader.create_config()
    file = io.open(mapblockloader.config_path, "w")
    local default_config = {
        mapblockloaders_per_player = 10
    }
    file:write(core.serialize(default_config))
    file:close()
end

function mapblockloader.read_config()
    return core.deserialize(io.open(mapblockloader.config_path, "r"):read())
end

mapblockloader.log("Version: " .. mapblockloader.version)
