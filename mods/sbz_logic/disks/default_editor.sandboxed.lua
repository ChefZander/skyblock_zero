-- This work by frogTheSecond is marked with CC0 1.0 https://creativecommons.org/publicdomain/zero/1.0/ .
---@diagnostic disable: undefined-global
-- Hello, if you are seeing this, go make your own editor, you can base it off this one


local is_on = coroutine_env ~= nil
local current_tab = mem.current_tab or 1
local prepend = [[
formspec_version[7]
size[20,15]
tabheader[0,0;1;tabs;Code,Terminal,Inventory,Disks;%s;false;true]
]]

local function render_formspec_edit()
    local control_button
    if is_on then
        control_button = "style[turn_off;bgcolor=red]button[0.2,12.5;3,1;turn_off;Turn off]"
    else
        control_button = "style[turn_on;bgcolor=green]button[0.2,12.5;3,1;turn_on;Turn on]"
    end

    return string.format(prepend, 1) .. string.format([[
hypertext[0,0.3;20,1;;<center><big>Super basic editor, YOU can make a better one :)]
style_type[textarea;font=mono;textcolor=black]
textarea[0.2,2;19.6,10;code;The code...;%s]
%s
label[4,12.5;%s]
]], minetest.formspec_escape(editor.code) or "", control_button, editor.error)
end

-- only makes sense to render if it's on
local function render_formspec_term()
    local terminal_text = minetest.formspec_escape((coroutine_env or {}).terminal_text or "")
    return string.format(prepend, 2) .. string.format([[
box[0,0;20,15;black]
textarea[0,0;20,15;;;%s]
]], terminal_text)
end

local function render_formspec_inventory()
    return string.format(prepend, 3) .. string.format([[
list[current_player;main;0.2,10;8,4]
label[0.2,1;Upgrades]
list[context;upgrades;0.2,1.5;8,1]

label[0.2,2.9;Disks]
list[context;disks;0.2,3.4;8,1]
    ]])
end

local function render_disk_editor()
    local fs = {}
    local Y = 0.2
    for k, v in ipairs(disks) do
        fs[#fs + 1] = string.format("image_button[0.2,%s;1,1;%s;%s;]", Y,
            v.immutable and "system_code_disk.png" or "data_disk.png",
            k)
        fs[#fs + 1] = string.format("tooltip[%s;%s]", k, v.name)
        Y = Y + 1.2
    end
    if #disks == 0 then
        fs[#fs + 1] = "label[0.4,0.4;No disks found... you may want to insert some?]"
    end
    if not mem.selected then
        return string.format(prepend, 4) .. table.concat(fs)
    end

    local selected_disk = disks[mem.selected]
    if not selected_disk then
        mem.selected = nil
        return string.format(prepend, 4) .. table.concat(fs)
    end
    if not selected_disk.immutable then
        fs[#fs + 1] = string.format([[
field[2,1;10,1;set_disk_name;Disk Name;%s]
textarea[2,3;10,10;%s;Disk Data;%s]
checkbox[13,1;punches_editor;Punches editor;%s]
checkbox[13,2;punches_code;Punches code;%s]
button[13,3;3,1;save;Save]
label[13,13;Can hold: %s kb]
    ]], minetest.formspec_escape(selected_disk.name),
            (type(selected_disk.data) == "string" or selected_disk.data == nil) and "set_disk_data" or "",
            (type(selected_disk.data) == "string" or selected_disk.data == nil) and
            minetest.formspec_escape(selected_disk.data or "") or
            "\nCan't edit it here because it's a non-string type, can't show it but here is the dumped version:\n" ..
            minetest.formspec_escape(dump(selected_disk.data)),
            tostring(selected_disk.punches_editor),
            tostring(selected_disk.punches_code),
            tostring(math.floor(selected_disk.max / 1024)))
    else
        fs[#fs + 1] = string.format([[
textarea[2,1;10,1;;Disk Name;%s]
textarea[2,3;10,10;;Disk Data;%s]
label[13,1;Punches editor: %s]
label[13,2;Punches code: %s]
label[13,13;This disk is immutable]
    ]], minetest.formspec_escape(selected_disk.name), minetest.formspec_escape(selected_disk.data),
            selected_disk.punches_editor and "yes" or "no",
            selected_disk.punches_code and "yes" or "no")
    end
    return string.format(prepend, 4) .. table.concat(fs)
end

local function render_formspec(tabs)
    if tabs == 1 then
        return render_formspec_edit()
    elseif tabs == 2 then
        return render_formspec_term()
    elseif tabs == 3 then
        return render_formspec_inventory()
    elseif tabs == 4 then
        return render_disk_editor()
    end
end

if event.type == "program" then
    editor.formspec = render_formspec_edit()
end

if event.type == "gui" or event.type == "off" or event.type == "on" or (event.type == "ran" and mem.old_terminal_text ~= coroutine_env.terminal_text and current_tab == 2) then
    local fields = event.fields or {}
    if fields.turn_off then
        turn_off()
    end
    if fields.turn_on then turn_on() end

    if fields.code then editor.code = fields.code end
    if tonumber(fields.tabs) then mem.current_tab = tonumber(fields.tabs) end
    for k, v in ipairs(disks) do
        if fields[tostring(k)] then
            mem.selected = tonumber(k)
        end
    end

    local selected_disk = disks[mem.selected]
    if selected_disk and not selected_disk.immutable then
        if fields.set_disk_name then
            selected_disk.name = fields.set_disk_name
        end
        if fields.set_disk_data then
            selected_disk.data = fields.set_disk_data
        end
        if fields.punches_editor then
            selected_disk.punches_editor = fields.punches_editor
        end
        if fields.punches_code then
            selected_disk.punches_code = fields.punches_code
        end
    end

    editor.formspec = render_formspec(tonumber(fields.tabs) or current_tab)
    mem.old_terminal_text = coroutine_env.terminal_text
end
