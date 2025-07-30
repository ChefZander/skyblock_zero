local shift_color_by_vars_hue = function(color)
    local rgb = core.colorspec_to_table(color)
    return function(vars)
        if not vars.HUE then vars.HUE = 0 end
        local new_rgb = sbz_api.color.rotate_hue(rgb, vars.HUE)
        return core.colorspec_to_colorstring(new_rgb)
    end
end

sbz_api.register_theme('space', {
    default = true,
    name = 'Space',
    description = '[Default Theme] The sbz experience',
    config = {
        ['HUE'] = {
            default = '0', -- -60 for forest
            type = { 'int', -180, 180 },
            description = 'Theme Hue (An integer, from -180 to 180)',
        },
        ['FONT'] = { -- becomes @@FONT
            default = true,
            value_true = ';font=mono',
            value_false = '',
            type = { 'bool' },
            description = 'Force mono font',
        },
        ['LIGHT_BUTTONS'] = {
            default = false,
            type = { 'bool' },
            description = 'Lighter button text color',
        },
    },
    button_theme = {
        shared = 'bgimg_middle=10;padding=-7,-7@@FONT',
        states = {
            [''] = ';bgimg=theme_space_button.png^[hsl:@@HUE',
            [':hovered'] = ';bgimg=theme_space_button_hovering.png^[hsl:@@HUE',
            [':focused'] = ';bgimg=theme_space_button_focusing.png^[hsl:@@HUE',
            [':pressed'] = ';bgimg=theme_space_button_pressing.png^[hsl:@@HUE',
        },
    },
    background = { name = 'theme_space_background.png^[hsl:@@HUE', middle = 16 },
    background_color = '#00000050',
    listcolors = function(config)
        local spec2table = core.colorspec_to_table
        -- tilde colors: "#11111169;#5A5A5A;#243024;#020402;lightgreen"

        local default_colors = {
            spec2table '#11111169',
            spec2table '#5A5A5A',
            spec2table '#242430',
            spec2table '#030d19',
            spec2table 'lightblue',
        }
        local converted_colors = {}
        for _, v in ipairs(default_colors) do
            converted_colors[#converted_colors + 1] = sbz_api.color.rotate_hue(v, config.HUE)
            converted_colors[#converted_colors].a = v.a
        end

        local result = ''
        for _, v in ipairs(converted_colors) do
            result = result .. core.colorspec_to_colorstring(v) .. ';'
        end
        result = result:sub(1, #result - 1) -- remove last ;
        return result
    end,
    colors = {
        background = shift_color_by_vars_hue '#12111a',
        text = shift_color_by_vars_hue 'lightblue',
        button_text = function(config)
            if config.LIGHT_BUTTONS then return config.colors.text(config) end
            return shift_color_by_vars_hue '#00b9bb'(config)
        end,
        field_text = shift_color_by_vars_hue '#000000',
        button_background = shift_color_by_vars_hue '#0a1b33',
        box = shift_color_by_vars_hue '#1C1D27', -- Box color = listlike color, if defined, fields automatically use box
        box_border = { width = -2, color = shift_color_by_vars_hue '#143464' }, -- If defined, no border on listlikes
        highlight_bg = shift_color_by_vars_hue '#143463',
        highlight_fg = shift_color_by_vars_hue 'lightblue',
        title = shift_color_by_vars_hue '#e8f4f8',
        mono = function(conf)
            return conf.colors.text(conf)
        end,
    },
    -- custom_formspec = '',
    hypertext_prepend = function(conf)
        return ('<global %s color=%s><tag name=big color=%s size=24><tag name=bigger color=%s size=36>'):format(
            conf.FONT and 'font=mono' or '',
            conf.colors.text(conf),
            conf.colors.title(conf),
            conf.colors.title(conf)
        )
    end,
})

-- The way i implemented this looks so bad oh i am sorry
sbz_api.register_theme('tilde', {
    default = false,
    unordered = false,
    name = 'Tilde',
    description = 'Theme inspired by https://tilde.team, This theme will most likely change a lot in the future. Some things may look ugly.',
    --    force_font = ";font=mono", -- => @@FONT
    config = {
        ['FONT'] = { -- becomes @@FONT
            default = true,
            value_true = ';font=mono',
            value_false = '',
            type = { 'bool' },
            description = 'Force mono font',
        },
    },
    button_theme = {
        shared = 'bgimg_middle=10;padding=-7,-7@@FONT',
        states = {
            [''] = ';bgimg=theme_tilde_button.png',
            [':hovered'] = ';bgimg=theme_tilde_button_hovering.png',
            [':focused'] = ';bgimg=theme_tilde_button_focusing.png',
            [':pressed'] = ';bgimg=theme_tilde_button_pressing.png',
        },
        ibutton_states = {
            [''] = ';bgimg=theme_tilde_ibutton.png',
            [':hovered'] = ';bgimg=theme_tilde_ibutton_hovering.png',
            [':focused'] = ';bgimg=theme_tilde_ibutton_focusing.png',
            [':pressed'] = ';bgimg=theme_tilde_ibutton_pressing.png',
        },
    },
    background = { name = 'theme_tilde_background.png', middle = 16 },
    background_color = '#00000050',
    listcolors = '#11111169;#5A5A5A;#243024;#020402;lightgreen',
    -- custom_formspec = '',
    colors = {
        text = 'lightgreen',
        button_text = 'black',

        box = '#282828',
        box_border = {
            width = '-2',
            color = '#14A02E',
        },
        background = '#060606',
        highlight = '#14A02E',
        title = '#AFD9AB',
    },

    hypertext_prepend = function(conf)
        return ('<global %s color=%s><tag name=big color=%s size=24><tag name=bigger color=%s size=36>'):format(
            conf.FONT and 'font=mono' or '',
            conf.colors.text,
            conf.colors.title,
            conf.colors.title
        )
    end,
})

-- I love vim substitution (:%s/blabla/blabla)
-- But i think macros are better
-- Original: https://github.com/morhetz/gruvbox/blob/master/colors/gruvbox.vim#L89

local gruvbox_colors = {
    dark0_hard = '#1d2021',
    dark0 = '#282828',
    dark0_soft = '#32302f',
    dark1 = '#3c3836',
    dark2 = '#504945',
    dark3 = '#665c54',
    dark4 = '#7c6f64',

    gray = '#928374',

    light0_hard = '#f9f5d7',
    light0 = '#fbf1c7',
    light0_soft = '#f2e5bc',
    light1 = '#ebdbb2',
    light2 = '#d5c4a1',
    light3 = '#bdae93',
    light4 = '#a89984',

    bright_red = '#fb4934',
    bright_green = '#b8bb26',
    bright_yellow = '#fabd2f',
    bright_blue = '#83a598',
    bright_purple = '#d3869b',
    bright_aqua = '#8ec07c',
    bright_orange = '#fe8019',

    neutral_red = '#cc241d',
    neutral_green = '#98971a',
    neutral_yellow = '#d79921',
    neutral_blue = '#458588',
    neutral_purple = '#b16286',
    neutral_aqua = '#689d6a',
    neutral_orange = '#d65d0e',

    faded_red = '#9d0006',
    faded_green = '#79740e',
    faded_yellow = '#b57614',
    faded_blue = '#076678',
    faded_purple = '#8f3f71',
    faded_aqua = '#427b58',
    faded_orange = '#af3a03',
}

sbz_api.register_theme('gruvbox', {
    default = true,
    name = 'Gruvbox',
    description = 'Gruvbox theme ported to sbz. Probably the only theme here with actually good colors.',
    config = {
        ['FONT'] = { -- becomes @@FONT
            default = true,
            value_true = ';font=mono',
            value_false = '',
            type = { 'bool' },
            description = 'Force mono font',
        },
    },
    button_theme = {
        shared = 'padding=2,2;@@FONTborder=false;bgimg=blank.png^[invert:rgba^[multiply:',
        states = {
            [''] = gruvbox_colors.dark1,
            [':hovered'] = gruvbox_colors.dark2,
            [':focused'] = gruvbox_colors.dark2,
            [':pressed'] = gruvbox_colors.dark1,
        },
    },
    background = { name = 'theme_gruvbox_background.png', middle = 4 },
    background_color = '#00000050',
    listcolors = function(config)
        local spec2table = core.colorspec_to_table

        local default_colors = {
            spec2table(gruvbox_colors.dark0),
            spec2table(gruvbox_colors.dark1),
            spec2table(gruvbox_colors.dark2),
            spec2table(gruvbox_colors.dark0),
            spec2table(gruvbox_colors.light1),
        }
        local result = ''
        for k, v in ipairs(default_colors) do
            result = result .. core.colorspec_to_colorstring(v) .. ';'
        end
        result = result:sub(1, #result - 1) -- remove last ;
        return result
    end,
    -- custom_formspec = '',
    colors = {
        text = gruvbox_colors.light1,
        button_text = gruvbox_colors.bright_aqua,
        box = gruvbox_colors.dark0,
        box_border = { color = gruvbox_colors.dark4, width = '-2' },
        highlight_bg = gruvbox_colors.dark1,
        title = gruvbox_colors.bright_purple,
        mono = gruvbox_colors.bright_green,
    },
    palette = gruvbox_colors,
    hypertext_prepend = function(conf)
        return ('<global color=%s %s><tag name=big color=%s size=24><tag name=bigger color=%s size=36><tag name=mono color=%s font=mono>'):format(
            conf.colors.text,
            conf.FONT and 'font=mono' or '',
            conf.colors.title,
            conf.colors.title,
            conf.colors.mono
        )
    end,
})
