minetest.register_entity("sbz_meteorites:gravitational_attractor_entity", {
    initial_properties = {
        visual = "cube",
        visual_size = {x=0.5, y=0.5},
        textures = {"neutronium.png", "neutronium.png", "neutronium.png", "neutronium.png", "neutronium.png", "neutronium.png"},
        automatic_rotate = 0.2,
        glow = 14,
        physical = false,
        pointable = false
    },
    on_activate = function (self)
        self.object:set_rotation(vector.new(math.random()*2, math.random(), math.random()*2)*math.pi)
    end,
    on_step = function (self)
        local pos = vector.round(self.object:get_pos())
        if minetest.get_node(pos).name ~= "sbz_meteorites:gravitational_attractor" then self.object:remove() end
    end
})

minetest.register_node("sbz_meteorites:gravitational_attractor", {
    description = "Gravitational Attractor",
    drawtype = "glasslike",
    tiles = {"gravitational_attractor.png"},
    inventory_image = "gravitational_attractor_inventory.png",
    wield_image = "gravitational_attractor_inventory.png",
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 7,
    groups = {matter=1, cracky=3},
    on_construct = function (pos)
        minetest.add_entity(pos, "sbz_meteorites:gravitational_attractor_entity")
    end
})

minetest.register_craft({
    output = "sbz_meteorites:gravitational_attractor",
    recipe = {
        {"sbz_resources:matter_blob", "", "sbz_resources:matter_blob"},
        {"", "sbz_meteorites:neutronium", ""},
        {"sbz_resources:matter_blob", "", "sbz_resources:matter_blob"}
    }
})

minetest.register_abm({
    interval = 1,
    chance = 1,
    nodenames = {"sbz_meteorites:gravitational_attractor"},
    action = function (pos, node)
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 200)) do
            if not obj:is_player() and obj:get_luaentity().name == "sbz_meteorites:meteorite" then
                local dir = pos-obj:get_pos()
                obj:add_velocity(vector.normalize(dir)*(30/vector.length(dir))^2)
                minetest.add_particlespawner({
                    time = 1,
                    amount = math.floor(vector.length(dir)/2),
                    exptime = 2,
                    size = {min=2, max=4},
                    drag = 3,
                    pos = {min=pos, max=obj:get_pos()},
                    texture = "meteorite_trail_emitter.png^[colorize:#888888:alpha",
                    animation = {type="vertical_frames", aspect_width=4, aspect_height=4, length=-1},
                    glow = 7,
                    attract = {
                        kind = "line",
                        origin = vector.zero(),
                        origin_attached = obj,
                        direction = dir,
                        strength = 3,
                        die_on_contact = false
                    }
                })
            end
        end
    end
})