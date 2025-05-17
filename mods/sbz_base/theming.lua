-- This code is responsible for the player's formspec prepend

sbz_api.themes = {
    ["builtin"] = { -- the very minimal theme
        name = "builtin",
        description = "Very minimal for sure...",
        theme_color = "white"
    }
}

dofile(core.get_modpath("sbz_base") .. "/colors.lua")

local themes = sbz_api.themes
local theme_order = { "builtin" }
sbz_api.theme_order = theme_order
local default_theme = "builtin"
sbz_api.default_theme = "builtin"
function sbz_api.register_theme(name, def)
    themes[name] = def
    if def.default then
        default_theme = name
        sbz_api.default_theme = name
    end
    if not def.unordered then -- use for themes which arent meant to be used
        theme_order[#theme_order + 1] = name
    end
end

--[[
    Some special things are expected frmo the default theme:
    - It should have a background
    - It should have a theme color
]]
-- SOME "PRE PACKAGED" THEMES

local shift_color_by_vars_hue = function(color)
    local rgb = core.colorspec_to_table(color)
    return function(vars)
        if not vars.HUE then vars.HUE = 0 end
        local new_rgb = sbz_api.rotate_hue(rgb, vars.HUE)
        return core.colorspec_to_colorstring(new_rgb)
    end
end

sbz_api.register_theme("space", {
    default = true,
    name = "Space",
    description = "[Default Theme] The sbz experience",
    config = {
        ["HUE"] = {
            default = "0", -- -60 for forest
            type = { "int", -180, 180 },
            description = "Theme Hue (An integer, from -180 to 180)",
        },
        ["FONT"] = { -- becomes @@FONT
            default = true,
            value_true = ";font=mono",
            value_false = "",
            type = { "bool" },
            description = "Force mono font"
        },
        ["LIGHT_BUTTONS"] = {
            default = false,
            type = { "bool" },
            description = "Lighter button text color",
        },
    },
    button_theme = {
        shared = "bgimg_middle=10;padding=-7,-7@@FONT",
        states = {
            [""] = ";bgimg=theme_space_button.png^[hsl:@@HUE",
            [":hovered"] = ";bgimg=theme_space_button_hovering.png^[hsl:@@HUE",
            [":focused"] = ";bgimg=theme_space_button_focusing.png^[hsl:@@HUE",
            [":pressed"] = ";bgimg=theme_space_button_pressing.png^[hsl:@@HUE",
        }
    },
    background = { name = "theme_space_background.png^[hsl:@@HUE", middle = 16 },
    background_color = "#00000050",
    listcolors = "#00000069;#5A5A5A;#141318;#30434C;#FFF",
    custom_formspec = "",
    textcolor_labellike = shift_color_by_vars_hue("lightblue"),
    textcolor_buttonlike = function(config)
        local basecolor = "#00b9b9"
        if config.LIGHT_BUTTONS then
            basecolor = "lightblue"
        end
        return shift_color_by_vars_hue(basecolor)(config)
    end,
    theme_color = shift_color_by_vars_hue("blue"),
    box_theme = {
        color = shift_color_by_vars_hue("#00b9b9"),
        inner_color = shift_color_by_vars_hue("lightblue"),
        width = "10",
    }
})

sbz_api.register_theme("tilde", {
    default = false,
    unordered = false, -- I feel like it would be an insult to the website itself honestly this theme looks bad
    name = "Tilde",
    description = "Theme inspired by https://tilde.team, some things may look ugly",
    --    force_font = ";font=mono", -- => @@FONT
    config = {
        ["FONT"] = { -- becomes @@FONT
            default = true,
            value_true = ";font=mono",
            value_false = "",
            type = { "bool" },
            description = "Force mono font"
        },
    },
    button_theme = {
        shared = "bgimg_middle=10;padding=-7,-7@@FONT",
        states = {
            [""] = ";bgimg=theme_tilde_button.png",
            [":hovered"] = ";bgimg=theme_tilde_button_hovering.png",
            [":focused"] = ";bgimg=theme_tilde_button_focusing.png",
            [":pressed"] = ";bgimg=theme_tilde_button_pressing.png",
        },
        ibutton_states = {
            [""] = ";bgimg=theme_tilde_ibutton.png",
            [":hovered"] = ";bgimg=theme_tilde_ibutton_hovering.png",
            [":focused"] = ";bgimg=theme_tilde_ibutton_focusing.png",
            [":pressed"] = ";bgimg=theme_tilde_ibutton_pressing.png",
        }
    },
    background = { name = "theme_tilde_background.png", middle = 16 },
    background_color = "#00000050",
    listcolors = "#00000069;#5A5A5A;#141318;#30434C;#FFF",
    custom_formspec = "",
    textcolor_labellike = "green",
    textcolor_buttonlike = "black",
    theme_color = "green",
})

-- Prepend Utils (e.g. the no_bg style)
sbz_api.prepend_utils = {}
function sbz_api.append_prepend_util(text)
    sbz_api.prepend_utils[#sbz_api.prepend_utils + 1] = text
end

local no_bg_util = "bgimg=blank.png"
local no_bg_util_result = ""
for _, state in ipairs { "", ":hovered", ":focused", ":pressed" } do
    no_bg_util_result = no_bg_util_result .. ("style[%s%s;%s]"):format("no_bg", state, no_bg_util)
end
sbz_api.append_prepend_util(no_bg_util_result)


local prepend_utils = ""
core.register_on_mods_loaded(function()
    prepend_utils = table.concat(sbz_api.prepend_utils)
end)

-- now... themes are mostly unchanging formspecs but i want to add some theme customization... so lets not treat them like that lol

local process_text = function(text, variables)
    return text:gsub("@@(%w+)", function(key)
        return variables[key] or key
    end)
end


sbz_api.get_theme = function(player)
    local meta = player:get_meta()
    local theme = sbz_api.themes[meta:get_string("theme_name")]
    if not theme then theme = sbz_api.themes[default_theme] end
    return theme
end
sbz_api.get_theme_name = function(player)
    local meta = player:get_meta()
    local theme = meta:get_string("theme_name")
    if not sbz_api.themes[theme] then theme = default_theme end
    return theme
end

-- includes theme vars which are immutable config
sbz_api.get_theme_config = function(player, raw_config)
    local meta = player:get_meta()
    local theme = meta:get_string("theme_name")
    if not sbz_api.themes[theme] then theme = default_theme end
    local theme_config = core.deserialize(meta:get_string("theme_config_" .. theme)) or {}
    -- now fill it in with default values
    local theme_def = sbz_api.themes[theme]
    if not theme_def.config then
        return {}
    end
    for name, value in pairs(theme_def.config) do
        local default = value.default
        if theme_config[name] == nil then theme_config[name] = default end
    end
    if theme_def.vars and not raw_config then
        for key, value in pairs(theme_def.vars) do
            theme_config[key] = value
        end
    end

    if not raw_config then
        for name, value in pairs(theme_def.config) do
            if value.type[1] == "bool" and value.value_true then -- basically switches 2 strings
                if theme_config[name]
                then
                    theme_config[name] = value.value_true
                else
                    theme_config[name] = value.value_false
                end
            end
        end
    end
    return theme_config
end

local labellike = {
    "label",
    "vertlabel",
    "checkbox",
    "textarea",
    "textlist",
    "table"
}

local buttonlike = {
    "button",
    "image_button",
    "item_image_button",
    "button_exit",
    -- "field",
    -- "pwdfield"
}

local function exec_conf_function_or_string(thing, config)
    if type(thing) == "function" then
        return thing(config)
    else
        return process_text(thing, config)
    end
end

local buttonlike_types = table.concat(buttonlike, ",")
local labellike_types = table.concat(labellike, ",")

sbz_api.prepend_from_theme = function(theme, config)
    local prepend = { prepend_utils }

    local force_font = config.FONT ~= "" and config.FONT ~= nil

    local variables = table.copy(config or {})

    if theme.button_theme then
        local shared = process_text(theme.button_theme.shared, variables)
        local states = theme.button_theme.states
        local ibutton_states = theme.button_theme.ibutton_states or theme.button_theme.states
        for _, button_type in ipairs({ "button", "button_exit", }) do
            for state, button_theme in pairs(states) do
                button_theme = shared .. process_text(button_theme, variables)
                prepend[#prepend + 1] = ("style_type[%s%s;%s]"):format(button_type, state, button_theme)
            end
        end
        for _, button_type in ipairs({ "image_button", "item_image_button" }) do
            for state, button_theme in pairs(ibutton_states) do
                button_theme = shared .. process_text(button_theme, variables)
                prepend[#prepend + 1] = ("style_type[%s%s;%s]"):format(button_type, state, button_theme)
            end
        end
    end

    if force_font then
        local force_font_types = table.concat({
            "label",
            "vertlabel",
            "button",
            "button_exit",
            "image_button",
            "item_image_button",
            "field",
            "pwdfield",
            "textarea",
            "tabheader",
            "textlist",
        }, ",")

        prepend[#prepend + 1] = "style_type[" .. force_font_types .. config.FONT .. "]"
    end
    if theme.background then
        prepend[#prepend + 1] = ("background9[0,0;0,0;%s;true;%s]"):format(
            process_text(theme.background.name, variables), theme.background.middle)
    end
    if theme.listcolors then
        prepend[#prepend + 1] = ("listcolors[%s]"):format(theme.listcolors)
    end
    if theme.custom_formspec then
        prepend[#prepend + 1] = theme.custom_formspec
    end
    if theme.background_color then
        prepend[#prepend + 1] = ("bgcolor[%s;true]"):format(exec_conf_function_or_string(theme.background_color, config))
    end
    if theme.textcolor then
        prepend[#prepend + 1] = ("style_type[*;textcolor=%s]"):format(exec_conf_function_or_string(theme.textcolor,
            config))
    end

    if theme.textcolor_labellike then
        prepend[#prepend + 1] = ("style_type[%s;textcolor=%s]"):format(labellike_types,
            exec_conf_function_or_string(theme.textcolor_labellike, config))
    end

    if theme.textcolor_buttonlike then
        prepend[#prepend + 1] = ("style_type[%s;textcolor=%s]"):format(buttonlike_types,
            exec_conf_function_or_string(theme.textcolor_buttonlike, config))
    end

    if theme.box_theme then -- then there is a util to get default box color
        prepend[#prepend + 1] = ("style_type[box;%s]"):format("bordercolors=" ..
            exec_conf_function_or_string(theme.box_theme.color, config) .. ",borderwidths=" .. theme.box_theme.width)
    end

    return table.concat(prepend)
end

sbz_api.update_theme = function(player)
    local meta = player:get_meta()
    local theme = sbz_api.themes[meta:get_string("theme_name")]
    if not theme then theme = sbz_api.themes[default_theme] end

    local config = sbz_api.get_theme_config(player)
    local prepend = sbz_api.prepend_from_theme(theme, config)
    player:set_formspec_prepend(prepend)
    return prepend
end

-- implement more as needed
sbz_api.validate_theme_config_input = function(value_def, value)
    local value_type = value_def.type[1]

    if value_type == "int" then
        local value_min, value_max = value_def.type[2], value_def.type[3]
        value = tonumber(value)
        if not value then
            return false, "Value needs to be a number"
        end
        if value ~= math.floor(value) then
            return false, "Value is an integer, meaning that it can't have a decimal part"
        end
        if value > value_max then
            return false, "Value too large, max value: " .. value_max
        end
        if value < value_min then
            return false, "Value too small, min value: " .. value_min
        end
        return value
    elseif value_type == "bool" then
        local bool
        if value == "true" or value == "1" or value == "y" or value == "yes" or value == true then
            bool = true
        elseif value == "false" or value == "0" or value == "-1" or value == "n" or value == "no" or value == false then
            bool = false
        end
        if bool == nil then
            return false, "That was not a boolean, try something like yes/no or y/n"
        end
        return bool
    end
end

core.register_on_joinplayer(sbz_api.update_theme)

core.register_chatcommand("theme", {
    params = "<name>",
    description = "Sets your theme",
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Unfortunutely, you need to be online to use this command" -- for mt webui users
        end
        local theme_name = param

        if not theme_name or (theme_name and not sbz_api.themes[theme_name]) then
            return false, "Need to provide a valid name, example: \"" .. default_theme .. "\""
        end

        local pmeta = player:get_meta()
        pmeta:set_string("theme_name", theme_name)

        sbz_api.update_theme(player)
        return true, "Updated your theme"
    end
})

dofile(core.get_modpath("sbz_base") .. "/theming_by_terminal.lua")
dofile(core.get_modpath("sbz_base") .. "/theming_by_gui.lua")
-- Code helpers
sbz_api.get_theme_background = function(player)
    local theme = sbz_api.get_theme(player)
    if not theme.background then theme = sbz_api.themes[default_theme] end
    return process_text(theme.background.name, sbz_api.get_theme_config(player))
end

sbz_api.get_theme_color = function(player)
    local theme = sbz_api.get_theme(player)
    if not theme.theme_color then theme = sbz_api.themes[default_theme] end
    return exec_conf_function_or_string(theme.theme_color, sbz_api.get_theme_config(player))
end

sbz_api.get_box_color = function(player)
    local theme = sbz_api.get_theme(player)
    if not theme.box_theme.inner_color then theme = sbz_api.themes[default_theme] end
    return exec_conf_function_or_string(theme.box_theme.inner_color, sbz_api.get_theme_config(player))
end
