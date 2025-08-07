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
        meta:set_int("prev_state", 0)
        meta:set_int("running", 0)
    end,
    on_place = function(itemstack, placer, pointed_thing)
        local config = chunkloader.read_config()
        local limit = config.chunkloaders_per_player

        local placed_chunkloaders = chunkloader.storage:get_int(placer:get_player_name())
        core.chat_send_player(placer:get_player_name(), tostring(placed_chunkloaders))
        if placed_chunkloaders >= limit then
            core.chat_send_player(placer:get_player_name(),
                "You can only place " .. tostring(limit) .. " chunkloader nodes per player")
            return itemstack
        end
        return core.item_place_node(itemstack, placer, pointed_thing, nil, false)
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing, param2)
        if placer and placer:is_player() then
            local meta = core.get_meta(pos)
            meta:set_string("owner", placer:get_player_name())
            chunkloader.storage:set_int(
                placer:get_player_name(),
                chunkloader.storage:get_int(placer:get_player_name()) + 1
            )
        end
    end,
    on_destruct = function(pos)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= nil then
            chunkloader.storage:set_int(
                owner,
                chunkloader.storage:get_int(owner) - 1
            )
        end
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
})
