-- This code is responsible for the player's formspec prepend

sbz_api.themes = {
    ["builtin"] = {
        description = "Not really meant to be used lol... but it is here if you want it",
        theme_color = "white"
    }
}
local themes = sbz_api.themes
local theme_order = { "builtin" }
local default_theme = "builtin"
function sbz_api.register_theme(name, def)
    themes[name] = def
    if def.default then
        default_theme = name
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
sbz_api.register_theme("space", {
    default = true,
    description = "[Default Theme] the skyblock zero theme",
    force_font = ";font=mono", -- => @@FONT
    button_theme = {
        shared = "bgimg_middle=10;padding=-7,-7@@FONT",
        states = {
            [""] = ";bgimg=theme_space_button.png",
            [":hovered"] = ";bgimg=theme_space_button_hovering.png",
            [":focused"] = ";bgimg=theme_space_button_focusing.png",
            [":pressed"] = ";bgimg=theme_space_button_pressing.png",
        }
    },
    background = { name = "theme_space_background.png", middle = 16 },
    background_color = "#00000050",
    listcolors = "#00000069;#5A5A5A;#141318;#30434C;#FFF",
    custom_formspec = "",
    textcolor_labellike = "lightblue",
    textcolor_buttonlike = "#00b9b9",
    theme_color = "blue",
})

sbz_api.register_theme("forest", {
    default = true,
    description = "Simply the hue shifted space theme",
    force_font = ";font=mono", -- => @@FONT
    vars = {
        ["COLOR"] = "^[hsl:-60"
    },
    button_theme = {
        shared = "bgimg_middle=10;padding=-7,-7@@FONT",
        states = {
            [""] = ";bgimg=theme_space_button.png@@COLOR",
            [":hovered"] = ";bgimg=theme_space_button_hovering.png@@COLOR",
            [":focused"] = ";bgimg=theme_space_button_focusing.png@@COLOR",
            [":pressed"] = ";bgimg=theme_space_button_pressing.png@@COLOR",
        }
    },
    background = { name = "theme_space_background.png@@COLOR", middle = 16 },
    background_color = "#00000050",
    listcolors = "#00000069;#5A5A5A;#141318;#30434C;#FFF",
    custom_formspec = "",
    textcolor_labellike = "lightgreen",
    textcolor_buttonlike = "#86da9b",
    theme_color = "green",
})

sbz_api.register_theme("tilde", {
    default = false,
    unordered = false,         -- I feel like it would be an insult to the website itself honestly this theme looks bad
    description = "Theme inspired by https://tilde.team",
    force_font = ";font=mono", -- => @@FONT
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

local buttonlike_types = table.concat(buttonlike, ",")
local labellike_types = table.concat(labellike, ",")

sbz_api.prepend_from_theme = function(theme, config)
    local prepend = { prepend_utils }
    local force_font = (not config.no_forced_font) and theme.force_font

    local variables = table.copy(theme.vars or {})
    if force_font then
        variables["FONT"] = theme.force_font
    else
        variables["FONT"] = ""
    end

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

        prepend[#prepend + 1] = "style_type[" .. force_font_types .. theme.force_font .. "]"
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
        prepend[#prepend + 1] = ("bgcolor[%s;true]"):format(theme.background_color)
    end
    if theme.textcolor then
        prepend[#prepend + 1] = ("style_type[*;textcolor=%s]"):format(theme.textcolor)
    end

    if theme.textcolor_labellike then
        prepend[#prepend + 1] = ("style_type[%s;textcolor=%s]"):format(labellike_types, theme.textcolor_labellike)
    end

    if theme.textcolor_buttonlike then
        prepend[#prepend + 1] = ("style_type[%s;textcolor=%s]"):format(buttonlike_types, theme.textcolor_buttonlike)
    end

    return table.concat(prepend)
end

sbz_api.update_theme = function(player)
    local meta = player:get_meta()
    local theme = sbz_api.themes[meta:get_string("theme_name")]
    if not theme then theme = sbz_api.themes[default_theme] end

    local no_forced_font = meta:get_int("no_forced_font") == 1

    player:set_formspec_prepend(sbz_api.prepend_from_theme(theme, {
        no_forced_font = no_forced_font
    }))
end

core.register_on_joinplayer(sbz_api.update_theme)

core.register_chatcommand("theme", {
    params = "<name> [force_font]",
    description = "Sets your theme, [force_font] determines if theme is allowed to force a font",
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Unfortunutely, you need to be online to use this command" -- for mt webui users
        end
        local split = param:split(" ")
        local theme_name = split[1]
        local force_font = split[2]

        if not theme_name or (theme_name and not sbz_api.themes[theme_name]) then
            return false, "Need to provide a valid name, example: \"" .. default_theme .. "\""
        end

        local pmeta = player:get_meta()
        pmeta:set_string("theme_name", theme_name)
        if force_font then
            pmeta:set_int("no_force_font", not core.is_yes(force_font) and 1 or 0)
        end

        sbz_api.update_theme(player)
        return true, "Updated your theme"
    end
})

-- Code helpers

sbz_api.get_theme = function(player)
    local meta = player:get_meta()
    local theme = sbz_api.themes[meta:get_string("theme_name")]
    if not theme then theme = sbz_api.themes[default_theme] end
    return theme
end

sbz_api.get_theme_background = function(player)
    local theme = sbz_api.get_theme(player)
    if not theme.background then theme = sbz_api.themes[default_theme] end
    return process_text(theme.background.name, theme.vars)
end

sbz_api.get_theme_color = function(player)
    local theme = sbz_api.get_theme(player)
    if not theme.theme_color then theme = sbz_api.themes[default_theme] end
    return theme.theme_color
end
