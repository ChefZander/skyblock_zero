local S = core.get_translator('sbz_progression')

local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1 then -- 1s
        timer = 0
        for _, player in ipairs(core.get_connected_players()) do
            local inv = player:get_inventory()
            if inv then
                if not inv:contains_item('main', 'sbz_progression:questbook') then
                    if player:get_meta():get_int 'questbook_warning' == 0 then
                        sbz_api.displayDialogLine(
                            player:get_player_name(),
                            S('Lost your questbook? Use /qb to get it back.')
                        )
                        player:get_meta():set_int('questbook_warning', 1)
                    end
                end
            end
        end
    end
end)

core.register_chatcommand('qb', {
    description = S("Gives you a questbook if you don't have one."),
    privs = {},
    func = function(name, param)
        local inv = core.get_player_by_name(name):get_inventory()
        if not inv then return end

        if inv:contains_item('main', 'sbz_progression:questbook') then
            sbz_api.displayDialogLine(name, S('You already have a Quest Book.'))
        else
            if inv:room_for_item('main', 'sbz_progression:questbook') then
                inv:add_item('main', 'sbz_progression:questbook')
                sbz_api.displayDialogLine(name, S('You have been given a Quest Book.'))
            else
                sbz_api.displayDialogLine(name, S('Your inventory is full.'))
            end
        end
    end,
})
