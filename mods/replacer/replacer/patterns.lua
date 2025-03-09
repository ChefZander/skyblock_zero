replacer.patterns = {}
local r = replacer
local rp = replacer.patterns
local floor = math.floor
local is_protected = minetest.is_protected
local poshash = minetest.hash_node_position
local core_registered_nodes = minetest.registered_nodes
local vector_add = vector.add
local vector_distance = vector.distance

-- cache results of minetest.get_node
replacer.patterns.known_nodes = {}
function replacer.patterns.get_node(pos)
	local i = poshash(pos)
	local node = rp.known_nodes[i]
	if nil ~= node then
		return node
	end
	node = minetest.get_node(pos)
	rp.known_nodes[i] = node
	return node
end -- get_node

-- The cache is only valid as long as no node is changed in the world.
function replacer.patterns.reset_nodes_cache()
	rp.known_nodes = {}
end

-- tests if there's a node at pos which should be replaced
function replacer.patterns.replaceable(pos, node_name, player_name, param2)
	local node = rp.get_node(pos)
	if nil == param2 then
		-- crust mode ignores param2
		if 'air' ~= node_name then
			return (node.name == node_name) and (not is_protected(pos, player_name))
		end
		-- right clicking in crust mode checks for air, but vacuum should work too
		-- TODO: add mechanism to register allowed types
		-- some servers might have other nodes like mars-lights that should be allowed too
		-- maybe dummy lights, on the other hand, it might be useful to be able to stop replacer with dummy lights
		return (('air' == node.name) or ('vacuum:vacuum' == node.name)
				or 'planetoidgen:airlight' == node.name)
			and (not is_protected(pos, player_name))
	end
	-- in field mode we also check that param2 is the same as the
	-- initial node that was clicked on
	return (node.name == node_name) and (node.param2 == param2)
		and (not is_protected(pos, player_name))
end -- replaceable

replacer.patterns.translucent_nodes = {}
function replacer.patterns.node_translucent(name)
	local is_translucent = rp.translucent_nodes[name]
	if nil ~= is_translucent then
		return is_translucent
	end
	local def = core_registered_nodes[name]
	if def and ((not def.drawtype) or ('normal' == def.drawtype)) then
		rp.translucent_nodes[name] = false
		return false
	end
	rp.translucent_nodes[name] = true
	return true
end -- node_translucent

function replacer.patterns.field_position(pos, data)
	return rp.replaceable(pos, data.name, data.pname, data.param2)
		and rp.node_translucent(
			rp.get_node(vector_add(data.above, pos)).name) ~= data.right_clicked
end -- field_position

replacer.patterns.offsets_touch = {
	{ x = -1, y = 0,  z = 0 },
	{ x = 1,  y = 0,  z = 0 },
	{ x = 0,  y = -1, z = 0 },
	{ x = 0,  y = 1,  z = 0 },
	{ x = 0,  y = 0,  z = -1 },
	{ x = 0,  y = 0,  z = 1 },
}

-- 3x3x3 hollow cube
replacer.patterns.offsets_hollowcube = {}
do
	local p
	for x = -1, 1 do
		for y = -1, 1 do
			for z = -1, 1 do
				if (0 ~= x) or (0 ~= y) or (0 ~= z) then
					p = { x = x, y = y, z = z }
					rp.offsets_hollowcube[#rp.offsets_hollowcube + 1] = p
				end
			end
		end
	end
end

-- To get the crust, first nodes near it need to be collected
function replacer.patterns.crust_above_position(pos, data)
	-- test if the node at pos is a translucent node and not part of the crust
	local node_name = rp.get_node(pos).name
	if (node_name == data.name) or (not rp.node_translucent(node_name)) then
		return false
	end
	-- test if a node of the crust is near pos
	local p2
	for i = 1, 26 do
		p2 = rp.offsets_hollowcube[i]
		if rp.replaceable(vector_add(pos, p2), data.name, data.pname) then
			return true
		end
	end
	return false
end -- crust_above_position

-- used to get nodes the crust belongs to
function replacer.patterns.crust_under_position(pos, data)
	if not rp.replaceable(pos, data.name, data.pname) then
		return false
	end
	local p2
	for i = 1, 26 do
		p2 = rp.offsets_hollowcube[i]
		if data.aboves[poshash(vector_add(pos, p2))] then
			return true
		end
	end
	return false
end -- crust_under_position

-- extract the crust from the nodes the crust belongs to
function replacer.patterns.reduce_crust_ps(data)
	local newps = {}
	local n = 0
	local p, p2
	for i = 1, data.num do
		p = data.ps[i]
		for i2 = 1, 6 do
			p2 = rp.offsets_touch[i2]
			if data.aboves[poshash(vector_add(p, p2))] then
				n = n + 1
				newps[n] = p
				break
			end
		end
	end
	data.ps = newps
	data.num = n
end -- reduce_crust_ps

-- gets the air nodes touching the crust
function replacer.patterns.reduce_crust_above_ps(data)
	local newps = {}
	local n = 0
	local p, p2
	for i = 1, data.num do
		p = data.ps[i]
		if rp.replaceable(p, 'air', data.pname) then
			for i2 = 1, 6 do
				p2 = rp.offsets_touch[i2]
				if rp.replaceable(vector_add(p, p2), data.name, data.pname) then
					n = n + 1
					newps[n] = p
					break
				end
			end
		end
	end
	data.ps = newps
	data.num = n
end -- reduce_crust_above_ps

-- Algorithm created by sofar and changed by others:
-- https://github.com/minetest/minetest/commit/d7908ee49480caaab63d05c8a53d93103579d7a9

local function search_dfs(go, p, apply_move, moves)
	local num_moves = #moves

	-- Uncomment if the starting position should be walked even if its
	-- neighbours cannot be walked
	--~ go(p)

	-- The stack contains the path to the current position;
	-- an element of it contains a position and direction (index to moves)
	local s = r.datastructures.create_stack()
	-- The neighbor order we will visit from our table.
	local v = 1

	while true do
		-- Push current state onto the stack.
		s:push({ p = p, v = v })
		-- Go to the next position.
		p = apply_move(p, moves[v])
		-- Now we check out the node. If it is in need of an update,
		-- it will let us know in the return value (true = updated).
		local can_go, abort = go(p)
		if not can_go then
			if abort then
				return
			end
			-- If we don't need to "recurse" (walk) to it then pop
			-- our previous pos off the stack and continue from there,
			-- with the v value we were at when we last were at that
			-- node
			repeat
				local pop = s:pop()
				p = pop.p
				v = pop.v
				-- If there's nothing left on the stack, and no
				-- more sides to walk to, we're done and can exit
				if s:is_empty() and v == num_moves then
					return
				end
			until v < num_moves
			-- The next round walk the next neighbor in list.
			v = v + 1
		else
			-- If we did need to walk the neighbor/current position, then
			-- start walking from here from the walk order start (1),
			-- and not the order we just pushed up the stack.
			v = 1
		end
	end
end -- search_dfs


function replacer.patterns.search_positions(params)
	local moves = params.moves
	local max_positions = params.max_positions
	local fdata = params.fdata
	local startpos = params.startpos
	-- visiteds has only positions where fdata.func evaluated to true
	local visiteds = {}
	local founds = {}
	local n_founds = 0
	local function go(p)
		local vi = poshash(p)
		if visiteds[vi] or not fdata.func(p, fdata) then
			return false
		end
		n_founds = n_founds + 1
		founds[n_founds] = p
		visiteds[vi] = true
		if n_founds >= max_positions then
			-- Abort, too many positions
			return false, true
		end
		return true
	end
	search_dfs(go, startpos, vector_add, moves)
	if n_founds < max_positions or 0 >= r.radius_factor then
		return founds, n_founds, visiteds
	end

	-- Too many positions were found, so search again but only within
	-- a limited sphere around startpos
	local rr = floor(max_positions ^ r.radius_factor + .5)
	local visiteds_old = visiteds
	visiteds = {}
	founds = {}
	n_founds = 0
	local function go2(p)
		local vi = poshash(p)
		if visiteds[vi] then
			return false
		end
		if vector_distance(p, startpos) > rr then
			-- Outside of the sphere
			return false
		end
		if not visiteds_old[vi] and not fdata.func(p, fdata) then
			return false
		end
		n_founds = n_founds + 1
		founds[n_founds] = p
		visiteds[vi] = true
		return true
	end
	search_dfs(go2, startpos, vector_add, moves)
	return founds, n_founds, visiteds
end -- search_positions
