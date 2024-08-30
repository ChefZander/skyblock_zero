local elapsed = 0

local function attract_meteorites(pos, dtime, t)
    elapsed = elapsed + dtime
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 200)) do
        if not obj:is_player() and obj:get_luaentity().name == "sbz_meteorites:meteorite" then
            obj:add_velocity(t * dtime * sbz_api.get_attraction(obj:get_pos(), pos))
            if elapsed > 1 then
                minetest.add_particlespawner({
                    time = 1,
                    amount = math.floor(vector.distance(pos, obj:get_pos()) / 2),
                    exptime = 2,
                    size = { min = 2, max = 4 },
                    drag = 3,
                    pos = { min = pos, max = obj:get_pos() },
                    texture = "meteorite_trail_emitter.png" ..
                    (t < 0 and "^[colorize:#ffcccc:alpha" or "^[colorize:#888888:alpha"),
                    animation = { type = "vertical_frames", aspect_width = 4, aspect_height = 4, length = -1 },
                    glow = 7,
                    attract = {
                        kind = "line",
                        origin = vector.zero(),
                        origin_attached = obj,
                        direction = pos - obj:get_pos(),
                        strength = 3,
                        die_on_contact = false
                    }
                })
            end
        end
    end
    if elapsed > 1 then elapsed = 0 end
end

minetest.register_entity("sbz_meteorites:gravitational_attractor_entity", {
    initial_properties = {
        visual = "cube",
        visual_size = { x = 0.5, y = 0.5 },
        automatic_rotate = 0.2,
        glow = 14,
        physical = false,
        pointable = false
    },
    on_activate = function(self)
        local node = minetest.get_node(vector.round(self.object:get_pos())).name
        if node == "sbz_meteorites:gravitational_attractor" then
            self.type = 1
        elseif node == "sbz_meteorites:gravitational_repulsor" then
            self.type = -1
        else
            self.object:remove()
            return
        end
        local t = self.type < 0 and "antineutronium.png" or "neutronium.png"
        self.object:set_properties({ textures = { t, t, t, t, t, t } })
        self.object:set_rotation(vector.new(math.random() * 2, math.random(), math.random() * 2) * math.pi)
    end,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        local node = minetest.get_node(vector.round(pos)).name
        if node ~= "sbz_meteorites:gravitational_attractor" and node ~= "sbz_meteorites:gravitational_repulsor" then self
                .object:remove() end
        attract_meteorites(pos, dtime, self.type)
    end
})

minetest.register_node("sbz_meteorites:gravitational_attractor", {
    description = "Gravitational Attractor",
    drawtype = "glasslike",
    tiles = { "gravitational_attractor.png" },
    inventory_image = "gravitational_attractor_inventory.png",
    wield_image = "gravitational_attractor_inventory.png",
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 7,
    groups = { gravity = 100, matter = 1, cracky = 3 },
    on_construct = function(pos)
        minetest.sound_play({ name = "machine_build" }, { pos = pos })
        minetest.add_entity(pos, "sbz_meteorites:gravitational_attractor_entity")
    end,
})

minetest.register_craft({
    output = "sbz_meteorites:gravitational_attractor",
    recipe = {
        { "sbz_resources:matter_blob", "",                          "sbz_resources:matter_blob" },
        { "",                          "sbz_meteorites:neutronium", "" },
        { "sbz_resources:matter_blob", "",                          "sbz_resources:matter_blob" }
    }
})

minetest.register_node("sbz_meteorites:gravitational_repulsor", {
    description = "Gravitational Repulsor",
    drawtype = "glasslike",
    tiles = { "gravitational_repulsor.png" },
    inventory_image = "gravitational_repulsor_inventory.png",
    wield_image = "gravitational_repulsor_inventory.png",
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 7,
    groups = { antigravity = 1, matter = 1, cracky = 3 },
    on_construct = function(pos)
        minetest.sound_play({ name = "machine_build" }, { pos = pos })
        minetest.add_entity(pos, "sbz_meteorites:gravitational_attractor_entity")
    end
})

minetest.register_craft({
    output = "sbz_meteorites:gravitational_repulsor",
    recipe = {
        { "sbz_resources:antimatter_dust", "",                          "sbz_resources:antimatter_dust" },
        { "",                              "sbz_meteorites:neutronium", "" },
        { "sbz_resources:antimatter_dust", "",                          "sbz_resources:antimatter_dust" }
    }
})

function sbz_api.get_attraction(pos1, pos2)
    local dir = pos2 - pos1
    return vector.normalize(dir) * (16 / vector.length(dir)) ^ 2
end
