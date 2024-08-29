local S = minetest.get_translator("pipeworks")
-- cache some recipe data to avoid calling the slow function
-- minetest.get_craft_result() every second
local autocrafterCache = {}


local next = next

local function count_index(invlist)
    local index = {}
    for _, stack in pairs(invlist) do
        stack = ItemStack(stack)
        if not stack:is_empty() then
            local stack_name = stack:get_name()
            index[stack_name] = (index[stack_name] or 0) + stack:get_count()
        end
    end
    return index
end

local function get_item_info(stack)
    local name = stack:get_name()
    local def = minetest.registered_items[name]
    local description = def and def.description or S("Unknown item")
    return description, name
end

-- Get best matching recipe for what user has put in crafting grid.
-- This function does not consider crafting method (mix vs craft)
local function get_matching_craft(output_name, example_recipe)
    local recipes = minetest.get_all_craft_recipes(output_name)
    if not recipes then
        return example_recipe
    end

    if 1 == #recipes then
        return recipes[1].items
    end

    local index_example = count_index(example_recipe)
    local best_score = 0
    local index_recipe, best_index, score, group
    for i = 1, #recipes do
        score = 0
        index_recipe = count_index(recipes[i].items)
        for recipe_item_name, _ in pairs(index_recipe) do
            if index_example[recipe_item_name] then
                score = score + 1
            elseif recipe_item_name:sub(1, 6) == "group:" then
                group = recipe_item_name:sub(7)
                for example_item_name, _ in pairs(index_example) do
                    if minetest.get_item_group(
                            example_item_name, group) ~= 0
                    then
                        score = score + 1
                        break
                    end
                end
            end
        end
        if best_score < score then
            best_index = i
            best_score = score
        end
    end

    return best_index and recipes[best_index].items or example_recipe
end

local function get_craft(pos, inventory, hash)
    local hash = hash or minetest.hash_node_position(pos)
    local craft = autocrafterCache[hash]
    if craft then return craft end

    local example_recipe = inventory:get_list("recipe")
    local output, decremented_input = minetest.get_craft_result({
        method = "normal", width = 3, items = example_recipe
    })

    local recipe = example_recipe
    if output and not output.item:is_empty() then
        recipe = get_matching_craft(output.item:get_name(), example_recipe)
    end

    craft = {
        recipe = recipe,
        consumption = count_index(recipe),
        output = output,
        decremented_input = decremented_input.items
    }
    autocrafterCache[hash] = craft
    return craft
end

local function reserve_slots(meta)
    local inv = meta:get_inventory()
    local recipe_inv = inv:get_list("recipe")

    local reserved_slots = {}
    for i = 1, 9 do
        reserved_slots[i] = recipe_inv[i]:get_name()
        reserved_slots[recipe_inv[i]:get_name()] = i
        meta:set_string("reserved_slots", minetest.serialize(reserved_slots))
    end
end

local function reserved_items_formspec(meta)
    local fs = {}
    local offset = { 0.22, 5 }
    local reserved_slots = minetest.deserialize(meta:get_string("reserved_slots"))
    for i = 1, 9 do
        local name = reserved_slots[i]
        fs[#fs + 1] = string.format("item_image[%s,%s;1,1;%s]", offset[1], offset[2], name)
        offset[1] = offset[1] + 1.25
    end
    return table.concat(fs)
end
-- From a consumption table with groups and an inventory index,
-- build a consumption table without groups
local function calculate_consumption(inv_index, consumption_with_groups)
    inv_index = table.copy(inv_index)
    consumption_with_groups = table.copy(consumption_with_groups)

    -- table of items to actually consume
    local consumption = {}
    -- table of ingredients defined as one or more groups each
    local grouped_ingredients = {}

    -- First consume all non-group requirements
    -- This is done to avoid consuming a non-group item which
    -- is also in a group
    for key, count in pairs(consumption_with_groups) do
        if key:sub(1, 6) == "group:" then
            -- build table with group recipe items while looping
            grouped_ingredients[key] = key:sub(7):split(',')
        else
            -- if the item to consume doesn't exist in inventory
            -- or not enough of them, abort crafting
            if not inv_index[key] or inv_index[key] < count then
                return nil
            end

            consumption[key] = (consumption[key] or 0) + count
            consumption_with_groups[key] = consumption_with_groups[key] - count
            assert(consumption_with_groups[key] == 0)
            consumption_with_groups[key] = nil
            inv_index[key] = inv_index[key] - count
            assert(inv_index[key] >= 0)
        end
    end

    -- helper function to resolve matching ingredients with multiple group
    -- requirements
    local function ingredient_groups_match_item(ingredient_groups, name)
        local found = 0
        local count_ingredient_groups = #ingredient_groups
        for i = 1, count_ingredient_groups do
            if minetest.get_item_group(name,
                    ingredient_groups[i]) ~= 0
            then
                found = found + 1
            end
        end
        return found == count_ingredient_groups
    end

    -- Next, resolve groups using the remaining items in the inventory
    if next(grouped_ingredients) ~= nil then
        local take
        for itemname, count in pairs(inv_index) do
            if count > 0 then
                -- groupname is the string as defined by recipe.
                --  e.g. group:dye,color_blue
                -- groups holds the group names split into a list
                --  ready to be passed to core.get_item_group()
                for groupname, groups in pairs(grouped_ingredients) do
                    if consumption_with_groups[groupname] > 0
                        and ingredient_groups_match_item(groups, itemname)
                    then
                        take = math.min(count,
                            consumption_with_groups[groupname])
                        consumption_with_groups[groupname] =
                            consumption_with_groups[groupname] - take

                        assert(consumption_with_groups[groupname] >= 0)
                        consumption[itemname] =
                            (consumption[itemname] or 0) + take

                        inv_index[itemname] =
                            inv_index[itemname] - take
                        assert(inv_index[itemname] >= 0)
                    end
                end
            end
        end
    end

    -- Finally, check everything has been consumed
    for key, count in pairs(consumption_with_groups) do
        if count > 0 then
            return nil
        end
    end

    return consumption
end

local function has_room_for_output(list_output, index_output)
    local name
    local empty_count = 0
    for _, item in pairs(list_output) do
        if item:is_empty() then
            empty_count = empty_count + 1
        else
            name = item:get_name()
            if index_output[name] then
                index_output[name] = index_output[name] - item:get_free_space()
            end
        end
    end
    for _, count in pairs(index_output) do
        if count > 0 then
            empty_count = empty_count - 1
        end
    end
    if empty_count < 0 then
        return false
    end

    return true
end

local function autocraft(inventory, craft)
    if not craft then return false end

    -- check if output and all replacements fit in dst
    local output = craft.output.item
    local out_items = count_index(craft.decremented_input)
    out_items[output:get_name()] =
        (out_items[output:get_name()] or 0) + output:get_count()

    if not has_room_for_output(inventory:get_list("dst"), out_items) then
        return false
    end

    -- check if we have enough material available
    local inv_index = count_index(inventory:get_list("src"))
    local consumption = calculate_consumption(inv_index, craft.consumption)
    if not consumption then
        return false
    end

    -- consume material
    for itemname, number in pairs(consumption) do
        -- We have to do that since remove_item does not work if count > stack_max
        for _ = 1, number do
            inventory:remove_item("src", ItemStack(itemname))
        end
    end

    -- craft the result into the dst inventory and add any "replacements" as well
    inventory:add_item("dst", output)
    local leftover
    for i = 1, 9 do
        leftover = inventory:add_item("dst", craft.decremented_input[i])
        if leftover and not leftover:is_empty() then
            minetest.log("warning", "[pipeworks] autocrafter didn't " ..
                "calculate output space correctly.")
        end
    end
    return true
end

-- returns false to stop the timer, true to continue running
-- is started only from start_autocrafter(pos) after sanity checks and
-- recipe is cached
local function run_autocrafter(pos)
    local meta = minetest.get_meta(pos)
    local inventory = meta:get_inventory()
    local craft = get_craft(pos, inventory)
    local output_item = craft.output.item
    -- only use crafts that have an actual result
    if output_item:is_empty() then
        meta:set_string("infotext", S("unconfigured Autocrafter: unknown recipe"))
        return false
    end
    local continue = autocraft(inventory, craft)
    if not continue then return false end
    return true
end

-- note, that this function assumes allready being updated to virtual items
-- and doesn't handle recipes with stacksizes > 1
local function after_recipe_change(pos, inventory)
    local hash = minetest.hash_node_position(pos)
    local meta = minetest.get_meta(pos)
    autocrafterCache[hash] = nil
    -- if we emptied the grid, there's no point in keeping it running or cached
    if inventory:is_empty("recipe") then
        inventory:set_stack("output", 1, "")
        return
    end
    local craft = get_craft(pos, inventory, hash)
    local output_item = craft.output.item
    local description, name = get_item_info(output_item)
    inventory:set_stack("output", 1, output_item)
end

-- clean out unknown items and groups, which would be handled like unknown
-- items in the crafting grid
-- if minetest supports query by group one day, this might replace them
-- with a canonical version instead
local function normalize(item_list)
    for i = 1, #item_list do
        local name = item_list[i]
        if not minetest.registered_items[name] then
            item_list[i] = ""
        end
    end
    return item_list
end

local function on_output_change(pos, inventory, stack)
    if not stack then
        inventory:set_list("output", {})
        inventory:set_list("recipe", {})
    else
        local input = minetest.get_craft_recipe(stack:get_name())
        if not input.items or input.type ~= "normal" then return end
        local items, width = normalize(input.items), input.width
        local item_idx, width_idx = 1, 1
        for i = 1, 9 do
            if width_idx <= width then
                inventory:set_stack("recipe", i, items[item_idx])
                item_idx = item_idx + 1
            else
                inventory:set_stack("recipe", i, ItemStack(""))
            end
            width_idx = (width_idx < 3) and (width_idx + 1) or 1
        end
        -- we'll set the output slot in after_recipe_change to the actual
        -- result of the new recipe
    end
    after_recipe_change(pos, inventory)
end

-- returns false if we shouldn't bother attempting to start the timer again
-- after this
local function update_meta(meta)
    reserve_slots(meta)
    local fs =
        "formspec_version[7]" ..
        "size[11.4,14]" ..
        "list[context;recipe;0.22,0.22;3,3;]" ..
        "image[4,1.45;1,1;[combine:16x16^[noalpha^[colorize:#141318:255]" ..
        "list[context;output;4,1.45;1,1;]" ..
        "list[context;dst;5.28,0.22;4,3;]" ..
        reserved_items_formspec(meta) ..
        "list[context;src;0.22,5;9,1;]" ..
        pipeworks.fs_helpers.get_inv(9) ..
        "listring[current_player;main]" ..
        "listring[context;src]" ..
        "listring[current_player;main]" ..
        "listring[context;dst]" ..
        "listring[current_player;main]" ..
        string.format("field[0.22,7;7,0.5;maxpow;Crafts/s (consumes more power);%s]",
            meta:get_int("maxpow"))
    meta:set_string("formspec", fs)

    -- toggling the button doesn't quite call for running a recipe change check
    -- so instead we run a minimal version for infotext setting only
    -- this might be more written code, but actually executes less
    local output = meta:get_inventory():get_stack("output", 1)
    if output:is_empty() then -- doesn't matter if paused or not
        meta:set_string("infotext", S("unconfigured Autocrafter"))
        return false
    end

    local description, name = get_item_info(output)
    local infotext = S("'@1' Autocrafter (@2)", description, name)

    meta:set_string("infotext", infotext)
    return true
end


minetest.register_node("pipeworks:autocrafter", {
    description = S("Automatic Autocrafter"),
    drawtype = "normal",
    tiles = { "autocrafter.png" },
    groups = { matter = 2, snappy = 3, tubedevice = 1, tubedevice_receiver = 1, dig_generic = 1, axey = 1, handy = 1, pickaxey = 1, pipe_connects = 1, pipe_conducts = 1, sbz_machine = 1 },
    is_ground_content = false,
    tube = {
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local slots = minetest.deserialize(meta:get_string("reserved_slots"))
            if not slots[stack:get_name()] then
                return stack
            end
            local inv = meta:get_inventory()

            for i = 1, 9 do
                if slots[i] == stack:get_name() then
                    local that_stack = inv:get_stack("src", i)
                    local leftover = that_stack:add_item(stack):get_count()
                    inv:set_stack("src", i, that_stack)
                    stack:set_count(leftover)
                    --[[
                    if stack:set_count(leftover) then
                        break
                    end
                    --]]
                end
            end
            return stack
        end,
        can_insert = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local slots = minetest.deserialize(meta:get_string("reserved_slots"))
            if not slots[stack:get_name()] then
                return false
            end
            return inv:room_for_item("src", stack)
        end,
        input_inventory = "dst",
        connect_sides = {
            left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1
        }
    },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("src", 9)
        inv:set_size("recipe", 3 * 3)
        inv:set_size("dst", 4 * 3)
        inv:set_size("output", 1)
        meta:set_int("maxpow", 1)
        update_meta(meta)
    end,
    on_rightclick = function(pos)
        update_meta(minetest.get_meta(pos))
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        if (fields.quit and not fields.key_enter_field)
            or not pipeworks.may_configure(pos, sender)
        then
            return
        end

        if fields.maxpow and tonumber(fields.maxpow) and (tonumber(fields.maxpow) > 0) then
            local meta = minetest.get_meta(pos)
            meta:set_int("maxpow", math.floor(fields.maxpow))
        end
    end,
    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        return (inv:is_empty("src") and inv:is_empty("dst"))
    end,
    after_place_node = pipeworks.scan_for_tube_objects,
    after_dig_node = function(pos)
        pipeworks.scan_for_tube_objects(pos)
    end,
    on_destruct = function(pos)
        autocrafterCache[minetest.hash_node_position(pos)] = nil
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        local inv = minetest.get_meta(pos):get_inventory()
        if listname == "recipe" then
            stack:set_count(1)
            inv:set_stack(listname, index, stack)
            after_recipe_change(pos, inv)
            return 0
        elseif listname == "output" then
            on_output_change(pos, inv, stack)
            return 0
        elseif listname == "src" then
            local meta = minetest.get_meta(pos)
            local reserved_slot = minetest.deserialize(meta:get_string("reserved_slots"))
            if not reserved_slot then return stack:get_count() end
            local stackname = stack:get_name()
            if stackname ~= reserved_slot[index] then
                return 0
            end
        end
        return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then
            minetest.log("action", string.format("%s attempted to take from " ..
                "autocrafter at %s",
                player:get_player_name(), minetest.pos_to_string(pos)))
            return 0
        end
        local inv = minetest.get_meta(pos):get_inventory()
        if listname == "recipe" then
            inv:set_stack(listname, index, ItemStack(""))
            after_recipe_change(pos, inv)
            return 0
        elseif listname == "output" then
            on_output_change(pos, inv, nil)
            return 0
        end
        return stack:get_count()
    end,
    allow_metadata_inventory_move = function(
        pos, from_list, from_index, to_list, to_index, count, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        local inv = minetest.get_meta(pos):get_inventory()
        local stack = inv:get_stack(from_list, from_index)

        if to_list == "output" then
            on_output_change(pos, inv, stack)
            return 0
        elseif from_list == "output" then
            on_output_change(pos, inv, nil)
            if to_list ~= "recipe" then
                return 0
            end -- else fall through to recipe list handling
        end

        if from_list == "recipe" or to_list == "recipe" then
            if from_list == "recipe" then
                inv:set_stack(from_list, from_index, ItemStack(""))
            end
            if to_list == "recipe" then
                stack:set_count(1)
                inv:set_stack(to_list, to_index, stack)
            end
            after_recipe_change(pos, inv)
            return 0
        end

        if to_list == "src" then
            local meta = minetest.get_meta(pos)
            local reserved_slot = minetest.deserialize(meta:get_string("reserved_slots"))
            if not reserved_slot then return stack:get_count() end
            local stackname = stack:get_name()
            if stackname ~= reserved_slot[to_index] then
                return 0
            end
        end
        return count
    end,
    info_extra = "1 power per 1 craft. Can craft unlimited** things per second.",
    action = function(pos, node, meta, supply, demand)
        if supply <= demand then
            meta:set_string("infotext", "Not enough power")
            return 0
        end
        reserve_slots(meta)

        local max_crafts = (supply - demand)
        max_crafts = math.min(max_crafts, meta:get_int("maxpow"))
        local is_max_crafts_forced = max_crafts ~= meta:get_int("maxpow")
        local result
        if max_crafts == 0 then
            return 0
        end

        local gi
        for i = 1, max_crafts do
            gi = i
            result = run_autocrafter(pos)
            if result == false then break end
        end
        local i = gi
        if i == 1 and is_max_crafts_forced then -- means that it just immiadedly failed
            meta:set_string("infotext", "Can't craft")
            return 0
        end

        meta:set_string("infotext", "Active, consuming: " .. i .. " power")
        return i
    end,

})

minetest.register_craft({
    output = "pipeworks:autocrafter",
    recipe = {
        { "sbz_resources:robotic_arm",       "sbz_resources:robotic_arm",       "sbz_resources:robotic_arm" },
        { "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit" },
        { "sbz_chem:titanium_alloy_ingot",   "sbz_meteorites:neutronium",       "sbz_chem:titanium_alloy_ingot" }
    }
})
