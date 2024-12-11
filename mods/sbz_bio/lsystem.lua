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


-- not exactly up to spec but good enough
local function lsystem(start_pos, dna, owner)
    local random = PcgRandom(dna.seed or (start_pos.x * 2 + start_pos.y * 4 + start_pos.z))
    local angle, trunk_type = dna.angle, dna.trunk_type

    dna = table.copy(dna)
    local stack_info = {}


    local set_node = function(pos, node, leafnode)
        pos = vector.round(pos)
        local node_at_pos = minetest.get_node(pos)
        if minetest.registered_nodes[node_at_pos.name].buildable_to or node_at_pos.name == leafnode
            and (not minetest.is_protected(pos, owner or "")) then
            minetest.set_node(pos, node)
        end
    end

    if type(dna.trunk) == "string" then dna.trunk = { name = dna.trunk } end
    if type(dna.leaves) == "string" then dna.leaves = { name = dna.leaves } end
    local serialized_dna = minetest.serialize(dna)
    local function spawn_leaves(pos)
        set_node(pos, dna.leaves, dna.leaves.name)
        minetest.get_meta(pos):set_string("dna", serialized_dna)
    end

    local function spawn_trunk(pos, branches)
        if dna.thin_branches and branches == false then
            set_node(pos, dna.branch or dna.trunk, dna.leaves.name)
        else
            if not trunk_type or trunk_type == "single" then
                set_node(pos, dna.trunk, dna.leaves.name)
            elseif trunk_type == "double" then
                local tmppos = vector.copy(pos)
                set_node(tmppos, dna.trunk, dna.leaves.name)
                tmppos.z = tmppos.z + 1
                set_node(tmppos, dna.trunk, dna.leaves.name)
                tmppos.x = tmppos.x + 1
                set_node(tmppos, dna.trunk, dna.leaves.name)
                tmppos.z = tmppos.z - 1
                set_node(tmppos, dna.trunk, dna.leaves.name)
            elseif trunk_type == "crossed" then
                local tmppos = vector.copy(pos)
                set_node(tmppos, dna.trunk, dna.leaves.name)
                tmppos.x = tmppos.x - 1
                set_node(tmppos, dna.trunk, dna.leaves.name)
                tmppos.x = tmppos.x + 2
                set_node(tmppos, dna.trunk, dna.leaves.name)
                tmppos.x = tmppos.x - 1
                tmppos.z = tmppos.z - 1
                set_node(tmppos, dna.trunk, dna.leaves.name)
                tmppos.z = tmppos.z + 2
                set_node(tmppos, dna.trunk, dna.leaves.name)
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
    local iterations_max = dna.iterations - random:next(0, dna.random_level or 0)
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
        if i > (dna.max_size or 100000) then
            break
        end
        if char == "G" then
            foward()
        elseif char == "F" then
            spawn_trunk(pos, true)
            foward()
        elseif char == "f" then
            spawn_leaves(pos)
            foward()
        elseif char == "T" then
            spawn_trunk(pos)
            foward()
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
            pos, rotation = unpack(table.remove(stack_info) or { pos, rotation })
        end
    end
end

local function string_insert(str1, str2, pos)
    return str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
end


local adding_probability = 10
local removing_probability = 5
-- changing probability is when those 3 dont work out
local max_size = 100


local rule_chars = "abcd"
local characters = "FFFfffTT" .. rule_chars:upper() .. rule_chars:lower() .. "+-&^/*["

local temp = {}
for i = 1, #characters do
    temp[#temp + 1] = string.sub(characters, i, i)
end
characters = temp


-- HORRIBLY OPTIMIZED
local function mutate_lsystem(axiom, random)
    local should_change = true
    if random:next(0, 100) <= adding_probability and #axiom < max_size then
        should_change = false
        local what_to_add = characters[random:next(1, #characters)]
        if what_to_add == "[" then
            local p1 = random:next(1, #axiom)
            local p2 = random:next(1, #axiom)

            if p2 > p1 then
                local temp = p2
                p2 = p1
                p1 = temp
            end
            if p2 == p1 then return end
            string_insert(axiom, "[", p1)
            string_insert(axiom, "]", p2)
        end
        axiom = axiom .. what_to_add
    end
    if random:next(0, 100) <= removing_probability then
        should_change = false
        local p = random:next(1, #axiom)
        local to_remove = { p }
        if p == "[" then
            local i = p
            local count_of_brackets = 1
            while true do
                i = i + 1
                local char = string.sub(axiom, i, i)
                if char == "" then break end
                if char == "[" then count_of_brackets = count_of_brackets + 1 end
                if char == "]" then count_of_brackets = count_of_brackets - 1 end
                if count_of_brackets == 0 then break end
            end
            if count_of_brackets == 0 then
                to_remove[#to_remove + 1] = i
            end
        end

        for i = 1, #to_remove do
            local v = to_remove[i]
            axiom = string.sub(axiom, v - 1) .. string.sub(axiom, v + 1)
        end
    end
    if should_change then
        local p = random:next(1, #axiom)
        local char_at_p = string.sub(axiom, p, p)
        if char_at_p == "]" or char_at_p == "[" then return end -- not gonna bother with those
        local change_to = characters[random:next(1, #characters - 1)]
        if change_to == "]" or change_to == "[" then return end
        axiom = string.sub(axiom, p - 1) .. change_to .. string.sub(axiom, p + 1)
    end
    return axiom
end

local chance_of_mutation = 30
local other_props_mutation_chance = 5 -- angle, iteration, random_level, trunk_type
local axiom_mutation_chance = 5
local rules_mutation_chance = 10



---@return nil
local function mutate_dna(dna, random, rate)
    -- alr.. so...
    if not random then random = PcgRandom(math.random(-2 ^ 31 + 1, 2 ^ 31 - 1)) end
    local function internal_mutate()
        -- if this gets passed, a mutation MAY happen, the number of mutations (=mutation rate) may be influenced by outside factors
        if random:next(0, 100) > chance_of_mutation then return end
        if random:next(0, 100) <= other_props_mutation_chance then
            local any_prop_mutation_chance = 100 / 4
            if random:next(0, 100) <= any_prop_mutation_chance then
                -- angle
                dna.angle = math.min(50, math.max(10, dna.angle + random:next(-10, 10)))
            elseif random:next(0, 100) <= any_prop_mutation_chance then
                -- iterations
                dna.iterations = math.max(5, math.abs(dna.iterations + random:next(-1, 1))) -- enforced a min of 2 automatically
            elseif random:next(0, 100) <= any_prop_mutation_chance then
                -- random_level
                dna.random_level = math.max(5, math.abs(dna.random_level + random:next(-1, 1)))
            elseif random:next(0, 100) <= any_prop_mutation_chance then
                dna.trunk_type = ({ "single", "double", "crossed" })[random:next(1, 3)]
            end
        end
        if random:next(0, 100) <= axiom_mutation_chance then
            dna.axiom = mutate_lsystem(dna.axiom, random) or dna.axiom
        end
        if random:next(0, 100) <= rules_mutation_chance then
            local rule_id = random:next(1, 4)
            local rule = string.sub(rule_chars, rule_id, rule_id)
            dna["rule_" .. rule] = mutate_lsystem(dna["rule_" .. rule] or " ", random) or dna["rule_" .. rule]
        end
    end
    for _ = 1, rate do
        internal_mutate()
    end
end

local function hash_dna(dna)
    return minetest.sha1(dna)
end


sbz_api.spawn_tree = lsystem
sbz_api.mutate_dna = mutate_dna
sbz_api.hash_dna = hash_dna
