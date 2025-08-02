local matter_blob = "sbz_resources:matter_blob"

core.register_craft({
    type = "shaped",
    output = "chunkloader:loader",
    recipe = {
        { matter_blob, "",          matter_blob },
        { "",          matter_blob, "" },
        { matter_blob, "",          matter_blob }
    }
})
