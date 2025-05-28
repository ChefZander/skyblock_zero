libox = {
    safe = {},
    supply_additional_environment = function(...) return ... end, -- for other mods to do their stuff
    default_hook_time = 20,
    default_time_limit = 3000, -- 3ms
    disabled = false,
    in_sandbox = false,
}

local MP = minetest.get_modpath("libox")
dofile(MP .. "/env.lua")
dofile(MP .. "/utils.lua")
dofile(MP .. "/normal.lua")
libox.pat = loadfile(MP .. "/pat.lua")()
