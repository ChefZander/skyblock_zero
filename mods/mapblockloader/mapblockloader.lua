sbz_api.register_stateful_machine("mapblockloader:loader", {
    short_description = "Mapblock Loader",
    description = "Forces the mapblock that it is inside of to be loaded, only works when the owner of it is online",
    tiles = {
        mapblockloader.img("top_off"), -- Top
        mapblockloader.img("sides_bottom"),
        mapblockloader.img("sides_all"),
        mapblockloader.img("sides_all"),
        mapblockloader.img("sides_all"),
        mapblockloader.img("sides_all")
    },
    autostate = true,
    is_ground_content = false,
    groups = { matter = 1 },
    drop = "mapblockloader:loader",
    on_construct = function(pos, node)
        local meta = core.get_meta(pos)
        meta:set_int("prev_state", 0)
        meta:set_int("running", 0)
    end,
    on_place = function(itemstack, placer, pointed_thing)
        local config = mapblockloader.read_config()
        local limit = config.mapblockloaders_per_player

        local placed_mapblockloaders = mapblockloader.storage:get_int(placer:get_player_name())
        if placed_mapblockloaders >= limit then
            core.chat_send_player(placer:get_player_name(),
                "You can only place " .. tostring(limit) .. " mapblockloader nodes per player")
            return itemstack
        end
        return core.item_place_node(itemstack, placer, pointed_thing, nil, false)
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing, param2)
        if placer and placer:is_player() then
            local meta = core.get_meta(pos)
            meta:set_string("owner", placer:get_player_name())
            mapblockloader.storage:set_int(
                placer:get_player_name(),
                mapblockloader.storage:get_int(placer:get_player_name()) + 1
            )
        end
    end,
    on_destruct = function(pos)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= nil then
            mapblockloader.storage:set_int(
                owner,
                mapblockloader.storage:get_int(owner) - 1
            )
        end
    end,
    action = mapblockloader.action,
    on_punch = mapblockloader.on_punch
}, {
    tiles = {
        { name = mapblockloader.img("top_on_animated"), animation = { type = "vertical_frames", length = 2 } },
        mapblockloader.img("sides_bottom"),
        mapblockloader.img("sides_all"),
        mapblockloader.img("sides_all"),
        mapblockloader.img("sides_all"),
        mapblockloader.img("sides_all")
    }
})
