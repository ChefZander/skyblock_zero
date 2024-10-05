local function getquestbyname(questname)
    for i, quest in ipairs(quests) do
        if quest.title == questname then
            return quest
        end
    end
end

local function combineWithAnd(list)
    local listLength = #list

    if listLength == 0 then
        return ""
    elseif listLength == 1 then
        return list[1]
    elseif listLength == 2 then
        return list[1] .. " and " .. list[2]
    else
        local combinedString = table.concat(list, ", ", 1, listLength - 1)
        combinedString = combinedString .. ", and " .. list[listLength]
        return combinedString
    end
end

function unlock_achievement(player_name, achievement_id)
    local player = minetest.get_player_by_name(player_name)
    if not player then
        return
    end

    local meta = player:get_meta()
    if not is_achievement_unlocked(player_name, achievement_id) then
        meta:set_string(achievement_id, "true")
        minetest.chat_send_player(player_name, "Quest Completed: " .. achievement_id .. "!")

        local pos = player:get_pos()
        minetest.add_particlespawner({
            amount = 50,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -5, y = -5, z = -5 },
            maxvel = { x = 5, y = 5, z = 5 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 15,
            maxexptime = 25,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "organic_particle.png",
            glow = 10
        })
    end
end

function revoke_achievement(player_name, achievement_id)
    local player = minetest.get_player_by_name(player_name)
    if not player then
        return
    end

    local meta = player:get_meta()
    if is_achievement_unlocked(player_name, achievement_id) then
        meta:set_string(achievement_id, "")
        minetest.chat_send_player(player_name, "Quest revoked: " .. achievement_id)
    end
end

function is_achievement_unlocked(player_name, achievement_id)
    local player = minetest.get_player_by_name(player_name)
    if not player then
        return false
    end

    local meta = player:get_meta()
    if meta then
        return meta:get_string(achievement_id) == "true"
    else
        return false
    end
end

function is_quest_available(player_name, quest_id)
    local quest = getquestbyname(quest_id)
    if quest.requires == nil then return true end

    for i, questname in ipairs(quest.requires) do
        if is_achievement_unlocked(player_name, questname) == false then
            return false
        end
    end
    return true
end

-- Function to create the formspec
local function get_questbook_formspec(selected_quest_index, player_name)
    local selected_quest = quests[selected_quest_index]
    local quest_list = ""

    for i, quest in ipairs(quests) do
        if quest.type == "quest" then
            if is_achievement_unlocked(player_name, quest.title) then
                quest_list = quest_list .. "✓ " .. quest.title .. ","
            elseif is_quest_available(player_name, quest.title) then
                quest_list = quest_list .. "► " .. quest.title .. ","
            else
                quest_list = quest_list .. " ✕ " .. quest.title .. ","
            end
        elseif quest.type == "text" then
            quest_list = quest_list .. "≡ " .. quest.title .. ","
        elseif quest.type == "secret" and is_achievement_unlocked(player_name, quest.title) then
            quest_list = quest_list .. "✪ " .. quest.title .. ","
        elseif quest.type == "secret" and is_achievement_unlocked(player_name, quest.title) == false then
            quest_list = quest_list .. "✪ ???,"
        end
    end
    quest_list = quest_list:sub(1, -2)

    local formspec = "formspec_version[7]" ..
        "size[12,8]" ..
        "label[0.1,0.3;Quest List]" ..
        "textlist[0,0.7;5.8,7;quest_list;" .. quest_list .. ";" .. selected_quest_index .. "]"

    if selected_quest.type == "quest" or (selected_quest.type == "secret" and is_achievement_unlocked(player_name, selected_quest.title)) then
        formspec = formspec ..
            "hypertext[6,0.3;100,100;;\\<big\\>" .. minetest.formspec_escape(selected_quest.title) .. "]" ..
            "textarea[6,1.3;5.8,5;;;" ..
            (is_quest_available(player_name, selected_quest.title) and minetest.formspec_escape(selected_quest.text) or "Complete " .. combineWithAnd(selected_quest.requires) .. " to unlock.") ..
            "]" .. -- minetest.formspec_escape(selected_quest.text)
            "label[6,7.2;" ..
            (is_achievement_unlocked(player_name, selected_quest.title) and "✔️ You have completed this Quest." or "You have not completed this Quest.") ..
            "]"
    elseif selected_quest.type == "secret" and is_achievement_unlocked(player_name, selected_quest.title) == false then
        formspec = formspec ..
            "label[6,0.3;Secret Quest]" ..
            "label[6,0.7;Title: ???]" ..
            "textarea[6,1.2;5.8,5;;;" .. "???" .. "]" .. -- minetest.formspec_escape(selected_quest.text)
            "label[6,7.2;" ..
            (is_achievement_unlocked(player_name, selected_quest.title) and "✔️ You have completed this Quest." or "You have not completed this Quest.") ..
            "]"
    elseif selected_quest.type == "text" then
        formspec = formspec ..
            "textarea[6,0.3;5.8,5;;;" ..
            (is_quest_available(player_name, selected_quest.title) and minetest.formspec_escape(selected_quest.text) or "Complete " .. combineWithAnd(selected_quest.requires) .. " to unlock.") ..
            "]"
    end

    -- play page sound lol

    minetest.sound_play("questbook", {
        to_player = player_name,
        gain = 1.0,
    })

    return formspec
end

-- Handle form submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "questbook:main" then
        if fields.quest_list then
            local event = minetest.explode_textlist_event(fields.quest_list)
            if event.type == "CHG" then
                local selected_quest_index = event.index
                local name = player:get_player_name()

                -- set selected quest index
                local meta = player:get_meta()
                if meta then
                    meta:set_int("selected_quest_index", selected_quest_index)
                end

                minetest.show_formspec(name, "questbook:main",
                    get_questbook_formspec(selected_quest_index, player:get_player_name()))
            end
        end
    end
end)


minetest.register_craftitem("sbz_progression:questbook", {
    description = "Quest Book",
    inventory_image = "questbook.png",
    stack_max = 1,
    on_use = function(itemstack, player, pointed_thing)
        local selected_quest_index = 1
        local meta = player:get_meta()
        if meta then
            selected_quest_index = meta:get_int("selected_quest_index")
        end
        if selected_quest_index == 0 then selected_quest_index = 1 end

        minetest.show_formspec(player:get_player_name(), "questbook:main",
            get_questbook_formspec(selected_quest_index, player:get_player_name()))
    end
})
