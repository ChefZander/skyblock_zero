sbz_api.ui = {}
local ui = sbz_api.ui
-- TODO : more UI stuffs here
-- TODO: Cache theme config

local player, theme, config

ui.set_player = function(set_player)
    player = set_player
    theme = sbz_api.get_theme(set_player)
    config = sbz_api.get_theme_config(player, true)
end

ui.del_player = function()
    player = nil
    theme = nil
    config = nil
end

ui.box = function(x, y, w, h)
    return ("box[%s,%s;%s,%s;]"):format(x, y, w, h)
end

--- Issue: it is different for each player
function ui.pixel_size(coord_name)
    local window_info = core.get_player_window_information(player:get_player_name())

    if not window_info then -- i want to BAN the player for causing me such TROUBLES, but unfortunutely, some people find that undesirable, so we are just going to say its 0.1
        return 0.1
    end
    return window_info.max_formspec_size[coord_name] / window_info.size[coord_name]
end

--- Meant to shadow over elements, like give tables that great border
--- BECAUSE LUANTI FOR SOME REASON CANNOT DO THAT
--- ok so the width is in pixels
ui.box_shadow = function(x, y, w, h, width)
    local wx, wy = width * ui.pixel_size("x"), width * ui.pixel_size("y")
    x = x - wx
    y = y - wy
    w = w + wx * 2
    h = h + wy * 2
    return ("box[%s,%s;%s,%s;]"):format(x, y, w, h)
end

ui.field = function(x, y, w, h, name, label, default)
    local extra = ""
    if theme.field_theme and theme.field_theme.use_box then
        extra = extra .. ("style[%s;%s]"):format(name, "border=false")
        extra = extra .. ("box[%s,%s;%s,%s;]"):format(x, y, w, h)
    end
    return extra .. ("field[%s,%s;%s,%s;%s;%s;%s]"):format(x, y, w, h, name, label, core.formspec_escape(default))
end


ui.wrap = {
    center = "<center>%s</center>",
    big = "<big>%s</big>"
}
---@param wrap string|nil
ui.hypertext = function(x, y, w, h, name, text, wrap)
    local prepend = sbz_api.get_hypertext_prepend(player, theme, config)
    wrap = wrap or "%s"
    return ("hypertext[%s,%s;%s,%s;%s;%s]"):format(x, y, w, h, name,
        prepend .. wrap:format(core.formspec_escape(text)))
end

ui.big_hypertext = function(x, y, w, h, name, text)
    local prepend = sbz_api.get_big_hypertext_prepend(player, theme, config)
    return ("hypertext[%s,%s;%s,%s;%s;%s]"):format(x, y, w, h, name,
        prepend .. (ui.wrap.big):format(core.formspec_escape(text)))
end
