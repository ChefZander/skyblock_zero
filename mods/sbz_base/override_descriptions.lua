-- adds info for sbz_power and sbz_pipeworks

local palettes = {
    ["unifieddyes_palette_colorfacedir.png"] = true,
    ["unifieddyes_palette_extended.png"] = true,
    ["unifieddyes_palette_colorwallmounted.png"] = true
}

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
            if v.groups.core_drop_multi ~= nil and v.groups.core_drop_multi ~= 1 then
                new_desc[#new_desc + 1] = v.groups.core_drop_multi .. "x effective at getting drops from core"
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
            if v.groups.eat then
                local sign = "+"
                if v.groups.eat < 0 then sign = "" end -- tostring(-x) does that automatically,
                new_desc[#new_desc + 1] = ("Can be eaten. %s HP"):format(sign .. v.groups.eat)
            end

            if v.groups.explody then explody = true end
        end


        if v.type == "node" and not explody then
            new_desc[#new_desc + 1] = "Immune to explosions."
        elseif v.type == "node" and explody == 1 then
            new_desc[#new_desc + 1] = "Immune to meteorite explosions. (But not stronger ones)"
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


        if sbz_api.mvps_stoppers[k] == true then
            new_desc[#new_desc + 1] = "Logic builders or jumpdrives cannot move this node. (mvps stopper)"
        end

        if v.light_source and v.light_source ~= 0 then
            new_desc[#new_desc + 1] = "Light source: " .. v.light_source
        end


        if palettes[v.palette or ""] then
            new_desc[#new_desc + 1] = "Can be colored."
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
