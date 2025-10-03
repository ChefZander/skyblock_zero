---@meta _
-- DRAFT 1 DONE
-- builtin/settingtypes.txt
-- minetest.conf.example


-- Section context mapping:
-- * [Client and Server] [*Client]: [client]
-- * [Client and Server] [*Server]: [server]
-- * [Client and Server] [*Server Security]: [server]
-- * [Client and Server] [*Server Gameplay]: [server]

---@alias _.LuantiSettings.client_and_server.keys.boolean
--- | "server_announce"
--- | "server_announce_send_players"
--- | "strict_protocol_version_checking"
--- | "ipv6_server"
--- | "disallow_empty_password"
--- | "enable_rollback_recording"
--- | "strip_color_codes"

---@alias _.LuantiSettings.client_and_server.keys
--- | "serverlist_url"
--- | "name"
--- | "serverlist_url"
--- | "server_name"
--- | "server_description"
--- | "server_address"
--- | "server_url"
--- | "server_announce"
--- | "server_announce_send_players"
--- | "motd"
--- | "max_users"
--- | "static_spawnpoint"
--- | "port"
--- | "bind_address"
--- | "strict_protocol_version_checking"
--- | "protocol_version_min"
--- | "remote_media"
--- | "ipv6_server"
--- | "default_password"
--- | "disallow_empty_password"
--- | "default_privs"
--- | "basic_privs"
--- | "anticheat_flags"
--- | "anticheat_movement_tolerance"
--- | "enable_rollback_recording"
--- | "csm_restriction_flags"
--- | "csm_restriction_noderange"
--- | "strip_color_codes"
--- | "chat_message_max_size"
--- | "chat_message_limit_per_10sec"
--- | "chat_message_limit_trigger_kick"
--- | "time_speed"
--- | "world_start_time"
--- | "item_entity_ttl"
--- | "default_stack_max"
--- | "movement_acceleration_default"
--- | "movement_acceleration_air"
--- | "movement_acceleration_fast"
--- | "movement_speed_walk"
--- | "movement_speed_crouch"
--- | "movement_speed_fast"
--- | "movement_speed_climb"
--- | "movement_speed_jump"
--- | "movement_liquid_fluidity"
--- | "movement_liquid_fluidity_smooth"
--- | "movement_liquid_sink"
--- | "movement_gravity"

---@class _.LuantiSettings.client_and_server.tablefmt : _.LuantiSettings.client_and_server.client.ctx_server, _.LuantiSettings.client_and_server.server, _.LuantiSettings.client_and_server.server.serverlist_and_motd.ctx_server, _.LuantiSettings.client_and_server.server.networking, _.LuantiSettings.client_and_server.server_security, _.luantisettings.client_and_server.server_security.client_side_modding, _.luantisettings.client_and_server.server_security.chat, _.luantisettings.client_and_server.server_gameplay, _.luantisettings.client_and_server.server_gameplay.physics

-- --------------------------- [Client and Server] -------------------------- --

-- ---------------------- [Client and Server] [*Client] --------------------- --

---@class _.LuantiSettings.client_and_server.client.ctx_common
--[[
#    URL to the server list displayed in the Multiplayer Tab.
[common]
(Serverlist URL) https://servers.luanti.org
]]
---@field serverlist_url string?

---@class _.LuantiSettings.client_and_server.client.ctx_client : _.LuantiSettings.client_and_server.client.ctx_common
--[[
#    Save the map received by the client on disk.
[client]
(Saving map received from server) false
]]
---@field enable_local_map_saving boolean?
--[[
#    If enabled, server account registration is separate from login in the UI.
#    If disabled, connecting to a server will automatically register a new account.
[client]
(Enable split login/register) true
]]
---@field enable_split_login_register boolean?
--[[
#    URL to JSON file which provides information about the newest Luanti release.
#    If this is empty the engine will never check for updates.
[client]
(Update information URL) https://www.luanti.org/release_info.json
]]
---@field update_information_url string?

---@class _.LuantiSettings.client_and_server.client.ctx_server : _.LuantiSettings.client_and_server.client.ctx_common

-- ---------------------- [Client and Server] [*Server] --------------------- --

---@class _.LuantiSettings.client_and_server.server
--[[
#    Name of the player.
#    When running a server, a client connecting with this name is admin.
#    When starting from the main menu, this is overridden.
[server]
(Admin name)
]]
---@field name string?

 -- ---------- [Client and Server] [*Server] [**Serverlist and MOTD] --------- --

---@class _.LuantiSettings.client_and_server.server.serverlist_and_motd.ctx_common
--[[
#    Announce to this serverlist.
[common]
(Serverlist URL) https://servers.luanti.org
]]
---@field serverlist_url string?

---@class _.LuantiSettings.client_and_server.server.serverlist_and_motd.ctx_server : _.LuantiSettings.client_and_server.server.serverlist_and_motd.ctx_common
--[[
#    Name of the server, to be displayed when players join and in the serverlist.
[server]
(Server name) Luanti server
]]
---@field server_name string?
--[[
#    Description of server, to be displayed when players join and in the serverlist.
[server]
(Server description) mine here
]]
---@field server_description string?
--[[
#    Domain name of server, to be displayed in the serverlist.
[server]
(Server address) game.example.net
]]
---@field server_address string?
--[[
#    Homepage of server, to be displayed in the serverlist.
[server]
(Server URL) https://game.example.net
]]
---@field server_url string?
--[[
#    Automatically report to the serverlist.
[server]
(Announce server) false
]]
---@field server_announce boolean?
--[[
#    Send names of online players to the serverlist. If disabled only the player count is revealed.
[server]
(Send player names to the server list) true
]]
---@field server_announce_send_players boolean?
--[[
#    Message of the day displayed to players connecting.
[server]
(Message of the day)
]]
---@field motd string?
--[[
#    Maximum number of players that can be connected simultaneously.
[server]
(Maximum users) 15 0 65535
]]
---@field max_users integer?
--[[
#    If this is set, players will always (re)spawn at the given position.
[server]
(Static spawn point)
]]
---@field static_spawnpoint string?

---@class _.LuantiSettings.client_and_server.server.serverlist_and_motd.ctx_client : _.LuantiSettings.client_and_server.server.serverlist_and_motd.ctx_common

 -- -------------- [Client and Server] [*Server] [**Networking] -------------- --

---@class _.LuantiSettings.client_and_server.server.networking
--[[
#    Network port to listen (UDP).
#    This value will be overridden when starting from the main menu.
[server]
(Server port) 30000 1 65535
]]
---@field port integer?
--[[
#    The network interface that the server listens on.
[server]
(Bind address)
]]
---@field bind_address string?
--[[
#    Enable to disallow old clients from connecting.
#    Older clients are compatible in the sense that they will not crash when connecting
#    to new servers, but they may not support all new features that you are expecting.
[server]
(Strict protocol checking) false
]]
---@field strict_protocol_version_checking boolean?
--[[
#    Define the oldest clients allowed to connect.
#    Older clients are compatible in the sense that they will not crash when connecting
#    to new servers, but they may not support all new features that you are expecting.
#    This allows for more fine-grained control than strict_protocol_version_checking.
#    Luanti still enforces its own internal minimum, and enabling
#    strict_protocol_version_checking will effectively override this.
[server]
(Protocol version minimum) 1 1 65535
]]
---@field protocol_version_min integer?
--[[
#    Specifies URL from which client fetches media instead of using UDP.
#    $filename should be accessible from $remote_media$filename via cURL
#    (obviously, remote_media should end with a slash).
#    Files that are not present will be fetched the usual way.
[server]
(Remote media)
]]
---@field remote_media string?
--[[
#    Enable IPv6 support for server.
#    Note that clients will be able to connect with both IPv4 and IPv6.
#    Ignored if bind_address is set.
#
#    Requires: enable_ipv6
[server]
(IPv6 server) true
]]
---@field ipv6_server boolean?

-- ----------------- [Client and Server] [*Server Security] ----------------- --

--[[
WIPDOC
]]
---@class core.LuantiSettings.flags.anticheat_flags
--[[
WIPDOC
]]
---@field digging boolean?
--[[
WIPDOC
]]
---@field nodigging boolean?
--[[
WIPDOC
]]
---@field interaction boolean?
--[[
WIPDOC
]]
---@field nointeraction boolean?
--[[
WIPDOC
]]
---@field movement boolean?
--[[
WIPDOC
]]
---@field nomovement boolean?

---@class _.LuantiSettings.client_and_server.server_security
--[[
#    New users need to input this password.
[server]
(Default password)
]]
---@field default_password string?
--[[
#    If enabled, players cannot join without a password or change theirs to an empty password.
[server]
(Disallow empty passwords) false
]]
---@field disallow_empty_password boolean?
--[[
#    The privileges that new users automatically get.
#    See /privs in game for a full list on your server and mod configuration.
[server]
(Default privileges) interact, shout
]]
---@field default_privs string?
--[[
#    Privileges that players with basic_privs can grant
[server]
(Basic privileges) interact, shout
]]
---@field basic_privs string?
--[[
#    Server anticheat configuration.
#    Flags are positive. Uncheck the flag to disable corresponding anticheat module.
[server]
(Anticheat flags) digging,interaction,movement digging,interaction,movement
]]
---@field anticheat_flags core.LuantiSettings.flags?
--[[
#    Tolerance of movement cheat detector.
#    Increase the value if players experience stuttery movement.
[server]
(Anticheat movement tolerance) 1.0 1.0
]]
---@field anticheat_movement_tolerance number?
--[[
#    If enabled, actions are recorded for rollback.
#    This option is only read when server starts.
[server]
(Rollback recording) false
]]
---@field enable_rollback_recording boolean?

-- ----- [Client and Server] [*Server Security] [**Client-side Modding] ----- --

---@class _.luantisettings.client_and_server.server_security.client_side_modding
--[[
#    Restricts the access of certain client-side functions on servers.
#    Combine the byteflags below to restrict client-side features, or set to 0
#    for no restrictions:
#    LOAD_CLIENT_MODS: 1 (disable loading client-provided mods)
#    CHAT_MESSAGES: 2 (disable send_chat_message call client-side)
#    READ_ITEMDEFS: 4 (disable get_item_def call client-side)
#    READ_NODEDEFS: 8 (disable get_node_def call client-side)
#    LOOKUP_NODES_LIMIT: 16 (limits get_node call client-side to
#    csm_restriction_noderange)
#    READ_PLAYERINFO: 32 (disable get_player_names call client-side)
[server]
(Client side modding restrictions) 62 0 63
]]
---@field csm_restriction_flags integer?
--[[
#   If the CSM restriction for node range is enabled, get_node calls are limited
#   to this distance from the player to the node.
[server]
(Client-side node lookup range restriction) 0 0 4294967295
]]
---@field csm_restriction_noderange integer?

-- ------------- [Client and Server] [*Server Security] [**Chat] ------------ --

---@class _.luantisettings.client_and_server.server_security.chat
--[[
#    Remove color codes from incoming chat messages
#    Use this to stop players from being able to use color in their messages
[server]
(Strip color codes) false
]]
---@field strip_color_codes boolean?
--[[
#    Set the maximum length of a chat message (in characters) sent by clients.
[server]
(Chat message max length) 500 10 65535
]]
---@field chat_message_max_size integer?
--[[
#    Number of messages a player may send per 10 seconds.
[server]
(Chat message count limit) 8.0 1.0
]]
---@field chat_message_limit_per_10sec number?
--[[
#    Kick players who sent more than X messages per 10 seconds.
[server]
(Chat message kick threshold) 50 1 65535
]]
---@field chat_message_limit_trigger_kick integer?

-- ----------------- [Client and Server] [*Server Gameplay] ----------------- --

---@class _.luantisettings.client_and_server.server_gameplay
--[[
#    Controls length of day/night cycle.
#    Examples:
#    72 = 20min, 360 = 4min, 1 = 24hour, 0 = day/night/whatever stays unchanged.
[server]
(Time speed) 72 0
]]
---@field time_speed integer?
--[[
#    Time of day when a new world is started, in millihours (0-23999).
[world_creation]
(World start time) 6125 0 23999
]]
---@field world_start_time integer?
--[[
#    Time in seconds for item entity (dropped items) to live.
#    Setting it to -1 disables the feature.
[server]
(Item entity TTL) 900 -1
]]
---@field item_entity_ttl integer?
--[[
#    Specifies the default stack size of nodes, items and tools.
#    Note that mods or games may explicitly set a stack for certain (or all) items.
[server]
(Default stack size) 99 1 65535
]]
---@field default_stack_max integer?

-- ----------- [Client and Server] [*Server Gameplay] [**Physics] ----------- --

---@class _.luantisettings.client_and_server.server_gameplay.physics
--[[
#    Horizontal and vertical acceleration on ground or when climbing,
#    in nodes per second per second.
[server]
(Default acceleration) 3.0 0.0
]]
---@field movement_acceleration_default number?
--[[
#    Horizontal acceleration in air when jumping or falling,
#    in nodes per second per second.
[server]
(Acceleration in air) 2.0 0.0
]]
---@field movement_acceleration_air number?
--[[
#    Horizontal and vertical acceleration in fast mode,
#    in nodes per second per second.
[server]
(Fast mode acceleration) 10.0 0.0
]]
---@field movement_acceleration_fast number?
--[[
#    Walking and flying speed, in nodes per second.
[server]
(Walking speed) 4.0 0.0
]]
---@field movement_speed_walk number?
--[[
#    Sneaking speed, in nodes per second.
[server]
(Sneaking speed) 1.35 0.0
]]
---@field movement_speed_crouch number?
--[[
#    Walking, flying and climbing speed in fast mode, in nodes per second.
[server]
(Fast mode speed) 20.0 0.0
]]
---@field movement_speed_fast number?
--[[
#    Vertical climbing speed, in nodes per second.
[server]
(Climbing speed) 3.0 0.0
]]
---@field movement_speed_climb number?
--[[
#    Initial vertical speed when jumping, in nodes per second.
[server]
(Jumping speed) 6.5 0.0
]]
---@field movement_speed_jump number?
--[[
#    How much you are slowed down when moving inside a liquid.
#    Decrease this to increase liquid resistance to movement.
[server]
(Liquid fluidity) 1.0 0.001
]]
---@field movement_liquid_fluidity number?
--[[
#    Maximum liquid resistance. Controls deceleration when entering liquid at
#    high speed.
[server]
(Liquid fluidity smoothing) 0.5
]]
---@field movement_liquid_fluidity_smooth number?
--[[
#    Controls sinking speed in liquid when idling. Negative values will cause
#    you to rise instead.
[server]
(Liquid sinking) 10.0
]]
---@field movement_liquid_sink number?
--[[
#    Acceleration of gravity, in nodes per second per second.
[server]
(Gravity) 9.81
]]
---@field movement_gravity number?