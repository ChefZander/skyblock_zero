-- surprisingly easy if its just ascii

local byte_space = string.byte(' ')
local amount_of_chars_supported = 256 - byte_space

machine_ui_api.font = {}

machine_ui_api.font.render_char = function(font, char)
    local byte = string.byte(char)
    return ('%s^[sheet:1x%s:0,%s'):format(font, amount_of_chars_supported - 1, byte - byte_space)
end

machine_ui_api.font.render = function(font, character_size_w, character_size_h, text)
    local text_split = text:split('\n')

    local text_height, text_width = #text_split, 0
    for _, line in ipairs(text_split) do
        text_width = math.max(text_width, #line)
    end

    local image = {}
    table.insert(image, ('[combine:%sx%s'):format(character_size_w * text_width, character_size_h * text_height))

    for y, line in ipairs(text_split) do
        for x = 1, #line do
            local char = line:sub(x, x)
            table.insert(
                image,
                (':%s,%s=%s'):format(
                    (x - 1) * character_size_w,
                    (y - 1) * character_size_h,
                    machine_ui_api.escape(machine_ui_api.font.render_char(font, char))
                )
            )
        end
    end
    return { image = table.concat(image), width = text_width, height = text_height }
end
