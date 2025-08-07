core.register_node("chunkloader:loader_inf", {
    short_description = "Chunk Loader (INF)",
    description =
    "Chunk Loader (INF)\nKeeps the mapblock it's located in active\nDoes not consume power.\nInfinite.\nOnly for admins.\nAnd mods maybe\nMods like moderators, not ones that are written in Lua.",
    tiles = {
        { name = chunkloader.img("top_on_animated"), animation = { type = "vertical_frames", length = 2 } },
        chunkloader.img("sides_bottom"),
        chunkloader.img("sides_bottom"),
        chunkloader.img("sides_bottom"),
        chunkloader.img("sides_bottom"),
        chunkloader.img("sides_bottom")
    },
    is_ground_content = false,
    groups = { unbreakable = 1 },
    drop = "chunkloader:loader_inf",
    on_construct = function(pos, _)
        local meta = core.get_meta(pos)
        core.forceload_block(pos)
        meta:set_string("infotext", "Working")
    end,
    on_destruct = function(pos, _)
        core.forceload_free_block(pos)
    end
})
