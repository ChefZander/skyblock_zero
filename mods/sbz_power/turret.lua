minetest.register_entity("sbz_power:turret_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "turret.gltf",
        visual_size = { x = 5, y = 5 },
        --automatic_rotate = 0.2,
        glow = 14,
        physical = false,
        pointable = false,
        textures = {
            "turret.png",
        }
    },
    on_activate = function(self)
        local node = minetest.get_node(vector.round(self.object:get_pos())).name
        if node ~= "sbz_power:turret" then
            self.object:remove()
        end
        -- self.object:set_rotation(vector.new(math.random() * 2, math.random(), math.random() * 2) * math.pi)
    end,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        local node = minetest.get_node(vector.round(pos)).name
        if node ~= "sbz_power:turret" then
            self.object:remove()
        end
    end
})

sbz_api.register_machine("sbz_power:turret", {
    description = "Automatic Turret",
    drawtype = "glasslike",
    tiles = { "gravitational_repulsor.png" },
    inventory_image = "gravitational_repulsor.png^(([combine:32x32:8,8=turret_front.png)^[invert:rgb^[resize:16x16)",
    wield_image = "gravitational_repulsor.png^(([combine:32x32:8,8=turret_front.png)^[invert:rgb^[resize:16x16)",
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 7,
    groups = { matter = 1, cracky = 3, charged = 1 },
    on_construct = function(pos)
        minetest.add_entity(vector.subtract(pos, vector.new(0, 0.25, 0)), "sbz_power:turret_entity")
        local meta = core.get_meta(pos)
        meta:get_inventory():set_size("main", 32)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;main;0.2,0.2;8,4;]
list[current_player;main;0.2,5;8,4;]
listring[]
]])
    end,
    sounds = sbz_api.sounds.machine(),
    action = function(...)
        return 0
    end
})

--- Side effect: creates turret entity when its not found
local function get_turret_entity(pos)
    local entities = core.get_objects_inside_radius(pos, 0.5)
    for k, v in pairs(entities) do
        if v:get_luaentity() then
            if v:get_luaentity().name == "sbz_power:turret_entity" then
                return v
            end
        end
    end

    return minetest.add_entity(vector.subtract(pos, vector.new(0, 0.25, 0)), "sbz_power:turret_entity")
end

local function get_index(inv, item)
    if not inv:contains_item("main", item) then return false end
    local list = inv:get_list("main")

    for k, v in ipairs(list) do
        v:set_count(1) -- so that counts match, doesnt actually modify anything in the inventory, kinda wish it would ngl
        v:set_wear(1)  -- so that wear matches
        if item:equals(v) and item:is_known() then
            return k
        end
    end
    return false
end

-- angles is look_dir, not yaw pitch roll crap
sbz_api.shoot_turret = function(pos, item, angles, owner)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    -- prepare item for comparing
    item = ItemStack(item)
    item:set_wear(1)
    item:set_count(1)
    local index = get_index(inv, item)
    if not index then return false end
    local stack = inv:get_stack("main", index)
    -- now...  call on_use
    -- prepare fake player n crap yknow how it goes
    local fakeplayer = fakelib.create_player {
        name = owner or "",
        position = pos,
        -- controls = todo?,
        inventory = inv,
        wield_list = "main",
        wield_index = index,
        -- what makes this different from the node breaker:
        direction = angles,
    }

    -- dont give a crap about pointed thing
    local pointed = {
        above = pos,
        under = pos,
        fake = true,
        swapped = false,
    } -- pointed_thing does not matter trust m

    -- these 2 lines copied from pipeworks sorry
    stack = item:get_definition().on_use(stack, fakeplayer, pointed) or stack
    fakeplayer:set_wielded_item(stack)

    local angles_vec = vector.new(angles[1], angles[2], 0)

    local rotation = vector.dir_to_rotation(angles_vec, vector.new(0, 1, 0))
    local turret_entity = get_turret_entity(pos)
    turret_entity:set_rotation(rotation)
end
