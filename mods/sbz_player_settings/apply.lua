local base_formname = 'sbz_base:player_settings'
local receive = core.register_on_player_receive_fields
local on_join = core.register_on_joinplayer

--- BGM
receive(function(player, formname, fields)
    if formname ~= (base_formname .. '_bgm') then return end
    core.debug 'HERE'

    local scrollbar = core.explode_scrollbar_event(fields.bgm_slider)
    if scrollbar.type ~= 'CHG' then return end

    local pmeta = player:get_meta()
    local new_value = math.min(200, math.max(0, scrollbar.value))
    pmeta:set_int('bgm_volume', new_value)
    pmeta:set_int('has_set_volume', 1)

    local handle = sbz_api.bgm_handles[player:get_player_name()]
    if handle then core.sound_fade(handle, 4, (new_value / 100) + 0.001) end -- HACK: +0.001 so that it doesn't delete the sound

    sbz_api.show_settings_formspec(fields, player)
end)

--- HUD/Inventory settings
receive(function(player, formname, fields)
    if formname ~= (base_formname .. '_hud') then return end
    if fields.quit then return end

    local autohide_hp = fields.autohide_hp
    local hotbar_size = fields.hotbar_size
    local zoom_fov = fields.zoom_fov

    if autohide_hp == 'true' or autohide_hp == 'false' then
        player:get_meta():set_int('no_autohide_hp', autohide_hp == 'true' and 0 or 1)
    end
    if tonumber(hotbar_size) then
        hotbar_size = tonumber(hotbar_size)
        hotbar_size = math.floor(sbz_api.clamp(hotbar_size, 1, 32))
        player:hud_set_hotbar_itemcount(hotbar_size)
        player:get_meta():set_int('hotbar_size', hotbar_size)
    end
    if tonumber(zoom_fov) then
        player:get_meta():set_float('zoom_fov', zoom_fov)
        player:set_properties { zoom_fov = zoom_fov }
    end
    sbz_api.show_settings_formspec(fields, player)
end)

--- Apply hotbar size
on_join(function(player)
    local pm = player:get_meta()
    if pm:get_int 'hotbar_size' ~= 0 then player:hud_set_hotbar_itemcount(pm:get_int 'hotbar_size') end
end)

-- Apply zoom fov on join
on_join(function(player)
    local zoom_fov = player:get_meta():get_float 'zoom_fov'
    if zoom_fov == 0 then zoom_fov = 15 end
    player:set_properties {
        zoom_fov = zoom_fov,
    }
end)
