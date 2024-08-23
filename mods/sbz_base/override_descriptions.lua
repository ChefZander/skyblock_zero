-- adds info for sbz_power and sbz_pipeworks
minetest.register_on_mods_loaded(function()
    for k, v in pairs(minetest.registered_nodes) do
        local og_desc = v.description
        local new_desc = { og_desc }
        if v.power_needed then
            new_desc[#new_desc + 1] = "Needs " .. v.power_needed .. " power"
        end
        if v.power_generated then
            new_desc[#new_desc + 1] = "Generates" .. v.power_generated .. " power"
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
