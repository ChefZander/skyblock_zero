sbz_api.ui = {}
local ui = sbz_api.ui
-- TODO : more UI stuffs here
-- TODO: Cache theme config

ui.get_content_box = function(player, x, y, w, h)
    local boxcolor = sbz_api.get_box_color(player)
    return ("box[%s,%s;%s,%s;%s]"):format(x, y, w, h, "" --[[, boxcolor]])
end
