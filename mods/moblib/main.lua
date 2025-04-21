storage = minetest.get_mod_storage()
entities_by_id = setmetatable({}, {__mode = "v"})
objects_by_id = setmetatable({}, {
	__index = function(_, id)
		local entity = entities_by_id[id]
		return entity and entity.object
	end,
	__newindex = function(self, id, object)
		local luaentity = object:get_luaentity()
		if luaentity then
			entities_by_id[id] = luaentity
		else
			self[id] = object
		end
	end,
	__mode = "v"
})

local highest_id = storage:get_int("highest_id")

minetest.register_on_joinplayer(function(player)
	-- INFO no need to check whether it's an entity
	rawset(objects_by_id, player:get_player_name(), player)
end)

minetest.register_on_leaveplayer(function(player)
	objects_by_id[player:get_player_name()] = nil
end)

function get_id(object)
	if object:is_player() then
		return object:get_player_name()
	end
	local luaentity = object:get_luaentity()
	if luaentity and luaentity._ then
		return luaentity._.id
	end
end

function get_object(id)
	return objects_by_id[id]
end

function get_entity(id)
	return entities_by_id[id]
end

-- x/z-rotation
local function horizontal_rotation(direction)
	return math.atan2(direction.y, math.sqrt(direction.x*direction.x + direction.z*direction.z))
end

-- y-rotation
local function vertical_rotation(direction)
	return -math.atan2(direction.x, direction.z)
end

-- gets rotation in radians for a z-facing object
function get_rotation(direction)
	return {
		x = horizontal_rotation(direction),
		y = vertical_rotation(direction),
		z = 0
	}
end

-- converts a rotation from -pi to pi to 2pi to 0
function convert_rotation(rotation)
	return vector.apply(rotation, function(c)
		if c < 0 then
			return 2*math.pi + c
		end
		return c
	end)
end

-- shorthand
function get_converted_rotation(direction)
	return convert_rotation(get_rotation(direction))
end

-- normalizes a rotation
function normalize_rotation(rotation)
	return vector.apply(rotation, function(c)
		local nc = c % (2*math.pi)
		if c < 0 then
			return 2*math.pi + nc
		end
		return nc
	end)
end

function get_minimum_converted_rotation_difference(rotation, other_rotation)
	return vector.apply(vector.subtract(rotation, other_rotation), function(c)
		if c > math.pi then
			return -2*math.pi + c
		end
		if c < -math.pi then
			return 2*math.pi + c
		end
		return c
	end)
end

-- gets rotation in radians for a wielditem (such as a sword)
function get_wield_rotation(direction)
	return {
		x = 0,
		y = 1.5*math.pi+vertical_rotation(direction),
		z = 1.25*math.pi+horizontal_rotation(direction)
	}
end

-- gets the direction for a rotated vector (0, 0, 1), inverse of get_rotation
function get_direction(rotation)
	local rx, ry = rotation.x, rotation.y
	local direction = {}
	-- x rotation
	direction.y = math.sin(rx)
	local z = math.cos(rx)
	-- y rotation
	direction.x = -(z * math.sin(ry))
	direction.z = z * math.cos(ry)
	return direction
end

function set_look_dir(player, direction)
	local rotation = get_rotation(direction)
	player:set_look_vertical(-rotation.x)
	player:set_look_horizontal(rotation.y)
end

function get_eye_pos(object)
	local eye_pos = object:get_pos()
	if object:is_player() then
		eye_pos.y = eye_pos.y + object:get_properties().eye_height
	end
	return eye_pos
end

function get_center(object)
	local collisionbox = object:get_properties().collisionbox
	return vector.add(object:get_pos(), vector.divide(vector.add(vector.new(collisionbox[1], collisionbox[2], collisionbox[3]), vector.new(unpack(collisionbox, 4))), 2))
end

function get_mass(object)
	local entity = object:get_luaentity()
	if entity and entity._mass then
		return entity._mass
	end
	local collisionbox = object:get_properties().collisionbox
	local mass = (collisionbox[4] - collisionbox[1]) * (collisionbox[5] - collisionbox[2]) * (collisionbox[6] - collisionbox[3])
	assert(mass > 0)
	return mass
end

function calculate_damage(object, time_since_last_punch, caps)
	local damage = 0
	local armor_groups = assert(object:get_armor_groups()) -- object has to be alive
	for group, group_damage in pairs(caps.damage_groups) do
		damage = damage + group_damage * (armor_groups[group] or 0) / 100
	end
	return damage * math.min(1, math.max(0, time_since_last_punch / caps.full_punch_interval))
end

-- TODO implement physics such as air resistance
local engine_has_moveresult = minetest.has_feature("object_step_has_moveresult")
local sensitivity = 0.01
function register_entity(name, def)
	local props = def.lua_properties
	def.lua_properties = nil
	local on_activate = def.on_activate or function() end
	local on_step = def.on_step or function() end
	local terminal_speed = props.terminal_speed
	if terminal_speed then
		local old_on_step = on_step
		function on_step(self, dtime, ...)
			old_on_step(self, dtime, ...)
			local obj = self.object
			local vel = obj:get_velocity()
			if not vel then return end -- object has been deleted
			local len = vector.length(obj:get_velocity())
			if len > terminal_speed then
				obj:set_velocity(vector.multiply(vector.divide(vel, len)))
			end
		end
	end
	local props_staticdata = props.staticdata
	local props_id = props.id
	if props_id then
		assert(props_staticdata)
	end
	if props_staticdata then
		local implementation
		if type(props_staticdata) == "table" then
			implementation = props_staticdata
		else
			implementation = ({
				json = {
					serializer = minetest.write_json,
					deserializer = minetest.parse_json
				},
				lua = {
					serializer = minetest.serialize,
					deserializer = minetest.deserialize
				}
			})[props_staticdata]
		end
		local serializer = implementation.serializer
		local deserializer = implementation.deserializer
		local old_on_activate = on_activate
		function on_activate(self, staticdata, dtime)
			self._ = (staticdata ~= "" and deserializer(staticdata)) or {}
			if props_id then
				if not self._.id then
					highest_id = highest_id + 1
					self._.id = highest_id
					storage:set_int("highest_id", highest_id)
				end
				entities_by_id[self._.id] = self
			end
			old_on_activate(self, staticdata, dtime)
		end
		function def.get_staticdata(self)
			return serializer(self._)
		end
	end
	-- TODO consider HACK for #10158
	if props.moveresult then
		-- localizing variables for performance reasons
		local mr = props.moveresult
		local mr_collisions = mr.collisions
		local mr_axes = mr.axes
		local mr_old_velocity = mr.old_velocity
		local mr_acc_dependent = mr.acceleration_dependent
		local mr_speed_diff = mr.speed_difference
		local mr_moblib = mr.moblib
		local old_on_activate = on_activate
		function on_activate(self, staticdata, dtime)
			old_on_activate(self, staticdata, dtime)
			self._last_velocity = self.object:get_velocity()
		end
		local old_on_step = on_step
		function on_step(self, dtime, moveresult)
			local obj = self.object
			if engine_has_moveresult and not mr_acc_dependent and not mr_moblib then
				if moveresult.collides then
					if mr_axes then
						local axes = {}
						for _, collision in ipairs(moveresult.collisions) do
							axes[collision.axis] = true
						end
						moveresult.axes = axes
					end
					if mr_old_velocity then
						if not moveresult.collisions[1] then
							moveresult.old_velocity = self._last_velocity
						else
							moveresult.old_velocity = moveresult.collisions[1].old_velocity
						end
					end
					if mr_speed_diff then
						local expected_vel = vector.add(self._last_velocity, vector.multiply(obj:get_acceleration(), dtime))
						moveresult.speed_difference = vector.length(vector.subtract(expected_vel, obj:get_velocity()))
					end
				end
			else
				moveresult = {collides = false}
				if self._last_velocity then
					local expected_vel = vector.add(self._last_velocity, vector.multiply(obj:get_acceleration(), dtime))
					local velocity = obj:get_velocity()
					local diff = vector.subtract(expected_vel, velocity)
					local speed_difference = vector.length(diff)
					local collides = speed_difference >= sensitivity
					moveresult.collides = collides
					if collides then
						if mr_speed_diff then
							moveresult.speed_difference = speed_difference
						end
						if mr_collisions then
							local collisions = {}
							diff = vector.apply(diff, math.abs)
							local new_velocity = self._last_velocity
							for axis, component_diff in pairs(diff) do
								if component_diff > sensitivity then
									new_velocity[axis] = velocity[axis]
									table.insert(collisions, {
										axis = axis,
										old_velocity = self._last_velocity,
										new_velocity = new_velocity
									})
								end
							end
							moveresult.collisions = collisions
						end
						if mr_axes then
							local axes = {}
							diff = vector.apply(diff, math.abs)
							for axis, component_diff in pairs(diff) do
								if component_diff > sensitivity then
									axes[axis] = true
								end
							end
							moveresult.axes = axes
						end
						if mr_old_velocity then
							moveresult.old_velocity = self._last_velocity
						end
						if mr_acc_dependent then
							moveresult.acceleration_dependent = vector.length(vector.subtract(self._last_velocity, velocity)) < sensitivity
						end
					end
				end
			end
			old_on_step(self, dtime, moveresult)
			self._last_velocity = obj:get_velocity()
		end
		function def._set_velocity(self, velocity)
			self.object:set_velocity(velocity)
			self._last_velocity = velocity
		end
	end
	def.on_activate = on_activate
	def.on_step = on_step
	minetest.register_entity(name, def)
end