-- like the craftdb
-- https://github.com/dennisjenkins75/digiline_craftdb/


local MAX_RESULTS = 100

core.register_node("sbz_logic_devices:node_db", {
    description = "Node DB",
    info_extra = { "Similar to the craftDB, use it to lookup node definitions and recipes" },
    groups = { matter = 1, ui_logic = 1 },

    tiles = {
        "gpu_bottom.png",
        "gpu_bottom.png",
        "node_db_side.png",
    },
    on_logic_send = function(pos, msg, from_pos)
        if type(msg) ~= "table" then return end
        if type(msg.type) ~= "string" then return end

        if msg.type == "search" then
            if not libox.type_check(msg, {
                    type = libox.type("string"),
                    text = libox.type("string"),
                    give_basic_def = function(x) return libox.type("boolean")(x) or x == nil end,
                    max_results = function(x) return libox.type("number") or x == nil end,
                    exclude_groups = function(x) return libox.type("table")(x) or x == nil end
                }) then
                return
            end

            local result = {}
            -- group search
            if string.sub(msg.text, 1, #"group:") == "group:" then
                local groups = table.foreachi(string.sub(msg.text, #"group:" + 1):split(","), string.trim, true)
                if #groups > 10 then return end

                for k, v in pairs(core.registered_items) do
                    local fit = true
                    for kk, vv in pairs(groups) do
                        if core.get_item_group(k, vv) == 0 then
                            fit = false
                        end
                    end
                    if fit == true then
                        result[#result + 1] = k
                    end
                end
            else
                for k, v in pairs(core.registered_items) do
                    if string.find(k, msg.text, 0, true) or string.find(v.short_description or v.description or "", msg.text, 0, true) then
                        result[#result + 1] = k
                    end
                end
            end

            -- filter
            local max_results = math.min(msg.max_results or 0, MAX_RESULTS)

            if #result > max_results then
                for i = max_results, #result do
                    result[i] = nil
                end
            end

            if msg.exclude_groups then
                local new_result = {}
                for k, v in ipairs(result) do
                    local fit = true
                    for kk, vv in ipairs(msg.exclude_groups) do
                        if minetest.get_item_group(v, type(vv) == "string" and vv or "INVALID GROUP YEA ") > 0 then
                            fit = false
                        end
                    end
                    if fit then
                        new_result[#new_result + 1] = v
                    end
                end
                result = new_result
            end

            -- add basic def
            if msg.give_basic_def then
                for k, v in pairs(result) do
                    local item = core.registered_items[v]
                    result[k] = {
                        name = v,
                        description = item.description,
                        short_description = item.short_description,
                        -- this is, what i would call, a "mess"
                        image = item.inventory_image or item.wield_image or
                            (type(item.tiles) == "table" and core.inventorycube(item.tiles[1] or "", item.tiles[3] or item.tiles[1] or "", item.tiles[5] or item.tiles[1] or ""))
                    }
                end
            end

            sbz_logic.send(from_pos, result, pos)
        elseif msg.type == "get_def" then
            if type(msg.item) ~= "string" then return end
            if not minetest.registered_items[msg.item] then return end

            sbz_logic.send(from_pos, libox.digiline_sanitize(minetest.registered_items[msg.item], false), pos)
        elseif msg.type == "recipes" then
            if type(msg.item) ~= "string" then return end
            if not minetest.registered_items[msg.item] then return end

            sbz_logic.send(from_pos, unified_inventory.get_recipe_list(msg.item), pos)
        elseif msg.type == "uses" then
            if type(msg.item) ~= "string" then return end
            if not minetest.registered_items[msg.item] then return end

            sbz_logic.send(from_pos, unified_inventory.get_usage_list(msg.item), pos)
        end
    end
})
