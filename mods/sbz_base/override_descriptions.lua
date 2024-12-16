-- adds info for sbz_power and sbz_pipeworks
minetest.register_on_mods_loaded(function()
    for k, v in pairs(minetest.registered_items) do
        local og_desc = v.description
        local new_desc = { og_desc }

        if v.power_needed or v.info_power_needed then
            new_desc[#new_desc + 1] = "Consumes " .. (v.power_needed or v.info_power_needed) .. " power"
        end
        if v.power_generated or v.info_generated then
            new_desc[#new_desc + 1] = "Generates " .. (v.power_generated or v.info_generated) .. " power"
        end

        if v.battery_max then
            new_desc[#new_desc + 1] = "Stores " .. sbz_api.format_power(v.battery_max)
        end

        if v.tube then
            if v.tube.priority then
                new_desc[#new_desc + 1] = "Tube priority: " .. v.tube.priority
            end
        end

        local explody = false
        if v.groups ~= nil then
            if v.groups.core_drop_multi ~= nil then
                new_desc[#new_desc + 1] = "Yields " .. v.groups.core_drop_multi .. "x core and emittrium drops"
            end
            if v.groups.moss_growable ~= nil then
                new_desc[#new_desc + 1] = "Moss can grow on this node."
            end
            if v.groups.chem_disabled ~= nil then
                new_desc[#new_desc + 1] =
                "This chemical is disabled.\nThis means that you won't be able to obtain it anymore, but it may receive a use in the future."
            end
            if v.groups.burn ~= nil then
                new_desc[#new_desc + 1] = "Burn power: " .. v.groups.burn .. " co2"
            end
            if v.groups.explody then explody = true end
        end


        if v.type == "node" and not explody then
            new_desc[#new_desc + 1] = "Immune to explosions."
        end

        if v.info_extra then
            if type(v.info_extra) == "string" then
                new_desc[#new_desc + 1] = v.info_extra
            elseif type(v.info_extra) == "table" then
                for i = 1, #v.info_extra do
                    new_desc[#new_desc + 1] = v.info_extra[i]
                end
            end
        end


        if not v.allow_metadata_inventory_put_was_nop and v.type == "node" then
            new_desc[#new_desc + 1] = "Logic can't put items to this node."
        end

        if sbz_api.mvps_stoppers[k] == true then
            new_desc[#new_desc + 1] = "Logic builders cannot move this node."
        end

        if #new_desc > 1 then
            for i = 2, #new_desc do
                new_desc[i] = minetest.colorize("#333333", new_desc[i])
            end
            minetest.override_item(k, {
                description = table.concat(new_desc, "\n"),
                short_description = og_desc,
            })
        end
    end
end)
