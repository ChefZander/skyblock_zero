--[[
    Hello, if you are seeing this, go make your own editor

    Anyway, this editor stores everything it needs in the coroutine_env (like terminal stuff)
]]
local is_on = coroutine_env ~= nil
local current_tab = (coroutine_env or {}).current_tab or 1
local prepend = [[
formspec_version[7]
size[20,15]
]]
if is_on then
    prepend = prepend .. [[
    tabheader[0,0;1;tabs;Code,Terminal;%s;false;true]
    ]]
end

local function render_formspec_edit()
    local control_button
    if is_on then
        control_button = "style[turn_off;bgcolor=red]button[0.2,12.5;3,1;turn_off;Turn off]"
    else
        control_button = "style[turn_on;bgcolor=green]button[0.2,12.5;3,1;turn_on;Turn on]"
    end

    return string.format(prepend, 1) .. string.format([[
hypertext[0,0.3;20,1;;<center><big>Super basic editor, YOU can make a better one :)]
textarea[0.2,2;19.6,10;code;The code...;%s]
%s
label[4,12.5;%s]
]], editor.code, control_button, editor.error)
end

-- only makes sense to render if it's on
local function render_formspec_term()
    local terminal_text = minetest.formspec_escape((coroutine_env or {}).terminal_text or "")
    return string.format(prepend, 2) .. string.format([[
    box[0,0;20,15;black]
    textarea[0,0;20,15;;;%s]
]], terminal_text)
end

local function render_formspec(tabs)
    if tabs == 1 then
        return render_formspec_edit()
    elseif tabs == 2 then
        return render_formspec_term()
    end
end

if event.type == "program" then
    editor.formspec = render_formspec_edit()
end


if event.type == "gui" or event.type == "off" or event.type == "on" then
    local fields = event.fields or {}
    if fields.turn_off then
        turn_off()
    end
    if fields.turn_on then turn_on() end

    if fields.code then editor.code = minetest.formspec_escape(fields.code) end
    if tonumber(fields.tabs) then coroutine_env.current_tab = fields.tabs end

    editor.formspec = render_formspec(tonumber(fields.tabs) or current_tab)
end
