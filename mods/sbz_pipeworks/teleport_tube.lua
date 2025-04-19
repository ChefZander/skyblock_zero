-- tp tube but modifieed :D
local S = minetest.get_translator("pipeworks")
local storage = minetest.get_mod_storage()

local enable_logging = minetest.settings:get_bool("pipeworks_log_teleport_tubes", false)

-- V4: Mod storage using "<can_receive>:<channel>" format.
local tube_db_version = 4
local tube_db = {}
local receiver_cache = {}

local function hash_pos(pos)
    vector.round(pos)
    return string.format("%.0f", minetest.hash_node_position(pos))
end

local function serialize_tube(tube)
    return string.format("%d:%s", tube.cr, tube.channel)
end

local function deserialize_tube(hash, str)
    local sep = str:sub(2, 2) == ":"
    local cr = tonumber(str:sub(1, 1))
    local channel = str:sub(3)
    if sep and cr and channel then
        local pos = minetest.get_position_from_hash(tonumber(hash))
        return { x = pos.x, y = pos.y, z = pos.z, cr = cr, channel = channel }
    end
end

local function save_tube_db()
    receiver_cache = {}
    local fields = { version = tube_db_version }
    for key, val in pairs(tube_db) do
        fields[key] = serialize_tube(val)
    end
    storage:from_table({ fields = fields })
end

local function save_tube(hash)
    local tube = tube_db[hash]
    receiver_cache[tube.channel] = nil
    storage:set_string(hash, serialize_tube(tube))
end


local function remove_tube(pos)
    local hash = hash_pos(pos)
    if tube_db[hash] then
        receiver_cache[tube_db[hash].channel] = nil
        tube_db[hash] = nil
        storage:set_string(hash, "")
    end
end

local function read_tube_db()
    for key, val in pairs(storage:to_table().fields) do
        if tonumber(key) then
            tube_db[key] = deserialize_tube(key, val)
        elseif key ~= "version" then
            error("Unknown field in teleport tube database: " .. key)
        end
    end
    tube_db.version = nil
end

local function set_tube(pos, channel, cr)
    local hash = hash_pos(pos)
    local tube = tube_db[hash]
    if tube then
        if tube.channel ~= channel or tube.cr ~= cr then
            tube.channel = channel
            tube.cr = cr
            save_tube(hash)
        end
    else
        tube_db[hash] = { x = pos.x, y = pos.y, z = pos.z, channel = channel, cr = cr }
        save_tube(hash)
    end
end

local function get_receivers(pos, channel)
    local hash = hash_pos(pos)
    local cache = receiver_cache[channel] or {}
    if cache[hash] then
        return cache[hash]
    end
    local receivers = {}
    for key, val in pairs(tube_db) do
        if val.cr == 1 and val.channel == channel and not vector.equals(val, pos) then
            minetest.load_area(val)
            local node_name = minetest.get_node(val).name
            if node_name:find("pipeworks:teleport_tube") or core.get_item_group(node_name, "tptube") then
                table.insert(receivers, val)
            else
                remove_tube(val)
            end
        end
    end
    cache[hash] = receivers
    receiver_cache[channel] = cache
    return receivers
end

local help_text = minetest.formspec_escape(
    S("Channels are public by default") .. "\n" ..
    S("Use <player>:<channel> for fully private channels") .. "\n" ..
    S("Use <player>;<channel> for private receivers")
)

local formspec = "formspec_version[2]size[8,4.4]" ..
    "image[0.5,0.3;1,1;warp_crystal.png]" ..
    "label[1.75,0.8;" .. S("Teleporting Tube") .. "]" ..
    "field[0.5,1.7;5,0.8;channel;" .. S("Channel") .. ";${channel}]" ..
    "button_exit[5.5,1.7;2,0.8;save;" .. S("Save") .. "]" ..
    "label[6.5,0.6;" .. S("Receive") .. "]" ..
    "label[0.5,2.8;" .. help_text .. "]"


local function update_meta(meta)
    local channel = meta:get_string("channel")
    local cr = meta:get_int("can_receive") == 1
    if channel == "" then
        meta:set_string("infotext", S("Unconfigured Teleport Tube"))
    else
        local desc = cr and "sending and receiving" or "sending"
        meta:set_string("infotext", S("Teleport Tube @1 on '@2'", desc, channel))
    end
    local state = cr and "on" or "off"
    meta:set_string("formspec", formspec ..
        "image_button[6.4,0.8;1,0.6;pipeworks_button_" .. state ..
        ".png;cr_" .. state .. ";;;false;pipeworks_button_interm.png]")
end

local function update_tube(pos, channel, cr, player_name)
    local meta = minetest.get_meta(pos)
    if meta:get_string("channel") == channel and meta:get_int("can_receive") == cr then
        return
    end
    if channel == "" then
        meta:set_string("channel", "")
        meta:set_int("can_receive", cr)
        remove_tube(pos)
        return
    end
    local name, mode = channel:match("^([^:;]+)([:;])")
    if name and mode and name ~= player_name then
        if mode == ":" then
            minetest.chat_send_player(player_name,
                S("Sorry, channel '@1' is reserved for exclusive use by @2", channel, name))
            return
        elseif mode == ";" and cr ~= 0 then
            minetest.chat_send_player(player_name,
                S("Sorry, receiving from channel '@1' is reserved for @2", channel, name))
            return
        end
    end
    meta:set_string("channel", channel)
    meta:set_int("can_receive", cr)
    set_tube(pos, channel, cr)
end

local function receive_fields(pos, _, fields, sender)
    if not fields.channel or not pipeworks.may_configure(pos, sender) then
        return
    end
    local meta = minetest.get_meta(pos)
    local channel = fields.channel:trim()
    local cr = meta:get_int("can_receive")
    if fields.cr_on then
        cr = 0
    elseif fields.cr_off then
        cr = 1
    end
    update_tube(pos, channel, cr, sender:get_player_name())
    update_meta(meta)
end

local function can_go(pos, node, velocity, stack)
    velocity.x = 0
    velocity.y = 0
    velocity.z = 0
    local src_meta = minetest.get_meta(pos)
    local channel = src_meta:get_string("channel")
    if channel == "" then
        return {}
    end
    local receivers = get_receivers(pos, channel)
    if #receivers == 0 then
        return {}
    end
    local target = receivers[math.random(1, #receivers)]
    if enable_logging then
        local src_owner = src_meta:get_string("owner")
        local dst_meta = minetest.get_meta(pos)
        local dst_owner = dst_meta:get_string("owner")
        minetest.log("action", string.format("[pipeworks] %s teleported from %s (owner=%s) to %s (owner=%s) via %s",
            stack:to_string(), minetest.pos_to_string(pos), src_owner, minetest.pos_to_string(target), dst_owner, channel
        ))
    end
    pos.x = target.x
    pos.y = target.y
    pos.z = target.z
    return pipeworks.meseadjlist
end

local function repair_tube(pos, node)
    minetest.swap_node(pos, { name = node.name, param2 = node.param2 })
    pipeworks.scan_for_tube_objects(pos)
    local meta = minetest.get_meta(pos)
    local channel = meta:get_string("channel")
    if channel ~= "" then
        set_tube(pos, channel, meta:get_int("can_receive"))
    end
    update_meta(meta)
end

local function logic_action(pos, msg, sender)
    local meta = minetest.get_meta(pos)
    local can_receive = meta:get_int("can_receive")
    if type(msg) == "string" then
        channel = msg
    elseif type(msg) == "table" then
        if type(msg.channel) == "string" then
            channel = msg.channel
        end
        if msg.can_receive == 1 or msg.can_receive == true then
            can_receive = 1
        elseif msg.can_receive == 0 or msg.can_receive == false then
            can_receive = 0
        end
    else
        return
    end
    local player_name = meta:get_string("owner")
    update_tube(pos, channel, can_receive, player_name)
    update_meta(meta)
end

local def = {
    tube = {
        can_go = can_go,
        on_repair = repair_tube,
        priority = 80,
    },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("can_receive", 1) -- Enabled by default
        update_meta(meta)
    end,
    on_receive_fields = receive_fields,
    on_destruct = remove_tube,
    after_place_node = function(pos, placer)
        minetest.get_meta(pos):set_string("owner", placer:get_player_name())
        pipeworks.after_place(pos)
    end,
    on_logic_send = logic_action,
    info_extra = "Place a higher priority tube/machine next to a receiving teleport tube.",
}

pipeworks.register_tube("pipeworks:teleport_tube", {
    description = S("Teleport Tube"),
    plain = { { name = "basic_tube_plain.png", backface_culling = pipeworks.tube_backface_culling, color = "navy" } },
    noctr = { { name = "basic_tube_noctr.png", backface_culling = pipeworks.tube_backface_culling, color = "navy" } },
    node_def = def,
})

minetest.register_craft({
    output = "pipeworks:teleport_tube_1 8",
    recipe = {
        { "pipeworks:tube_1", "pipeworks:tube_1",           "pipeworks:tube_1" },
        { "pipeworks:tube_1", "sbz_resources:warp_crystal", "pipeworks:tube_1" },
        { "pipeworks:tube_1", "pipeworks:tube_1",           "pipeworks:tube_1" },
    }
})


mesecon.register_on_mvps_move(function(moved_nodes)
    for _, n in ipairs(moved_nodes) do
        if n.node.name:find("pipeworks:teleport_tube") then
            local meta = minetest.get_meta(n.pos)
            remove_tube(n.oldpos)
            set_tube(n.pos, meta:get_string("channel"), meta:get_int("can_receive"))
        end
    end
end)

-- Expose teleport tube database API for other mods
pipeworks.tptube = {
    version = tube_db_version,
    hash = hash_pos,
    get_db = function() return tube_db end,
    save_tube_db = save_tube_db,
    remove_tube = remove_tube,
    set_tube = set_tube,
    save_tube = save_tube,
    update_tube = update_tube,
    update_meta = function(meta, cr)
        -- Legacy behaviour
        if cr ~= nil then
            meta:set_int("can_receive", cr and 1 or 0)
        end
        update_meta(meta)
    end,
    receive_fields = receive_fields,
    logic_action = logic_action,
    get_receivers = get_receivers,
}

-- Load the database
read_tube_db()
