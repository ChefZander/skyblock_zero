-- Dont touch this stuff

minetest.register_chatcommand("dev_givequest", {
    description = "Gives achievements - for debugging only",
    params = '<name> | "all"',

    privs = { ["server"] = true },
    func = function(name, param)
        if param == "all" then
            for _, q in ipairs(quests) do
                unlock_achievement(name, q.title)
            end
            minetest.chat_send_player(name, "Gave you all achievements")
        else
            unlock_achievement(name, param)
            minetest.chat_send_player(name, "Gave you the achievement with the name \"" .. param .. "\"")
        end
    end
})

minetest.register_chatcommand("dev_revokequest", {
    description = "Revoke an achievement - for debugging only",
    params = '<name> | "all"',

    privs = { ["server"] = true },
    func = function(name, param)
        if param == "all" then
            for _, q in ipairs(quests) do
                revoke_achievement(name, q.title)
            end
            minetest.chat_send_player(name, "Revoked all achievements")
        else
            revoke_achievement(name, param)
            minetest.chat_send_player(name, "Revoked the achievement with the name \"" .. param .. "\"")
        end
    end
})

minetest.register_chatcommand("dev_hotbar", {
    description = "Set hotbar slot count - for debugging only",
    params = '<count>',
    privs = { ["server"] = true },

    func = function(name, param)
        local count = tonumber(param) or 32

        local player = minetest.get_player_by_name(name)
        if player then
            player:hud_set_hotbar_itemcount(count)
            return true, "Hotbar slot count set to " .. count
        else
            return false, "Player not found."
        end
    end
})

minetest.register_chatcommand("dev_platform", {
    description = "Spawn a 10x10 platform below the player - for debugging only",
    privs = { ["server"] = true },

    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if player then
            local pos = player:get_pos()
            local platform_start_pos = vector.subtract(pos, {x = 5, y = 1, z = 5})
            for x = 0, 9 do
                for z = 0, 9 do
                    if (x == 0 and z == 0) or (x == 0 and z == 9) or (x == 9 and z == 0) or (x == 9 and z == 9) then
                        local platform_pos = vector.add(platform_start_pos, {x = x, y = 0, z = z})
                        minetest.set_node(platform_pos, {name = "sbz_decor:photonlamp"})
                    else
                        local platform_pos = vector.add(platform_start_pos, {x = x, y = 0, z = z})
                        minetest.set_node(platform_pos, {name = "sbz_resources:matter_blob"})
                    end
                end
            end
            return true, "platform spawned."
        else
            return false, "Player not found."
        end
    end
})

minetest.register_chatcommand("dev_trail", {
    description = "Set hotbar slot count - for debugging only",
    params = '',
    privs = { ["server"] = true },

    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local state = ((player:get_meta():get_int("trailHidden") == 1) and 0 or 1)
        player:get_meta():set_int("trailHidden", state)
        return true, "Trail state is "..state
    end
})