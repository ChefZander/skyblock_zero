logic = sbz_api.logic
local P = minetest.get_modpath("sbz_logic") .. "/help_pages/"

sbz_api.help_pages = {}
sbz_api.help_pages_by_index = {
    "Introduction",
    "Getting Started",
    "Better Understanding Main Sandboxes",
    "Standard Libox Environment",
    "Main Sandbox Environment",
    "Editor Environment",
    "Event Types",
    "Disks and Mem",
    "Lua Builder",
    "Object Detector",
    "Formspec Screen",
    "Matrix Screen",
    "Signs",
    "Note Blocks",
    "Buttons",
    "Nic",
    "NodeDB",
    "Autocrafter",
    "Gpu",
    "Transferring Items with Logic",
    "Hologram Projector",
    "Luanium Attractor",
    "Jumpdrives",
    "Drawer Controller"
}

local function edit_text(t)
    local function f(x)
        return "<mono>" .. math.floor(x / 1000) .. "</mono>"
    end
    t = string.gsub(t, "%$EDITOR_MS_LIMIT%$", f(logic.editor_limit))
    t = string.gsub(t, "%$MAIN_MS_LIMIT%$", f(logic.main_limit))
    t = string.gsub(t, "%$COMBINED_MS_LIMIT%$", f(logic.combined_limit))
    t = string.gsub(t, "%$MAIN_RAM_LIMIT%$", f(logic.max_ram / 1024))
    t = string.gsub(t, "%$C1", string.char(1)) -- needed because minetest hypertext is insanely dumb
    return t
end

for _, v in pairs(sbz_api.help_pages_by_index) do
    local f = assert(io.open(P .. v .. ".txt", "r"),
        "dude no you arent cool, dont delete random files you think are 'unimportant' but turn out to be actually required")
    local tex = f:read("*a")
    f:close()
    sbz_api.help_pages[v] = edit_text(tex)
end

local function gen_page(meta)
    local idx = meta:get_int "index"
    if idx == 0 then idx = 1 end
    local fs = {
        string.format([[
        formspec_version[7]
        size[20,20]
        container[0.2,0.2]
            textlist[0,0;5,19.6;main;%s;%s;false]
            hypertext[5.2,0;14.6,19.6;a;%s]
        container_end[]
        ]],
            table.concat(sbz_api.help_pages_by_index, ","),
            idx,
            minetest.formspec_escape(sbz_api.help_pages[sbz_api.help_pages_by_index[idx]])
        )
    }

    return table.concat(fs, "")
end

local function on_receive_fields(pos, formname, fields, sender)
    local meta = minetest.get_meta(pos)
    local textlist = minetest.explode_textlist_event(fields.main)
    meta:set_int("index", tonumber(textlist.index) or meta:get_int("index"))
    meta:mark_as_private("index")
    meta:set_string("formspec", gen_page(meta))

    local player_name = sender:get_player_name()
    minetest.sound_play("questbook", {
        to_player = sender:get_player_name(),
        gain = 1,
    })
end

minetest.register_node("sbz_logic:knowledge_station", {
    description = "Knowledge Station",
    info_extra = "Explains logic.",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", gen_page(meta))
    end,
    on_receive_fields = on_receive_fields,
    groups = { matter = 1, ui_logic = 1 },
    tiles = { "knowledge_station.png" },
    sounds = sbz_api.sounds.matter(),
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player_name = clicker:get_player_name()
        minetest.sound_play("questbook", {
            to_player = player_name,
            gain = 1,
        })
    end
})

minetest.register_craft {
    output = "sbz_logic:knowledge_station",
    recipe = {
        { "sbz_resources:stone", "sbz_resources:luanium",          "sbz_resources:stone" },
        { "sbz_resources:stone", "sbz_power:simple_charged_field", "sbz_resources:stone" },
        { "sbz_resources:stone", "sbz_resources:stone",            "sbz_resources:stone" },
    }
}
