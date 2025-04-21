local inaction_treshold = 5 * 60
sbz_api.afk_players = setmetatable({}, {
    __index = function(t, k)
        if rawget(t, k) ~= nil then
            return rawget(t, k)
        else
            rawset(t, k, {})
            return rawget(t, k)
        end
    end,
})

local afkp = sbz_api.afk_players
sbz_api.is_afk = function(name)
    if not core.get_player_by_name(name) then return false end
    if not afkp[name].action then return false end
    return os.difftime(os.time(), afkp[name].action) >= inaction_treshold
end

local function afk_globalstep(dtime)
    for _, obj in pairs(core.get_connected_players()) do
        local name = obj:get_player_name()
        local vlook = obj:get_look_vertical()
        local hlook = obj:get_look_horizontal()
        if afkp[name].vlook ~= vlook then
            afkp[name].vlook = vlook
            afkp[name].hlook = hlook
            afkp[name].action = os.time()
        end
        local control = obj:get_player_control_bits()
        if afkp[name].control ~= control then
            afkp[name].control = control
            afkp[name].action = os.time()
        end
        if sbz_api.is_afk(name) then
            obj:set_nametag_attributes({
                bgcolor = "yellow#55"
            })
        else
            obj:set_nametag_attributes({
                bgcolor = "white#00"
            })
        end
    end
end

core.register_globalstep(afk_globalstep)

core.register_on_chat_message(function(name, message)
    afkp[name].action = os.time()
end)
core.register_on_leaveplayer(function(ObjectRef, timed_out)
    afkp[ObjectRef:get_player_name()] = nil
end)


local modstorage = core.get_mod_storage()
local timer = 0

local playtime_globalstep = function(dtime)
    timer = timer + dtime
    if timer >= 1 then
        timer = timer - 1 -- precise hehe
        for _, obj in pairs(core.get_connected_players()) do
            if not sbz_api.is_afk(obj:get_player_name()) then
                local playtime = modstorage:get_int(obj:get_player_name() .. "_playtime")
                playtime = playtime + 1
                modstorage:set_int(obj:get_player_name() .. "_playtime", playtime)
            else
                local afk_playtime = modstorage:get_int(obj:get_player_name() .. "_afk_playtime")
                afk_playtime = afk_playtime + 1
                modstorage:set_int(obj:get_player_name() .. "_afk_playtime", afk_playtime)
            end
        end
    end
end

core.register_globalstep(playtime_globalstep)

local function get_time(x)
    local hours = x / 60 / 60
    local minutes = (hours - math.floor(hours)) * 60
    local seconds = (minutes - math.floor(minutes)) * 60
    hours, minutes, seconds = math.floor(hours), math.floor(minutes), math.floor(seconds)
    return hours .. " hours, " .. minutes .. " minutes, " .. seconds .. " seconds"
end

core.register_chatcommand("playtime", {
    description = "Shows your, or other player's playtime.",
    params = "[player]",
    privs = {},
    func = function(name, param)
        local player = name
        if #param ~= 0 and param ~= " " then
            player = param
        end
        core.chat_send_player(name, ("%s's playtime: %s\n%s's afk time: %s\n%s's afk and playtime: %s"):format(
            player, get_time(modstorage:get_int(player .. "_playtime")),
            player, get_time(modstorage:get_int(player .. "_afk_playtime")),
            player, get_time(modstorage:get_int(player .. "_playtime") + modstorage:get_int(player .. "_afk_playtime"))
        ))
    end,
})

core.register_chatcommand("afk", {
    description = "Become afk",
    param = "",
    privs = {},
    func = function(name)
        afkp[name].action = 0
        return true, "You became afk"
    end
})
