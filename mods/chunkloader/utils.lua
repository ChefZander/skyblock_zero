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

chunkloader.log("Version: " .. chunkloader.version)
