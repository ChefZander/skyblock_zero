-- GOALS
-- /theme_gui command
-- a button in unified inv

--[[
    GUI layout:
    -- left side: all the themes
    -- Right side: the configuration
]]


local formspec_left_side = [[
formspec_version[10]
size[20,20]
style_type[label;font_size=20]

box[0.5,0.5;5,19;#000]
label[0.8,1;Themes]

box[6,0.5;13.5,19;#000]
label[6.2,1;Theme configuration]

]] -- constant, includes also the constant part of right side

core.register_on_mods_loaded(function()
    local y = 2.5
    local y_inc = 1.5 -- increases y
    for order, name in pairs(sbz_api.theme_order) do
        local theme_def = sbz_api.themes[name]
        formspec_left_side = formspec_left_side ..
            ("button[0.95,%s;4,1;theme_%s;%s]"):format(y, name, theme_def.name or name)
        y = y + y_inc
    end
end)


local function show_gui(player, prepend)
    local selected_theme = sbz_api.get_theme(player)
    local player_defaults = sbz_api.get_theme_config(player, true)

    local fs = { formspec_left_side }

    if prepend then
        table.insert(fs, "no_prepend[]" .. prepend)
    end

    local config = selected_theme.config
    if not config then
        fs[#fs + 1] = [[
style_type[label;font_size=]
label[6.2,2;This theme cannot be configured]
]]
    else
        -- make right side
        local ordered_settings = {}
        for k, v in pairs(config) do
            ordered_settings[#ordered_settings + 1] = k
        end
        table.sort(ordered_settings)
        local y = 2.5
        local y_inc = 1.5
        for order, name in ipairs(ordered_settings) do
            local config_entry = config[name]
            local fname = "config_" .. name
            local type = config_entry.type[1]
            if type == "bool" then
                fs[#fs + 1] = ("checkbox[6.2,%s;%s;%s;%s]"):format(y, fname, config_entry.description,
                    player_defaults[name])
            elseif type == "int" then
                fs[#fs + 1] = ("field_close_on_enter[%s;false]field_enter_after_edit[%s;true]"):format(fname, fname)
                fs[#fs + 1] = ("field[6.2,%s;8,1;%s;%s;%s]"):format(y - (y_inc / 4), fname,
                    config_entry.description, player_defaults[name])
            end
            y = y + y_inc
        end
        fs[#fs + 1] = "button[6.2,18.2;5,1;defaults;Reset to defaults]"
        fs[#fs + 1] = ("hypertext[11.8,17.5;7.5,1.8;;<global valign=bottom halign=right>%s]"):format(core
            .formspec_escape(selected_theme
                .description))
    end
    core.show_formspec(player:get_player_name(), "sbz_base:theming_gui", table.concat(fs))
end
sbz_api.theme_editor_formspec = show_gui

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "sbz_base:theming_gui" then return end
    if fields.quit then return end
    local change_theme_to
    for name, _ in pairs(fields) do
        if name:sub(1, #"theme_") == "theme_" then
            change_theme_to = name:sub(#"theme_" + 1)
        end
    end

    if change_theme_to and sbz_api.themes[change_theme_to] then
        player:get_meta():set_string("theme_name", change_theme_to)
    elseif fields.defaults then -- wants to remove config
        local pmeta = player:get_meta()
        local theme_name = pmeta:get_string("theme_name")
        if not sbz_api.themes[theme_name] then theme_name = sbz_api.default_theme end
        pmeta:set_string("theme_config_" .. theme_name, "")
    else -- changed config surely
        local changed_key
        local changed_value
        local config = sbz_api.get_theme_config(player, true)
        for name, value in pairs(fields) do
            if name:sub(1, #"config_") == "config_" then
                local key = name:sub(#"config_" + 1)
                if value == "true" then
                    value = true
                elseif value == "false" then
                    value = false
                end
                if config[key] ~= value then
                    changed_key = key
                    changed_value = value
                    break
                end
            end
        end
        if changed_key then
            local theme = sbz_api.get_theme(player)
            for config_name, value_definition in pairs(theme.config) do
                if config_name == changed_key then
                    local value, errmsg = sbz_api.validate_theme_config_input(value_definition, changed_value)
                    if errmsg then
                        core.chat_send_player(player:get_player_name(), "Error while configuring: " .. errmsg)
                    else
                        config[changed_key] = value
                        player:get_meta():set_string("theme_config_" .. sbz_api.get_theme_name(player),
                            core.serialize(config))
                    end
                end
            end
        end
    end
    local prepend = sbz_api.update_theme(player)
    show_gui(player, prepend) -- this is due to prepends being buggy ok just trust the code or you will go insane trying to figure out that one bug
end)

core.register_chatcommand("theme_gui", {
    description = "Edit the theme with teh gui",
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then return false, "you must be online" end -- mtui users maybe?
        show_gui(player)
    end
})
