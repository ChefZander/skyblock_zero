-- inspired by https://github.com/BuckarooBanzay/holoemitter/ though should be completely different in implementation (i havent looked at the code of holoemitter)

local function transform_texture_name(tex, is_incomplete)
    local addon = ""
    if is_incomplete then
        addon = "x.png" -- dummy
    end
    if type(tex) == "string" then
        local texmod = pcall(modlib.minetest.texmod.read_string, addon .. tex, true) -- literally the only reason i went out of my way to use modlib lol, this hopefully SHOULDNT crash clients (should throw an error)
        if texmod == false then
            return ""
        else
            return tex -- it means its probably valid
        end
    else
        return ""
    end
end

local projectors = {}
local h = core.hash_node_position

local range = 15
local range_max = 20

local range_vec = vector.new(range, range, range)
local objects_max_limit = 15

local function type_or_nil(t)
    return function(x)
        return type(x) == t or x == nil
    end
end

local function all_in_range(t, min, max)
    for k, v in pairs(t) do
        if type(v) == "number" then
            if math.abs(v) < min or math.abs(v) > max and not minetest.is_nan(v) then
                return false
            end
        end
    end
    return true
end

local function is_valid_box(x)
    return x == nil or (type(x) == "table"
        and type(x[1]) == "number"
        and type(x[2]) == "number"
        and type(x[3]) == "number"
        and type(x[4]) == "number"
        and type(x[5]) == "number"
        and type(x[6]) == "number"
        and (type(x.rotate) == "boolean" or x.rotate == nil)
        and all_in_range(x, 0, 5)
    )
end

local function type_any(x)
    return true
end

local function process_textures(og_textures)
    local new_textures = {}
    for k, v in ipairs(og_textures) do
        if type(v) == "string" or (type(v) == "table" and not v.name) then
            -- normal texture or texmod
            new_textures[k] = transform_texture_name(v)
        elseif type(v) == "table" and v.name then
            -- now it gets a little tricky
            -- nah jk
            v.name = transform_texture_name(v)
            v.image = nil
            v.scale = nil
            v.align_style = nil
            if v.animation then
                if v.animation.type == "vertical_frames" then
                    if libox.type_check(v.animation, {
                            type = libox.type("string"),
                            aspect_w = function(x) return type(x) == "number" and math.floor(x) == x and x > 1 end,
                            aspect_h = function(x) return type(x) == "number" and math.floor(x) == x and x > 1 end,
                            length = function(x) return type(x) == "number" and x > 0.1 end,
                        }) == false then
                        v.animation = nil
                    end
                elseif v.animation.type == "sheet_2d" then
                    if libox.type_check(v.animation, {
                            type = libox.type("string"),
                            frames_w = function(x) return type(x) == "number" and math.floor(x) == x and x > 1 end,
                            frames_h = function(x) return type(x) == "number" and math.floor(x) == x and x > 1 end,
                            frame_length = function(x) return type(x) == "number" and x > 0.1 end,
                        }) == false then
                        v.animation = nil
                    end
                else
                    v.animation = nil
                end
            end
            new_textures[k] = v
        end
    end
    return new_textures
end

local function t_count(t)
    local x = 0
    for _ in pairs(t) do x = x + 1 end
    return x
end

local function validate_object_properties(props, not_strict)
    -- im gonna shorten "must not have" as "no"
    local t = libox.type
    local ton = type_or_nil
    -- after this, for all strings, limit their size to like 500 bytes
    props.static_save = false
    local t = {
        type = t("string"),
        pos = libox.type_vector,
        id = t("string"),
        -- no hp_max
        -- no breath_max
        -- no zoom_fov
        -- no eye_height
        physical = ton "boolean",
        collide_with_objects = ton "boolean",
        collisionbox = is_valid_box,
        selectionbox = is_valid_box,
        pointable = ton "boolean",
        visual = function(x)
            return
                x == nil or
                x == "cube" or
                x == "sprite" or
                x == "upright_sprite" or
                x == "mesh" or
                x == "wielditem" or
                x == "item"
        end,
        visual_size = function(x)
            return x == nil or (type(x) == "table"
                and (type(x.x) == "number" or x.x == nil)
                and (type(x.y) == "number" or x.y == nil)
                and (type(x.z) == "number" or x.z == nil)
                and all_in_range(x, 0, 20)
            )
        end,
        mesh = ton "string",
        textures = ton "table",
        colors = ton "table",
        use_texture_alpha = ton "boolean",
        spritediv = function(x)
            return x == nil or (type(x) == "table"
                and type(x.x) == "number"
                and type(x.y) == "number"
                and math.floor(x.x) == x.x
                and math.floor(x.y) == x.y
                and all_in_range(x, 1, 100)
            )
        end,
        initial_sprite_basepos = function(x)
            return x == nil or (type(x) == "table"
                and type(x.x) == "number"
                and type(x.y) == "number"
                and math.floor(x.x) == x.x
                and math.floor(x.y) == x.y
                and all_in_range(x, 1, 100)
            )
        end,
        is_visible = ton "boolean",
        makes_footstep_sound = ton "boolean",
        automatic_rotate = ton "number",
        stepheight = ton "number",
        automatic_face_movement_dir = function(x) return x == nil or x == false or type(x) == "number" end,
        automatic_face_movement_max_rotation_per_sec = ton "number",
        backface_culling = ton "boolean",
        glow = ton "number",
        nametag = ton "string",
        nametag_color = type_any,
        nametag_bgcolor = type_any,
        infotext = ton "string",
        static_save = function(x) return x == false end,
        damage_texture_modifier = function(x) return x == nil or type(x) == "string" end,
        shaded = ton "boolean",
        -- no show_on_minimap
    }
    if not_strict then
        t.pos = nil
        t.type = nil
        t.id = nil
    end
    local ok, errmsg = libox.type_check(props, t)
    if not ok then return ok, errmsg end

    props.textures = process_textures(props.textures)
    props.damage_texture_modifier = props.damage_texture_modifier and
        transform_texture_name(props.damage_texture_modifier, true)
    return ok, errmsg
end

minetest.register_entity("sbz_logic_devices:hologram", {
    initial_properties = { static_save = false },
    on_activate = function(self, staticdata, dtime_s)
        staticdata = minetest.deserialize(staticdata)
        if staticdata == nil then return self.object:remove() end
        staticdata.properties.static_save = false
        self.parent = staticdata.parent
        self.id = staticdata.id
        self.object:set_properties(staticdata.properties)
    end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
        local parent = self.parent
        local meta = minetest.get_meta(parent)
        local subscribed = vector.from_string(meta:get_string("subscribed"))
        if subscribed then
            sbz_logic.send(subscribed, {
                type = "punch",
                puncher = puncher:get_player_name(),
                time_from_last_punch = time_from_last_punch,
                tool_capabilities = tool_capabilities,
                dir = dir,
                damage = damage,
                id = self.id
            }, parent)
        end
    end,
    on_rightclick = function(self, clicker)
        local parent = self.parent
        local meta = minetest.get_meta(parent)
        local subscribed = vector.from_string(meta:get_string("subscribed"))
        if subscribed then
            sbz_logic.send(subscribed, {
                type = "right_click",
                clicker = clicker:get_player_name(),
                id = self.id
            }, parent)
        end
    end,
    on_step = function(self, dtime, moveresult)
        local parent = self.parent
        local diff = vector.subtract(parent, self.object:get_pos())
        if math.abs(diff.x) > range_max
            or math.abs(diff.y) > range_max
            or math.abs(diff.z) > range_max then
            return self.object:remove()
        end
        --[[
        if moveresult and #moveresult.collisions ~= 0 then
            local meta = minetest.get_meta(parent)
            local subscribed = vector.from_string(meta:get_string("subscribed"))

            if subscribed then
                sbz_logic.send(subscribed, {
                    type = "collision",
                    id = self.id,
                    moveresult = moveresult
                })
            end
        end
        so turns out that yea this is horrible
        ]]
    end
})

local function exec_command(pos, cmd, from_pos)
    local meta = minetest.get_meta(pos)
    if cmd == "subscribe" or cmd == "unsubscribe" then
        if cmd == "subscribe" then
            meta:set_string("subscribed", vector.to_string(from_pos))
        else
            meta:set_string("subscribed", "")
        end
        return
    end


    local subscribed = vector.from_string(meta:get_string("subscribed"))

    local notify = sbz_logic.get_notify(subscribed, pos)

    if type(cmd) ~= "table" then return end



    local stuff = projectors[h(pos)]
    if stuff == nil then
        projectors[h(pos)] = {
            objects = {}, -- they point directly to objectrefs
            -- stuff may get added in the future
        }
        stuff = projectors[h(pos)]
    end


    -- clean up inactive objects
    for k, v in pairs(stuff.objects) do
        if v:is_valid() == false then
            stuff.objects[k] = nil
        end
    end

    if cmd.type == "object" then
        local props_ok, props_errmsg = validate_object_properties(cmd)
        if not props_ok then
            return notify {
                type = "error",
                msg = "Invalid field in object properties: " .. props_errmsg
            }
        end

        if not vector.in_area(cmd.pos, -range_vec, range_vec) then
            return notify {
                type = "error",
                msg = "The object is out of range"
            }
        end

        cmd.pos = vector.add(cmd.pos, pos)

        if t_count(stuff.objects) > objects_max_limit then
            return notify {
                type = "error",
                msg = "Too many objects, max: " .. objects_max_limit
            }
        end
        -- alright, now the fun stuff


        local obj = minetest.add_entity(cmd.pos, "sbz_logic_devices:hologram", minetest.serialize({
            parent = pos,
            properties = cmd,
        }))

        if not obj then
            return notify {
                type = "error",
                msg = "Failed to spawn object"
            }
        end

        stuff.objects[cmd.id] = obj
    elseif cmd.type == "reset" then
        for k, v in pairs(stuff.objects) do
            if v.remove then v:remove() end
            stuff.objects[k] = nil
        end
    elseif cmd.type == "remove" and type(cmd.id) == "string" then
        if stuff.objects[cmd.id] and stuff.objects[cmd.id].remove then
            stuff.objects[cmd.id]:remove()
            table.remove(stuff.objects, cmd.id)
        else
            notify {
                type = "error",
                msg = "Invalid id in remove command"
            }
        end
    elseif cmd.type == "modify_object" then -- set acceleration n stuff like that... this wont be painful at all xD
        local id = cmd.id
        if type(id) ~= "string" then return end

        if stuff.objects[id] == nil then return notify { type = "error", msg = "Invalid id in modify_object command" } end

        local obj = stuff.objects[id]

        if cmd.set_properties then
            local ok, invalid_element = validate_object_properties(cmd.set_properties, true)
            if not ok then
                notify {
                    type = "error",
                    msg = "Invalid properties in modify_object set_properties table, problematic element: " .. invalid_element
                }
            end
            obj:set_properties(cmd.set_properties)
        end
        if cmd.set_nametag_attributes then
            local ok, invalid_element = libox.type_check(cmd.set_nametag_attributes, {
                text = type_or_nil("string"),
                color = type_any,
                bgcolor = type_any,
            })
            if not ok then
                notify {
                    type = "error",
                    msg = "Invalid properties in modify_object set_nametag_attributes table, problematic element: " .. invalid_element
                }
            end
            obj:set_nametag_attributes(cmd.set_nametag_attributes)
        end

        if libox.type_vector(cmd.pos) then -- it will be relative
            local abs_pos = vector.add(pos, cmd.pos)
            if not vector.in_area(cmd.pos, -range_vec, range_vec) then
                return notify {
                    type = "error",
                    msg = "The object is out of range"
                }
            end
            obj:set_pos(abs_pos)
        end

        if libox.type_vector(cmd.velocity) then
            obj:set_velocity(cmd.velocity)
        end

        if libox.type_vector(cmd.rotation) then
            obj:set_rotation(cmd.rotation)
        end

        if libox.type_vector(cmd.acceleration) then
            obj:set_acceleration(cmd.acceleration)
        end

        if libox.type("string")(cmd.texture_mod) then
            obj:set_texture_mod(transform_texture_name(cmd.texture_mod, true))
        end
    elseif cmd.type == "get_object" then -- get the entire ref
        local id = cmd.id
        if type(id) ~= "string" then return end

        if stuff.objects[id] == nil then return notify { type = "error", msg = "Invalid id in get_object command" } end
        local obj = stuff.objects[id]
        notify { -- the exact same format as object detector
            type = "get_object",
            is_player = false,
            nametag = obj:get_nametag_attributes(),
            pos = obj:get_pos(),
            props = obj:get_properties(),
            hp = obj:get_hp(),
            armor_groups = obj:get_armor_groups(),
            velocity = obj:get_velocity(),

            acceleration = obj:get_acceleration(),
            rotation = obj:get_rotation(),
            yaw = obj:get_yaw(),
            texture_mod = obj:get_texture_mod(),
            name = obj:get_luaentity().name,
        }
        --[[
        -- IF ANYONE WANTS TO REVIVE THIS FEEL FREE!!!
    elseif cmd.type == "make_texture_for_voxelmodel" then
        -- i know it feels like it doesnt belong here but it returns a png texmod, should be useful, also async
        minetest.handle_async(function(cmd)
            local screen = cmd.screen -- uses XYZ
            if type(screen) ~= "string" then
                return nil,
                    "3D Screen must be in format of <r><g><b><r><g><b>.... where <r>, <g>, <b> are byte representations of them..."
            end
            ---@type string[]
            local image_result = {} -- colorspec2bytes[]
            -- size is 48x272
            -- cmd.screen's size should be 16^3

            local function hash3d(x, y, z) -- custom
                return (x - 1) + (y - 1) * 16 + (z - 1) * 16 * 16
            end

            local function hash2d(x, y)
                return (y - 1) * 48 + x
            end

            local function get(hash)
                return cmd.screen:sub(hash * 4 - 3, hash * 4)
            end

            for x = 1, 16 do
                for y = 1, 16 do
                    for z = 1, 16 do
                        local color = get(hash3d(x, y, z))
                        if #color == 4 and string.sub(color, 4) ~= "\0" then
                            -- -Y
                            image_result[hash2d((16 * 2) + (x - 1), (math.abs(16 - (y - 1)) * 16) + z)] = color
                            -- +Y
                            image_result[hash2d((16 * 2) + (x - 1), (math.abs(16 - (y - 1)) * 16) - 16 + z)] = color

                            -- -X
                            image_result[hash2d(math.abs(16 - (z - 1)), math.abs(16 - (x - 1)) * 16 + math.abs(16 - (y - 1)))] =
                                color
                            -- +X

                            image_result[hash2d(math.abs(16 - (z - 1)), math.abs(16 - (x - 1)) * 16 + 16 + math.abs(16 - (y - 1)))] =
                                color

                            -- -Z
                            image_result[hash2d(16 + math.abs(16 - (x - 1)), math.abs(16 - (z - 1)) * 16 + math.abs(16 - (y - 1)))] =
                                color
                        end
                    end
                end
            end

            for i = 1, (16 * 16 * 17 * 3) do
                image_result[i] = image_result[i] or minetest.colorspec_to_bytes("#00000000")
            end
            local png = minetest.encode_png(48, 272, table.concat(image_result), 1)
            png = minetest.encode_base64(png)
            return png
        end, function(png_data, error)
            if not error then
                notify {
                    type = "make_texture_for_voxelmodel",
                    png_data = png_data
                }
            else
                notify {
                    type = "error",
                    msg = error
                }
            end
        end, cmd)
        --]]
    elseif cmd.type == "particle" then
        -- cant do spawner sorry
        local t = libox.type
        local ton = type_or_nil
        local ok, invalid_element = libox.type_check(cmd, {
            type = t "string",
            pos = function(x)
                return libox.type_vector(x) and all_in_range(x, -range, range)
            end,
            velocity = function(x)
                return x == nil or libox.type_vector(x) and all_in_range(x, -10, 10)
            end,
            acceleration = function(x)
                return x == nil or libox.type_vector(x) and all_in_range(x, -10, 10)
            end,
            expirationtime = function(x)
                return x == nil or t "number" (x) and not core.is_nan(x) and x >= 0 and x <= 10
            end,
            size = function(x)
                return x == nil or t "number" (x) and not core.is_nan(x) and x >= 0 and x <= 20
            end,
            collisiondetection = ton "boolean",
            collision_removal = ton "boolean",
            object_collision = ton "boolean",
            vertical = ton "boolean",
            texture = t "string",
            playername = ton "string",
            glow = function(x)
                return x == nil or t "number" (x) and x <= 14 and x >= 0
            end,
            drag = function(x)
                return x == nil or libox.type_vector(x) and all_in_range(x, -3, 100)
            end,
            jitter = function(x)
                return x == nil or t "number" (x) and x >= -5 and x <= 5
            end,
            bounce = function(x)
                return x == nil or t "number" (x) and x >= 0 and x <= 1.5
            end,
        })
        if not ok then
            return notify {
                type = "error",
                msg = "Invalid types, bad element: " .. invalid_element
            }
        end
        cmd.pos = vector.add(cmd.pos, pos)
        cmd.texture = transform_texture_name(cmd.texture)
        minetest.add_particle(cmd) -- yeah thats literally it
    end
end

mesecon.register_on_mvps_move(function(moved_nodes)
    for i = 1, #moved_nodes do
        local moved_node = moved_nodes[i]
        if rawget(projectors, h(moved_node.oldpos)) then
            projectors[h(moved_node.pos)] = projectors[h(moved_node.oldpos)]
            projectors[h(moved_node.oldpos)] = nil
        end
    end
end)

core.register_node("sbz_logic_devices:hologram_projector", {
    description = "Hologram Projector",
    info_extra = "Inspired by the holoemitter mod.",
    groups = { ui_logic = 1, matter = 1 },
    sonuds = sbz_api.sounds.matter(),
    on_logic_send = exec_command,
    tiles = { "hologram_projector.png" },
    on_punch = function(pos, _, player)
        vizlib.draw_cube(pos, range + 0.5, { player = player })
        vizlib.draw_cube(pos, range_max + 0.5, { player = player, color = "orange" })
        minetest.get_meta(pos):set_string("infotext", "Object Detector")
    end,
})

unified_inventory.register_craft {
    type = "ele_fab",
    items = {
        "sbz_resources:lua_chip 15",
        "sbz_logic_devices:matrix_screen 15",
        "sbz_logic_devices:object_detector",
        "unifieddyes:colorium_blob 10",
    },
    output = "sbz_logic_devices:hologram_projector",
    width = 2,
    height = 2,
}
