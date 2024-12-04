-- make_axiom and make_treedef are from stellua, temporary
local MOVES = "FFffTTABCDabcd+-&^/*"

--Create random axiom recursively
local function make_axiom(rand, loops)
    loops = loops or 2
    local out = ""
    for _ = 1, rand:next(1, 20) do
        local char = rand:next(-loops, string.len(MOVES))
        if char <= 0 then
            out = out .. "[" .. make_axiom(rand, 0) .. "]"
        else
            out = out .. string.sub(MOVES, char, char)
        end
    end
    return out
end

--Generate random L-system definition
local function make_treedef(rand)
    return {
        axiom = make_axiom(rand),
        rules_a = make_axiom(rand),
        rules_b = make_axiom(rand),
        rules_c = make_axiom(rand),
        rules_d = make_axiom(rand),
        trunk = "sbz_bio:colorium_tree",
        leaves = "sbz_bio:colorium_leaves",
        angle = rand:next(10, 50),
        iterations = rand:next(1, 6),
        random_level = rand:next(0, 3),
        trunk_type = ({ "single", "single", "single", "double", "crossed" })[rand:next(1, 5)],
        thin_branches = true,
        fruit_chance = 0,
        seed = rand:next()
    }
end

local ruleset_chars = {
    ["A"] = 10,
    ["B"] = 10,
    ["C"] = 10,
    ["D"] = 10,
    ["a"] = 9,
    ["b"] = 8,
    ["c"] = 7,
    ["d"] = 6,
}

local set_node = function(pos, node)
    local node_at_pos = minetest.get_node(pos)
    if minetest.registered_nodes[node_at_pos.name].buildable_to then
        minetest.set_node(pos, node)
    end
end

-- not exactly up to spec but good enough
local function interpret_dna(start_pos, dna)
    local random = PcgRandom(dna.seed or (start_pos.x * 2 + start_pos.y * 4 + start_pos.z))
    local angle, trunk_type = dna.angle, dna.trunk_type

    dna = table.copy(dna)
    local stack_info = {}

    if type(dna.trunk) == "string" then dna.trunk = { name = dna.trunk } end
    if type(dna.leaves) == "string" then dna.leaves = { name = dna.leaves } end
    local function spawn_leaves(pos)
        set_node(pos, dna.leaves)
    end

    local function spawn_trunk(pos, branches)
        if dna.thin_branches and branches == false then
            set_node(pos, dna.branch or dna.trunk)
        else
            if not trunk_type or trunk_type == "single" then
                set_node(pos, dna.trunk)
            elseif trunk_type == "double" then
                local tmppos = vector.copy(pos)
                set_node(tmppos, dna.trunk)
                tmppos.z = tmppos.z + 1
                set_node(tmppos, dna.trunk)
                tmppos.x = tmppos.x + 1
                set_node(tmppos, dna.trunk)
                tmppos.z = tmppos.z - 1
                set_node(tmppos, dna.trunk)
            elseif trunk_type == "crossed" then
                local tmppos = vector.copy(pos)
                set_node(tmppos, dna.trunk)
                tmppos.x = tmppos.x - 1
                set_node(tmppos, dna.trunk)
                tmppos.x = tmppos.x + 2
                set_node(tmppos, dna.trunk)
                tmppos.x = tmppos.x - 1
                tmppos.z = tmppos.z - 1
                set_node(tmppos, dna.trunk)
                tmppos.z = tmppos.z + 2
                set_node(tmppos, dna.trunk)
            end
        end



        if branches and #stack_info ~= 0 then -- dont ask me, this is just minetest ok?
            local size = 1

            for x = -size, size do
                for y = -size, size do
                    for z = -size, size do
                        local abs = math.abs
                        if (abs(x) == size and abs(y) == size and abs(z) == size) then
                            spawn_leaves(vector.new(pos.x + x + 1, pos.y + y, pos.z + z))
                            spawn_leaves(vector.new(pos.x + x - 1, pos.y + y, pos.z + z))
                            spawn_leaves(vector.new(pos.x + x, pos.y + y, pos.z + z + 1))
                            spawn_leaves(vector.new(pos.x + x, pos.y + y, pos.z + z - 1))
                        end
                    end
                end
            end
        end
    end



    -- angle stuff
    angle = angle * math.pi / 180
    local iterations_max = dna.iterations - random:next(0, dna.random_level)
    if iterations_max < 2 then iterations_max = 2 end

    -- preprocess rules
    -- inspired by engine code (mfw its so undocumented i have to actually resort to that)
    -- https://github.com/minetest/minetest/blob/a45b04ffb4c0583ef3c8727ea0f73d40e3662e9d/src/mapgen/treegen.cpp#L194

    local axiom = dna.axiom
    for _ = 1, iterations_max do
        local temp = {}
        for i = 1, #axiom do
            local char = string.sub(axiom, i, i)
            if ruleset_chars[char] then
                local probability = ruleset_chars[char]
                if (random:next(1, 10) <= probability) then
                    temp[#temp + 1] = (dna["rules_" .. char:lower()] or "")
                end
            else
                temp[#temp + 1] = char
            end
        end
        axiom = table.concat(temp) -- took me a while to guess why this is there specifically, confusing code
    end

    local pos = vector.copy(start_pos)

    local rotation = { x = 0, y = 0, z = 0 }
    angle = angle

    local function foward()
        pos = pos + vector.rotate(vector.new(0, 1, 0), rotation)
    end
    local i = 0

    while true do
        i = i + 1
        local char = string.sub(axiom, i, i)
        if char == nil or char == "" then break end
        if char == "G" then
            foward()
        elseif char == "F" then
            foward()
            spawn_trunk(pos, true)
        elseif char == "f" then
            foward()
            spawn_leaves(pos)
        elseif char == "T" then
            foward()
            spawn_trunk(pos)
        elseif char == "+" then -- yaw
            rotation.y = rotation.y + angle
        elseif char == "-" then
            rotation.y = rotation.y - angle
        elseif char == "&" then -- pitch
            rotation.x = rotation.x - angle
        elseif char == "^" then
            rotation.x = rotation.x + angle
        elseif char == "/" then -- roll
            rotation.z = rotation.z + angle
        elseif char == "*" then
            rotation.z = rotation.z - angle
        elseif char == "[" then
            table.insert(stack_info, { table.copy(rotation), table.copy(pos) })
        elseif char == "]" then
            pos, rotation = unpack(table.remove(stack_info))
            if pos == nil then break end
        end
    end
end

local apple_tree = {
    axiom = "FFFFFAFFBF",
    rules_a = "[&&&FFFFF&&FFFF][&&&++++FFFFF&&FFFF][&&&----FFFFF&&FFFF]",
    rules_b = "[&&&++FFFFF&&FFFF][&&&--FFFFF&&FFFF][&&&------FFFFF&&FFFF]",
    trunk = "sbz_bio:colorium_tree",
    leaves = "sbz_bio:colorium_leaves",
    angle = 30,
    iterations = 2,
    random_level = 0,
    trunk_type = "single",
    thin_branches = true,
    fruit_chance = 0,
}

--Command to spawn a tree with random definition, for debugging
minetest.register_chatcommand("spawntree", {
    params = "",
    description = "Spawn a tree at current position",
    privs = { give = true, debug = true },
    func = function(playername, param)
        local treedef = make_treedef(PcgRandom(1))
        local pos = vector.round(minetest.get_player_by_name(playername):get_pos())
        if param == "dna" then
            interpret_dna(pos, treedef)
        elseif param == "l" then
            core.spawn_tree(pos, treedef)
        end
    end
})
