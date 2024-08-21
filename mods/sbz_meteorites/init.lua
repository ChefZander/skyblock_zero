local function get_nearby_player(pos)
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 200)) do
        if obj:is_player() then return obj end
    end
end

minetest.register_entity("sbz_meteorites:meteorite", {
    initial_properties = {
        visual = "cube",
        visual_size = {x=2, y=2},
        automatic_rotate = 0.2,
        glow = 14,
        physical = true
    },
    on_activate = function (self, staticdata)
        self.object:set_rotation(vector.new(math.random()*2, math.random(), math.random()*2)*math.pi)
        if staticdata and staticdata ~= "" then --not new, just unpack staticdata
            self.type = staticdata
        else --new entity, initialise stuff
            local types = {"matter_blob", "emitter"}
            self.type = types[math.random(#types)]
            local offset = vector.new(math.random(-48, 48), math.random(-48, 48), math.random(-48, 48))
            local pos = self.object:get_pos()
            local target = get_nearby_player(pos)
            if not target then minetest.log("nope") self.object:remove() end
            self.object:set_velocity(vector.normalize(target:get_pos()-pos+offset))
        end
        local texture = self.type..".png^meteorite.png"
        self.object:set_properties({textures={texture, texture, texture, texture, texture, texture}})
        self.object:set_armor_groups({immortal=1})
    end,
    get_staticdata = function (self)
        return self.type
    end,
    on_step = function (self, dtime)
        local pos = self.object:get_pos()
        local diag = vector.new(1, 1, 1)
        minetest.add_particlespawner({
            time = dtime,
            amount = 1,
            pos = {min=pos-diag, max=pos+diag},
            vel = {min=-0.5*diag, max=0.5*diag},
            drag = 0.2,
            glow = 14,
            exptime = {min=10, max=20},
            size = {min=1, max=2},
            texture = "meteorite_trail_"..self.type..".png",
            animation = {type="vertical_frames", aspect_width=4, aspect_height=4, length=-1}
        })
    end
})

local function spawn_meteorite(pos)
    local players = minetest.get_connected_players()
    local player = players[math.random(#players)]
    if not pos then
        pos = vector.zero()
        while vector.length(pos) < 100 do
            pos = vector.new(math.random(-120, 120), math.random(-120, 120), math.random(-120, 120))
        end
        pos = player:get_pos()+pos
    end
    return minetest.add_entity(pos, "sbz_meteorites:meteorite")
end

minetest.register_chatcommand("spawn_meteorite", {
    params = "[<x> <y> <z>]",
    description = "Attempts to spawn a meteorite somewhere.",
    privs = {give=true},
    func = function (name, param)
        param = string.split(param, " ")
        if #param == 3 and tonumber(param[1]) ~= "fail" and tonumber(param[2]) ~= "fail" and tonumber(param[3]) ~= "fail" then
            param = vector.new(tonumber(param[1]), tonumber(param[2]), tonumber(param[3]))
        else param = nil end
        local meteorite = spawn_meteorite(param)
        if not meteorite then minetest.chat_send_player(name, "Failed to spawn meteorite.") return end
        local pos = vector.round(meteorite:get_pos())
        minetest.chat_send_player(name, "Spawned meteorite at "..pos.x.." "..pos.y.." "..pos.z..".")
    end
})