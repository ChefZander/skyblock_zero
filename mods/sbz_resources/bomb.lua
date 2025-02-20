-- can be stacked in water for extra... bad....

local function detonate(obj, owner)
    sbz_api.explode(obj:get_pos(), 4, 0.9, true, owner or "", 2.5, nil, true)
    obj:remove()
end

local speed = 30
local speed_vec = vector.new(speed, speed, speed)

core.register_entity("sbz_resources:bomb_stick_entity", {
    initial_properties = {
        visual = "sprite",
        visual_size = { x = 1, y = 1, z = 1 },
        pointable = false,
        collide_with_objects = true,
        physical = true,
        textures = { "bomb_stick_inv.png" },
        glow = 14,
        static_save = false,
    },
    on_activate = function(self, staticdata, dtime_s)
        staticdata = core.deserialize(staticdata)
        self.object:set_armor_groups { matter = 100, antimatter = 100 }
        self.owner = staticdata.owner
        self.direction = staticdata.direction
        self.object:set_acceleration(vector.new(0, -sbz_api.gravity, 0))
        self.object:set_velocity(vector.multiply(vector.add(speed_vec, staticdata.vel), self.direction))
    end,
    on_punch = function(self)
        -- use to defend yourself i guess idk lmfao good luck!
        detonate(self.object, self.owner)
    end,
    on_death = function(self, killer)
        detonate(self.object, self.owner)
    end,
    on_step = function(self, dtime, moveresult)
        if moveresult.collides then
            detonate(self.object, self.owner)
        end
    end
})

core.register_craftitem("sbz_resources:bomb_stick", {
    description = "TNT Stick",
    wield_scale = { x = 1, y = 1, z = 2.5 },
    wield_image = "bomb_stick_wield.png",
    inventory_image = "bomb_stick_inv.png",
    on_use = function(stack, placer, pointed)
        local look_dir = placer:get_look_dir()
        local name = placer:get_player_name()
        core.add_entity(
            vector.add(sbz_api.get_pos_with_eye_height(placer), vector.multiply(look_dir, 0.05)),
            "sbz_resources:bomb_stick_entity",
            core.serialize { owner = name, direction = look_dir, vel = placer:get_velocity() })
        stack:set_count(stack:get_count() - 1)
        return stack
    end
})

unified_inventory.register_craft {
    type = "compressing",
    output = "sbz_resources:bomb",
    items = { "sbz_resources:bomb_stick 9" }
}
unified_inventory.register_craft {
    type = "compressing",
    output = "sbz_resources:bomb_stick",
    items = { "sbz_bio:pyrograss 9" }
}

local time = 3
-- now... the radius.... since its crafted from 9 bomb sticks
-- the radius works to be around 8.32, dont trust me with math but ill go with r=9
local function bomb_detonate(obj, owner)
    sbz_api.explode(obj:get_pos(), 9, 0.9, true, owner or "", 2.5, nil, true)
    obj:remove()
end

local friction = 0.9
core.register_entity("sbz_resources:bomb_entity", {
    initial_properties = {
        physical = true,
        collide_with_objects = false,
        visual = "cube",
        textures = {
            "bomb_top.png^[brighten",
            "bomb_top.png^[brighten",
            "bomb.png^[brighten",
            "bomb.png^[brighten",
            "bomb.png^[brighten",
            "bomb.png^[brighten",
        },
        static_save = false,
        pointable = true
    },

    on_activate = function(self, staticdata)
        self.object:set_armor_groups({ immortal = 1, can_move = 1 })
        self.time = time
        self.owner = staticdata
        self.object:add_velocity(vector.new(0, 1, 0))
        self.object:set_acceleration(vector.new(0, -sbz_api.gravity, 0))
    end,
    on_step = function(self, dtime, moveresult)
        self.time = self.time - dtime
        self.object:set_acceleration(vector.new(0, -sbz_api.gravity, 0))
        if moveresult.touching_ground or moveresult.standing_on_object then
            -- TODO: maybe make sliperry nodes do less friction?
            self.object:set_velocity(self.object:get_velocity() * friction)
        end
        if self.time <= 0 then
            bomb_detonate(self.object, self.owner)
        end
    end,
})

core.register_node("sbz_resources:bomb", {
    description = "TNT",
    tiles = {
        "bomb_top.png",
        "bomb_top.png",
        "bomb.png"
    },
    groups = { matter = 1, explody = 10 },
    on_rightclick = function(pos, node, player)
        if core.is_protected(pos, player:get_player_name()) then
            return core.record_protection_violation(pos, player:get_player_name())
        end

        core.remove_node(pos)
        core.add_entity(pos, "sbz_resources:bomb_entity", player:get_player_name())
        core.sound_play("tnt_ignite", {
            pos = pos,
            gain = 2.5,
        }, true)
    end,
    on_blast = function(pos, power, original_pos, owner, r)
        if core.is_protected(pos, owner) then
            return
        end

        core.remove_node(pos)
        core.add_entity(pos, "sbz_resources:bomb_entity", owner)
    end
})
