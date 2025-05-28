sbz_api.disabled_areas_hud = {} -- t[name] = status

core.register_chatcommand("toggle_areas_hud", {
    description =
    "Enables/Disables the areas hud. (Those are the areas that you see in your HUD when you enter a protected area.)",

    func = function(name)
        sbz_api.disabled_areas_hud[name] = not sbz_api.disabled_areas_hud[name]
        local status = sbz_api.disabled_areas_hud[name]
        if not status then
            return true, "Enabled the area HUD."
        else
            return true, "Disabled the area HUD."
        end
    end
})
