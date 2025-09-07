--[[
Some of the recipe stuff:tm:

"Single" craft matching: O(1)
Other: O(n) (may change, only if needed)

Use this/extend this for crafts that are meant for machines.
Do not use for purely unified inventory crafts

This doesn't support any crafts with metadata or wear info
]]

sbz_api.recipe = {}
sbz_api.recipe.registered_craft_types = {}
sbz_api.recipe.registered_crafts = {}
sbz_api.recipe.registered_crafts_by_type_single = {}
sbz_api.recipe.registered_crafts_by_type = {}

local reg_crafts = sbz_api.recipe.registered_crafts -- Unordered
local reg_crafts_by_type_single = sbz_api.recipe.registered_crafts_by_type_single
local reg_crafts_by_type = sbz_api.recipe.registered_crafts_by_type
local reg_craft_types = sbz_api.recipe.registered_craft_types

function sbz_api.recipe.register_craft_type(def)
    assert(def.type, 'It needs a name')
    reg_craft_types[def.type] = def
    if def.single then
        reg_crafts_by_type_single[def.type] = {}
        def.width = 1
        def.height = 1
        def.uses_crafting_grid = false
    end
    reg_crafts_by_type[def.type] = {}
    reg_craft_types[def.type] = def
    unified_inventory.register_craft_type(def.type, def)
end

function sbz_api.recipe.register_craft(def)
    -- i know i know its a HACK: - it allows for registering crafts for craft types which haven't loaded in yet
    core.after(0, function()
        table.insert(reg_crafts, def)
        unified_inventory.register_craft(def)

        local type = def.type
        local craft_def = reg_craft_types[type]
        assert(craft_def, type .. ' is not a valid craft type')

        table.insert(reg_crafts_by_type[type], def)

        if craft_def.single then
            local item = ItemStack(def.items[1]) -- the only item
            def.input_count = item:get_count()
            def.input_name = item:get_name()

            item:set_count(1)
            reg_crafts_by_type_single[type][item:get_name()] = reg_crafts_by_type_single[type][item:get_name()] or {}
            table.insert(reg_crafts_by_type_single[type][item:get_name()], def)
        end
    end)
end

--- Returns (stack, count, decremented)?, slot? in `single` recipe types
--- Decremented is simply the input items if recipe is not of type single
--- and decremented is only for one count, not multiple, if that makes sense
--- Count is how many times it can do the recipe
---@return ItemStack?, integer?, integer|ItemStack[]?, integer?
function sbz_api.recipe.resolve_craft(item_or_list, type, is_list)
    local craft_def = reg_craft_types[type]
    assert(craft_def, type .. ' is not a valid craft type')

    if is_list and craft_def.single then
        for slot, stack in pairs(item_or_list) do
            local name, count, decremented = sbz_api.recipe.resolve_craft(stack, type, false)
            if name then return name, count, decremented, slot end
        end
        return
    end

    if craft_def.single then
        local item = ItemStack(item_or_list)
        local name = item:get_name()
        local count = item:get_count()
        local crafts = reg_crafts_by_type_single[type][name]
        if not crafts then return end

        local craft = crafts[math.random(1, #crafts)]
        local input_count = craft.input_count
        if input_count > count then return end
        return ItemStack(craft.output), math.floor(count / input_count), input_count
    end

    local list = item_or_list
    -- TODO: IF NEEDED: Optimize this
    local function inner_loop(craft)
        -- Need to compare list to craft.items
        -- Is this O(n^2): Yes, but ehh whatever i'm no leetcoder
        -- jokes aside this geniuenly sounds like a leetcode problem

        local decremented = {}
        local max_count = 65535 -- that's a lot ya know
        for ci, compare_item in pairs(craft.items) do
            compare_item = ItemStack(compare_item)
            local matched = false
            for li, item in pairs(list) do
                if item:get_name() == compare_item:get_name() then
                    matched = true
                    max_count = math.min(max_count, math.floor(item:get_count() / compare_item:get_count()))
                    if max_count < 1 then return end
                    decremented[li] = craft.items[ci]
                end
            end
            if not matched then return end
        end

        return ItemStack(craft.output), max_count, decremented
    end
    local crafts = reg_crafts_by_type[type]
    for _, craft in ipairs(crafts) do
        local name, count, decremented = inner_loop(craft)
        if name and count then return name, count, decremented end
    end
end

--- Gives you the possible crafts
--- Only "single" craft types supported for now
--- Optionally gives a slot as 3nd parameter, and success as 2nd
--- Useful for things like centrifuges
---@return table, boolean, integer?
function sbz_api.recipe.resolve_craft_raw_single(item_or_list, type, is_list)
    local craft_def = reg_craft_types[type]
    assert(craft_def, type .. ' is not a valid craft type')

    if is_list and craft_def.single then
        for slot, stack in pairs(item_or_list) do
            local crafts, success = sbz_api.recipe.resolve_craft_raw_single(stack, type, false)
            if success then return crafts, true, slot end
        end
        return {}, false
    end

    local item = ItemStack(item_or_list)
    local name = item:get_name()
    local count = item:get_count()
    local crafts = reg_crafts_by_type_single[type][name]
    if not crafts then return {}, false end
    return crafts, true
end

function sbz_api.recipe.get_all_crafts_of_type(type)
    return reg_crafts_by_type[type]
end
