core.register_chatcommand("theme_config_set", {
    params = "<name> <value>",
    description = "Sets the config values for your theme",
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Unfortunutely, you need to be online to use this command" -- for mt webui users
        end
        local meta = player:get_meta()

        local set_name, set_value = unpack(param:split(" "))

        local theme_name = meta:get_string("theme_name")
        if not sbz_api.themes[theme_name] then theme_name = sbz_api.default_theme end

        local theme_config = core.deserialize(meta:get_string("theme_config_" .. theme_name)) or {}
        -- now fill it in with default values
        local theme_def = sbz_api.themes[theme_name]
        if not theme_def.config then
            return false, "That theme cannot be configured"
        end

        for config_name, value_definition in pairs(theme_def.config) do
            if config_name == set_name then
                local value, errmsg = sbz_api.validate_theme_config_input(value_definition, set_value)
                if errmsg then
                    return false, errmsg
                end
                theme_config[set_name] = value
                meta:set_string("theme_config_" .. theme_name, core.serialize(theme_config))
                sbz_api.update_theme(player)
                return true, ("Successfuly updated config; " .. config_name .. "=" .. tostring(value))
            end
        end

        return false, "That name is unsupported"
    end
})

core.register_chatcommand("theme_config", {
    params = "[reset to default]",
    description = "Gives you your theme configuration",
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Unfortunutely, you need to be online to use this command" -- for mt webui users
        end
        if core.is_yes(param) then
            local pmeta = player:get_meta()
            local theme_name = pmeta:get_string("theme_name")
            if not sbz_api.themes[theme_name] then theme_name = sbz_api.default_theme end
            pmeta:set_string("theme_config_" .. theme_name, "")
            sbz_api.update_theme(player)
            return true, "Re-set your theme to default settings"
        end

        local conf = sbz_api.get_theme_config(player, true)
        local out = {}
        for k, v in pairs(conf) do
            out[#out + 1] = tostring(k) .. "=" .. tostring(v)
        end
        return true, table.concat(out, "\n")
    end
})
