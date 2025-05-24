quests = {}

function sbz_api.register_quest(def)
    quests[#quests + 1] = def
end

local quest_files = {
    "Introduction",
    "Emittrium",
    "Chemistry",
    "Storage",
    "Meteorites",
    "Organics",
    "Decorator",
    "Pipeworks_and_fluid_transport",
    "Reactor",
    "Jumpdrive",
    "Sensors",
    "Completionist",
    "Status_Effects",
}


--- Use markdown instead!
--- So sbz_api.quests_from_file_md
---@deprecated
function sbz_api.quests_from_file(path)
    table.foreach(assert(loadfile(path))(), sbz_api.register_quest, true)
end

function sbz_api.quests_from_file_md(path)
    local file = assert(io.open(path))
    local qdata = sbz_api.quest_parser.decode(file:read("*a"))
    file:close()
    table.foreach(qdata, sbz_api.register_quest, true)
end

local t0 = core.get_us_time()
table.foreach(quest_files, function(name)
    sbz_api.quests_from_file_md(minetest.get_modpath("sbz_progression") .. "/quests/" .. name .. ".md")
end, true)
core.log("action", "Loading quests from markdown took: " .. ((core.get_us_time() - t0) / 1000) .. "ms")
