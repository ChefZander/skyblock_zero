local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1 then -- 1s
        timer = 0
        for _, player in ipairs(minetest.get_connected_players()) do
            local inv = player:get_inventory()
            if inv then
                if not inv:contains_item("main", "sbz_progression:questbook") then
                    if player:get_meta():get_int("questbookwarning") == 0 then
                        sbz_api.displayDialogLine(player:get_player_name(),
                            "Lost your questbook? Use /qb to get it back.")
                        player:get_meta():set_int("questbookwarning", 1)
                    end
                end
            end
        end
    end
end)

minetest.register_chatcommand("qb", {
    description = "Gives you a questbook if you don't have one.",
    privs = {},
    func = function(name, param)
        local inv = minetest.get_player_by_name(name):get_inventory()
        if inv then
            if inv:contains_item("main", "sbz_progression:questbook") then
                sbz_api.displayDialogLine(name, "You already have a Quest Book.")
            else
                if inv:room_for_item("main", "sbz_progression:questbook") then
                    inv:add_item("main", "sbz_progression:questbook")
                    sbz_api.displayDialogLine(name, "You have been given a Quest Book.")
                else
                    sbz_api.displayDialogLine(name, "Your inventory is full.")
                end
            end
        end
    end,
})
