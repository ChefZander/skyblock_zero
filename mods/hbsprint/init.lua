-- Vars

local speed = 1.8
local jump = 1.1
local dir = false
local particles = 2
local stamina = true
local stamina_drain = 0.3
local stamina_regen = 0.3
local replenish = 0.1 -- time
local autohide = true

local sprint_timer_step = 0.1
local sprint_timer = 0
local sprinting = {}
local stamina_timer = {}

local mod_hudbars = minetest.get_modpath 'hudbars' ~= nil
local mod_player_monoids = minetest.get_modpath 'player_monoids' ~= nil

-- Functions

local function start_sprint(player)
    local name = player:get_player_name()
    if not sprinting[name] then
        if mod_player_monoids then
            player_monoids.speed:add_change(player, speed, 'hbsprint:speed')
            player_monoids.jump:add_change(player, jump, 'hbsprint:jump')
        else
            player:set_physics_override { speed = speed, jump = jump }
        end
        sprinting[name] = true
    end
end

local function stop_sprint(player)
    local name = player:get_player_name()
    if sprinting[name] then
        if mod_player_monoids then
            player_monoids.speed:del_change(player, 'hbsprint:speed')
            player_monoids.jump:del_change(player, 'hbsprint:jump')
        else
            player:set_physics_override { speed = 1, jump = 1 }
        end
        sprinting[name] = false
    end
end

local function drain_stamina(player)
    local player_stamina = player:get_meta():get_float 'hbsprint:stamina'
    if player_stamina > 0 then
        player_stamina = math.max(0, player_stamina - stamina_drain)
        player:get_meta():set_float('hbsprint:stamina', player_stamina)
    end
    if mod_hudbars then
        if autohide and player_stamina < 20 then hb.unhide_hudbar(player, 'stamina') end
        hb.change_hudbar(player, 'stamina', player_stamina)
    end
end

local function replenish_stamina(player)
    local player_stamina = player:get_meta():get_float 'hbsprint:stamina'
    player_stamina = math.min(20, player_stamina + stamina_regen)
    player:get_meta():set_float('hbsprint:stamina', player_stamina)
    if mod_hudbars then
        hb.change_hudbar(player, 'stamina', player_stamina)
        if autohide and player_stamina >= 20 then hb.hide_hudbar(player, 'stamina') end
    end
end

local function is_walkable(ground)
    local ground_def = minetest.registered_nodes[ground.name]
    return ground_def and (ground_def.walkable and ground_def.liquidtype == 'none')
end

local function create_particles(player, name, ground)
    local def = minetest.registered_nodes[ground.name] or {}
    local tile = def.tiles and def.tiles[1] or def.inventory_image
    if type(tile) == 'table' then tile = tile.name end
    if not tile then return end

    local pos = player:get_pos()
    local rand = function()
        return math.random(-1, 1) * math.random() / 2
    end
    for i = 1, particles do
        minetest.add_particle {
            pos = { x = pos.x + rand(), y = pos.y + 0.1, z = pos.z + rand() },
            velocity = { x = 0, y = 5, z = 0 },
            acceleration = { x = 0, y = -13, z = 0 },
            expirationtime = math.random(),
            size = math.random() + 0.5,
            vertical = false,
            texture = tile,
        }
    end
end

-- Registrations

if mod_hudbars and stamina then
    hb.register_hudbar('stamina', 0xFFFFFF, 'Stamina', {
        bar = 'sprint_stamina_bar.png',
        icon = 'sprint_stamina_icon.png',
        bgicon = 'sprint_stamina_bgicon.png',
    }, 20, 20, autohide)
end

minetest.register_on_joinplayer(function(player)
    if stamina then
        if mod_hudbars then hb.init_hudbar(player, 'stamina', 20, 20, autohide) end
        player:get_meta():set_float('hbsprint:stamina', 20)
    end
end)

local function sprint_step(player, dtime)
    local name = player:get_player_name()
    local fast = minetest.get_player_privs(name).fast

    if not fast then
        if stamina then stamina_timer[name] = (stamina_timer[name] or 0) + dtime end
    end

    local ctrl = player:get_player_control()
    local key_press
    if dir then
        key_press = ctrl.aux1 and ctrl.up and not ctrl.left and not ctrl.right
    else
        key_press = ctrl.aux1 and (ctrl.up or ctrl.left or ctrl.right or ctrl.down)
    end

    if not key_press then
        stop_sprint(player)
        if stamina and not fast and stamina_timer[name] >= replenish then
            replenish_stamina(player)
            stamina_timer[name] = 0
        end
        return
    end

    local ground_pos = player:get_pos()
    ground_pos.y = math.floor(ground_pos.y)
    -- check if player is reasonably near a walkable node
    local ground
    for _, y_off in ipairs { 0, -1, -2 } do
        local testpos = vector.add(ground_pos, { x = 0, y = y_off, z = 0 })
        local testnode = minetest.get_node_or_nil(testpos)
        if testnode ~= nil and is_walkable(testnode) then
            ground = testnode
            break
        end
    end

    local player_stamina = 1
    if stamina then player_stamina = player:get_meta():get_float 'hbsprint:stamina' end

    if (player_stamina > 0) or fast then
        start_sprint(player)
        if stamina and not fast then drain_stamina(player) end
        if particles and ground then create_particles(player, name, ground) end
    else
        stop_sprint(player)
    end
end

minetest.register_globalstep(function(dtime)
    sprint_timer = sprint_timer + dtime
    if sprint_timer >= sprint_timer_step then
        for _, player in ipairs(minetest.get_connected_players()) do
            sprint_step(player, sprint_timer)
        end
        sprint_timer = 0
    end
end)
