local S = core.get_translator('sbz_progression')

-- Returns the display title or text for a quest in the player's language,
-- falling back to the English default if no translation exists.
local function localized(quest, field, lang)
    local localized_field = field .. '_localized'
    if lang and quest[localized_field] and quest[localized_field][lang] then
        return quest[localized_field][lang]
    end
    return quest[field] -- English default
end

-- Gets the lang code for a player, defaulting to "en".
local function player_lang(player_name)
    local info = core.get_player_information(player_name)
    return (info and info.lang_code and info.lang_code ~= '') and info.lang_code or 'en'
end

local function get_quest_by_id(quest_id)
    for _, quest in ipairs(quests) do
        if quest.id == quest_id then return quest end
    end
end

local function combineWithAnd(list)
    local n = #list
    if n == 0 then
        return ''
    elseif n == 1 then
        return list[1]
    elseif n == 2 then
        return S('@1 and @2', list[1], list[2])
    else
        -- Produces "A, B, and C".
        -- Translators can reorder as needed via @1 and @2.
        return S('@1, and @2', table.concat(list, ', ', 1, n - 1), list[n])
    end
end

function unlock_achievement(player_name, achievement_id)
    local player = core.get_player_by_name(player_name)
    if not player then return end

    local meta = player:get_meta()
    if not is_achievement_unlocked(player_name, achievement_id) then
        meta:set_string(achievement_id, 'true')
        core.chat_send_player(player_name, S('Quest Completed: @1!', S(achievement_id)))

        local pos = player:get_pos()
        core.add_particlespawner {
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
            texture = 'organic_particle.png',
            glow = 10,
        }
    end
end

function revoke_achievement(player_name, achievement_id)
    local player = core.get_player_by_name(player_name)
    if not player then return end

    local meta = player:get_meta()
    if is_achievement_unlocked(player_name, achievement_id) then
        meta:set_string(achievement_id, '')
        core.chat_send_player(player_name, S('Quest revoked: @1', achievement_id))
    end
end

function is_achievement_unlocked(player_name, achievement_id)
    local player = core.get_player_by_name(player_name)
    if not player then return false end

    local meta = player:get_meta()
    if meta then
        return meta:get_string(achievement_id) == 'true'
    else
        return false
    end
end

function is_quest_available(player_name, quest_id)
    local quest = get_quest_by_id(quest_id)
    if quest == nil or quest.requires == nil then return true end

    for _, req_id in ipairs(quest.requires) do
        if not is_achievement_unlocked(player_name, req_id) then return false end
    end
    return true
end

-- Function to create the formspec
local function get_questbook_formspec(selected_quest_index, player_name, quests_to_show, search_text)
    local player_ref = core.get_player_by_name(player_name)
    if not player_ref then return '' end
    sbz_api.ui.set_player(player_ref)

    local lang = player_lang(player_name)

    local selected_quest = quests_to_show[selected_quest_index]
    local quest_count = #quests -- we subtract uncompletable quests from this later, like infotexts
    local completed_count = 0
    local available_count = 0

    search_text = search_text or ''
    local quest_list = {}

    local ins = function(element)
        table.insert(quest_list, element)
    end

    local default_indent = '1'
    if search_text ~= '' then default_indent = '0' end

    local pal = sbz_api.ui.get_theme().palette or sbz_api.default_palette

    for _, quest in ipairs(quests_to_show) do
        if quest.type == 'quest' then
            if is_achievement_unlocked(player_name, quest.id) then
                ins(pal.bright_green)
                ins(default_indent)
                ins '✓'
                ins(localized(quest, 'title', lang))
                completed_count = completed_count + 1
            elseif is_quest_available(player_name, quest.id) then
                ins(pal.light1)
                ins(default_indent)
                ins '►'
                ins(localized(quest, 'title', lang))
                available_count = available_count + 1
            else
                ins(pal.light4)
                ins(default_indent)
                ins '✕'
                ins(localized(quest, 'title', lang))
            end
        elseif quest.info == true then -- info text
            ins(pal.bright_blue)
            ins(default_indent)
            ins '!'
            ins(localized(quest, 'title', lang))
            quest_count = quest_count - 1
        elseif quest.type == 'text' then
            ins(pal.bright_aqua)
            ins '0'
            ins '≡'
            ins(localized(quest, 'title', lang))
            quest_count = quest_count - 1
        elseif quest.type == 'secret' then
            ins(pal.bright_purple)
            ins(quest.istoplevel and '0' or default_indent)
            ins '✪'
            if is_achievement_unlocked(player_name, quest.id) then
                ins(localized(quest, 'title', lang))
                completed_count = completed_count + 1
            else
                ins '???'
                available_count = available_count + 1
            end
        end
    end

    ---@diagnostic disable-next-line: cast-local-type
    quest_list = table.concat(quest_list, ',')

    local table_style = sbz_api.get_font_style(sbz_api.ui.get_player_and_theme_and_config())
    if table_style ~= '' then table_style = ('style_type[table%s]'):format(table_style) end

    local formspec = ([[
        formspec_version[7]
        size[17.25,12.8]
        padding[0.01,0.01]
        %s
        tablecolumns[color;tree,width=0.5;text;text]
        %s
        %s
        table[0.2,0.7;5.6,11.3;quest_list;%s;%s]
        field_close_on_enter[search;false]
        %s
        image_button[5.25,12;0.5,0.5;ui_search_icon.png;dummybutton;]
        image_button[5.75,12;0.5,0.5;ui_reset_icon.png;search_reset;]

		button[5.25,0.35;0.3,0.3;font_add;+]
		button[5.55,0.35;0.3,0.3;font_sub;-]
		tooltip[font_add;%s]
		tooltip[font_sub;%s]
]]):format(
        sbz_api.ui.hypertext(
            0.3,
            0.25,
            5.6,
            0.5,
            '',
            S('Quest List (✓ @1 / ► @2 / ✕ @3)', completed_count, available_count, quest_count - completed_count)
        ),
        sbz_api.ui.box_shadow(0.2, 0.7, 5.6, 11.3, 2),
        table_style,
        quest_list,
        selected_quest_index,
        sbz_api.ui.field(0.2, 12, 5.25, 0.5, 'search', '', search_text),
        core.formspec_escape(S('Makes font larger')),
        core.formspec_escape(S('Makes font smaller'))
    )
    formspec = formspec .. sbz_api.ui.box(5.85, 0.2, 11.2, 11.8)

    local font_size = player_ref:get_meta():get_int 'font_size'
    if font_size == 0 then font_size = 16 end -- the default font size according to some undocumented C++ luanti code
    -- thanks luanti

    --- so, this is something like hypertext[blabla;%s]
    --- where the %s gets filled in later, so dont worry about it
    local hypertext = ([[
    %s
    %s
    label[7.35,12.25;%s]
    ]]):format(
        sbz_api.ui.big_hypertext(6, 0.3, 100, 100, '', '%s'),
        sbz_api.ui.hypertext(
            6.1,
            1.3,
            10.8,
            10.3,
            '',
            ('<global size=%s><tag name=dash color=%s>%%s'):format(font_size, pal.bright_orange)
        ),
        '%s'
    )

    if selected_quest then
        if
            selected_quest.type == 'quest'
            or (selected_quest.type == 'secret' and is_achievement_unlocked(player_name, selected_quest.id))
        then
            formspec = formspec
                .. hypertext:format(
                    core.formspec_escape('<big>' .. localized(selected_quest, 'title', lang) .. '</big>'),
                    (
                        is_quest_available(player_name, selected_quest.id)
                        and core.formspec_escape(localized(selected_quest, 'text', lang))
                        or core.formspec_escape(S('Complete @1 to unlock.', combineWithAnd(selected_quest.requires)))
                    ),
                    (
                        is_achievement_unlocked(player_name, selected_quest.id)
                        and (selected_quest.type == 'secret' and core.formspec_escape(S("✔ Shhh... don't tell anyone :)")) or core.formspec_escape(S('✔ You have completed this Quest.')))
                        or core.formspec_escape(S('You have not completed this Quest.'))
                    )
                )
        elseif
            selected_quest.type == 'secret' and not is_achievement_unlocked(player_name, selected_quest.id)
        then
            formspec = formspec
                .. hypertext:format(
                    '???',
                    '',
                    core.formspec_escape(S('You have not completed this Quest.'))
                )
        elseif selected_quest.type == 'text' then
            formspec = formspec
                .. hypertext:format(
                    ('<style color=%s>'):format(pal.bright_aqua or '#9ab7fc') ..
                    localized(selected_quest, 'title', lang) .. '</style>',
                    (
                        is_quest_available(player_name, selected_quest.id)
                        and core.formspec_escape(localized(selected_quest, 'text', lang))
                        or core.formspec_escape(S('Complete @1 to unlock.', combineWithAnd(selected_quest.requires)))
                    ),
                    ''
                )
        end
    end

    if available_count == 1 and (quest_count - completed_count) == 1 then
        unlock_achievement(player_name, 'Credits')

        -- okay let me explain
        -- this will be called only once
        -- to refresh the questbook
        -- if i dont do this, the quest will be granted but show up as not complete in the book
        -- so by refreshing it once here, itll show up correct
        -- it looks so ugly though...
        return get_questbook_formspec(selected_quest_index, player_name, quests_to_show, search_text)
    end

    -- play page sound lol
    core.sound_play('questbook', {
        to_player = player_name,
        gain = 1,
    })
    sbz_api.ui.del_player()

    return formspec
end

-- Handle form submissions
core.register_on_player_receive_fields(function(player, formname, fields)
    if formname == 'questbook:main' then
        local name = player:get_player_name()
        local lang = player_lang(name)
        local meta = player:get_meta()
        local force_query = false
        if fields.search_reset then
            fields.search = ''
            force_query = true
        end

        if fields.font_add or fields.font_sub then
            local font_size = player:get_meta():get_int 'font_size'
            if font_size == 0 then font_size = 16 end

            if fields.font_add then
                font_size = font_size + 1
            else
                font_size = font_size - 1
            end
            font_size = sbz_api.clamp(font_size, 6, 24)
            player:get_meta():set_int('font_size', font_size)
        end

        if fields.quest_list or fields.search or force_query or (fields.font_add or fields.font_sub) then
            local event = core.explode_table_event(fields.quest_list)

            local selected_quest_index
            if event.row and event.row ~= 0 or (fields.search and fields.search ~= '') then
                selected_quest_index = event.row or 0
            else
                selected_quest_index = meta:get_int 'selected_quest_index'
            end
            meta:set_int('selected_quest_index', selected_quest_index)

            local filtered_quests = {}
            if fields.search and fields.search ~= '' then
                if fields.search == 'reachable' then -- When re-working this, don't forget to update the questbook, it's in the introduction questline, last infopage
                    for k, v in pairs(quests) do
                        if
                            is_quest_available(name, v.id)
                            and v.type == 'quest'
                            and is_achievement_unlocked(name, v.id) == false
                        then
                            filtered_quests[#filtered_quests + 1] = v
                        end
                    end
                else
                    local real_search = fields.search:lower()
                    local quests_with_holes = table.copy(quests)
                    for k, v in pairs(quests_with_holes) do
                        -- Search against the player's localized title so they can search in their own language
                        local title = localized(v, 'title', lang):lower()
                        if not title:find(real_search, 1, true) then quests_with_holes[k] = nil end
                    end
                    for i = 1, #quests do
                        if quests_with_holes[i] then filtered_quests[#filtered_quests + 1] = quests_with_holes[i] end
                    end
                end
            else
                filtered_quests = table.copy(quests)
            end
            core.show_formspec(
                name,
                'questbook:main',
                get_questbook_formspec(selected_quest_index, player:get_player_name(), filtered_quests, fields.search)
            )
        end
    end
end)

core.register_craftitem('sbz_progression:questbook', {
    description = S('Quest Book'),
    inventory_image = 'questbook.png',
    stack_max = 1,
    on_use = function(itemstack, player, pointed_thing)
        local selected_quest_index = 1
        local meta = player:get_meta()
        if meta then selected_quest_index = meta:get_int 'selected_quest_index' end
        if selected_quest_index == 0 then selected_quest_index = 1 end

        core.show_formspec(
            player:get_player_name(),
            'questbook:main',
            get_questbook_formspec(selected_quest_index, player:get_player_name(), quests)
        )
    end,
})
