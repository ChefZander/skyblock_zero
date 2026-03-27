local S, PS = core.get_translator(core.get_current_modname())

-- Don't touch this stuff

core.register_chatcommand("dev_givequest", {
    description = S("Gives achievements - for debugging only"),
    params = '<name> | "all"',

    privs = { ["server"] = true },
    func = function(name, param)
        if param == "all" then
            for _, q in ipairs(quests) do
                unlock_achievement(name, q.title)
            end
            core.chat_send_player(name, S("Gave you all achievements"))
        else
            unlock_achievement(name, param)
            core.chat_send_player(name, S("Gave you the achievement with the name ") .. '"' .. param .. '".')
        end
    end
})

core.register_chatcommand("dev_revokequest", {
    description = S("Revoke an achievement - for debugging only"),
    params = '<name> | "all"',

    privs = { ["server"] = true },
    func = function(name, param)
        if param == "all" then
            for _, q in ipairs(quests) do
                revoke_achievement(name, q.title)
            end
            core.chat_send_player(name, S("Revoked all achievements"))
        else
            revoke_achievement(name, param)
            core.chat_send_player(name, S("Revoked the achievement with the name ") .. '"' .. param .. '".')
        end
    end
})

core.register_chatcommand("dev_hotbar", {
    description = S("Set hotbar slot count - for debugging only"),
    params = '<count>',
    privs = { ["server"] = true },

    func = function(name, param)
        local count = tonumber(param) or 32

        local player = core.get_player_by_name(name)
        if player then
            player:hud_set_hotbar_itemcount(count)
            return true, S("Hotbar slot count set to ") .. count
        else
            return false, S("Player not found.")
        end
    end
})

core.register_chatcommand("dev_platform", {
    description = S("Spawn a 10x10 platform below the player - for debugging only"),
    privs = { ["server"] = true },

    func = function(name, param)
        local player = core.get_player_by_name(name)
        if player then
            local pos = player:get_pos()
            local platform_start_pos = vector.subtract(pos, { x = 5, y = 1, z = 5 })
            for x = 0, 9 do
                for z = 0, 9 do
                    if (x == 0 and z == 0) or (x == 0 and z == 9) or (x == 9 and z == 0) or (x == 9 and z == 9) then
                        local platform_pos = vector.add(platform_start_pos, { x = x, y = 0, z = z })
                        core.set_node(platform_pos, { name = "sbz_decor:photonlamp" })
                    else
                        local platform_pos = vector.add(platform_start_pos, { x = x, y = 0, z = z })
                        core.set_node(platform_pos, { name = "sbz_resources:matter_blob" })
                    end
                end
            end
            return true, S("Platform spawned.")
        else
            return false, S("Player not found.")
        end
    end
})

core.register_chatcommand("dev_close", {
    description = S("Get the 8 closest unique nodes within a distance of 32 and receive them as items - for debugging only"),
    privs = { ["server"] = true },
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return false, S("Player not found!")
        end

        local pos = vector.round(player:get_pos())
        local unique_nodes = {}
        local found_nodes = 0

        -- Define the maximum distance
        local max_distance = 32

        -- Search from the player position outward
        for distance = 0, max_distance do
            for x = -distance, distance do
                for y = -distance, distance do
                    for z = -distance, distance do
                        -- Skip points outside the current spherical shell
                        if math.abs(x) ~= distance and math.abs(y) ~= distance and math.abs(z) ~= distance then
                            goto continue
                        end

                        if found_nodes >= 8 then
                            break
                        end

                        local node_pos = vector.add(pos, { x = x, y = y, z = z })
                        local node = core.get_node(node_pos)
                        local node_name = node.name

                        if node_name ~= "air" and not unique_nodes[node_name] then
                            unique_nodes[node_name] = true
                            found_nodes = found_nodes + 1
                            local item_stack = ItemStack(node_name)
                            player:get_inventory():add_item("main", item_stack)
                        end

                        ::continue::
                    end
                    if found_nodes >= 8 then
                        break
                    end
                end
                if found_nodes >= 8 then
                    break
                end
            end
            if found_nodes >= 8 then
                break
            end
        end

        if found_nodes == 0 then
            return false, S("No unique nodes found within 32 blocks.")
        end

        return true, PS("Given @1 unique node.", "Given @2 unique nodes.", found_nodes, tostring(found_nodes))
    end
})

-- this is such a zander thing to do lmfao
core.register_chatcommand("dev_clear", {
    description = S("Clears the player's inventory - for debugging only"),
    privs = { ["server"] = true },
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return false, S("Player not found!")
        end

        local inventory = player:get_inventory()
        inventory:set_list("main", {})
        inventory:set_list("craft", {})

        return true, S("Inventory cleared.")
    end
})

core.register_chatcommand("dev_toggle_libox", {
    description = S("Enables/Disables all lua sandboxing"),
    privs = { ["server"] = true },
    func = function()
        libox.disabled = not libox.disabled
        return true, "Status: " .. dump(libox.disabled)
    end
})

sbz_api.forced_light = {}
core.register_chatcommand("dev_light", {
    description = S("Makes it day only for you"),
    privs = { ["server"] = true },
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return false, S("Player not found!")
        end
        sbz_api.forced_light[name] = true
        player:override_day_night_ratio(1)
    end
})

core.register_chatcommand("dev_craft", {
    description =
    S("Fake a craft, used for quest testing, param should be an item name or \"item\" to specify wielded item's name"),
    privs = { ["server"] = true },
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, S("Player not found!")
        end

        if param == "item" or param == "" then param = player:get_wielded_item():get_name() end

        for k, v in pairs(core.registered_on_crafts) do
            v(ItemStack(param), player)
        end
    end
})

core.register_chatcommand("dev_regen", {
    description = S("Re-generate a mapblock (one that you are standing on)"),
    params = "[radius]",
    privs = { ["server"] = true },
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, S("Player not found!")
        end

        local radius = tonumber(param) or 1

        core.delete_area(vector.subtract(player:get_pos(), vector.new(radius, radius, radius)),
            vector.add(player:get_pos(), vector.new(radius, radius, radius)))
        return true, S("Area re-generated!")
    end
})

core.register_chatcommand("dev_mapblocks", {
    description =
    S("Sends you all the mapblocks in the radius. RADIUS IS IN MAPBLOCKS!! may not work... in singleplayer at least"),
    params = "[radius]",
    privs = { ["server"] = true },
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, S("Player not found!")
        end

        local radius = tonumber(param) or 1
        local playerpos = vector.apply(player:get_pos() / 16, math.floor)
        for x = 1, radius do
            for y = 1, radius do
                for z = 1, radius do
                    player:send_mapblock(playerpos + vector.new(x, y, z))
                end
            end
        end

        return true, S("Area sent!")
    end
})
core.register_chatcommand("dev_fast_habitats", {
    description = S("Toggles making habitats fast, don't use this in a server"),
    params = "",
    privs = { ["server"] = true },
    func = function(name, param)
        sbz_api.accelerated_habitats = not sbz_api.accelerated_habitats
    end
})

core.register_chatcommand("dev_toggle_pvp", {
    description = S("Toggle pvp, NEEDS SERVER RESTART, bad idea to use if you aren't a dev"),
    params = "<enable>",
    privs = { ["server"] = true },
    func = function(name, param)
        core.settings:set("enable_pvp", core.is_yes(param) and "true" or "false")
    end
})

core.register_chatcommand("dev_test_rain", {
    description = S("Test rain particles <remove later>"),
    privs = { ["server"] = true },
    func = function(name, param)

    end
})
