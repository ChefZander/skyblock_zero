sbz_api.multiblocks = {}
local multiblocks = sbz_api.multiblocks


function multiblocks.register_multiblock(def)

end

-- validate and link
function multiblocks.form_multiblock(pos, name, schem)

end

function multiblocks.break_multiblock(schem)

end

local mp = core.get_modpath(core.get_current_modname())
dofile(mp .. "/visuals.lua")

dofile(mp .. "/blast_furnace.lua")
