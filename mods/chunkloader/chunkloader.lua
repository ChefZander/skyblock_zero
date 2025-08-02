sbz_api.register_stateful_machine("chunkloader:loader", {
    short_description = "Chunk Loader",
    description = "Chunk Loader\nKeeps the mapblock it's located in active\nConsumes power.",
    tiles = {
        chunkloader.img("top_off"), -- Top
        chunkloader.img("sides_bottom"),
        chunkloader.img("sides_all"),
        chunkloader.img("sides_all"),
        chunkloader.img("sides_all"),
        chunkloader.img("sides_all")
    },
    autostate = true,
    is_ground_content = false,
    groups = { matter = 1 },
    drop = "chunkloader:loader",
    on_construct = function(pos, node)
        local meta = core.get_meta(pos)
        meta:set_int("perpetual", 0)
        meta:set_int("prev_state", 0)
        meta:set_int("running", 0)
    end,
    action = chunkloader.action
}, {
    tiles = {
        { name = chunkloader.img("top_on_animated"), animation = { type = "vertical_frames", length = 2 } },
        chunkloader.img("sides_bottom"),
        chunkloader.img("sides_all"),
        chunkloader.img("sides_all"),
        chunkloader.img("sides_all"),
        chunkloader.img("sides_all")
    }
}
)
