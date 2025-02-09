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
local function get_questbook_formspec(selected_quest_index, player_name, quests_to_show, search_text)
    local selected_quest = quests_to_show[selected_quest_index]
    search_text = search_text or ""
    local quest_list = {}

    for i, quest in ipairs(quests_to_show) do
        if quest.type == "quest" then
            if is_achievement_unlocked(player_name, quest.title) then
                quest_list[#quest_list + 1] = "✓ " .. quest.title
            elseif is_quest_available(player_name, quest.title) then
                quest_list[#quest_list + 1] = "► " .. quest.title
            else
                quest_list[#quest_list + 1] = " ✕ " .. quest.title
            end
        elseif quest.type == "text" then
            quest_list[#quest_list + 1] = "≡ " .. quest.title
        elseif quest.type == "secret" and is_achievement_unlocked(player_name, quest.title) then
            quest_list[#quest_list + 1] = "✪ " .. quest.title
        elseif quest.type == "secret" and is_achievement_unlocked(player_name, quest.title) == false then
            quest_list[#quest_list + 1] = "✪ ???"
        end
    end
    ---@diagnostic disable-next-line: cast-local-type
    quest_list = table.concat(quest_list, ",")

    local formspec = ([[
        formspec_version[7]
        size[17.25,13.25]
        label[0.1,0.3;Quest List]
        textlist[0,0.7;5.8,11.3;quest_list;%s;%s]
        field_close_on_enter[search;false]
        field[0,12;5.25,0.85;search;;%s]
        image_button[5.25,12;0.85,0.85;ui_search_icon.png;dummybutton;]
        image_button[6.1,12;0.85,0.85;ui_reset_icon.png;search_reset;]
]]):format(quest_list, selected_quest_index, core.formspec_escape(search_text))

    if selected_quest then
        if selected_quest.type == "quest" or (selected_quest.type == "secret" and is_achievement_unlocked(player_name, selected_quest.title)) then
            formspec = formspec .. ([[
            hypertext[6,0.3;69,420;;%s]
            hypertext[6,1.3;9.8,9.5;;%s]
            label[6,11.3;%s]
    ]]):format(minetest.formspec_escape("<big>" .. selected_quest.title .. "</big>"),
                (is_quest_available(player_name, selected_quest.title) and minetest.formspec_escape(selected_quest.text) or "Complete " .. combineWithAnd(selected_quest.requires) .. " to unlock."),
                (is_achievement_unlocked(player_name, selected_quest.title) and "✔️ You have completed this Quest." or "You have not completed this Quest.")
            )
        elseif selected_quest.type == "secret" and is_achievement_unlocked(player_name, selected_quest.title) == false then
            formspec = formspec .. ([[
        hypertext[6,0.3;69,420;;<big>???]
        textarea[6,1.3;9.8,9.5;;;???]
        label[6,11.3;%s]
    ]]):format((is_achievement_unlocked(player_name, selected_quest.title) and "✔️ You have completed this Quest." or "You have not completed this Quest."))
        elseif selected_quest.type == "text" then
            formspec = formspec ..
                ([[textarea[6,0.3;9.8,9.5;;;%s] ]]):format((is_quest_available(player_name, selected_quest.title) and minetest.formspec_escape(selected_quest.text) or "Complete " .. combineWithAnd(selected_quest.requires) .. " to unlock."))
        end
    end

    -- play page sound lol
    minetest.sound_play("questbook", {
        to_player = player_name,
        gain = 1,
    })

    return formspec
end

-- Handle form submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "questbook:main" then
        local name = player:get_player_name()
        local meta = player:get_meta()
        local force_query = false
        if fields.search_reset then
            fields.search = ""
            force_query = true
        end

        if fields.quest_list or (fields.search and fields.search ~= "") or force_query then
            local event = minetest.explode_textlist_event(fields.quest_list)
            local selected_quest_index = event.index or meta:get_int("selected_quest_index")

            -- set selected quest index
            if meta then
                meta:set_int("selected_quest_index", selected_quest_index)
            end

            local filtered_quests = {}
            if fields.search and fields.search ~= "" then
                local real_search = fields.search:lower()
                local quests_with_holes = table.copy(quests)
                for k, v in pairs(quests_with_holes) do
                    local title = v.title:lower()
                    if not title:find(real_search, 1, true) then
                        quests_with_holes[k] = nil
                    end
                end
                for i = 1, #quests do
                    if quests_with_holes[i] then
                        filtered_quests[#filtered_quests + 1] = quests_with_holes[i]
                    end
                end
            else
                filtered_quests = table.copy(quests)
            end
            minetest.show_formspec(name, "questbook:main",
                get_questbook_formspec(selected_quest_index, player:get_player_name(), filtered_quests, fields
                    .search))
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
            get_questbook_formspec(selected_quest_index, player:get_player_name(), quests))
    end
})
