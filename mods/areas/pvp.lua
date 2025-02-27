--[[
Hello, this was copied from https://github.com/BlockySurvival/areas/commit/085d10041da9e81d4c3fe309ccf7cdb05fa2b1f3
also https://github.com/BlockySurvival/areas/commit/dacfe5fbad7ae3d2f32a897fde8e4107326c9f5c too
]]
minetest.register_chatcommand("toggle_area_pvp", {
    description = "Toggle PvP in an area",
    params = "<ID>",
    func = function(name, param)
        local id = tonumber(param)
        if not id then
            return false, "Invalid usage, see /help toggle_area_pvp."
        end
        if not areas:isAreaOwner(id, name) then
            return false, "Area " .. id .. " does not exist"
                .. " or is not owned by you."
        end
        local canPvP = not areas.areas[id].canPvP
        -- Save false as nil to avoid inflating the DB.
        areas.areas[id].canPvP = canPvP or nil
        areas:save()
        return true, ("PvP is %s in Area."):format(canPvP and "enabled" or "disabled")
    end
})

local function punchplayer_func(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, no_dm)
    -- If it's a mob, deal damage as usual
    if hitter == nil then return false end
    if not hitter:is_player() then
        return false
    end
    -- Check if the victim is in an area with allowed PvP or in an unprotected area
    local inAreas = areas:getAreasAtPos(player:get_pos()) -- replaced hitter:getpos() with player:getpos(), honestly, would not be surprized if thats a bug on bls still
    -- If the table is empty, PvP is allowed
    if not next(inAreas) then
        return false
    end
    -- Do any of the areas have allowed PvP?
    for id, area in pairs(inAreas) do
        if area.canPvP then
            return false
        end
    end
    -- Otherwise, it doesn't do damage
    if no_dm ~= nil then
        minetest.chat_send_player(hitter:get_player_name(), "PvP is not allowed in this area!")
    end
    return true
end

minetest.register_on_punchplayer(punchplayer_func)

-- i added
local knockback = core.calculate_knockback
function core.calculate_knockback(player, hitter, tflp, tool_capabilities, dir, distance, damage)
    if punchplayer_func(player, hitter, tflp, tool_capabilities, dir, damage, true) == true then
        return vector.zero()
    end
    return knockback(player, hitter, tflp, tool_capabilities, dir, distance, damage)
end
