local function get_nearby_player(pos)
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 200)) do
        if obj:is_player() then return obj end
    end
end

local function meteorite_explode(pos, type)
    --breaking nodes
    for _ = 1, 100 do
        local raycast = minetest.raycast(pos, pos + vector.random_direction() * 8, false)
        local wear = 0
        for pointed in raycast do
            if pointed.type == "node" then
                local nodename = minetest.get_node(pointed.under).name
                wear = wear + (1 / minetest.get_item_group(nodename, "explody"))
                --the explody group hence signifies roughly how many such nodes in a straight line it can break before stopping
                --although this is very random
                if wear > 1 then break end
                minetest.set_node(pointed.under, { name = minetest.registered_nodes[nodename]._exploded or "air" })
            end
        end
    end
    --placing nodes
    minetest.set_node(pos, { name = type == "antimatter_blob" and "sbz_meteorites:antineutronium" or "sbz_meteorites:neutronium" })
    local node_types = { matter_blob = {"sbz_meteorites:meteoric_matter","sbz_meteorites:meteoric_metal"},
						 emitter = {"sbz_meteorites:meteoric_emittrium","sbz_meteorites:meteoric_metal"},
						 antimatter_blob = {"sbz_meteorites:meteoric_antimatter","sbz_meteorites:meteoric_antimatter"}}
    for _ = 1, 16 do
        local new_pos = pos + vector.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
        if minetest.get_node(new_pos).name == "air" then
            minetest.set_node(new_pos, {
                name = math.random() < 0.2 and node_types[type][2] or
                    node_types[type][1]
            })
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
        amount = 2000,
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

    for _ = 1, 500 do
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

minetest.register_entity("sbz_meteorites:meteorite", {
    initial_properties = {
        visual = "cube",
        visual_size = { x = 2, y = 2 },
        automatic_rotate = 0.2,
        glow = 14,
        physical = true
    },
    on_activate = function(self, staticdata, dtime)
        if dtime and dtime > 60 then
            self.object:remove()
            return
        end
        self.object:set_rotation(vector.new(math.random() * 2, math.random(), math.random() * 2) * math.pi)
        if staticdata and staticdata ~= "" then --not new, just unpack staticdata
            self.type = staticdata
        else                                    --new entity, initialise stuff
            local types = { "matter_blob", "emitter", "antimatter_blob" }
            self.type = types[math.random(#types)]
            local offset = vector.new(math.random(-48, 48), math.random(-48, 48), math.random(-48, 48))
            local pos = self.object:get_pos()
            local target = get_nearby_player(pos)
            if not target then self.object:remove() end
            self.object:set_velocity(1.5 * vector.normalize(target:get_pos() - pos + offset))
        end
        local texture = self.type .. ".png^meteorite.png"
        self.object:set_properties({ textures = { texture, texture, texture, texture, texture, texture } })
        self.object:set_armor_groups({ immortal = 1 })
        self.sound = minetest.sound_play({ name = "rocket-loop-99748", gain = 0.15, fade = 0.1 }, { loop = true })
        self.waypoint = nil
        self.time_since = 100
    end,
    on_deactivate = function(self)
        if not self.type then return end
        minetest.sound_fade(self.sound, 0.1, 0)
        if self.waypoint then sbz_api.remove_waypoint(self.waypoint) end
    end,
    get_staticdata = function(self)
        return self.type
    end,
    on_step = function(self, dtime, moveresult)
        if not self.type then return end
        local pos = self.object:get_pos()
        local diag = vector.new(1, 1, 1)
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
        if moveresult and moveresult.collisions[1] then --colliding with something, should explode
            self.object:remove()
            meteorite_explode(pos, self.type)
            minetest.sound_play({ name = "distant-explosion-47562", gain = 0.4 })
            return
        end
        self.time_since = self.time_since + dtime
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
