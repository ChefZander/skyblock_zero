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