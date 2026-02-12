quests = {}

function sbz_api.register_quest(def)
    quests[#quests + 1] = def
end

local quest_files = {
    'Introduction',
    'Emittrium',
    'Chemistry',
    'Storage',
    'Meteorites',
    'Organics',
    'Decorator',
    'Pipeworks_and_fluid_transport',
    'Reactor',
    'Jumpdrive',
    'Sensors',
    'Secrets',
    'Status_Effects',
}

--- Use markdown instead!
--- So sbz_api.quests_from_file_md
---@deprecated
function sbz_api.quests_from_file(path)
    table.foreach(assert(loadfile(path))(), sbz_api.register_quest, true)
end

function sbz_api.quests_from_file_md(path)
    local file = assert(io.open(path))
    local qdata = sbz_api.quest_parser.decode(file:read '*a')
    file:close()
    table.foreach(qdata, sbz_api.register_quest, true)
end

local t0 = core.get_us_time()
table.foreach(quest_files, function(name)
    sbz_api.quests_from_file_md(minetest.get_modpath 'sbz_progression' .. '/quests/' .. name .. '.md')
end, true)
sbz_api.register_quest({
    ["type"] = "secret",
    ["istoplevel"] = true,
    ["title"] = "Credits",
    ["text"] = 
    "Thank you for playing Skyblock: Zero. "
    .. "You demonstrated extreme logical thinking skills, planning skills, and invested probably at least a couple of hours into our game. "
    .. "We hope you enjoyed this current version, because there will be more coming. "
    .. "- Zander\n"
    .. "\n"

    .. "Below is a list of all the people who helped work on the game, optionally, along with a quote by the respective developer.\n"
    -- Note to developers: Feel free to add yourself to the list if you're new, along with a quote. 
    -- If you're already on the list, feel free to edit your quote as well. (But not other people's)

    .. "Developers & Contributors\n"
    .. "- Zander \"Removing Global Power is the worst thing to have happened to Skyblock: Zero\"\n"
    .. "- frogTheSecond\n"
    .. "- theidealist\n"
    .. "- birdlover32767\n"
    .. "- ACorp \"0 coolant - not great, not terrible\"\n"
    .. "- lnee\n"
    .. "- The4codeblocks\n"
    .. "- watilin\n"
    .. "- Aredron\n"
    .. "- 0je\n"
    .. "- JustAPotota\n"
    .. "- Kycilak\n"
    .. "- cx384\n"
    .. "- AbbyRead\n"
    .. "- jack-obrien\n"
    .. "- gamefreq0\n"
    .. "\n"

    .. "Submodule Contributors\n"
    .. "- SmallJoker\n"
    .. "- SwissalpS\n"
    .. "- lumberjackgames\n"
    .. "- Emojigit\n"
    .. "\n"

    .. "Translators\n"
    .. "There's not been any work to translate the game outside of English. Maybe your name will one day show up here?\n"
    .. "\n"

    .. "Menu & In-Game Music\n"
    .. "- 'Tragic ambient main menu' by Brandon Morris (Menu Music)\n"
    .. "- 'Cave Theme' by Brandon Morris\n"
    .. "- 'Background space track' by yd\n"
    .. "- 'Bleeding Out' by Brandon Morris\n"
    .. "- 'Factory Ambiance' by yd\n"
    .. "- 'Galactic Temple' by yd\n"
    .. "- 'A Choice With Many Regrets' by Tsorthan Grove"
    .. "\n"

    .. "Skybox was made by StumpyStrust.\n"
    .. "\n"

    .. "You've finished the Questbook, but the game has only just begun.\n"
    .. "",
})
core.log('action', 'Loading quests from markdown took: ' .. ((core.get_us_time() - t0) / 1000) .. 'ms')
