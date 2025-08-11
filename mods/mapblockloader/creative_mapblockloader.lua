core.register_node("mapblockloader:creative_loader", {
    short_description = "Creative Mapblock Loader",
    description =
    "Creative mapblock Loader\nKeeps the mapblock it's located active.\nDoes not consume power.\nInfinite.\nOnly for admins.\nAnd mods maybe\nMods like moderators, not ones that are written in Lua.",
    tiles = {
        { name = mapblockloader.img("top_on_animated"), animation = { type = "vertical_frames", length = 2 } },
        mapblockloader.img("sides_bottom"),
        mapblockloader.img("sides_bottom"),
        mapblockloader.img("sides_bottom"),
        mapblockloader.img("sides_bottom"),
        mapblockloader.img("sides_bottom")
    },
    is_ground_content = false,
    groups = { unbreakable = 1 },
    drop = "mapblockloader:creative_loader",
    on_construct = function(pos, _)
        local meta = core.get_meta(pos)
        core.forceload_block(pos)
        meta:set_string("infotext", "Working")
    end,
    on_destruct = function(pos, _)
        core.forceload_free_block(pos)
    end
})
