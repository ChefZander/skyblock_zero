---@meta
---@version 5.1|JIT

-- This work is marked with CC0 1.0 - https://creativecommons.org/publicdomain/zero/1.0/
-- by frog :D
-- Types for luanti

---@class vector
---@field x number
---@field y number
---@field z number
vector = {}

---@param x number
---@param y number
---@param z number
---@return vector
function vector.new(x, y, z) end

---@return vector
function vector.zero() end

---Returns v, np, where v is a vector read from the given string s and np is the next position in the string after the vector.
---Returns nil on failure.
--- s: Has to begin with a substring of the form "(x, y, z)". Additional spaces, leaving away commas and adding an additional comma to the end is allowed.
---@param v vector
---@return vector
function vector.copy(v) end

---@return vector
---@param init integer?
---@param s string
function vector.from_string(s, init) end

---@param v vector
---@return string
function vector.to_string(v) end

---@param p1 vector
---@param p2 vector
---@return vector
function vector.direction(p1, p2) end

---@param p1 vector
---@param p2 vector
---@return number
function vector.distance(p1, p2) end

---@param v vector
---@return number
function vector.length(v) end

---@param v vector
---@return vector
function vector.normalize(v) end

---@param v vector
---@return vector
function vector.floor(v) end

---@param v vector
---@return vector
function vector.round(v) end

---@param v vector
---@param func function
---@return vector
function vector.round(v, func) end

---@param v vector
---@param w vector
---@param func function
---@return vector
function vector.combine(v, w, func) end

---@param v1 vector
---@param v2 vector
---@return vector
function vector.equals(v1, v2) end

---@param v1 vector
---@param v2 vector
---@return vector
function vector.sort(v1, v2) end

---@param v1 vector
---@param v2 vector
---@return vector
function vector.angle(v1, v2) end

---@param v1 vector
---@param v2 vector
---@return vector
function vector.dot(v1, v2) end

---@param v1 vector
---@param v2 vector
---@return vector
function vector.cross(v1, v2) end

---@param v1 vector
---@param v2 vector
---@return vector
function vector.offset(v1, v2) end

---@param v vector
---@return boolean
function vector.check(v) end

---@param v vector
---@param x number|vector
---@return vector
function vector.add(v, x) end

---@param v vector
---@param x number|vector
---@return vector
function vector.subtract(v, x) end

---@param v vector
---@param x number|vector
---@return vector
function vector.multiply(v, x) end

---@param v vector
---@param x number|vector
---@return vector
function vector.divide(v, x) end

---@param pos vector
---@return number
function core.hash_node_position(pos) end

---@class node
---@field name string
---@field param2 integer
---@field param1 integer

---@class ObjectRef


core = {}

---@deprecated
minetest = core

---@alias alias "mapgen_stone" | "mapgen_water_source" | "mapgen_river_water_source" | "mapgen_lava_source" | "mapgen_cobble" | "mapgen_singlenode"

---@param alias alias
---@param original_name string
---@return nil
function core.register_alias(alias, original_name) end

--- The only difference between core.register_alias and core.register_alias_force is that if an item named alias already exists, core.register_alias will do nothing while core.register_alias_force will unregister it.
---@param alias alias
---@param original_name string
---@return nil
function core.register_alias_force(alias, original_name) end

---@class vector

---@class sound_def
---@field gain number
---@field pitch number
---@field fade number
---@field start_time number
---@field loop boolean
---@field pos vector
---@field object ObjectRef
---@field to_player string
---@field exclude_player string
---@field max_hear_distance number

---@class node_def: any

---@type table<string, table>
core.registered_nodes = {}

--- x1, y1, z1, x2, y2, z2
---@alias box table<integer,integer> | nil
---@alias box_or_boxes box | table<integer, box> | nil

---@class nodebox
---@field type string
---@field fixed box_or_boxes
---@field wall_top box
---@field wall_bottom box
---@field wall_side box
---@field connect_top box_or_boxes
---@field connect_bottom box_or_boxes
---@field connect_front box_or_boxes
---@field connect_left box_or_boxes
---@field connect_back box_or_boxes
---@field connect_right box_or_boxes
---@field disconnected_top box_or_boxes
---@field disconnected_bottom box_or_boxes
---@field disconnected_front box_or_boxes
---@field disconnected_left box_or_boxes
---@field disconnected_back box_or_boxes
---@field disconnected_right box_or_boxes
--- When there is *no* neighbour
---@field disconnected box_or_boxes
--- when there are *no* neighbours to the sides
---@field disconnected_sides box_or_boxes


---@alias pointed_thing { type: "nothing" } | { type: "node", under: vector, above: vector, intersection_point: vector | nil, box_id: integer, intersection_normal: vector | nil} | { type: "object", ref: ObjectRef, intersection_point: vector | nil, box_id: integer, intersection_normal: vector | nil }

---@class ItemStack_table
---@field name string
---@field count integer | nil
---@field wear integer | nil
---@field metadata string | nil

---@alias group_type integer | nil

---@class groups<string, group_type>: { [string]: group_type }
---@field attached_node group_type
---@field bouncy group_type
---@field connect_to_raillike group_type
---@field dig_immediate group_type
---@field disable_jump group_type
---@field disable_descent group_type
---@field fall_damage_add_percent group_type
---@field falling_node group_type
---@field float group_type
---@field level group_type
---@field slippery group_type
---@field disable_repair group_type

---@class armor_groups<string, group_type>: { [string]: group_type }
---@field immortal group_type
---@field fall_damage_add_percent group_type
---@field punch_operable group_type

---@param itemname string
---@param groupname string
---@return integer
function core.get_item_group(itemname, groupname) end

---@class ItemStack:userdata

--- #RGB defines a color in hexadecimal format.
---#RGBA defines a color in hexadecimal format and alpha channel.
---#RRGGBB defines a color in hexadecimal format.
---#RRGGBBAA defines a color in hexadecimal format and alpha channel.
---Named colors are also supported and are equivalent to CSS Color Module Level 4. To specify the value of the alpha channel, append #A or #AA to the end of the color name (e.g. colorname#08).
---@class ColorString:string


---A ColorSpec specifies a 32-bit color. It can be written in any of the following forms:
---    table form: Each element ranging from 0..255 (a, if absent, defaults to 255):
---        colorspec = {a=255, r=0, g=255, b=0}
---    numerical form: The raw integer value of an ARGB8 quad:
---        colorspec = 0xFF00FF00
---    string form: A ColorString (defined above):
---        colorspec = "green"
---@alias ColorSpec string|table|integer


---@param color ColorString
---@return string
function core.get_color_escape_sequence(color) end

---@param color ColorString
---@param message string
---@return string
function core.colorize(color, message) end

---@param color ColorString
---@return string
function core.get_background_escape_sequence(color) end

---@param str string
---@return string
function core.strip_foreground_colors(str) end

---@param str string
---@return string
function core.strip_background_colors(str) end

---@param str string
---@return string
function core.strip_colors(str) end

---@param obj any
---@param name string?
---@param dumped table?
---@return string
function dump2(obj, name, dumped) end

---@param obj any
---@param dumped table?
function dump(obj, dumped) end

---@param x number
---@param y number
---@return number
function math.hypot(x, y) end

---@param x number
---@param tolerance number | nil
---@return number
function math.sign(x, tolerance) end

---@param x number
---@return number
function math.factorial(x) end

---@param x number
---@return number
function math.round(x) end

---@param str string
---@param separator string | nil
---@param include_empty boolean|nil
---@param max_splits integer|nil
---@param sep_is_pattern boolean|nil
---@return table<integer, string>
function string.split(str, separator, include_empty, max_splits, sep_is_pattern) end

---@return string
function string:trim() end

---@param str string
---@param limit integer | nil
---@param as_table boolean | nil
---@return string | table
function core.wrap_text(str, limit, as_table) end

---@param pos vector
---@param decimal_places integer | nil
---@return string
function core.pos_to_string(pos, decimal_places) end

---@param relative_to vector | nil
---@param str string
---@return [vector, vector]
function core.string_to_area(str, relative_to) end

---@param string string
---@return string
function core.formspec_escape(string) end

---@param arg string
---@return string
function core.is_yes(arg) end

---@param arg number
---@return boolean
function core.is_nan(arg) end

---@return number
function core.get_us_time() end

---@param table table
---@return table
function table.copy(table) end

---@param list table
---@param val number
---@return integer
function table.indexof(list, val) end

---@param table table
---@param other_table table
function table.insert_all(table, other_table) end

---@param t table
---@return table
function table.key_value_swap(t) end

---@param t table
---@param from integer?
---@param to integer?
---@param random_func function?
function table.shuffle(t, from, to, random_func) end

---@param pointed_thing pointed_thing
---@param placer ObjectRef
---@return vector
function core.pointed_thing_to_face_pos(placer, pointed_thing) end

---@param uses integer
---@param initial_wear integer?
---@return integer
function core.get_tool_wear_after_use(uses, initial_wear) end

--- TEMPORARY CLASSES YO HEY
---@class tool_capabilities: table
---@class dig_params: table
---@class hit_params: table
---@class item_def: table
---@class abm_def: table
---@class lbm_def: table
---@class biome_def: table
---@class luaentity_def: table
---@class ore_def: table
---@class deco_def: table
---@class recipe_def: table
---@class priv_def: table
---@class chatcommand_def: table
---@class schem_def: table

---@param tool_capabilities tool_capabilities
---@param groups table no its not the groups type for a reason
---@param wear integer?
---@return dig_params
function core.get_dig_params(groups, tool_capabilities, wear) end

---@param groups table
---@param tool_capabilities tool_capabilities
---@param time_from_last_punch integer?
---@param wear integer?
---@return hit_params
function core.get_hit_params(groups, tool_capabilities, time_from_last_punch, wear) end

---@param textdomain string?
---@return fun(str: string, ...:string ): string
function core.get_translator(textdomain) end

---@param textdomain string?
---@param str string
---@vararg string
function core.translate(textdomain, str, ...) end

---@param lang_code string
---@param string string
function core.get_translated_string(lang_code, string) end

---@class NoiseParams
---@field offset integer
---@field scale integer
---@field spread vector
---@field seed integer
---@field octaves integer
---@field persistence integer
---@field lacunarity integer
---@field flags table|string|nil


---@param p1 vector?
---@param p2 vector?
---@return VoxelManip
function core.get_voxel_manip(p1, p2) end

---@class VoxelManip
---@operator call:fun(p1, p2):VoxelManip
VoxelManip = {}

---returns actual emerged pmin, actual emerged pmax
---@param p1 vector
---@param p2 vector
---@return [vector, vector]
function VoxelManip:read_from_map(p1, p2) end

---@param light boolean?
function VoxelManip:write_to_map(light) end

---@param pos vector
---@return node
function VoxelManip:get_node_at(pos) end

---@param pos vector
---@param node node
function VoxelManip:set_node_at(pos, node) end

---@class content_ids:integer

---@param buffer table?
---@return table<integer, content_ids>
function VoxelManip:get_data(buffer) end

---@param data table<integer, content_ids>
function VoxelManip:set_data(data) end

---Does literally nothing lmao
---@deprecated
---@return nil
function VoxelManip:update_map() end

--- day = 0...15, night = 0...15
---@alias vmanip_light { day: integer, night: integer }

---@param light vmanip_light
---@param p1 vector?
---@param p2 vector?
function VoxelManip:set_lighting(light, p1, p2) end

---@param buffer table?
---@return table?
function VoxelManip:get_light_data(buffer) end

---@param param2_data table<integer, integer>
---@return nil
function VoxelManip:set_param2_data(param2_data) end

---@param p1 vector?
---@param p2 vector?
---@param propagate_shadow boolean?
function VoxelManip:calc_lighting(p1, p2, propagate_shadow) end

---@return nil
function VoxelManip:update_liquids() end

---@return boolean
function VoxelManip:was_modified() end

---@return [vector, vector]
function VoxelManip:get_emerged_area() end

---@class VoxelArea
VoxelArea = {}
---@operator call:fun(pmin, pmax):VoxelArea|fun(edges: { MinEdge: vector, MaxEdge: vector }):VoxelArea

---@return vector
function VoxelArea:getExtent() end

---@return vector
function VoxelArea:getVolume() end

---@param x number
---@param y number
---@param z number
---@return integer
function VoxelArea:index(x, y, z) end

---@param p number
---@return integer
function VoxelArea:indexp(p) end

---@param i integer
---@return vector
function VoxelArea:position(i) end

---@param x number
---@param y number
---@param z number
---@return boolean
function VoxelArea:contains(x, y, z) end

---@param p vector
---@return boolean
function VoxelArea:containsp(p) end

---@param i integer
---@return boolean
function VoxelArea:containsi(i) end

---@param minx number
---@param miny number
---@param minz number
---@param maxx number
---@param maxy number
---@param maxz number
---@nodiscard
function VoxelArea:iter(minx, miny, minz, maxx, maxy, maxz) end

---@param minp vector
---@param maxp vector
---@nodiscard
function VoxelArea:interp(minp, maxp) end

---@class l_system_tree_def
---@field axiom string
---@field rules_a string|nil
---@field rules_b string|nil
---@field rules_c string|nil
---@field rules_d string|nil
---@field trunk string
---@field leaves string
---@field leaves2 string
---@field leaves2_chance string
---@field angle number
---@field iterations number
---@field random_level number
---@field trunk_type "single"|"double"|"crossed"
---@field thin_branches boolean
---@field fruit string
---@field fruit_chance number
---@field seed number|nil

---@return string
function core.get_current_modname() end

---@param modname string
---@return string
function core.get_modpath(modname) end

---@return string[]
function core.get_modnames() end

---@return { id: string, title:string, author: string, path:string}
function core.get_game_info() end

---@return string
function core.get_worldpath() end

---@return string
function core.get_mod_data_path() end

---@return boolean
function core.is_singleplayer() end

--- no im not gonna type the entire thing out, NO, no chance
---@type table
core.features = {}

---@param arg string | table<string, boolean>
---@return boolean, table<string, boolean>
function core.has_feature(arg) end

---@class player_info_def
---@field address string, # IP address of client
---@field ip_version number, # IPv4 / IPv6
---@field connection_uptime number, # seconds since client connected
---@field protocol_version number, # protocol version used by client
---@field formspec_version number, # supported formspec version
---@field lang_code string, # Language code used for translation
---@field min_rtt number?
---@field max_rtt number?
---@field avg_rtt number?
---@field min_jitter number?
---@field max_jitter number?
---@field avg_jitter number?

---@alias vector2 { x: number, y:number }

---@class window_info_def
---@field size vector2
---@field max_formspec_size vector2
---@field real_gui_scaling number
---@field real_hud_scaling number
---@field touch_controls boolean

---@param player_name string
---@return player_info_def
function core.get_player_information(player_name) end

---@param player_name string
---@return window_info_def
function core.get_player_window_information(player_name) end

---@param path string
---@return boolean
function core.mkdir(path) end

---@param path string
---@param recursive boolean
---@return boolean
function core.rmdir(path, recursive) end

---@param source string
---@param destination string
---@return boolean
function core.cpdir(source, destination) end

---@param source string
---@param destination string
---@return boolean
function core.mvdir(source, destination) end

---@param is_dir boolean?
---@param path string
---@return string[]
function core.get_dir_list(path, is_dir) end

---Replaces contents of file at path with new contents in a safe (atomic) way. Use this instead of below code when writing e.g. database files: local f = io.open(path, "wb"); f:write(content); f:close()
---@param path string
---@param content string
---@return boolean
function core.safe_file_write(path, content) end

---@class mt_version_def
---@field project string
---@field string string
---@field proto_min integer
---@field proto_max integer
---@field hash string
---@field is_dev boolean

---@return mt_version_def
function core.get_version() end

---@param data string
---@param raw? boolean
---@return string
function core.sha1(data, raw) end

---@return string
---@param data string
---@param raw boolean?
function core.sha256(data, raw) end

---@param colorspec ColorSpec|any
---@return ColorString?
function core.colorspec_to_colorstring(colorspec) end

---@param colorspec ColorSpec|any
---@return string?
function core.colorspec_to_bytes(colorspec) end

---@return string
---@param width integer
---@param height integer
---@param data ColorSpec[]|string
---@param compression integer?
function core.encode_png(width, height, data, compression) end

---@param str string
---@return string
function core.urlencode(str) end

---@param ... any
function core.debug(...) end

---@param level "none"|"error"|"warning"|"action"|"info"|"verbose"
---@param text string
---@return nil
function core.log(level, text) end

---@param text string
---@return nil
function core.log(text) end

---@param name string
---@param node_def node_def
---@return nil
function core.register_node(name, node_def) end

---@param name string
---@param item_def item_def
---@return nil
function core.register_craftitem(name, item_def) end

---@param name string
---@param item_def item_def
---@return nil
function core.register_tool(name, item_def) end

---@param name string
---@param redefinition table
---@param del_fields table?
---@return nil
function core.override_item(name, redefinition, del_fields) end

---@param name string
---@return nil
function core.unregister_item(name) end

---@param name string
---@param luaentity_def luaentity_def
---@return nil
function core.register_entity(name, luaentity_def) end

---@param abm_def abm_def
---@return nil
function core.register_abm(abm_def) end

---@param lbm_def lbm_def
---@return nil
function core.register_lbm(lbm_def) end

---@param ore_def ore_def
---@return nil
function core.register_ore(ore_def) end

---@param biome_def biome_def
---@return nil
function core.register_biome(biome_def) end

---@param name string
---@return nil
function core.unregister_biome(name) end

---@param deco_def deco_def
---@return nil
function core.register_decoration(deco_def) end

---@param schem_def schem_def
---@return nil
function core.register_schematic(schem_def) end

---@return nil
function core.clear_registered_biomes() end

---@return nil
function core.clear_registered_decorations() end

---@return nil
function core.clear_registered_schematics() end

---@param recipe recipe_def
---@return nil
function core.register_craft(recipe) end

---@param recipe recipe_def
---@return nil
function core.clear_craft(recipe) end

---@param chatcommand_def chatcommand_def
---@return nil
function core.register_chatcommand(cmd, chatcommand_def) end

---@param redef table
---@param name string
---@return nil
function core.override_chatcommand(name, redef) end

---@param name string
---@param redef table
---@return nil
function core.unregister_chatcommand(name, redef) end

---@param def priv_def
---@param name string
---@return nil
function core.register_privilege(name, def) end

--- this function is so absurdly uncommon im not going to bother
function core.register_authentication_handler(auth_handler_def) end
