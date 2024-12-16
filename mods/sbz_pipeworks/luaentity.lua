local max_entity_id = 1000000000000 -- If you need more, there's a problem with your code

local luaentity = {}
pipeworks.luaentity = luaentity

luaentity.registered_entities = {}

local filename = minetest.get_worldpath() .. "/luaentities"
local function read_file()
	local f = io.open(filename, "r")
	if f == nil then return {} end
	local t = f:read("*all")
	f:close()
	if t == "" or t == nil then return {} end
	return minetest.deserialize(t) or {}
end

local function write_file(tbl)
	local f = io.open(filename, "w")
	f:write(minetest.serialize(tbl))
	f:close()
end

local function read_entities()
	local t = read_file()
	for _, entity in pairs(t) do
		if entity.start_pos ~= nil then
			local x = entity.start_pos.x
			local y = entity.start_pos.y
			local z = entity.start_pos.z

			x = math.max(-30912, x)
			y = math.max(-30912, y)
			z = math.max(-30912, z)
			x = math.min(30927, x)
			y = math.min(30927, y)
			z = math.min(30927, z)

			entity.start_pos.x = x
			entity.start_pos.y = y
			entity.start_pos.z = z

			setmetatable(entity, luaentity.registered_entities[entity.name])
		end
	end
	return t
end

local function write_entities()
	if not luaentity.entities then
		-- This can happen if crashing on startup, causing another error that
		-- masks the original one. Return gracefully in that case instead.
		return
	end
	for _, entity in pairs(luaentity.entities) do
		setmetatable(entity, nil)
		for _, attached in pairs(entity._attached_entities) do
			if attached.entity then
				attached.entity:remove()
				attached.entity = nil
			end
		end
		entity._attached_entities_master = nil
	end
	write_file(luaentity.entities)
end

minetest.register_on_shutdown(write_entities)
luaentity.entities_index = 0

local move_entities_globalstep_part1
local is_active

if pipeworks.use_real_entities then
	local active_blocks = {} -- These only contain active blocks near players (i.e., not forceloaded ones)

	local function get_blockpos(pos)
		return {
			x = math.floor(pos.x / 16),
			y = math.floor(pos.y / 16),
			z = math.floor(pos.z / 16)
		}
	end

	move_entities_globalstep_part1 = function(dtime)
		local active_block_range = tonumber(minetest.settings:get("active_block_range")) or 2
		for key in pairs(active_blocks) do
			active_blocks[key] = nil
		end
		for _, player in ipairs(minetest.get_connected_players()) do
			local blockpos = get_blockpos(player:get_pos())
			local minpx = blockpos.x - active_block_range
			local minpy = blockpos.y - active_block_range
			local minpz = blockpos.z - active_block_range
			local maxpx = blockpos.x + active_block_range
			local maxpy = blockpos.y + active_block_range
			local maxpz = blockpos.z + active_block_range

			for x = minpx, maxpx do
				for y = minpy, maxpy do
					for z = minpz, maxpz do
						local pos = { x = x, y = y, z = z }
						active_blocks[minetest.hash_node_position(pos)] = true
					end
				end
			end
		end
		-- todo: callbacks on block load/unload
	end

	is_active = function(pos)
		return active_blocks[minetest.hash_node_position(get_blockpos(pos))] ~= nil
	end
else
	move_entities_globalstep_part1 = function()
	end

	is_active = function()
		return false
	end
end

local entitydef_default = {
	_attach = function(self, attached, attach_to)
		local attached_def = self._attached_entities[attached]
		local attach_to_def = self._attached_entities[attach_to]
		attached_def.entity:set_attach(
			attach_to_def.entity, "",
			vector.subtract(attached_def.offset, attach_to_def.offset), -- todo: Does not work because is object space
			vector.new(0, 0, 0)
		)
	end,
	_set_master = function(self, index)
		self._attached_entities_master = index
		if not index then
			return
		end
		local def = self._attached_entities[index]
		if not def.entity then
			return
		end
		def.entity:set_pos(vector.add(self._pos, def.offset))
		def.entity:set_velocity(self._velocity)
		def.entity:set_acceleration(self._acceleration)
	end,
	_attach_all = function(self)
		local master = self._attached_entities_master
		if not master then
			return
		end
		for id, entity in pairs(self._attached_entities) do
			if id ~= master and entity.entity then
				self:_attach(id, master)
			end
		end
	end,
	_detach_all = function(self)
		local master = self._attached_entities_master
		for id, entity in pairs(self._attached_entities) do
			if id ~= master and entity.entity then
				entity.entity:set_detach()
			end
		end
	end,
	_add_attached = function(self, index)
		local entity = self._attached_entities[index]
		if entity.entity then
			return
		end
		local entity_pos = vector.add(self._pos, entity.offset)
		if not is_active(entity_pos) then
			return
		end
		local object = minetest.add_entity(entity_pos, entity.name)
		if not object then
			return
		end
		local ent = object:get_luaentity()
		ent:from_data(entity.data)
		ent.parent_id = self._id
		ent.attached_id = index
		entity.entity = object
		local master = self._attached_entities_master
		if master then
			self:_attach(index, master)
		else
			self:_set_master(index)
		end
	end,
	_remove_attached = function(self, index)
		local master = self._attached_entities_master
		local entity = self._attached_entities[index]
		local ent = entity and entity.entity
		if entity then entity.entity = nil end
		if index == master then
			self:_detach_all()
			local newmaster
			for id, attached in pairs(self._attached_entities) do
				if id ~= master and attached.entity then
					newmaster = id
					break
				end
			end
			self:_set_master(newmaster)
			self:_attach_all()
		elseif master and ent then
			ent:set_detach()
		end
		if ent then
			ent:remove()
		end
	end,
	_add_loaded = function(self)
		for id, _ in pairs(self._attached_entities) do
			self:_add_attached(id)
		end
	end,
	get_id = function(self)
		return self._id
	end,
	get_pos = function(self)
		return vector.new(self._pos)
	end,
	set_pos = function(self, pos)
		self._pos = vector.new(pos)
		--for _, entity in pairs(self._attached_entities) do
		--	if entity.entity then
		--		entity.entity:set_pos(vector.add(self._pos, entity.offset))
		--	end
		--end
		local master = self._attached_entities_master
		if master then
			local master_def = self._attached_entities[master]
			master_def.entity:set_pos(vector.add(self._pos, master_def.offset))
		end
	end,
	get_velocity = function(self)
		return vector.new(self._velocity)
	end,
	set_velocity = function(self, velocity)
		self._velocity = vector.new(velocity)
		local master = self._attached_entities_master
		if master then
			self._attached_entities[master].entity:set_velocity(self._velocity)
		end
	end,
	get_acceleration = function(self)
		return vector.new(self._acceleration)
	end,
	set_acceleration = function(self, acceleration)
		self._acceleration = vector.new(acceleration)
		local master = self._attached_entities_master
		if master then
			self._attached_entities[master].entity:set_acceleration(self._acceleration)
		end
	end,
	remove = function(self)
		self:_detach_all()
		for _, entity in pairs(self._attached_entities) do
			if entity.entity then
				entity.entity:remove()
			end
		end
		luaentity.entities[self._id] = nil
	end,
	add_attached_entity = function(self, name, data, offset)
		local index = #self._attached_entities + 1
		self._attached_entities[index] = {
			name = name,
			data = data,
			offset = vector.new(offset),
		}
		self:_add_attached(index)
		return index
	end,
	remove_attached_entity = function(self, index)
		self:_remove_attached(index)
		self._attached_entities[index] = nil
	end,
}

function luaentity.register_entity(name, prototype)
	-- name = check_modname_prefix(name)
	prototype.name = name
	setmetatable(prototype, { __index = entitydef_default })
	prototype.__index = prototype -- Make it possible to use it as metatable
	luaentity.registered_entities[name] = prototype
end

-- function luaentity.get_entity_definition(entity)
--	 return luaentity.registered_entities[entity.name]
-- end

function luaentity.add_entity(pos, name)
	if not luaentity.entities then
		minetest.after(0, luaentity.add_entity, vector.new(pos), name)
		return
	end
	local index = luaentity.entities_index
	while luaentity.entities[index] do
		index = index + 1
		if index >= max_entity_id then
			index = 0
		end
	end
	luaentity.entities_index = index

	local entity = {
		name = name,
		_id = index,
		_pos = vector.new(pos),
		_velocity = { x = 0, y = 0, z = 0 },
		_acceleration = { x = 0, y = 0, z = 0 },
		_attached_entities = {},
	}

	local prototype = luaentity.registered_entities[name]
	setmetatable(entity, prototype) -- Default to prototype for other methods
	luaentity.entities[index] = entity

	if entity.on_activate then
		entity:on_activate()
	end
	return entity
end

-- todo: check if remove in get_staticdata works
function luaentity.get_staticdata(self)
	local parent = luaentity.entities[self.parent_id]
	if parent and parent._remove_attached then
		parent:_remove_attached(self.attached_id)
	end
	return "toremove"
end

function luaentity.on_activate(self, staticdata)
	if staticdata == "toremove" then
		self.object:remove()
	end
end

function luaentity.get_objects_inside_radius(pos, radius)
	local objects = {}
	local index = 1
	for _, entity in pairs(luaentity.entities) do
		if vector.distance(pos, entity:get_pos()) <= radius then
			objects[index] = entity
			index = index + 1
		end
	end
	return objects
end

local move_entities_globalstep_part2 = function(dtime)
	if not luaentity.entities then
		luaentity.entities = read_entities()
	end
	for _, entity in pairs(luaentity.entities) do
		local master = entity._attached_entities_master
		local master_def = master and entity._attached_entities[master]
		local master_entity = master_def and master_def.entity
		local master_entity_pos = master_entity and master_entity:get_pos()
		if master_entity_pos then
			entity._pos = vector.subtract(master_entity_pos, master_def.offset)
			entity._velocity = master_entity:get_velocity()
			entity._acceleration = master_entity:get_acceleration()
		else
			entity._velocity = entity._velocity or vector.new(0, 0, 0)
			entity._acceleration = entity._acceleration or vector.new(0, 0, 0)
			entity._pos = vector.add(vector.add(
					entity._pos,
					vector.multiply(entity._velocity, dtime)),
				vector.multiply(entity._acceleration, 0.5 * dtime * dtime))
			entity._velocity = vector.add(
				entity._velocity,
				vector.multiply(entity._acceleration, dtime))
		end
		if master and not master_entity_pos then -- The entity has somehow been cleared
			if pipeworks.delete_item_on_clearobject then
				entity:remove()
			else
				entity:_remove_attached(master)
				entity:_add_loaded()
				if entity.on_step then
					entity:on_step(dtime)
				end
			end
		else
			entity:_add_loaded()
			if entity.on_step then
				entity:on_step(dtime)
			end
		end
	end
end

-- dtime after which there is an update (or skip).
local dtime_threshold = pipeworks.entity_update_interval
-- Accumulated dtime since last update (or skip).
local dtime_accum = 0
-- Delayed dtime accumulated due to skipped updates.
local dtime_delayed = 0
local skip_update = false

minetest.register_globalstep(function(dtime)
	if dtime >= 0.2 and dtime_delayed < 1 then
		-- Reduce activity when the server is lagging.
		skip_update = true
	end

	dtime_accum = dtime_accum + dtime
	if dtime_accum < dtime_threshold then
		return
	end

	if skip_update then
		dtime_delayed = dtime_delayed + dtime_accum
		skip_update = false
	else
		move_entities_globalstep_part1(dtime_accum + dtime_delayed)
		move_entities_globalstep_part2(dtime_accum + dtime_delayed)
		dtime_delayed = 0
	end

	-- Tune the threshold so that the average interval is pipeworks.entity_update_interval.
	dtime_threshold = math.max(dtime_threshold + (pipeworks.entity_update_interval - dtime_accum) / 10, 0)

	dtime_accum = 0
end)
