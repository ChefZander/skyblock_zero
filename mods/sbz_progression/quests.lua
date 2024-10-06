quests = {}

function sbz_api.register_quest(def)
    quests[#quests + 1] = def
end

local quest_files = {
    [1] = "Introduction",
    [2] = "Emittrium",
    [3] = "Chemistry",
    [4] = "Organics",
    [5] = "Decorator",
    [6] = "Pipeworks_and_fluid_transport",
    [7] = "Reactor",
    [8] = "Completionist"
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
