minetest.register_on_mods_loaded(function()
    table.foreach(minetest.registered_nodes, function(k)
        if minetest.get_item_group(k, "sign_logic_compatible") ~= 1 then return end

        -- great
        minetest.override_item(k, {
            on_logic_send = function(pos, msg, _)
                if type(msg) ~= "string" then return end
                signs_lib.update_sign(pos, {
                    text = msg
                })
            end
        })
    end, false)
end)
