-- local matter_blob = "sbz_resources:matter_blob"
local warp_crystal = "sbz_resources:warp_crystal"
local phlogiston_crystal = "sbz_chem:phlogiston_crystal"
local phlogiston_circuit = "sbz_resources:phlogiston_circuit"

core.register_craft({
    type = "shaped",
    output = "mapblockloader:loader",
    recipe = {
        { warp_crystal,       phlogiston_circuit, warp_crystal },
        { phlogiston_circuit, phlogiston_crystal, phlogiston_circuit },
        { warp_crystal,       phlogiston_circuit, warp_crystal },
    }
})
