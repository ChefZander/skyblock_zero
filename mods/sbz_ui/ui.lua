sbz_api.ui = {}

-- TODO : more UI stuffs here
-- TODO: Cache theme config

local player, theme, config, colors

sbz_api.ui.set_player = function(set_player)
    player = set_player
    theme = sbz_api.get_theme(set_player)
    config = sbz_api.get_theme_config(player, false)
    colors = sbz_api.get_theme_colors(player)
end

sbz_api.ui.del_player = function()
    player = nil
    theme = nil
    config = nil
    colors = nil
end

sbz_api.ui.get_theme_config = function()
    return config
end

sbz_api.ui.get_theme = function()
    return theme
end

function sbz_api.ui.get_player_and_theme_and_config()
    return player, theme, config
end

-- Playerdata - basically, temporary player data
-- Clears up on leaveplayer
-- lol
sbz_api.ui.playerdata = {}
local playerdata = sbz_api.ui.playerdata

function sbz_api.ui.get_playerdata(formname)
    playerdata[formname] = playerdata[formname] or {}
    return playerdata[formname][player:get_player_name()]
end

function sbz_api.ui.set_playerdata(formname, set_playerdata)
    playerdata[formname] = playerdata[formname] or {}
    playerdata[formname][player:get_player_name()] = set_playerdata
end

core.register_on_leaveplayer(function(left_player)
    local left_player_name = left_player:get_player_name()
    for _, data in pairs(playerdata) do
        data[left_player_name] = nil
    end
end)

-- Ok now random elements

sbz_api.ui.box = function(x, y, w, h)
    return ('box[%s,%s;%s,%s;]'):format(x, y, w, h)
end

--- Issue: it is different for each player
function sbz_api.ui.pixel_size(coord_name)
    local window_info = core.get_player_window_information(player:get_player_name())

    if not window_info then -- i want to BAN the player for causing me such TROUBLES, but unfortunutely, some people find that undesirable, so we are just going to say its 0.1
        return 0.05
    end
    return window_info.max_formspec_size[coord_name] / window_info.size[coord_name]
end

--- Meant to shadow over elements, like give tables that great border
--- BECAUSE LUANTI FOR SOME REASON CANNOT DO THAT
--- ok so the width is in pixels
sbz_api.ui.box_shadow = function(x, y, w, h, width)
    local wx, wy = width * sbz_api.ui.pixel_size 'x', width * sbz_api.ui.pixel_size 'y'
    x = x - wx
    y = y - wy
    w = w + (wx * 2)
    h = h + (wy * 2)
    return ('box[%s,%s;%s,%s;]'):format(x, y, w, h)
end

sbz_api.ui.field = function(x, y, w, h, name, label, default)
    local extra = ''
    if colors.box then
        extra = extra .. ('style[%s;%s]'):format(name, 'border=false')
        extra = extra .. ('box[%s,%s;%s,%s;]'):format(x, y, w, h)
    end
    return extra .. ('field[%s,%s;%s,%s;%s;%s;%s]'):format(x, y, w, h, name, label, core.formspec_escape(default))
end

sbz_api.ui.wrap = {
    center = '<center>%s</center>',
    big = '<big>%s</big>',
}
---@param wrap string|nil
sbz_api.ui.hypertext = function(x, y, w, h, name, text, wrap)
    local prepend = sbz_api.get_hypertext_prepend(player, theme, config)
    wrap = wrap or '%s'
    return ('hypertext[%s,%s;%s,%s;%s;%s]'):format(x, y, w, h, name, prepend .. wrap:format(core.formspec_escape(text)))
end

sbz_api.ui.big_hypertext = function(x, y, w, h, name, text)
    local prepend = sbz_api.get_hypertext_prepend(player, theme, config)
    return ('hypertext[%s,%s;%s,%s;%s;%s]'):format(
        x,
        y,
        w,
        h,
        name,
        prepend .. (sbz_api.ui.wrap.big):format(core.formspec_escape(text))
    )
end

sbz_api.ui.scrollbar = function(x, y, w, h, orientation, name, value) -- MAY GET CHANGED IN THE FUTURE TO ALLOW HACK-STYLING (A term i made up just now describing the way i style fields)
    -- Also, scrollbars look scary
    -- Just look at the amount of stuff thats like... required here
    -- i like having a function for scary
    return ('scrollbar[%s,%s;%s,%s;%s;%s;%s]'):format(x, y, w, h, orientation, name, value)
end

-- WINDOW STUFF!

--- End window with container_end[]
sbz_api.ui.window = function(x, y, w, h)
    return ([[
box[0,0;1000,1000;#00000080]
allow_close[false]
container[%s,%s]
%s
button[%s,0.2;1,1;try_quit;X]
        ]]):format(x, y, sbz_api.ui.box(0, 0, w, h), w - 1.2)
end

sbz_api.ui.window_end = function()
    return 'container_end[]'
end -- for completeness
