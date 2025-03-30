visible_wielditem = {}

local entity_name = "visible_wielditem:visible_wielditem"

local entities = {}

local function create_entity(player)
	local pos = player:get_pos()
	if not pos then return end -- HACK deal with player object being invalidated before on_leaveplayer has been called
	minetest.add_entity(pos, entity_name):get_luaentity():_set_player(player)
end

minetest.register_on_joinplayer(create_entity)

minetest.register_on_leaveplayer(function(player)
	entities[player:get_player_name()]:_remove()
end)

visible_wielditem.model_attachments = {
	default = {
		bonename = "Arm_Right",
		position = vector.new(0, 0.375, 0),
		rotation = vector.new(180, 90, 0),
		scale = 0.25
	}
}

visible_wielditem.item_tweaks = {
	types = {
		unknown = {},
		node = {
			position = vector.new(0, 0.2, 0),
			rotation = vector.new(0, 0, 180)
		},
		tool = {
			position = vector.new(0, 0, 0.3),
			rotation = vector.new(0, 0, 135)
		},
		craft = {
			position = vector.new(0, 0, 0.3),
			rotation = vector.new(0, 0, 45),
		}
	},
	groups = {},
	names = {}
}

local quaternion_from_euler_rot_deg = modlib.quaternion.from_euler_rotation_deg

local quaternion_to_euler_rot_deg = modlib.quaternion.to_euler_rotation_irrlicht

-- HACK quaternion multiplication should be fixed in modlib eventually
local function quaternion_compose(other, self)
	local X, Y, Z, W = unpack(self)
	return modlib.quaternion.normalize{
		(other[4] * X) + (other[1] * W) + (other[2] * Z) - (other[3] * Y);
		(other[4] * Y) + (other[2] * W) + (other[3] * X) - (other[1] * Z);
		(other[4] * Z) + (other[3] * W) + (other[1] * Y) - (other[2] * X);
		(other[4] * W) - (other[1] * X) - (other[2] * Y) - (other[3] * Z);
	}
end

function visible_wielditem.get_attachment(modelname, itemname)
	local model_attachments = visible_wielditem.model_attachments
	local attachment = modlib.table.copy(model_attachments[modelname] or model_attachments.default)
	local rotation = quaternion_from_euler_rot_deg(attachment.rotation)
	local function apply_tweaks(tweaks)
		tweaks = tweaks or {}
		if tweaks.position then attachment.position = vector.add(attachment.position, tweaks.position) end
		if tweaks.rotation then
			rotation = quaternion_compose(rotation, quaternion_from_euler_rot_deg(tweaks.rotation))
		end
		if tweaks.scale then attachment.scale = attachment.scale * tweaks.scale end
	end
	local def = minetest.registered_items[itemname] or {}
	local item_tweaks = visible_wielditem.item_tweaks
	apply_tweaks(item_tweaks.types[def.type or "unknown"])
	for groupname, rating in pairs(def.groups or {}) do
		if rating ~= 0 then
			apply_tweaks(item_tweaks.groups[groupname])
		end
	end
	apply_tweaks(item_tweaks.names[itemname])
	attachment.rotation = quaternion_to_euler_rot_deg(rotation)
	return attachment
end

minetest.register_entity(entity_name, {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		pointable = false,
		visual = "wielditem" ,
		wield_item = "",
		is_visible = false,
		backface_culling = false,
		use_texture_alpha = true,
		glow = 0,
		static_save = false,
		shaded = true
	},
	on_activate = function(self)
		local object = self.object
		object:set_armor_groups{immortal = 1}
	end,
	_force_resend = function(self) -- HACK
		self.object:set_pos(self.object:get_pos())
	end,
	_update_attachment = function(self)
		if not self._item then return end
		local object = self.object
		local attachment = visible_wielditem.get_attachment(self._player:get_properties().mesh, self._item:get_name() or "")
		-- TODO softcode
		local stack_scale = 1
		if self._item:get_definition().type ~= "tool" then
			stack_scale = 0.75 + 0.5 * math.min(1, self._item:get_count() / self._item:get_stack_max())
		end
		local vsize = attachment.scale * stack_scale
		object:set_properties{visual_size = vector.new(vsize, vsize, vsize)}
		object:set_attach(self._player,
			attachment.bonename,
			vector.multiply(vector.offset(attachment.position, 0, vsize / 2, 0), 10),
			attachment.rotation)
		self:_force_resend()
	end,
	_set_player = function(self, player)
		self._player = player -- HACK this assumes that PlayerRefs don't change
		self:_set_item(player:get_wielded_item())
		self:_update_attachment()
		entities[player:get_player_name()] = self
	end,
	on_deactivate = function(self)
		create_entity(self._player)
	end,
	_set_item = function(self, item)
		self._item = item
		local object = self.object
		if item:is_empty() then
			object:set_properties{
				is_visible = false,
				wield_item = ""
			}
			return
		end
		object:set_properties{
			is_visible = true,
			wield_item = item:to_string(),
			glow = item:get_definition().light_source or 0
		}
		self:_update_attachment()
	end,
	_remove = function(self)
		self.on_deactivate = modlib.func.no_op -- don't recreate entity; it's supposed to be removed
		self.object:remove()
		entities[self._player:get_player_name()] = nil
	end
	-- TODO on_step: reattach regularly to work around engine bugs?
})

modlib.minetest.register_on_wielditem_change(function(player, _, _, item)
	local entity = entities[player:get_player_name()]
	if entity.object:get_pos() then
		entity:_set_item(item)
	else -- recreate entity if necessary
		create_entity(player)
	end
end)
