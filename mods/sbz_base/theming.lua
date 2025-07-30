-- This code is responsible for the player's formspec prepend
-- And also for theming you know
-- And also some helpers that the ui library can use

sbz_api.themes = {
    ['builtin'] = { -- the very minimal theme
        name = 'builtin',
        description = 'Very minimal for sure... not recomended to use',
    },
}

local themes = sbz_api.themes
local theme_order = { 'builtin' }
sbz_api.theme_order = theme_order

local default_theme = 'builtin'
sbz_api.default_theme = 'builtin'

function sbz_api.register_theme(name, def)
    themes[name] = def
    if def.default then
        default_theme = name
        sbz_api.default_theme = name
    end
    if not def.unordered then theme_order[#theme_order + 1] = name end
end

sbz_api.default_colors = {}

-- Prepend Utils (e.g. the no_bg style)
sbz_api.prepend_utils = {}
function sbz_api.append_prepend_util(text)
    sbz_api.prepend_utils[#sbz_api.prepend_utils + 1] = text
end

local no_bg_util = 'bgimg=blank.png'
local no_bg_util_result = ''
for _, state in ipairs { '', ':hovered', ':focused', ':pressed' } do
    no_bg_util_result = no_bg_util_result .. ('style[%s%s;%s]'):format('no_bg', state, no_bg_util)
end
sbz_api.append_prepend_util(no_bg_util_result)

local prepend_utils = ''
core.register_on_mods_loaded(function()
    prepend_utils = table.concat(sbz_api.prepend_utils)
end)

-- now... themes are mostly unchanging formspecs but i want to add some theme customization... so lets not treat them like that lol

local process_text = function(text, variables)
    return text:gsub('@@(%w+)', function(key)
        return variables[key] or key
    end)
end

sbz_api.get_theme = function(player)
    local meta = player:get_meta()
    local theme = sbz_api.themes[meta:get_string 'theme_name']
    if not theme then theme = sbz_api.themes[default_theme] end
    return theme
end

sbz_api.get_theme_name = function(player)
    local meta = player:get_meta()
    local theme = meta:get_string 'theme_name'
    if not sbz_api.themes[theme] then theme = default_theme end
    return theme
end

-- includes theme vars which are immutable config
-- TODO: CACHE THIS
sbz_api.get_theme_config = function(player, raw_config)
    local meta = player:get_meta()
    local theme = meta:get_string 'theme_name'
    if not sbz_api.themes[theme] then theme = default_theme end
    local theme_config = core.deserialize(meta:get_string('theme_config_' .. theme)) or {}
    -- now fill it in with default values
    local theme_def = sbz_api.themes[theme]
    if not theme_def.config then return {} end
    for name, value in pairs(theme_def.config) do
        local default = value.default
        if theme_config[name] == nil then theme_config[name] = default end
    end
    if theme_def.vars and not raw_config then
        for key, value in pairs(theme_def.vars) do
            theme_config[key] = value
        end
    end

    if theme_def.colors and not raw_config then
        theme_config.colors = theme_def.colors -- Have fun and DON'T MODIFY
    end

    if not raw_config then
        local info = core.get_player_information(player:get_player_name())
        if info then theme_config.protocol_version = info.protocol_version or 0 end
        for name, value in pairs(theme_def.config) do
            if value.type[1] == 'bool' and value.value_true then -- basically switches 2 strings
                if theme_config[name] then
                    theme_config[name] = value.value_true
                else
                    theme_config[name] = value.value_false
                end
            end
        end
    end
    return theme_config
end

sbz_api.get_theme_colors = function(player)
    local theme = sbz_api.get_theme(player)
    return theme.colors or {}
end

local labellike = {
    'label',
    'vertlabel',
    'checkbox',
    'textlist',
    'table',
}

local buttonlike = {
    'button',
    'image_button',
    'item_image_button',
    'button_exit',
    -- "field",
    -- "pwdfield",
    -- "textarea",
}

local function exec_conf_function_or_string(thing, config)
    if type(thing) == 'function' then
        return thing(config)
    else
        return process_text(thing, config)
    end
end

local buttonlike_types = table.concat(buttonlike, ',')
local labellike_types = table.concat(labellike, ',')

sbz_api.prepend_from_theme = function(theme, config)
    local prepend = { prepend_utils }

    local force_font = config.FONT ~= '' and config.FONT ~= nil

    local variables = table.copy(config or {})

    if theme.button_theme then
        local shared = process_text(theme.button_theme.shared, variables)
        local states = theme.button_theme.states
        local ibutton_states = theme.button_theme.ibutton_states or theme.button_theme.states
        for _, button_type in ipairs { 'button', 'button_exit' } do
            for state, button_theme in pairs(states) do
                button_theme = shared .. process_text(button_theme, variables)
                prepend[#prepend + 1] = ('style_type[%s%s;%s]'):format(button_type, state, button_theme)
            end
        end
        for _, button_type in ipairs { 'image_button', 'item_image_button' } do
            for state, button_theme in pairs(ibutton_states) do
                button_theme = shared .. process_text(button_theme, variables)
                prepend[#prepend + 1] = ('style_type[%s%s;%s]'):format(button_type, state, button_theme)
            end
        end
    end

    if force_font then
        local force_font_types = table.concat({
            'label',
            'vertlabel',
            'button',
            'button_exit',
            'image_button',
            'item_image_button',
            'field',
            'pwdfield',
            'textarea',
            'tabheader',
            'textlist',
        }, ',')

        if config.protocol_version > 48 then -- when this was written, a protocol version of 49 did not exist
            force_font_types = force_font_types .. ',table'
        end

        prepend[#prepend + 1] = 'style_type[' .. force_font_types .. config.FONT .. ']'
    end

    if theme.background then
        prepend[#prepend + 1] = ('background9[0,0;0,0;%s;true;%s]'):format(
            process_text(theme.background.name, variables),
            theme.background.middle
        )
    end
    if theme.listcolors then
        prepend[#prepend + 1] = ('listcolors[%s]'):format(exec_conf_function_or_string(theme.listcolors, config))
    end
    if theme.custom_formspec then prepend[#prepend + 1] = theme.custom_formspec end
    if theme.background_color then
        prepend[#prepend + 1] = ('bgcolor[%s;true]'):format(
            exec_conf_function_or_string(theme.background_color, config)
        )
    end

    if theme.colors then
        local col = theme.colors
        if col.text then
            prepend[#prepend + 1] = ('style_type[*;textcolor=%s]'):format(
                exec_conf_function_or_string(col.text, config)
            )
        end

        if col.label then
            prepend[#prepend + 1] = ('style_type[%s;textcolor=%s]'):format(
                labellike_types,
                exec_conf_function_or_string(col.label, config)
            )
        end

        if col.button_text then
            prepend[#prepend + 1] = ('style_type[%s;textcolor=%s]'):format(
                buttonlike_types,
                exec_conf_function_or_string(col.button_text, config)
            )
        end

        if col.box then
            prepend[#prepend + 1] = ('style_type[box;colors=%s]'):format(exec_conf_function_or_string(col.box, config))
            if col.box_border then
                prepend[#prepend + 1] = ('style_type[box;bordercolors=%s;borderwidths=%s]'):format(
                    exec_conf_function_or_string(col.box_border.color, config),
                    col.box_border.width
                )
            end
        end

        if col.box then
            prepend[#prepend + 1] = ('tableoptions[border=false;color=%s;background=%s]'):format(
                exec_conf_function_or_string(col.field_text or col.button_text or col.text or col.label or '', config),
                exec_conf_function_or_string(col.box, config)
            )

            if col.highlight_fg then
                prepend[#prepend + 1] = ('tableoptions[highlight_text=%s]'):format(
                    exec_conf_function_or_string(col.highlight_fg, config)
                )
            end

            if col.highlight_bg then
                prepend[#prepend + 1] = ('tableoptions[highlight=%s]'):format(
                    exec_conf_function_or_string(col.highlight_bg, config)
                )
            end
        end
    end
    return table.concat(prepend)
end

sbz_api.update_theme = function(player)
    local meta = player:get_meta()
    local theme = sbz_api.themes[meta:get_string 'theme_name']
    if not theme then theme = sbz_api.themes[default_theme] end

    local config = sbz_api.get_theme_config(player)
    local prepend = sbz_api.prepend_from_theme(theme, config)
    player:set_formspec_prepend(prepend)
    return prepend
end

-- implement more as needed
sbz_api.validate_theme_config_input = function(value_def, value)
    local value_type = value_def.type[1]

    if value_type == 'int' then
        local value_min, value_max = value_def.type[2], value_def.type[3]
        value = tonumber(value)
        if not value then return false, 'Value needs to be a number' end
        if value ~= math.floor(value) then
            return false, "Value is an integer, meaning that it can't have a decimal part"
        end
        if value > value_max then return false, 'Value too large, max value: ' .. value_max end
        if value < value_min then return false, 'Value too small, min value: ' .. value_min end
        return value
    elseif value_type == 'bool' then
        local bool
        if value == 'true' or value == '1' or value == 'y' or value == 'yes' or value == true then
            bool = true
        elseif value == 'false' or value == '0' or value == '-1' or value == 'n' or value == 'no' or value == false then
            bool = false
        end
        if bool == nil then return false, 'That was not a boolean, try something like yes/no or y/n' end
        return bool
    end
end

core.register_on_joinplayer(sbz_api.update_theme)

dofile(core.get_modpath 'sbz_base' .. '/theming_gui.lua')
-- Code helpers
sbz_api.get_theme_background = function(player)
    local theme = sbz_api.get_theme(player)
    if not theme.background then theme = sbz_api.themes[default_theme] end
    return process_text(theme.background.name, sbz_api.get_theme_config(player))
end

sbz_api.get_hypertext_prepend = function(player, theme, config)
    if not theme.hypertext_prepend then return '' end
    return exec_conf_function_or_string(theme.hypertext_prepend, config)
end

sbz_api.get_font_style = function(player, theme, config)
    return config.FONT or ''
end
