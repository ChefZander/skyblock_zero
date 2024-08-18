minetest.log("action", "sbz progression: init")
local modpath = minetest.get_modpath("sbz_progression")

dofile(modpath.."/questbook.lua")
dofile(modpath.."/annoy.lua")

function displayDialougeLine(player_name, text)
    minetest.chat_send_player(player_name, "⌠ " .. text .. " ⌡")
    minetest.sound_play("dialouge", {
        to_player = player_name,
        gain = 1.0,
    })
end
function displayGlobalDialougeLine(text)
    minetest.chat_send_all("⌠ " .. text .. " ⌡")
    minetest.sound_play("dialouge", {
        gain = 1.0,
    })
end

minetest.register_chatcommand("cheat_hacker", {
    description = "Cheat haguh",
    privs = {},
    func = function(name, param)
        if not name == "zander" then return end -- if youre a modder, change this to your name to allow for easier testing
        unlock_achievement(name, param)
        displayDialougeLine(name, "Cheat haguh")
    end,
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    if itemstack:get_name() == "sbz_resources:matter_blob" then
        unlock_achievement(player:get_player_name(), "A bigger platform")


    elseif itemstack:get_name() == "sbz_resources:antimatter_dust" then
        unlock_achievement(player:get_player_name(), "Antimatter")


    elseif itemstack:get_name() == "sbz_resources:matter_annihilator" then
        unlock_achievement(player:get_player_name(), "Annihilator")


    elseif itemstack:get_name() == "sbz_resources:simple_charged_field" then
        unlock_achievement(player:get_player_name(), "Charged Field")


    elseif itemstack:get_name() == "sbz_resources:simple_matter_extractor" then
        unlock_achievement(player:get_player_name(), "Automation")


    elseif itemstack:get_name() == "sbz_resources:advanced_matter_extractor" then
        unlock_achievement(player:get_player_name(), "Advanced Extractors")


    elseif itemstack:get_name() == "sbz_resources:simple_circuit" then
        unlock_achievement(player:get_player_name(), "Circuitry")


    elseif itemstack:get_name() == "sbz_resources:simple_charge_generator" then
        unlock_achievement(player:get_player_name(), "Generators")


    elseif itemstack:get_name() == "sbz_resources:matter_plate" then
        unlock_achievement(player:get_player_name(), "Matter Plates")


    elseif itemstack:get_name() == "sbz_resources:retaining_circuit" then
        unlock_achievement(player:get_player_name(), "Retaining Circuits")


    elseif itemstack:get_name() == "sbz_resources:storinator" then
        unlock_achievement(player:get_player_name(), "Storinators")


    elseif itemstack:get_name() == "sbz_resources:emitter_imitator" then
        unlock_achievement(player:get_player_name(), "Emitter Immitators")


    elseif itemstack:get_name() == "sbz_resources:pebble" then
        unlock_achievement(player:get_player_name(), "Pretty Pebbles")


    elseif itemstack:get_name() == "sbz_resources:stone" then
        unlock_achievement(player:get_player_name(), "Concrete Plan")


    elseif itemstack:get_name() == "sbz_decor:photonlamp" then
        unlock_achievement(player:get_player_name(), "Photon Lamps")


    elseif itemstack:get_name() == "sbz_resources:emittirum_circuit" then
        unlock_achievement(player:get_player_name(), "Emittrium Circuits")


    elseif itemstack:get_name() == "sbz_resources:angels_wing" then
        unlock_achievement(player:get_player_name(), "Angel's Wing")


    elseif itemstack:get_name() == "sbz_resources:battery" then
        unlock_achievement(player:get_player_name(), "Batteries")
    end
end)

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        if pos.y < -100 then
            unlock_achievement(player:get_player_name(), "Emptiness")
        end
        if pos.y < -110 then
            displayDialougeLine(player:get_player_name(), "You fell off the platform.")
            player:set_pos({x = 0, y = 1, z = 0})
        end
    end
end)