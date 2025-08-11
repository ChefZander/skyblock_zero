-- local matter_blob = "sbz_resources:matter_blob"
local warp_crystal = "sbz_resources:warp_crystal"
local titanium_block = "sbz_chem:titanium_block"
local retaining_circuit = "sbz_resources:retaining_circuit"

core.register_craft({
    type = "shaped",
    output = "mapblockloader:loader",
    recipe = {
        { warp_crystal, 	 retaining_circuit, warp_crystal         },
        { retaining_circuit, titanium_block,       retaining_circuit },
        { warp_crystal, 	 retaining_circuit, warp_crystal         },
    }
})
