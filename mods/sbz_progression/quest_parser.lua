--[[
    Reason:
        1) The current implementation of how we write quests makes them highly unenjoyable to write for me and its easy to write bugs
        2) Why not?
            > "It overcomplicates the code!"
            It really doesn't, if you want to add something, add it in decode_text_and_meta function, where its decoding the meta

    What does this actually do:
        It is technically a serializer/deserializer that turns quests into markdown or markdown into quests, i think?

    Syntax:
Stuff above gets ignored, could be like a disclaimer that this contains spoilers

# Some Questline name
Some questline description
## Some quest name
### ID: qid_some_quest_name
### Text
Some quest text
### Meta
Requires: qid_something
## Info: Some info name
### ID: qid_some_info_name
Hello! Yes this is an info

The ### ID: line must appear immediately after every ## header.
It is the stable, permanent key for the quest and must never be changed after release.
The ## title above it is the human-readable display name and may be translated freely.

]]

--local S = core.get_translator('sbz_progression')
-- This file processes internal data and contains no player-facing strings.

local markdown_parser = {}

local questline_fmt = '\n# %s\n'
local quest_fmt = '\n## %s\n'
local id_fmt = '### ID: %s\n'
local info_fmt = '## Info: %s\n'
local secret_fmt = '## Secret: %s\n'

local meta_fmt = '\n### %s\n'
local requires_fmt = 'Requires: %s'
local requires_sep = ', '
local requires_sep_trim = requires_sep:trim()

local function ltrim(text) -- trim each line separately
    return table.concat(
        table.foreach(text:split('\n', true), function(v)
            return v:trim()
        end, true),
        '\n'
    )
end

function markdown_parser.encode_text(text)
    text = ltrim(text) -- ""mutating"" immutable variables like a pro
        :gsub('\n', '  \n')
        :gsub('</?b>', '**')
        :gsub('</?mono>', '`')
        :gsub('<', '\\<')
        :gsub('>', '\\>')

    return text
end

local encode_text = markdown_parser.encode_text
function markdown_parser.encode(quests)
    local result = {}
    for k, v in ipairs(quests) do
        if v.type == 'text' then
            if v.info then -- Case: Infopage
                result[#result + 1] = info_fmt:format(v.title)
                result[#result + 1] = id_fmt:format(v.id)
                result[#result + 1] = meta_fmt:format 'Text'
                result[#result + 1] = encode_text(v.text)
                result[#result + 1] = meta_fmt:format 'Meta'
                if v.requires then
                    result[#result + 1] = requires_fmt:format(table.concat(v.requires, requires_sep))
                else
                    result[#result + 1] = 'Requires: '
                end
            else -- Case: Questline banner
                result[#result + 1] = questline_fmt:format(v.title)
                result[#result + 1] = v.text
            end
        elseif v.type == 'quest' then
            result[#result + 1] = quest_fmt:format(v.title)
            result[#result + 1] = id_fmt:format(v.id)
            result[#result + 1] = meta_fmt:format 'Text'
            result[#result + 1] = encode_text(v.text)
            result[#result + 1] = meta_fmt:format 'Meta'
            if v.requires then
                result[#result + 1] = requires_fmt:format(table.concat(v.requires, requires_sep))
            else
                result[#result + 1] = 'Requires: '
            end
        elseif v.type == 'secret' then
            result[#result + 1] = secret_fmt:format(v.title)
            result[#result + 1] = id_fmt:format(v.id)
            result[#result + 1] = meta_fmt:format 'Text'
            result[#result + 1] = encode_text(v.text)
            result[#result + 1] = meta_fmt:format 'Meta'
            if v.requires then
                result[#result + 1] = requires_fmt:format(table.concat(v.requires, requires_sep))
            else
                result[#result + 1] = 'Requires: '
            end
        else
            error('Unsupported quest type: ' .. tostring(v.type))
        end
    end
    return table.concat(result, '\n'):gsub('\n\n\n', '\n\n')
end

local starts_with = function(str1, target)
    return string.sub(str1, 1, #target) == target
end

-- Job: markdown -> mt hypertext, but specifically made to decode quest text, so "#"'s won't be supported
function markdown_parser.decode_text(text)
    local closing_tag = false
    text = text
        :gsub('%*%*', function(_)
            if closing_tag == true then
                closing_tag = false
                return '</b>'
            else
                closing_tag = true
                return '<b>'
            end
        end)
        :gsub('\\<', '<')
        :gsub('\\>', '>')
        :gsub('`', function(_)
            if closing_tag == true then
                closing_tag = false
                return '</mono>'
            else
                closing_tag = true
                return '<mono>'
            end
        end)
        -- highlights all "*", "-", "<digit>)" or "digit." with <dash>
        :gsub('%-', '<dash>-</dash>')
        :gsub('%*', '<dash>*</dash>')
        :gsub('%d+[%.%)]', function(match) -- mystery
            return ('<dash>%s</dash>'):format(match)
        end)
    return text
end

-- Reads the ### ID:, ### Text, and ### Meta blocks for a quest.
-- The ### ID: line must be the first ### encountered after a ## header.
local function decode_text_and_meta(lines, line_index, quest)
    local got_id
    local got_text
    local line
    local break_out_of_main_loop = false
    while true do
        line_index = line_index + 1
        line = lines[line_index]
        if line == nil then break end
        if starts_with(line, '### ID:') then
            quest.id = string.sub(line, #'### ID:' + 1):trim()
            assert(
                starts_with(quest.id, 'qid_'),
                '[parser]: Quest "' .. quest.title .. '" has an ### ID: that does not start with qid_: ' .. quest.id
            )
            got_id = true
        elseif starts_with(line, '### Meta') then
            assert(
                got_id,
                '[parser]: Quest "' .. quest.title .. '" is missing ### ID: before ### Meta'
            )
            assert(
                got_text,
                '[parser]: Quest: '
                .. quest.title
                .. ": I know, I'm strict, but you need to have the ### Text BEFORE the ### Meta"
            )
            while true do
                line_index = line_index + 1
                line = lines[line_index]
                if line == nil then break end
                if starts_with(line, 'Requires: ') then
                    quest.requires = table.foreach(
                        string.split(string.sub(line, #'Requires: ' + 1), requires_sep_trim, false, math.huge, false),
                        string.trim,
                        true
                    )
                end
                if starts_with(line, '#') then
                    line_index = line_index - 1
                    break_out_of_main_loop = true
                    break
                end
            end
        elseif starts_with(line, '### Text') then
            local text = {}
            while true do
                line_index = line_index + 1
                line = lines[line_index]
                if line == nil then break end
                if starts_with(line, '#') then
                    line_index = line_index - 1
                    break
                end
                text[#text + 1] = line
            end
            quest.text = markdown_parser.decode_text(table.concat(text, '\n'))
            got_text = true
        end
        if break_out_of_main_loop then break end
    end
    return line_index
end

function markdown_parser.decode(text)
    local quests = {}
    local lines = text:split('\n', true)
    local line_index = 1
    while line_index <= #lines do
        local line = lines[line_index]
        local quest = {}
        local write_to_quests = false
        if starts_with(line, '## Info: ') then
            quest.title = string.sub(line, #'## Info: ' + 1):trim()
            quest.type  = 'text'
            quest.info  = true
            line_index  = decode_text_and_meta(lines, line_index, quest)
            write_to_quests = true
        elseif starts_with(line, '## ') then
            local name = string.sub(line, #'## ' + 1)
            local secret = false
            if starts_with(line, '## Secret: ') then
                name   = string.sub(line, #'## Secret: ' + 1)
                secret = true
            end
            quest.title = name:trim() -- display text; may be translated freely
            quest.type  = secret and 'secret' or 'quest'
            -- quest.id is read from ### ID: inside decode_text_and_meta
            line_index  = decode_text_and_meta(lines, line_index, quest)
            assert(
                quest.id,
                '[parser]: Quest "' .. quest.title .. '" is missing a ### ID: line'
            )
            write_to_quests = true
        elseif starts_with(line, '# ') then
            -- Questline banner: no ID required, not part of the progression graph
            quest.title = string.sub(line, #'# ' + 1):trim()
            quest.id    = quest.title -- banners use title as id; they are never referenced by Requires:
            quest.type  = 'text'
            local desc  = {}

            while true do
                line_index = line_index + 1
                line = lines[line_index]
                if line == nil then break end
                if starts_with(line, '#') then
                    line_index = line_index - 1
                    break
                end
                desc[#desc + 1] = line
            end
            quest.text = markdown_parser.decode_text(table.concat(desc, '\n'))
            write_to_quests = true
        end
        if write_to_quests then quests[#quests + 1] = quest end
        line_index = line_index + 1
    end
    return quests
end

sbz_api.quest_parser = markdown_parser
