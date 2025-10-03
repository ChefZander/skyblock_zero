---@meta _
-- DRAFT 1 DONE
-- builtin/settingtypes.txt
-- minetest.conf.example

-- NOTE: because there's so much contexts used, it must be specified via ctx_*
-- Section context mapping:
-- * [Advanced] [*Developer options] [**Mod Security]: [server]
-- * [Advanced] [*Developer options] [**Mod Profiler]: [server]
-- * [Advanced] [*Developer options] [**Engine Profiler]: [common]
-- * [Advanced] [*Advanced] [**Graphics]: [client]
-- * [Advanced] [*Advanced] [**Sound]: [client]
-- * [Advanced] [*Advanced] [**Font]: [client]
-- * [Advanced] [*Advanced] [**Lighting]: [client]
-- * [Advanced] [*Advanced] [**Server]: [server]
-- * [Advanced] [*Advanced] [**Server/Env Performance]: [server]
-- * [Advanced] [*Advanced] [**Mapgen]: [server]
-- * [Advanced] [*Advanced] [**cURL]: [common]
-- * [Advanced] [*Advanced] [**Client Debugging]: [client]
-- * [Advanced] [*Gamepads]: [client]
-- * [Advanced] [*Hide: Temporary Settings]: [common]

---@alias _.LuantiSettings.advanced.keys.boolean
--- | "secure.enable_security"
--- | "random_mod_load_order"
--- | "enable_mod_channels"
--- | "profiler.load"
--- | "instrument.entity"
--- | "instrument.abm"
--- | "instrument.lbm"
--- | "instrument.chatcommand"
--- | "instrument.global_callback"
--- | "instrument.builtin"
--- | "instrument.profiler"
--- | "enable_ipv6"
--- | "ask_reconnect_on_crash"
--- | "unlimited_player_transfer_distance"
--- | "server_side_occlusion_culling"
--- | "enable_mapgen_debug_info"
--- | "enable_console"
--- | "ignore_world_load_errors"
--- | "enable_remote_media_server"
--- | "enable_minimap"
--- | "minimap_shape_round"
--- | "enable_damage"
--- | "creative_mode"
--- | "enable_pvp"
--- | "free_move"
--- | "pitch_move"
--- | "fast_move"
--- | "noclip"
--- | "continuous_forward"
--- | "cinematic"
--- | "show_technical_names"
--- | "show_advanced"

---@alias _.LuantiSettings.advanced.keys
--- | "secure.enable_security"
--- | "secure.trusted_mods"
--- | "secure.http_mods"
--- | "debug_log_level"
--- | "debug_log_size_max"
--- | "deprecated_lua_api_handling"
--- | "random_mod_load_order"
--- | "enable_mod_channels"
--- | "profiler.load"
--- | "profiler.default_report_format"
--- | "profiler.report_path"
--- | "instrument.entity"
--- | "instrument.abm"
--- | "instrument.lbm"
--- | "instrument.chatcommand"
--- | "instrument.global_callback"
--- | "instrument.builtin"
--- | "instrument.profiler"
--- | "profiler_print_interval"
--- | "enable_ipv6"
--- | "max_packets_per_iteration"
--- | "prometheus_listener_address"
--- | "max_simultaneous_block_sends_per_client"
--- | "full_block_send_enable_min_time_from_building"
--- | "map_compression_level_net"
--- | "chat_message_format"
--- | "chatcommand_msg_time_threshold"
--- | "kick_msg_shutdown"
--- | "kick_msg_crash"
--- | "ask_reconnect_on_crash"
--- | "dedicated_server_step"
--- | "unlimited_player_transfer_distance"
--- | "player_transfer_distance"
--- | "active_object_send_range_blocks"
--- | "active_block_range"
--- | "max_block_send_distance"
--- | "max_forceloaded_blocks"
--- | "server_map_save_interval"
--- | "server_unload_unused_data_timeout"
--- | "max_objects_per_block"
--- | "active_block_mgmt_interval"
--- | "abm_interval"
--- | "abm_time_budget"
--- | "nodetimer_interval"
--- | "liquid_loop_max"
--- | "liquid_queue_purge_time"
--- | "liquid_update"
--- | "block_send_optimize_distance"
--- | "server_side_occlusion_culling"
--- | "block_cull_optimize_distance"
--- | "chunksize"
--- | "enable_mapgen_debug_info"
--- | "emergequeue_limit_total"
--- | "emergequeue_limit_diskonly"
--- | "emergequeue_limit_generate"
--- | "num_emerge_threads"
--- | "curl_timeout"
--- | "curl_parallel_limit"
--- | "curl_file_download_timeout"
--- | "enable_console"
--- | "clickable_chat_weblinks"
--- | "display_density_factor"
--- | "ignore_world_load_errors"
--- | "max_clearobjects_extra_loaded_blocks"
--- | "map-dir"
--- | "sqlite_synchronous"
--- | "map_compression_level_disk"
--- | "enable_remote_media_server"
--- | "serverlist_file"
--- | "texture_path"
--- | "enable_minimap"
--- | "minimap_shape_round"
--- | "address"
--- | "remote_port"
--- | "enable_damage"
--- | "creative_mode"
--- | "enable_pvp"
--- | "free_move"
--- | "pitch_move"
--- | "fast_move"
--- | "noclip"
--- | "continuous_forward"
--- | "cinematic"
--- | "show_technical_names"
--- | "show_advanced"

---@class _.LuantiSettings.advanced.tablefmt : _.LuantiSettings.advanced.developer_options.mod_security.ctx_server, _.LuantiSettings.advanced.developer_options.debugging.ctx_server, _.LuantiSettings.advanced.developer_options.mod_profiler.ctx_server, _.LuantiSettings.advanced.developer_options.engine_profiler.ctx_server, _.LuantiSettings.advanced.advanced.networking.ctx_server, _.LuantiSettings.advanced.advanced.server.ctx_server, _.LuantiSettings.advanced.advanced.server_env_performance.ctx_server, _.LuantiSettings.advanced.advanced.mappgen.ctx_server, _.LuantiSettings.advanced.advanced.cURL.ctx_server, _.LuantiSettings.advanced.advanced.miscellaneous.ctx_server, _.LuantiSettings.advanced.hide_temporary_settings.ctx_server

-- ------------------------------- [Advanced] ------------------------------- --

-- --------------------- [Advanced] [*Developer Options] -------------------- --

---@class _.LuantiSettings.advanced.developer_options.ctx_client
--[[
#    Enable Lua modding support on client.
#    This support is experimental and API can change.
[client]
(Client modding) false
]]
---@field enable_client_modding boolean?
--[[
#    Replaces the default main menu with a custom one.
[client]
(Main menu script)
]]
---@field main_menu_script string?

-- ------------ [Advanced] [*Developer Options] [**Mod Security] ------------ --

---@class _.LuantiSettings.advanced.developer_options.mod_security.ctx_server
--[[
#    Prevent mods from doing insecure things like running shell commands.
[server]
(Enable mod security) true
]]
---@field ["secure.enable_security"] boolean?
--[[
#    Comma-separated list of trusted mods that are allowed to access insecure
#    functions even when mod security is on (via request_insecure_environment()).
[server]
(Trusted mods)
]]
---@field ["secure.trusted_mods"] string?
--[[
#    Comma-separated list of mods that are allowed to access HTTP APIs, which
#    allow them to upload and download data to/from the internet.
[server]
(HTTP mods)
]]
---@field ["secure.http_mods"] string?

-- -------------- [Advanced] [*Developer Options] [**Debugging] ------------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.debug_log_level
--- | ""
--- | "none"
--- | "error"
--- | "warning"
--- | "action"
--- | "info"
--- | "verbose"
--- | "trace"

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.deprecated_lua_api_handling
--- | "none"
--- | "log"
--- | "error"

---@class _.LuantiSettings.advanced.developer_options.debugging.ctx_common
--[[
#    Level of logging to be written to debug.txt:
#    -    <nothing> (no logging)
#    -    none (messages with no level)
#    -    error
#    -    warning
#    -    action
#    -    info
#    -    verbose
#    -    trace
[common]
(Debug log level) action ,none,error,warning,action,info,verbose,trace
]]
---@field debug_log_level core.LuantiSettings.enums.debug_log_level?
--[[
#    If the file size of debug.txt exceeds the number of megabytes specified in
#    this setting when it is opened, the file is moved to debug.txt.1,
#    deleting an older debug.txt.1 if it exists.
#    debug.txt is only moved if this setting is positive.
[common]
(Debug log file size threshold) 50 1
]]
---@field debug_log_size_max integer?
--[[
#    Handling for deprecated Lua API calls:
#    -    none: Do not log deprecated calls
#    -    log: mimic and log backtrace of deprecated call (default).
#    -    error: abort on usage of deprecated call (suggested for mod developers).
[common]
(Deprecated Lua API handling) log none,log,error
]]
---@field deprecated_lua_api_handling core.LuantiSettings.enums.deprecated_lua_api_handling?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.chat_log_level
--- | ""
--- | "none"
--- | "error"
--- | "warning"
--- | "action"
--- | "info"
--- | "verbose"
--- | "trace"

---@class _.LuantiSettings.advanced.developer_options.debugging.ctx_client : _.LuantiSettings.advanced.developer_options.debugging.ctx_common
--[[
#    Minimal level of logging to be written to chat.
[client]
(Chat log level) error ,none,error,warning,action,info,verbose,trace
]]
---@field chat_log_level core.LuantiSettings.enums.chat_log_level?
--[[
#    Enable random user input (only used for testing).
[client]
(Random input) false
]]
---@field random_input boolean?


---@class _.LuantiSettings.advanced.developer_options.debugging.ctx_server : _.LuantiSettings.advanced.developer_options.debugging.ctx_common
--[[
#    Enable random mod loading (mainly used for testing).
[server]
(Random mod load order) false
]]
---@field random_mod_load_order boolean?
--[[
#    Enable mod channels support.
[server]
(Mod channels) false
]]
---@field enable_mod_channels boolean?

-- ------------ [Advanced] [*Developer Options] [**Mod Profiler] ------------ --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.profiler.default_report_format
--- | "txt"
--- | "csv"
--- | "lua"
--- | "json"
--- | "json_pretty"

---@class _.LuantiSettings.advanced.developer_options.mod_profiler.ctx_server
--[[
#    Load the game profiler to collect game profiling data.
#    Provides a /profiler command to access the compiled profile.
#    Useful for mod developers and server operators.
[server]
(Load the game profiler)  false
]]
---@field ["profiler.load"] boolean?
--[[
#    The default format in which profiles are being saved,
#    when calling `/profiler save [format]` without format.
[server]
(Default report format)  txt txt,csv,lua,json,json_pretty
]]
---@field ["profiler.default_report_format"] core.LuantiSettings.enums.profiler.default_report_format?
--[[
#    The file path relative to your world path in which profiles will be saved to.
[server]
(Report path)
]]
---@field ["profiler.report_path"] string?
--[[
#    Instrument the methods of entities on registration.
[server]
(Entity methods)  true
]]
---@field ["instrument.entity"] boolean?
--[[
#    Instrument the action function of Active Block Modifiers on registration.
[server]
(Active Block Modifiers)  true
]]
---@field ["instrument.abm"] boolean?
--[[
#    Instrument the action function of Loading Block Modifiers on registration.
[server]
(Loading Block Modifiers)  true
]]
---@field ["instrument.lbm"] boolean?
--[[
#    Instrument chat commands on registration.
[server]
(Chat commands)  true
]]
---@field ["instrument.chatcommand"] boolean?
--[[
#    Instrument global callback functions on registration.
#    (anything you pass to a core.register_*() function)
[server]
(Global callbacks)  true
]]
---@field ["instrument.global_callback"] boolean?
--[[
#    Instrument builtin.
#    This is usually only needed by core/builtin contributors
[server]
(Builtin)  false
]]
---@field ["instrument.builtin"] boolean?
--[[
#    Have the profiler instrument itself:
#     * Instrument an empty function.
#       This estimates the overhead, that instrumentation is adding (+1 function call).
#     * Instrument the sampler being used to update the statistics.
[server]
(Profiler)  false
]]
---@field ["instrument.profiler"] boolean?

-- ----------- [Advanced] [*Developer Options] [**Engine Profiler] ---------- --

---@class _.LuantiSettings.advanced.developer_options.engine_profiler.ctx_common
--[[
#    Print the engine's profiling data in regular intervals (in seconds).
#    0 = disable. Useful for developers.
[common]
(Engine profiling data print interval) 0 0
]]
---@field profiler_print_interval integer?

---@class _.LuantiSettings.advanced.developer_options.engine_profiler.ctx_client : _.LuantiSettings.advanced.developer_options.engine_profiler.ctx_common

---@class _.LuantiSettings.advanced.developer_options.engine_profiler.ctx_server : _.LuantiSettings.advanced.developer_options.engine_profiler.ctx_common

-- ------------------------- [Advanced] [*Advanced] ------------------------- --

-- ------------------- [Advanced] [*Advanced] [**Graphics] ------------------ --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.video_driver
--- | ""
--- | "opengl"
--- | "opengl3"
--- | "ogles2"

---@class _.LuantiSettings.advanced.advanced.graphics.ctx_client
--[[
#    Enables debug and error-checking in the OpenGL driver.
[client]
(OpenGL debug) false
]]
---@field opengl_debug boolean?
--[[
#    Path to shader directory. If no path is defined, default location will be used.
[client]
(Shader path)
]]
---@field shader_path core.LuantiSettings.path?
--[[
#    The rendering back-end.
#    Note: A restart is required after changing this!
#    OpenGL is the default for desktop, and OGLES2 for Android.
[client]
(Video driver)  ,opengl,opengl3,ogles2
]]
---@field video_driver core.LuantiSettings.enums.video_driver?
--[[
#    Distance in nodes at which transparency depth sorting is enabled.
#    Use this to limit the performance impact of transparency depth sorting.
#    Set to 0 to disable it entirely.
[client]
(Transparency Sorting Distance) 16 0 128
]]
---@field transparency_sorting_distance integer?
--[[
#    Draw transparency sorted triangles grouped by their mesh buffers.
#    This breaks transparency sorting between mesh buffers, but avoids situations
#    where transparency sorting would be very slow otherwise.
[client]
(Transparency Sorting Group by Buffers) true
]]
---@field transparency_sorting_group_by_buffers boolean?
--[[
#    Radius of cloud area stated in number of 64 node cloud squares.
#    Values larger than 26 will start to produce sharp cutoffs at cloud area corners.
[client]
(Cloud radius) 12 8 62
]]
---@field cloud_radius integer?
--[[
#    Delay between mesh updates on the client in ms. Increasing this will slow
#    down the rate of mesh updates, which can help reduce jitter.
[client]
(Mapblock mesh generation delay) 0 0 25
]]
---@field mesh_generation_interval integer?
--[[
#    Number of threads to use for mesh generation.
#    Value of 0 (default) will let Luanti automatically choose the number of threads.
[client]
(Mapblock mesh generation threads) 0 0 8
]]
---@field mesh_generation_threads integer?
--[[
#    All mesh buffers with less than this number of vertices will be merged
#    during map rendering. This improves rendering performance.
[client]
(Minimum vertex count for mesh buffers) 300 0 1000
]]
---@field mesh_buffer_min_vertices integer?
--[[
#    True = 256
#    False = 128
#    Usable to make minimap smoother on slower machines.
[client]
(Minimap scan height) true
]]
---@field minimap_double_scan_height boolean?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.world_aligned_mode
--- | "disable"
--- | "enable"
--- | "force_solid"
--- | "force_nodebox"

---@class _.LuantiSettings.advanced.advanced.graphics.ctx_client
--[[
#    Textures on a node may be aligned either to the node or to the world.
#    The former mode suits better things like machines, furniture, etc., while
#    the latter makes stairs and microblocks fit surroundings better.
#    However, as this possibility is new, thus may not be used by older servers,
#    this option allows enforcing it for certain node types. Note though that
#    that is considered EXPERIMENTAL and may not work properly.
[client]
(World-aligned textures mode) enable disable,enable,force_solid,force_nodebox
]]
---@field world_aligned_mode core.LuantiSettings.enums.world_aligned_mode?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.autoscale_mode
--- | "disable"
--- | "enable"
--- | "force"

---@class _.LuantiSettings.advanced.advanced.graphics.ctx_client
--[[
#    World-aligned textures may be scaled to span several nodes. However,
#    the server may not send the scale you want, especially if you use
#    a specially-designed texture pack; with this option, the client tries
#    to determine the scale automatically based on the texture size.
#    See also texture_min_size.
#    Warning: This option is EXPERIMENTAL!
[client]
(Autoscaling mode) disable disable,enable,force
]]
---@field autoscale_mode core.LuantiSettings.enums.autoscale_mode?
--[[
#    When using bilinear/trilinear filtering, low-resolution textures
#    can be blurred, so this option automatically upscales them to preserve
#    crisp pixels. This defines the minimum texture size for the upscaled textures;
#    higher values look sharper, but require more memory.
#    This setting is ONLY applied if any of the mentioned filters are enabled.
#    This is also used as the base node texture size for world-aligned
#    texture autoscaling.
[client]
(Base texture size) 192 192 16384
]]
---@field texture_min_size integer?
--[[
#    Side length of a cube of map blocks that the client will consider together
#    when generating meshes.
#    Larger values increase the utilization of the GPU by reducing the number of
#    draw calls, benefiting especially high-end GPUs.
#    Systems with a low-end GPU (or no GPU) would benefit from smaller values.
[client]
(Client Mesh Chunksize) 1 1 16
]]
---@field client_mesh_chunk integer?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.post_processing_texture_bits
--- | "8"
--- | "10"
--- | "16"

---@class _.LuantiSettings.advanced.advanced.graphics.ctx_client
--[[
#    Decide the color depth of the texture used for the post-processing pipeline.
#    Reducing this can improve performance, but some effects (e.g. debanding)
#    require more than 8 bits to work.
#
#    Requires: enable_post_processing
[client]
(Color depth for post-processing texture) 16 8,10,16
]]
---@field post_processing_texture_bits core.LuantiSettings.enums.post_processing_texture_bits?
--[[
#    Enable Poisson disk filtering.
#    On true uses Poisson disk to make "soft shadows". Otherwise uses PCF filtering.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Poisson filtering) true
]]
---@field shadow_poisson_filter boolean?
--[[
#    Spread a complete update of the shadow map over a given number of frames.
#    Higher values might make shadows laggy, lower values
#    will consume more resources.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Map shadows update frames) 16 1 32
]]
---@field shadow_update_frames integer?
--[[
#    Set to true to render debugging breakdown of the bloom effect.
#    In debug mode, the screen is split into 4 quadrants:
#    top-left - processed base image, top-right - final image
#    bottom-left - raw base image, bottom-right - bloom texture.
#
#    Requires: enable_post_processing, enable_bloom
[client]
(Enable Bloom Debug) false
]]
---@field enable_bloom_debug boolean?

-- -------------------- [Advanced] [*Advanced] [**Sound] -------------------- --

---@class _.LuantiSettings.advanced.advanced.sound.ctx_client
--[[
#    Comma-separated list of AL and ALC extensions that should not be used.
#    Useful for testing. See al_extensions.[h,cpp] for details.
[client]
(Sound Extensions Blacklist)
]]
---@field sound_extensions_blacklist string?

-- --------------------- [Advanced] [*Advanced] [**Font] -------------------- --

---@class _.LuantiSettings.advanced.advanced.font.ctx_client
--[[
[client]
(Font bold by default) false
]]
---@field font_bold boolean?
--[[
[client]
(Font italic by default) false
]]
---@field font_italic boolean?
--[[
#    Shadow offset (in pixels) of the default font. If 0, then shadow will not be drawn.
[client]
(Font shadow) 1 0 65535
]]
---@field font_shadow integer?
--[[
#    Opaqueness (alpha) of the shadow behind the default font, between 0 and 255.
[client]
(Font shadow alpha) 127 0 255
]]
---@field font_shadow_alpha integer?
--[[
#    Font size of the default font where 1 unit = 1 pixel at 96 DPI
[client]
(Font size) 16 5 72
]]
---@field font_size integer?
--[[
#    For pixel-style fonts that do not scale well, this ensures that font sizes used
#    with this font will always be divisible by this value, in pixels. For instance,
#    a pixel font 16 pixels tall should have this set to 16, so it will only ever be
#    sized 16, 32, 48, etc., so a mod requesting a size of 25 will get 32.
[client]
(Font size divisible by) 1 1
]]
---@field font_size_divisible_by integer?
--[[
#    Path to the default font. Must be a TrueType font.
#    The fallback font will be used if the font cannot be loaded.
[client]
(Regular font path) fonts/Arimo-Regular.ttf
]]
---@field font_path core.LuantiSettings.path?
--[[
#    Path to the default bold font. Must be a TrueType font.
#    The fallback font will be used if the font cannot be loaded.
[client]
(Bold font path) fonts/Arimo-Bold.ttf
]]
---@field font_path_bold core.LuantiSettings.path?
--[[
#    Path to the default italic font. Must be a TrueType font.
#    The fallback font will be used if the font cannot be loaded.
[client]
(Italic font path) fonts/Arimo-Italic.ttf
]]
---@field font_path_italic core.LuantiSettings.path?
--[[
#    Path to the default bold italic font. Must be a TrueType font.
#    The fallback font will be used if the font cannot be loaded.
[client]
(Bold and Italic font path) fonts/Arimo-BoldItalic.ttf
]]
---@field font_path_bold_italic core.LuantiSettings.path?
--[[
#    Font size of the monospace font where 1 unit = 1 pixel at 96 DPI
[client]
(Monospace font size) 16 5 72
]]
---@field mono_font_size integer?
--[[
#    For pixel-style fonts that do not scale well, this ensures that font sizes used
#    with this font will always be divisible by this value, in pixels. For instance,
#    a pixel font 16 pixels tall should have this set to 16, so it will only ever be
#    sized 16, 32, 48, etc., so a mod requesting a size of 25 will get 32.
[client]
(Monospace font size divisible by) 1 1
]]
---@field mono_font_size_divisible_by integer?
--[[
#    Path to the monospace font. Must be a TrueType font.
#    This font is used for e.g. the console and profiler screen.
[client]
(Monospace font path) fonts/Cousine-Regular.ttf
]]
---@field mono_font_path core.LuantiSettings.path?
--[[
#    Path to the bold monospace font. Must be a TrueType font.
#    This font is used for e.g. the console and profiler screen.
[client]
(Bold monospace font path) fonts/Cousine-Bold.ttf
]]
---@field mono_font_path_bold core.LuantiSettings.path?
--[[
#    Path to the italic monospace font. Must be a TrueType font.
#    This font is used for e.g. the console and profiler screen.
[client]
(Italic monospace font path) fonts/Cousine-Italic.ttf
]]
---@field mono_font_path_italic core.LuantiSettings.path?
--[[
#    Path to the bold italic monospace font. Must be a TrueType font.
#    This font is used for e.g. the console and profiler screen.
[client]
(Bold and italic monospace font path) fonts/Cousine-BoldItalic.ttf
]]
---@field mono_font_path_bold_italic core.LuantiSettings.path?
--[[
#    Path of the fallback font. Must be a TrueType font.
#    This font will be used for certain languages or if the default font is unavailable.
[client]
(Fallback font path) fonts/DroidSansFallbackFull.ttf
]]
---@field fallback_font_path core.LuantiSettings.path?

-- ------------------- [Advanced] [*Advanced] [**Lighting] ------------------ --

---@class _.LuantiSettings.advanced.advanced.lighting.ctx_client
--[[
#    Gradient of light curve at minimum light level.
#    Controls the contrast of the lowest light levels.
[client]
(Light curve low gradient) 0.0 0.0 3.0
]]
---@field lighting_alpha number?
--[[
#    Gradient of light curve at maximum light level.
#    Controls the contrast of the highest light levels.
[client]
(Light curve high gradient) 1.5 0.0 3.0
]]
---@field lighting_beta number?
--[[
#    Strength of light curve boost.
#    The 3 'boost' parameters define a range of the light
#    curve that is boosted in brightness.
[client]
(Light curve boost) 0.2 0.0 0.4
]]
---@field lighting_boost number?
--[[
#    Center of light curve boost range.
#    Where 0.0 is minimum light level, 1.0 is maximum light level.
[client]
(Light curve boost center) 0.5 0.0 1.0
]]
---@field lighting_boost_center number?
--[[
#    Spread of light curve boost range.
#    Controls the width of the range to be boosted.
#    Standard deviation of the light curve boost Gaussian.
[client]
(Light curve boost spread) 0.2 0.0 0.4
]]
---@field lighting_boost_spread number?

-- ------------------ [Advanced] [*Advanced] [**Networking] ----------------- --

---@class _.LuantiSettings.advanced.advanced.networking.ctx_common
--[[
#    Enable IPv6 support (for both client and server).
#    Required for IPv6 connections to work at all.
[common]
(IPv6) true
]]
---@field enable_ipv6 boolean?
--[[
#    Maximum number of packets sent per send step in the low-level networking code.
#    You generally don't need to change this, however busy servers may benefit from a higher number.
[common]
(Max. packets per iteration) 1024 1 65535
]]
---@field max_packets_per_iteration integer?

---@class _.LuantiSettings.advanced.advanced.networking.ctx_server : _.LuantiSettings.advanced.advanced.networking.ctx_common
--[[
#    Prometheus listener address.
#    If Luanti is compiled with Prometheus support, this setting
#    enables the metrics listener for Prometheus on that address.
#    By default you can fetch metrics from http://127.0.0.1:30000/metrics.
#    An empty value disables the metrics listener.
[server]
(Prometheus listener address) 127.0.0.1:30000
]]
---@field prometheus_listener_address string?
--[[
#    Maximum number of blocks that are simultaneously sent per client.
#    The maximum total count is calculated dynamically:
#    max_total = ceil((#clients + max_users) * per_client / 4)
[server]
(Maximum simultaneous block sends per client) 40 1 4294967295
]]
---@field max_simultaneous_block_sends_per_client integer?
--[[
#    To reduce lag, block transfers are slowed down when a player is building something.
#    This determines how long they are slowed down after placing or removing a node.
[server]
(Delay in sending blocks after building) 2.0 0.0
]]
---@field full_block_send_enable_min_time_from_building number?
--[[
#    Compression level to use when sending mapblocks to the client.
#    -1 - use default compression level
#     0 - least compression, fastest
#     9 - best compression, slowest
[server]
(Map Compression Level for Network Transfer) -1 -1 9
]]
---@field map_compression_level_net integer?

---@class _.LuantiSettings.advanced.advanced.networking.ctx_client : _.LuantiSettings.advanced.advanced.networking.ctx_common
--[[
#    Maximum size of the client's outgoing chat queue.
#    0 to disable queueing and -1 to make the queue size unlimited.
[client]
(Maximum size of the client's outgoing chat queue) 20 -1 32767
]]
---@field max_out_chat_queue_size integer?
--[[
#    Timeout for client to remove unused map data from memory, in seconds.
[client]
(Mapblock unload timeout) 600.0 0.0
]]
---@field client_unload_unused_data_timeout number?
--[[
#    Maximum number of mapblocks for client to be kept in memory.
#    Note that there is an internal dynamic minimum number of blocks that
#    won't be deleted, depending on the current view range.
#    Set to -1 for no limit.
[client]
(Mapblock limit) 7500 -1 2147483647
]]
---@field client_mapblock_limit integer?

-- -------------------- [Advanced] [*Advanced] [**Server] ------------------- --

---@class _.LuantiSettings.advanced.advanced.server.ctx_server
--[[
#    Format of player chat messages. The following strings are valid placeholders:
#    @name, @message, @timestamp (optional)
[server]
(Chat message format) <@name> @message
]]
---@field chat_message_format string?
--[[
#    If the execution of a chat command takes longer than this specified time in
#    seconds, add the time information to the chat command message
[server]
(Chat command time message threshold) 0.1 0.0
]]
---@field chatcommand_msg_time_threshold number?
--[[
#    A message to be displayed to all clients when the server shuts down.
[server]
(Shutdown message) Server shutting down.
]]
---@field kick_msg_shutdown string?
--[[
#    A message to be displayed to all clients when the server crashes.
[server]
(Crash message) This server has experienced an internal error. You will now be disconnected.
]]
---@field kick_msg_crash string?
--[[
#    Whether to ask clients to reconnect after a (Lua) crash.
#    Set this to true if your server is set up to restart automatically.
[server]
(Ask to reconnect after crash) false
]]
---@field ask_reconnect_on_crash boolean?

-- ------------ [Advanced] [*Advanced] [**Server/Env Performance] ----------- --

---@class _.LuantiSettings.advanced.advanced.server_env_performance.ctx_server
--[[
#    Length of a server tick (the interval at which everything is generally updated),
#    stated in seconds.
#    Does not apply to sessions hosted from the client menu.
#    This is a lower bound, i.e. server steps may not be shorter than this, but
#    they are often longer.
[server]
(Dedicated server step) 0.09 0.0 1.0
]]
---@field dedicated_server_step number?
--[[
#    Whether players are shown to clients without any range limit.
#    Deprecated, use the setting player_transfer_distance instead.
[server]
(Unlimited player transfer distance) true
]]
---@field unlimited_player_transfer_distance boolean?
--[[
#    Defines the maximal player transfer distance in blocks (0 = unlimited).
[server]
(Player transfer distance) 0 0 65535
]]
---@field player_transfer_distance integer?
--[[
#    From how far clients know about objects, stated in mapblocks (16 nodes).
#
#    Setting this larger than active_block_range will also cause the server
#    to maintain active objects up to this distance in the direction the
#    player is looking. (This can avoid mobs suddenly disappearing from view)
[server]
(Active object send range) 8 1 65535
]]
---@field active_object_send_range_blocks integer?
--[[
#    The radius of the volume of blocks around every player that is subject to the
#    active block stuff, stated in mapblocks (16 nodes).
#    In active blocks objects are loaded and ABMs run.
#    This is also the minimum range in which active objects (mobs) are maintained.
#    This should be configured together with active_object_send_range_blocks.
[server]
(Active block range) 4 1 65535
]]
---@field active_block_range integer?
--[[
#    From how far blocks are sent to clients, stated in mapblocks (16 nodes).
[server]
(Max block send distance) 12 1 65535
]]
---@field max_block_send_distance integer?
--[[
#    Default maximum number of forceloaded mapblocks.
#    Set this to -1 to disable the limit.
[server]
(Maximum forceloaded blocks) 16 -1
]]
---@field max_forceloaded_blocks integer?
--[[
#    Interval of saving important changes in the world, stated in seconds.
[server]
(Map save interval) 5.3 0.001
]]
---@field server_map_save_interval number?
--[[
#    How long the server will wait before unloading unused mapblocks, stated in seconds.
#    Higher value is smoother, but will use more RAM.
[server]
(Unload unused server data) 29 0 4294967295
]]
---@field server_unload_unused_data_timeout integer?
--[[
#    Maximum number of statically stored objects in a block.
[server]
(Maximum objects per block) 256 256 65535
]]
---@field max_objects_per_block integer?
--[[
#    Length of time between active block management cycles, stated in seconds.
[server]
(Active block management interval) 2.0 0.0
]]
---@field active_block_mgmt_interval number?
--[[
#    Length of time between Active Block Modifier (ABM) execution cycles, stated in seconds.
[server]
(ABM interval) 1.0 0.1 30.0
]]
---@field abm_interval number?
--[[
#    The time budget allowed for ABMs to execute on each step
#    (as a fraction of the ABM Interval)
[server]
(ABM time budget) 0.2 0.1 0.9
]]
---@field abm_time_budget number?
--[[
#    Length of time between NodeTimer execution cycles, stated in seconds.
[server]
(NodeTimer interval) 0.2 0.1 1.0
]]
---@field nodetimer_interval number?
--[[
#    Max liquids processed per step.
[server]
(Liquid loop max) 100000 1 4294967295
]]
---@field liquid_loop_max integer?
--[[
#    The time (in seconds) that the liquids queue may grow beyond processing
#    capacity until an attempt is made to decrease its size by dumping old queue
#    items.  A value of 0 disables the functionality.
[server]
(Liquid queue purge time) 0 0 65535
]]
---@field liquid_queue_purge_time integer?
--[[
#    Liquid update interval in seconds.
[server]
(Liquid update tick) 1.0 0.001
]]
---@field liquid_update number?
--[[
#    At this distance the server will aggressively optimize which blocks are sent to
#    clients.
#    Small values potentially improve performance a lot, at the expense of visible
#    rendering glitches (some blocks might not be rendered correctly in caves).
#    Setting this to a value greater than max_block_send_distance disables this
#    optimization.
#    Stated in MapBlocks (16 nodes).
[server]
(Block send optimize distance) 4 2 2047
]]
---@field block_send_optimize_distance integer?
--[[
#    If enabled, the server will perform map block occlusion culling based on
#    on the eye position of the player. This can reduce the number of blocks
#    sent to the client by 50-80%. Clients will no longer receive most
#    invisible blocks, so that the utility of noclip mode is reduced.
[server]
(Server-side occlusion culling) true
]]
---@field server_side_occlusion_culling boolean?
--[[
#    At this distance the server will perform a simpler and cheaper occlusion check.
#    Smaller values potentially improve performance, at the expense of temporarily visible
#    rendering glitches (missing blocks).
#    This is especially useful for very large viewing range (upwards of 500).
#    Stated in MapBlocks (16 nodes).
[server]
(Block cull optimize distance) 25 2 2047
]]
---@field block_cull_optimize_distance integer?

-- -------------------- [Advanced] [*Advanced] [**Mapgen] ------------------- --

---@class _.LuantiSettings.advanced.advanced.mappgen.ctx_server
--[[
#    Size of mapchunks generated by mapgen, stated in mapblocks (16 nodes).
#    WARNING: There is no benefit, and there are several dangers, in
#    increasing this value above 5.
#    Reducing this value increases cave and dungeon density.
#    Altering this value is for special usage, leaving it unchanged is
#    recommended.
[world_creation]
(Chunk size) 5 1 10
]]
---@field chunksize integer?
--[[
#    Dump the mapgen debug information.
[server]
(Mapgen debug) false
]]
---@field enable_mapgen_debug_info boolean?
--[[
#    Maximum number of blocks that can be queued for loading.
[server]
(Absolute limit of queued blocks to emerge) 1024 1 1000000
]]
---@field emergequeue_limit_total integer?
--[[
#    Maximum number of blocks to be queued that are to be loaded from file.
#    This limit is enforced per player.
[server]
(Per-player limit of queued blocks load from disk) 128 1 1000000
]]
---@field emergequeue_limit_diskonly integer?
--[[
#    Maximum number of blocks to be queued that are to be generated.
#    This limit is enforced per player.
[server]
(Per-player limit of queued blocks to generate) 128 1 1000000
]]
---@field emergequeue_limit_generate integer?
--[[
#    Number of emerge threads to use.
#    Value 0:
#    -    Automatic selection. The number of emerge threads will be
#    -    'number of processors - 2', with a lower limit of 1.
#    Any other value:
#    -    Specifies the number of emerge threads, with a lower limit of 1.
#    WARNING: Increasing the number of emerge threads increases engine mapgen
#    speed, but this may harm game performance by interfering with other
#    processes, especially in singleplayer and/or when running Lua code in
#    'on_generated'. For many users the optimum setting may be '1'.
[server]
(Number of emerge threads) 1 0 32767
]]
---@field num_emerge_threads integer?

-- --------------------- [Advanced] [*Advanced] [**cURL] -------------------- --

---@class _.LuantiSettings.advanced.advanced.cURL.ctx_common
--[[
#    Maximum time an interactive request (e.g. server list fetch) may take, stated in milliseconds.
[common]
(cURL interactive timeout) 20000 1000 2147483647
]]
---@field curl_timeout integer?
--[[
#    Limits number of parallel HTTP requests. Affects:
#    -    Media fetch if server uses remote_media setting.
#    -    Serverlist download and server announcement.
#    -    Downloads performed by main menu (e.g. mod manager).
#    Only has an effect if compiled with cURL.
[common]
(cURL parallel limit) 8 1 2147483647
]]
---@field curl_parallel_limit integer?
--[[
#    Maximum time a file download (e.g. a mod download) may take, stated in milliseconds.
[common]
(cURL file download timeout) 300000 5000 2147483647
]]
---@field curl_file_download_timeout integer?

---@class _.LuantiSettings.advanced.advanced.cURL.ctx_server : _.LuantiSettings.advanced.advanced.cURL.ctx_common

---@class _.LuantiSettings.advanced.advanced.cURL.ctx_client : _.LuantiSettings.advanced.advanced.cURL.ctx_common

-- --------------- [Advanced] [*Advanced] [**Client Debugging] -------------- --

---@class _.LuantiSettings.advanced.advanced.client_debugging.ctx_client
--[[
#    Key for toggling the camera update. Only usable with 'debug' privilege.
[client]
(Toggle camera update)
]]
---@field keymap_toggle_update_camera _.LuantiSettings.key?
--[[
#    Key for switching to the previous entry in Quicktune.
[client]
(Quicktune: select previous entry)
]]
---@field keymap_quicktune_prev _.LuantiSettings.key?
--[[
#    Key for switching to the next entry in Quicktune.
[client]
(Quicktune: select next entry)
]]
---@field keymap_quicktune_next _.LuantiSettings.key?
--[[
#    Key for decrementing the selected value in Quicktune.
[client]
(Quicktune: decrement value)
]]
---@field keymap_quicktune_dec _.LuantiSettings.key?
--[[
#    Key for incrementing the selected value in Quicktune.
[client]
(Quicktune: increment value)
]]
---@field keymap_quicktune_inc _.LuantiSettings.key?

-- ---------------- [Advanced] [*Advanced] [**Miscellaneous] ---------------- --

---@class _.LuantiSettings.advanced.advanced.miscellaneous.ctx_common
--[[
#    Windows systems only: Start Luanti with the command line window in the background.
#    Contains the same information as the file debug.txt (default name).
[common]
(Enable console window) false
]]
---@field enable_console boolean?

---@class _.LuantiSettings.advanced.advanced.miscellaneous.ctx_client : _.LuantiSettings.advanced.advanced.miscellaneous.ctx_common
--[[
#    Clickable weblinks (middle-click or Ctrl+left-click) enabled in chat console output.
[client]
(Chat weblinks) true
]]
---@field clickable_chat_weblinks boolean?
--[[
#    Adjust the detected display density, used for scaling UI elements.
[client]
(Display Density Scaling Factor) 1 0.5 5.0
]]
---@field display_density_factor number?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.sqlite_synchronous
--- | "0"
--- | "1"
--- | "2"

---@class _.LuantiSettings.advanced.advanced.miscellaneous.ctx_server : _.LuantiSettings.advanced.advanced.miscellaneous.ctx_common
--[[
#    If enabled, invalid world data won't cause the server to shut down.
#    Only enable this if you know what you are doing.
[server]
(Ignore world errors) false
]]
---@field ignore_world_load_errors boolean?
--[[
#    Number of extra blocks that can be loaded by /clearobjects at once.
#    This is a trade-off between SQLite transaction overhead and
#    memory consumption (4096=100MB, as a rule of thumb).
[server]
(Max. clearobjects extra blocks) 4096 0 4294967295
]]
---@field max_clearobjects_extra_loaded_blocks integer?
--[[
#    World directory (everything in the world is stored here).
#    Not needed if starting from the main menu.
[server]
(Map directory)
]]
---@field ["map-dir"] core.LuantiSettings.path?
--[[
#    See https://www.sqlite.org/pragma.html#pragma_synchronous
[server]
(Synchronous SQLite) 2 0,1,2
]]
---@field sqlite_synchronous core.LuantiSettings.enums.sqlite_synchronous?
--[[
#    Compression level to use when saving mapblocks to disk.
#    -1 - use default compression level
#     0 - least compression, fastest
#     9 - best compression, slowest
[server]
(Map Compression Level for Disk Storage) -1 -1 9
]]
---@field map_compression_level_disk integer?
--[[
#    Enable usage of remote media server (if provided by server).
#    Remote servers offer a significantly faster way to download media (e.g. textures)
#    when connecting to the server.
[client]
(Connect to external media server) true
]]
---@field enable_remote_media_server boolean?
--[[
#    File in client/serverlist/ that contains your favorite servers displayed in the
#    Multiplayer Tab.
[client]
(Serverlist file) favoriteservers.json
]]
---@field serverlist_file string?

-- ------------------------- [Advanced] [*Gamepads] ------------------------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.joystick_type
--- | "auto"
--- | "generic"
--- | "xbox"
--- | "dragonrise_gamecube"

---@class _.LuantiSettings.advanced.gamepads.ctx_client
--[[
#    Enable joysticks. Requires a restart to take effect
[client]
(Enable joysticks) false
]]
---@field enable_joysticks boolean?
--[[
#    The identifier of the joystick to use
[client]
(Joystick ID) 0 0 255
]]
---@field joystick_id integer?
--[[
#    The type of joystick
[client]
(Joystick type) auto auto,generic,xbox,dragonrise_gamecube
]]
---@field joystick_type core.LuantiSettings.enums.joystick_type?
--[[
#    The time in seconds it takes between repeated events
#    when holding down a joystick button combination.
[client]
(Joystick button repetition interval) 0.17 0.001
]]
---@field repeat_joystick_button_time number?
--[[
#    The dead zone of the joystick
[client]
(Joystick dead zone) 2048 0 65535
]]
---@field joystick_deadzone integer?
--[[
#    The sensitivity of the joystick axes for moving the
#    in-game view frustum around.
[client]
(Joystick frustum sensitivity) 170.0 0.001
]]
---@field joystick_frustum_sensitivity number?

-- ----------------- [Advanced] [*Hide: Temporary Settings] ----------------- --

---@class _.LuantiSettings.advanced.hide_temporary_settings.ctx_common
--[[
#    Path to texture directory. All textures are first searched from here.
[common]
(Texture path)
]]
---@field texture_path core.LuantiSettings.path?
--[[
#    Enables minimap.
[common]
(Minimap) true
]]
---@field enable_minimap boolean?
--[[
#    Shape of the minimap. Enabled = round, disabled = square.
[common]
(Round minimap) true
]]
---@field minimap_shape_round boolean?
--[[
#    Address to connect to.
#    Leave this blank to start a local server.
#    Note that the address field in the main menu overrides this setting.
[common]
(Server address)
]]
---@field address string?
--[[
#    Port to connect to (UDP).
#    Note that the port field in the main menu overrides this setting.
[common]
(Remote port) 30000 1 65535
]]
---@field remote_port integer?
--[[
#    Enable players getting damage and dying.
[common]
(Damage) false
]]
---@field enable_damage boolean?
--[[
#    Enable creative mode for all players
[common]
(Creative) false
]]
---@field creative_mode boolean?
--[[
#    Whether to allow players to damage and kill each other.
[common]
(Player versus player) true
]]
---@field enable_pvp boolean?
--[[
#    Player is able to fly without being affected by gravity.
#    This requires the "fly" privilege on the server.
[common]
(Flying) false
]]
---@field free_move boolean?
--[[
#    If enabled, makes move directions relative to the player's pitch when flying or swimming.
[common]
(Pitch move mode) false
]]
---@field pitch_move boolean?
--[[
#    Fast movement (via the "Aux1" key).
#    This requires the "fast" privilege on the server.
[common]
(Fast movement) false
]]
---@field fast_move boolean?
--[[
#    If enabled together with fly mode, player is able to fly through solid nodes.
#    This requires the "noclip" privilege on the server.
[common]
(Noclip) false
]]
---@field noclip boolean?
--[[
#    Continuous forward movement, toggled by autoforward key.
#    Press the autoforward key again or the backwards movement to disable.
[common]
(Continuous forward) false
]]
---@field continuous_forward boolean?
--[[
#    This can be bound to a key to toggle camera smoothing when looking around.
#    Useful for recording videos
[common]
(Cinematic mode) false
]]
---@field cinematic boolean?
--[[
#    Affects mods and texture packs in the Content and Select Mods menus, as well as
#    setting names.
#    Controlled by a checkbox in the settings menu.
[common]
(Show technical names) false
]]
---@field show_technical_names boolean?
--[[
#    Controlled by a checkbox in the settings menu.
[common]
(Show advanced settings) false
]]
---@field show_advanced boolean?

---@class _.LuantiSettings.advanced.hide_temporary_settings.ctx_server : _.LuantiSettings.advanced.hide_temporary_settings.ctx_common

---@class _.LuantiSettings.advanced.hide_temporary_settings.ctx_client : _.LuantiSettings.advanced.hide_temporary_settings.ctx_common