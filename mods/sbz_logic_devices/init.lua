local MP = minetest.get_modpath("sbz_logic_devices")
dofile(MP .. "/builder.lua")
dofile(MP .. "/object_detector.lua")
dofile(MP .. "/formspec_screen.lua")
dofile(MP .. "/mscreen.lua")
dofile(MP .. "/signs_compat.lua")
dofile(MP .. "/noteblock.lua")
dofile(MP .. "/button.lua")
dofile(MP .. "/explosive.lua")

local HTTPApiTable = minetest.request_http_api()
if HTTPApiTable ~= nil then
    loadfile(MP .. "/nic.lua")(HTTPApiTable)
end

dofile(MP .. "/gpu.lua")
dofile(MP .. "/nodeDB.lua")
dofile(MP .. "/hologram_projector.lua")
dofile(MP .. "/meteorite_attractor.lua")
