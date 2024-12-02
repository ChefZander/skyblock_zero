local max_attract = 10

sbz_api.register_machine("sbz_logic_devices:luanium_attractor", {
    description = "Luanium Meteorite Attractor",
    info_extra = "At this point it might as well be a black hole...",
    tiles = { "luanium_attractor.png" },
    groups = { ui_logic = 1, matter = 1, charged = 1, sbz_machine_subticking = 1 },
    on_logic_send = function(pos, msg, from_pos)
        if type(msg) ~= "table" then return end
        if type(msg.attract) ~= "number" then return end
        if msg.attract ~= msg.attract then return end
        msg.attract = math.max(-max_attract, math.min(max_attract, msg.attract))
        if msg.type == nil or msg.type == "manual" then
            sbz_api.attract_meteorites(pos, 1, msg.attract)
        else
            minetest.get_meta(pos):set_float("attract", msg.attract)
        end
    end,
    action_subtick = function(pos, node, meta, supply, demand)
        local attract = meta:get_float("attract")
        local time = meta:get_float("time")
        if time == 0 then
            time = os.clock()
            meta:set_float("time", time)
        end

        local dtime = math.abs(time - os.clock())
        meta:set_float("time", os.clock())
        if attract == 0 then
            meta:set_string("infotext", "Idle")
            return 0
        else
            if supply > demand + math.abs((attract * 10)) then
                meta:set_string("infotext", "Working, power use: " .. math.abs(attract * 10) .. "Cj")
                sbz_api.attract_meteorites(pos, dtime, attract)
            else
                meta:set_string("infotext", "Not enough power")
            end
            return math.floor(math.abs(attract * 10))
        end
    end,
    action = function() return 0 end,
})

minetest.register_craft {
    output = "sbz_logic_devices:luanium_attractor",
    recipe = {
        { "sbz_resources:luanium", "sbz_meteorites:gravitational_attractor", "sbz_resources:luanium" },
        { "sbz_resources:luanium", "sbz_resources:lua_chip",                 "sbz_resources:luanium" },
        { "sbz_resources:luanium", "sbz_meteorites:gravitational_repulsor",  "sbz_resources:luanium" }
    },
}
