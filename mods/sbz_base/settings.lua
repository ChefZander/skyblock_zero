-- SETTINGS!!
-- For now: background music and themes
-- Layout:
--[[
+--------+-------------------+
|        | container[<that plus, it will hold the settings sub-menu>]
| Themes | Also, BGM setting will be a "window"
| BGM    | Will need an ui "window lib" for this
|        | Also a box too, yeah
|        |                   | 
|        |                   |
+--------+-------------------+
--]]

local settings_prepend = [[
formspec_version[10]
size[26,20]
]]

local buttons = {}
local buttons_by_name = {}

core.register_on_mods_loaded(function()
    table.insert(buttons, {
        display_name = 'Themes',
        name = 'themes',
        get_formspec = sbz_api.get_theme_settings_ui,
    })

    table.insert(buttons, {
        display_name = 'BGM volume',
        name = 'bgm',
        get_formspec = function(player, _)
            local fs = {}
            local w, h = 8, 4
            table.insert(fs, sbz_api.ui.window((26 - w) / 2, (20 - w) / 2, w, h))
            table.insert(
                fs,
                sbz_api.ui.hypertext(0, 0.2, w - 1.4, 1, '', '<mono><center>Adjust BGM Volume</center></mono>')
            )

            local pmeta = player:get_meta()
            local volume = pmeta:get_int 'bgm_volume'
            table.insert(fs, 'scrollbaroptions[min=0;max=200]')
            table.insert(fs, sbz_api.ui.scrollbar(0.2, 1.5, w - 0.4, 0.5, 'horizontal', 'bgm_slider', volume))
            table.insert(fs, ('label[0.2,2.5;%s]'):format('Volume: ' .. volume .. '%'))

            table.insert(fs, sbz_api.ui.window_end())
            return table.concat(fs)
        end,
        no_container = true,
    })

    for _, v in pairs(buttons) do
        buttons_by_name[v.name] = v
    end
end)

local formname = 'sbz_base:player_settings'

local function display_settings_formspec(fields, player, prepend)
    sbz_api.ui.set_player(player)
    local pal = sbz_api.ui.get_theme().palette or {}

    local data = sbz_api.ui.get_playerdata(formname) or { selected = 'themes' }

    local formspec = { settings_prepend }
    if prepend then table.insert(formspec, 'no_prepend[]' .. prepend) end

    table.insert(formspec, 'box[0.4,0.4;5.6,19.2;]')
    table.insert(formspec, sbz_api.ui.big_hypertext(0.6, 0.6, 5.8, 2, '_', 'Player Settings'))

    local selected_button_data = buttons_by_name[data.selected]

    table.insert(formspec, ('style[%s;bgcolor=%s]'):format(selected_button_data.name, pal.neutral_green or '#AC4FC6'))

    local y = 2.5
    for _, button_data in pairs(buttons) do
        table.insert(formspec, ('button[0.6,%s;5.2,1;%s;%s]]'):format(y, button_data.name, button_data.display_name))
        y = y + 1.5
    end

    if not selected_button_data.no_container then table.insert(formspec, 'container[6,0]') end
    table.insert(formspec, selected_button_data.get_formspec(player, fields))
    if not selected_button_data.no_container then table.insert(formspec, 'container_end[]') end

    core.show_formspec(player:get_player_name(), formname .. '_' .. data.selected, table.concat(formspec))
    sbz_api.ui.set_playerdata(formname, data)
    sbz_api.ui.del_player()
end

sbz_api.show_settings_formspec = display_settings_formspec -- Any setting sub-menu is in charge of calling this

core.register_on_player_receive_fields(function(player, supplied_formname, fields)
    if string.sub(supplied_formname, 1, #formname) == formname then
        local selected_button = nil

        local quit_window = false

        for name, _ in pairs(fields) do
            if name == 'try_quit' then quit_window = true end
            for button_name, _ in pairs(buttons_by_name) do
                if name == button_name then selected_button = button_name end
            end
        end

        if quit_window then selected_button = buttons[1].name end

        if selected_button ~= nil then
            sbz_api.ui.set_player(player)
            local pdata = sbz_api.ui.get_playerdata(formname)
            pdata.selected = selected_button
            sbz_api.ui.del_player()
            sbz_api.show_settings_formspec(fields, player)
            return true
        end
    end
end)

-- BGM VOLUME SETTING (Since its so basic its included here for convenience)

core.register_on_player_receive_fields(function(player, supplied_formname, fields)
    if supplied_formname == formname .. '_bgm' then
        local scrollbar = core.explode_scrollbar_event(fields.bgm_slider)
        if scrollbar.type == 'CHG' then
            local pmeta = player:get_meta()
            local new_value = math.min(200, math.max(0, scrollbar.value))
            pmeta:set_int('bgm_volume', new_value)
            local handle = sbz_api.bgm_handles[player:get_player_name()]
            if handle then core.sound_fade(handle, 4, new_value / 100) end
            sbz_api.show_settings_formspec(fields, player)
        end
    end
end)
