local function get_nearby_player(pos)
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 200)) do
        if obj:is_player() then return obj end
    end
end

local function meteorite_explode(pos, type)
    --breaking nodes
    sbz_api.explode(pos, 8, 0.9, false)
    --placing nodes
    local protected = minetest.is_protected(pos, ".meteorite")
    if not protected then
        minetest.set_node(pos,
            { name = type == "antimatter_blob" and "sbz_meteorites:antineutronium" or "sbz_meteorites:neutronium" })
    end
    local node_types = {
        matter_blob = { "sbz_meteorites:meteoric_matter", "sbz_meteorites:meteoric_metal" },
        emitter = { "sbz_meteorites:meteoric_emittrium", "sbz_meteorites:meteoric_metal" },
        antimatter_blob = { "sbz_meteorites:meteoric_antimatter", "sbz_meteorites:meteoric_antimatter" },
        strange_blob = { "sbz_resources:strange_blob", "sbz_resources:strange_blob" },
    }
    if not protected then
        for _ = 1, 16 do
            local new_pos = pos + vector.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
            if minetest.get_node(new_pos).name == "air" then
                minetest.set_node(new_pos, {
                    name = math.random() < 0.2 and node_types[type][2] or
                        node_types[type][1]
                })
            end
        end
    end
    --knockback
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 16)) do
        if obj:is_player() then
            local dir = obj:get_pos() - pos
            obj:add_velocity((vector.normalize(dir) + vector.new(0, 0.5, 0)) * 0.5 * (16 - vector.length(dir)))
        end
    end
    --particle effects
    minetest.add_particlespawner({
        time = 0.1,
        amount = 2000 / (protected and 5 or 1),
        pos = pos,
        radius = 1,
        drag = 0.2,
        glow = 14,
        exptime = { min = 2, max = 5 },
        size = { min = 3, max = 6 },
        texture = "meteorite_trail_" .. type .. ".png",
        animation = { type = "vertical_frames", aspect_width = 4, aspect_height = 4, length = -1 },
        attract = {
            kind = "point",
            origin = pos,
            strength = { min = -4, max = 0 }
        }
    })
    local forward = vector.new(1, 0, 0)
    local up = vector.new(0, 1, 0)

    for _ = 1, 500 / (protected and 5 or 1) do
        local dir = vector.rotate_around_axis(forward, up, math.random() * 2 * math.pi)
        local expiry = math.random() * 3 + 2
        minetest.add_particle({
            pos = pos + dir,
            velocity = dir * (5 + math.random()),
            drag = vector.new(0.2, 0.2, 0.2),
            glow = 14,
            expirationtime = expiry,
            size = math.random() * 3 + 3,
            texture = "meteorite_trail_" .. type .. ".png^[colorize:#aaaaaa:alpha",
            animation = { type = "vertical_frames", aspect_width = 4, aspect_height = 4, length = expiry },
        })
    end
end

sbz_api.meteorite_explode = meteorite_explode

minetest.register_entity("sbz_meteorites:meteorite", {
    initial_properties = {
        visual = "cube",
        visual_size = { x = 2, y = 2 },
        automatic_rotate = 0.2,
        glow = 14,
        selectionbox = { -1, -1, -1, 1, 1, 1 },
        physical = false --so they enter unloaded chunks properly
    },
    on_activate = function(self, staticdata, dtime)
        if dtime and dtime > 600 then
            self.object:remove()
            return
        end
        self.object:set_rotation(vector.new(math.random() * 2, math.random(), math.random() * 2) * math.pi)
        if staticdata and staticdata ~= "" then --not new, just unpack staticdata
            self.type = staticdata
        else                                    --new entity, initialise stuff
            local types = { "matter_blob", "emitter", "antimatter_blob", "strange_blob" }
            local pos = self.object:get_pos()
            if vector.in_area(pos, vector.new(-100, -100, -100), vector.new(100, 100, 100)) then
                types[4] = nil -- dont want strange meteorites spawning to some noob who wont know what to do
            end
            self.type = types[math.random(#types)]
            local offset = vector.new(math.random(-48, 48), math.random(-48, 48), math.random(-48, 48))
            local pos = self.object:get_pos()
            local target = get_nearby_player(pos)
            if not target then
                self.object:remove()
                return
            end
            self.object:set_velocity(1.5 * vector.normalize(target:get_pos() - pos + offset))
        end
        local texture = self.type .. ".png^meteorite.png"
        self.object:set_properties({ textures = { texture, texture, texture, texture, texture, texture } })
        self.object:set_armor_groups({ immortal = 1 })
        self.sound = minetest.sound_play("rocket-loop-99748", { loop = true, gain = 0.15, fade = 0.1 })
        self.waypoint = nil
        self.time_since = 100
    end,
    on_deactivate = function(self)
        if not self.type then return end
        if self.sound then
            minetest.sound_fade(self.sound, 0.1, 0)
        end
        if self.waypoint then sbz_api.remove_waypoint(self.waypoint) end
    end,
    get_staticdata = function(self)
        return self.type
    end,
    on_step = function(self, dtime)
        if not self.type then return end
        local pos = self.object:get_pos()
        local diag = vector.new(1, 1, 1)
        for x = -1, 1 do
            for y = -1, 1 do
                for z = -1, 1 do
                    local node = minetest.get_node(pos + vector.new(x, y, z)).name
                    if node ~= "ignore" and node ~= "air" and node ~= "sbz_power:funny_air" then --colliding with something, should explode
                        self.object:remove()
                        meteorite_explode(pos, self.type)
                        minetest.sound_play({ name = "distant-explosion-47562", gain = 0.4 })
                        return
                    end
                end
            end
        end
        --the stopping moving bug seems to be it hitting unloaded chunks
        minetest.add_particlespawner({
            time = dtime,
            amount = 1,
            pos = { min = pos - diag, max = pos + diag },
            vel = { min = -0.5 * diag, max = 0.5 * diag },
            drag = 0.2,
            glow = 14,
            exptime = { min = 10, max = 20 },
            size = { min = 2, max = 4 },
            texture = "meteorite_trail_" .. self.type .. ".png",
            animation = { type = "vertical_frames", aspect_width = 4, aspect_height = 4, length = -1 }
        })
        self.time_since = (self.time_since or 0) + dtime
        if self.waypoint and self.time_since >= 2 then
            sbz_api.remove_waypoint(self.waypoint)
            self.waypoint = nil
        end
        sbz_api.move_waypoint(self.waypoint, pos)
    end,
    show_waypoint = function(self)
        if not self.waypoint then
            self.waypoint = sbz_api.set_waypoint(self.object:get_pos(), {
                name = "",
                dist = 10,
                image = "visualiser_trail.png^[verticalframe:3:0"
            })
        end
        self.time_since = 0
    end
})
