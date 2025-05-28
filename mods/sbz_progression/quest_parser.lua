--[[
    Reason:
        1) The current implementation of how we write quests makes them highly unenjoyable to write for me and its easy to write bugs
        2) Why not?
            > "It overcomplicates the code!"
            It really doesn't, if you want to add something, add it in decode_text_and_meta function, where its decoding the meta

    What does this actually do:
        It is technically a serializer/deserializer that turns quests into markdown or markdown into quests

    Syntax:
Stuff above gets ignored, could be like a disclaimer that this contains spoilers
# Some Questline name
Some questline description
## Some quest name
### Text
Some quest text
### Meta
Requires: Something
## Info: Some info name
Hello! Yes this is an info

Oh and! Whatever you do, don't let a windows user edit a quests.md file
Don't let them add \cr

Also! This is a strict format, it can throw errors if you got things wrong...
i mean... most things... should... i hope...


Anyway zander i know you will still complain

]]

local markdown_parser = {}


local questline_fmt = "\n# %s\n"
local quest_fmt = "\n## %s\n"
local info_fmt = quest_fmt:format("Info: %s")
local secret_fmt = quest_fmt:format("Secret: %s")

local meta_fmt = "\n### %s\n"
local requires_fmt = "Requires: %s"
local requires_sep = ", "
local requires_sep_trim = requires_sep:trim()

local function ltrim(text) -- trim each line seperately
    return table.concat(table.foreach(text:split("\n", true), function(v) return v:trim() end, true), "\n")
end

function markdown_parser.encode_text(text)
    text = ltrim(text) -- ""mutating"" immutable variables like a pro
        :gsub("\n", "  \n")
        :gsub("</?b>", "**")
        :gsub("</?mono>", "`")
        :gsub("<", "\\<"):gsub(">", "\\>")

    return text
end

local encode_text = markdown_parser.encode_text
function markdown_parser.encode(quests)
    local result = {}
    for k, v in ipairs(quests) do
        if v.type == "text" then
            if v.info then -- Case: Infopage (more similar to a quest)
                result[#result + 1] = info_fmt:format(v.title)
                result[#result + 1] = meta_fmt:format("Text")
                result[#result + 1] = encode_text(v.text)
                result[#result + 1] = meta_fmt:format("Meta")
                if v.requires then
                    result[#result + 1] = requires_fmt:format(table.concat(v.requires, requires_sep))
                else
                    result[#result + 1] = "Requires: "
                end
            else -- Case: Questline
                result[#result + 1] = questline_fmt:format(v.title)
                result[#result + 1] = v.text
            end
        elseif v.type == "quest" then
            result[#result + 1] = quest_fmt:format(v.title)
            result[#result + 1] = meta_fmt:format("Text")
            result[#result + 1] = encode_text(v.text)
            result[#result + 1] = meta_fmt:format("Meta")
            if v.requires then
                result[#result + 1] = requires_fmt:format(table.concat(v.requires, requires_sep))
            else
                result[#result + 1] = "Requires: "
            end
        elseif v.type == "secret" then
            result[#result + 1] = secret_fmt:format(v.title)
            result[#result + 1] = meta_fmt:format("Text")
            result[#result + 1] = encode_text(v.text)
            result[#result + 1] = meta_fmt:format("Meta")
            if v.requires then
                result[#result + 1] = requires_fmt:format(table.concat(v.requires, requires_sep))
            else
                result[#result + 1] = "Requires: "
            end
        else
            error("Unsupported quest type: " .. tostring(v.type))
        end
    end
    return table.concat(result, "\n"):gsub("\n\n\n", "\n\n")
end

local starts_with = function(str1, target)
    return string.sub(str1, 1, #target) == target
end

-- Job: markdown -> mt hypertext, but specifically made to decode quest text, so "#"'s won't be supported
function markdown_parser.decode_text(text)
    local closing_tag = false
    text = text:gsub("%*%*", function(match)
        if closing_tag == true then
            closing_tag = false
            return "</b>"
        else
            closing_tag = true
            return "<b>"
        end
    end):gsub("\\<", "<"):gsub("\\>", ">"):gsub("`", function(match)
        if closing_tag == true then
            closing_tag = false
            return "</mono>"
        else
            closing_tag = true
            return "<mono>"
        end
    end)
    return text
end

local function decode_text_and_meta(lines, line_index, quest)
    local got_text
    local line
    local break_out_of_main_loop = false
    while true do
        line_index = line_index + 1
        line = lines[line_index]
        if line == nil then break end
        if starts_with(line, "### Meta") then
            assert(got_text,
                "[parser]: Quest: " ..
                quest.title ..
                ": I know, i'm strict, but you need to have the ### Text AFTER the ### Meta")
            while true do
                line_index = line_index + 1
                line = lines[line_index]
                if line == nil then break end
                if starts_with(line, "Requires: ") then
                    quest.requires = table.foreach(
                        string.split(
                            string.sub(line, #"Requires: " + 1), requires_sep_trim, false, math.huge, false
                        ),
                        string.trim, true
                    )
                end
                if starts_with(line, "#") then
                    line_index = line_index - 1
                    break_out_of_main_loop = true
                    break
                end
            end
        elseif starts_with(line, "### Text") then
            local text = {}
            while true do
                line_index = line_index + 1
                line = lines[line_index]
                if line == nil then break end
                if starts_with(line, "#") then
                    line_index = line_index - 1
                    break
                end
                text[#text + 1] = line
            end
            quest.text = markdown_parser.decode_text(table.concat(text, "\n"))
            got_text = true
        end
        if break_out_of_main_loop then break end
    end
    return line_index
end

function markdown_parser.decode(text)
    local quests = {}
    local lines = text:split("\n", true)
    local line_index = 1
    while line_index <= #lines do
        local line = lines[line_index]
        local quest = {}
        local write_to_quests = false
        if starts_with(line, "## Info: ") then
            quest.type = "text"
            quest.info = true
            quest.title = string.sub(line, #"## Info: " + 1):trim()
            line_index = decode_text_and_meta(lines, line_index, quest)
            write_to_quests = true
        elseif starts_with(line, "## ") then
            local name = string.sub(line, #"## " + 1)
            local secret = false
            if starts_with(line, "## Secret: ") then
                name = string.sub(line, #"## Secret: " + 1)
                secret = true
            end
            quest.type = secret and "secret" or "quest"
            quest.title = name:trim()
            line_index = decode_text_and_meta(lines, line_index, quest)

            write_to_quests = true
        elseif starts_with(line, "# ") then
            local name = line
            quest.title = string.sub(name, #"# " + 1)
            quest.type = "text"
            local desc = {}

            while true do
                line_index = line_index + 1
                line = lines[line_index]
                if line == nil then break end
                if starts_with(line, "#") then
                    line_index = line_index - 1
                    break
                end
                desc[#desc + 1] = line
            end
            quest.text = markdown_parser.decode_text(table.concat(desc, "\n"))
            write_to_quests = true
        end
        if write_to_quests then
            quests[#quests + 1] = quest
        end
        line_index = line_index + 1
    end
    return quests
end

sbz_api.quest_parser = markdown_parser
