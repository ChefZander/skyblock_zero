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
    "Completionist",
}

local function foreach(t, f)
    for k, v in ipairs(t) do f(v) end
end

function sbz_api.quests_from_file(path)
    foreach(assert(loadfile(path))(), sbz_api.register_quest)
end

foreach(quest_files, function(name)
    sbz_api.quests_from_file(minetest.get_modpath("sbz_progression") .. "/quests/" .. name .. ".lua")
end)
