-- This work by frogTheSecond is marked with CC0 1.0 https://creativecommons.org/publicdomain/zero/1.0/ .
-- Further contributed work follows the same license unless explicitly stated otherwise
---@diagnostic disable: undefined-global
-- Hello, if you are seeing this, go make your own editor, you can base it off this one


local E = core.formspec_escape
local is_on = coroutine_env ~= nil
local main_env = coroutine_env or {}
local prepend = [=[
formspec_version[7]
size[20,15]
tabheader[0,0;1;tabs;Code,Terminal,Inventory,Disks;%s;false;true]]=]
local mem, editor_errmsg = read_mem()
local dirty_mem = false

-- NOTE: slots only, will not use disk names at all
local disk_slots, disk_names
local disks, dirty_disks = {}, {}

local _read_disk = read_disk
local function read_disk(disk_id)
    if disks[disk_id] then return disks[disk_id] end
    local disk, errmsg = _read_disk(disk_id)
    if disk then disks[disk_id] = disk end
    return disk, errmsg
end

-- Always run this before exiting editor environment
local function finalizer()
    if mem and dirty_mem then write_mem(mem) end

    for slot, _ in pairs(dirty_disks) do
        local ok, errmsg = write_disk(slot, disks[slot])
    end
end


local function text_wrap(text, max_length)
    local result = {}
    local line = ''
    local pos = 1

    local total_length = #text
    if total_length > 1024 then -- aw hell nah ToT
        return text
    end

    while pos <= total_length do
        -- Find the next space or end of string
        local next_space = string.find(text, ' ', pos, true) or (total_length + 1)
        local word = string.sub(text, pos, next_space - 1)

        if #line + next_space - pos <= max_length then
            if line ~= '' then
                line = line .. ' ' .. word
            else
                line = line .. word
            end
        else
            result[#result+1] = line
            line = word
        end

        pos = next_space + 1
    end

    if #line > 0 then
        result[#result+1] = line
    end

    return table.concat(result, '\n')
end

local function render_formspec_edit()
    local control_button
    if is_on then
        control_button = [[
style[turn_off;bgcolor=red]
button[0.2,12.5;3,1;turn_off;Turn off]
]]
    else
        control_button = [[
style[turn_on;bgcolor=green]
button[0.2,12.5;3,1;turn_on;Turn on]
]]
    end


    return string.format(prepend, 1) .. string.format([=[
hypertext[0,0.3;20,1;;<center><big>Super basic editor, YOU can make a better one :)]
style_type[textarea;font=mono;textcolor=black]
textarea[0.2,2;19.6,10;code;The code...;%s]
%s
button[3.4,12.5;3,1;save;Save]
label[6.7,12.5;%s]]=],
        E(editor.code) or '',
        control_button,
        E(text_wrap(editor_errmsg or editor.error, 60)))
end

-- If mem is bad, tell error in the edit tab
if editor_errmsg then
    render_formspec_edit()
    finalizer()
    return
end

local function render_formspec_term()
    local terminal_text = E(main_env.terminal_text or "")
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

local function render_formspec_disk()
    local fs = {}
    local Y = 0.2
    local selected = mem.selected

    -- sorry, users will not know which is an immutable disk without reading it
    for i, slot in ipairs(disk_slots) do
        if slot == selected then
            fs[#fs + 1] = string.format([=[
style_type[box;colors=#42beef69]
box[0.1,%s;1.2,1.2;]
style_type[box;colors=]
image_button[0.2,%s;1,1;data_disk.png;%s;]
]=], Y-0.1, Y, slot)
        else
            fs[#fs + 1] = string.format(
                "image_button[0.2,%s;1,1;data_disk.png;%s;]", Y, slot)
        end
        if disk_names[i] ~= '' then
            fs[#fs + 1] = string.format(
                "tooltip[%s;Disk #%s: %s]", slot, slot, disk_names[i])
        else
            fs[#fs + 1] = string.format(
                "tooltip[%s;Unnamed Disk #%s]", slot, slot)
        end
        Y = Y + 1.2
    end

    if #disk_slots == 0 then
        fs[#fs + 1] = "label[0.4,0.4;No disks found... you may want to insert some?]"
    end

    if not selected then
        return string.format(prepend, 4) .. table.concat(fs)
    end

    local disk, errmsg = read_disk(selected)
    if errmsg then
        fs[#fs + 1] = string.format('label[13,13;%s], ', errmsg)
        dirty_mem = true
        mem.selected = nil
        return string.format(prepend, 4) .. table.concat(fs)
    end

    if not disk.immutable then -- writable disk
        local is_editable = type(disk.data) == "string" or disk.data == nil
        local non_editable_msg =
            "\nCan't edit it here because it's a non-string type, can't show it but here is the dumped version:\n"
            .. E(dump(disk.data))

        fs[#fs + 1] = string.format([=[
field[2,1;10,1;write_disk_name;Disk Name;%s]
textarea[2,3;10,10;%s;Disk Data;%s]
style[disk_type;bgcolor=#0000;border=false]
style[disk_type:pressed;content_offset=0,0]
image_button[11.25,0.2;0.75,0.75;data_disk.png;disk_type;]
tooltip[disk_type;System Code Disk]
checkbox[13,1;punches_editor;Punches editor;%s]
checkbox[13,2;punches_code;Punches code;%s]
button[13,12;3,1;save;Save]
label[13,3;Can hold: %s kB]]=],
            E(disk.name),
            is_editable and "write_disk_data" or "",
            is_editable and E(disk.data or "") or non_editable_msg,
            tostring(disk.punches_editor),
            tostring(disk.punches_code),
            tostring(math.floor(disk.max / 1024)))

    else -- immutable disk
        fs[#fs + 1] = string.format([=[
style_type[box;colors=#ff71718f]
box[2,1;10,1;]
box[2,3;10,10;]
style_type[box;colors=]
textarea[2,1;10,1;;Disk Name;%s]
textarea[2,3;10,10;;Disk Data;%s]
style[disk_type;bgcolor=#0000;border=false]
style[disk_type:pressed;content_offset=0,0]
image_button[11.25,0.2;0.75,0.75;system_code_disk.png;disk_type;]
tooltip[disk_type;System Code Disk]
label[13,1;Punches editor: %s]
label[13,2;Punches code: %s]
label[13,3;This disk is immutable]]=],
            E(disk.name),
            E(disk.data),
            disk.punches_editor and "yes" or "no",
            disk.punches_code and "yes" or "no")
    end
    return string.format(prepend, 4) .. table.concat(fs)
end

if event.type == "program" then -- load this editor
    editor.formspec = render_formspec_edit()

elseif (event.type == "gui" or event.type == "off" or event.type == "on") or
    (event.type == "ran" and mem.current_tab == 2 and mem.old_terminal_text ~= main_env.terminal_text) then
    local fields = event.fields or {}
    if fields.turn_off then turn_off() end
    if fields.turn_on then turn_on() end

    if tonumber(fields.tabs) then
        dirty_mem = true
        mem.current_tab = tonumber(fields.tabs)
    end
    local tab = tonumber(fields.tabs) or mem.current_tab

    if tab == 1 then
        editor.formspec = render_formspec_edit()
        if fields.code then editor.code = fields.code end

    elseif tab == 2 then
        editor.formspec = render_formspec_term()

    elseif tab == 3 then
        editor.formspec = render_formspec_inventory()

    elseif tab == 4 then
        disk_slots = available_disks()
        disk_names = available_disk_names()

        for i, slot in ipairs(disk_slots) do
            if fields[tostring(slot)] then
                dirty_mem = true
                mem.selected = slot
            end
        end
        local selected = mem.selected

        if selected then
            disks[selected] = read_disk(selected)
            local disk = disks[selected]

            if fields.save then -- button also collecs textarea fields
                dirty_disks[selected] = true
                disk.name = fields.write_disk_name
                disk_names[selected] = disk.name
                disk.data = fields.write_disk_data
            end
            if fields.punches_editor then
                dirty_disks[selected] = true
                disk.punches_editor = fields.punches_editor == 'true'
            end
            if fields.punches_code then
                dirty_disks[selected] = true
                disk.punches_code = fields.punches_code == 'true'
            end
        end

        editor.formspec = render_formspec_disk()
    end
end

if event.type == 'ran' then
    dirty_mem = true
    mem.old_terminal_text = main_env.terminal_text
end

finalizer()