local function get_nearby_player(pos)
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 200)) do
        if obj:is_player() then return obj end
    end
end

--vector.random_direction was added in 5.10-dev, but I use 5.9, so make sure this exists
--code borrowed from builtin/vector.lua in 5.10-dev
if not vector.random_direction then
    function vector.random_direction()
        -- Generate a random direction of unit length, via rejection sampling
        local x, y, z, l2
        repeat -- expected less than two attempts on average (volume sphere vs. cube)
            x, y, z = math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1
            l2 = x*x + y*y + z*z
        until l2 <= 1 and l2 >= 1e-6
        -- normalize
        local l = math.sqrt(l2)
        return vector.new(x/l, y/l, z/l)
    end
end

local function meteorite_explode(pos, type)
    --breaking nodes
    for _ = 1, 100 do
        local raycast = minetest.raycast(pos, pos+vector.random_direction()*8, false)
        local wear = 0
        for pointed in raycast do
            if pointed.type == "node" then
                local nodename = minetest.get_node(pointed.under).name
                wear = wear+(1/minetest.get_item_group(nodename, "explody"))
                --the explody group hence signifies roughly how many such nodes in a straight line it can break before stopping
                --although this is very random
                if wear > 1 then break end
                minetest.set_node(pointed.under, {name=minetest.registered_nodes[nodename]._exploded or "air"})
            end
        end
    end
    --placing nodes
    local node_types = {matter_blob="sbz_meteorites:meteoric_matter", emitter="sbz_meteorites:meteoric_emittrium"}
    for _ = 1, 16 do
        local new_pos = pos+vector.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
        if minetest.get_node(new_pos).name == "air" then
            minetest.set_node(new_pos, {name=math.random() < 0.2 and "sbz_meteorites:meteoric_metal" or node_types[type]})
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
        exptime = {min=2, max=5},
        size = {min=3, max=6},
        texture = "meteorite_trail_"..type..".png",
        animation = {type="vertical_frames", aspect_width=4, aspect_height=4, length=-1},
        attract = {
            kind = "point",
            origin = pos,
            strength = {min=-4, max=0}
        }
    })
    local forward = vector.new(1, 0, 0)
    local up = vector.new(0, 1, 0)
    for _ = 1, 500 do
        local dir = vector.rotate_around_axis(forward, up, math.random()*2*math.pi)
        local expiry = math.random()*3+2
        minetest.add_particle({
            pos = pos+dir,
            velocity = dir*(5+math.random()),
            drag = vector.new(0.2, 0.2, 0.2),
            glow = 14,
            expirationtime = expiry,
            size = math.random()*3+3,
            texture = "meteorite_trail_"..type..".png^[colorize:#aaaaaa:alpha",
            animation = {type="vertical_frames", aspect_width=4, aspect_height=4, length=expiry},
        })
    end
end

minetest.register_node("sbz_meteorites:meteoric_matter", {
    description = "Meteoric Matter",
    tiles = {"matter_blob.png^meteoric_overlay.png"},
    paramtype = "light",
    light_source = 10,
    groups = {matter=1, cracky=3},
    drop = {
        max_items = 9,
        items = {
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}},
            {rarity=2, items={"sbz_resources:matter_dust"}}
        }
    }
})

minetest.register_node("sbz_meteorites:meteoric_emittrium", {
    description = "Meteoric Emittrium",
    tiles = {"emitter.png^meteoric_overlay.png"},
    paramtype = "light",
    light_source = 10,
    groups = {matter=1, cracky=3},
    drop = {
        max_items = 9,
        items = {
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}},
            {rarity=2, items={"sbz_resources:raw_emittrium"}}
        }
    }
})

minetest.register_node("sbz_meteorites:meteoric_metal", {
    description = "Meteoric Metal",
    tiles = {"metal.png^meteoric_overlay.png"},
    paramtype = "light",
    light_source = 10,
    groups = {matter=1, cracky=3},
    drop = {
        max_items = 9,
        items = {
            {rarity=16, items={"sbz_chem:gold_powder"}},
            {rarity=16, items={"sbz_chem:silver_powder"}},
            {rarity=16, items={"sbz_chem:iron_powder"}},
            {rarity=16, items={"sbz_chem:copper_powder"}},
            {rarity=16, items={"sbz_chem:aluminum_powder"}},
            {rarity=16, items={"sbz_chem:lead_powder"}},
            {rarity=16, items={"sbz_chem:zinc_powder"}},
            {rarity=16, items={"sbz_chem:tin_powder"}},
            {rarity=16, items={"sbz_chem:nickel_powder"}},
            {rarity=16, items={"sbz_chem:platinum_powder"}},
            {rarity=16, items={"sbz_chem:mercury_powder"}},
            {rarity=16, items={"sbz_chem:cobalt_powder"}},
            {rarity=16, items={"sbz_chem:titanium_powder"}},
            {rarity=16, items={"sbz_chem:magnesium_powder"}},
            {rarity=16, items={"sbz_chem:calcium_powder"}},
            {rarity=16, items={"sbz_chem:sodium_powder"}},
            {rarity=16, items={"sbz_chem:lithium_powder"}}
        }
    }
})

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
    on_step = function (self, dtime, moveresult)
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
        if moveresult and moveresult.collisions[1] then --colliding with something, should explode
            self.object:remove()
            meteorite_explode(pos, self.type)
        end
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