--[[
Template to Easily Make Fancy Voxelized Models
Copyright (C) 2020 Noodlemire

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--]]

--[[
Some important notes about how to use Voxelmodel:

Using the model itself means giving nodes the "mesh" drawtype, and setting their mesh to "voxelmodel.obj"

It should be provided a texture with an aspect ratio of 3:17.

Voxelmodel textures use an even grid of squares within the texture. The default square size is 16px.
See the included voxelmodel_guide.png for more details. It shows which column corresponds to which axis,
which end of each column is positive or negative, and has color-coded borders to show how axis are aligned.

Due to the nature of how it works, disable backface_culling for all nodes and entities that use voxelmodel.
Nodes have it disabled by default, but entities need it specified in their initial_properties table.

Please provide some kind of inventory and wield image. The default wield model will be partially culled.
--]]

--If default is enabled and bookshelf overriding is enabled...
--[[
if default and minetest.settings:get_bool("voxelmodel_override_bookshelf") then
	--Override the default bookshelf to look like the voxelmodel bookshelf
	minetest.override_item("default:bookshelf", {
		drawtype = "mesh",
		mesh = "voxelmodel.obj",
		tiles = {"voxelmodel_bookshelf.png"},
		inventory_image = "voxelmodel_bookshelf_inv.png",
		wield_image = "voxelmodel_bookshelf_inv.png",
	})
else
	--The voxelmodel bookshelf is designed to look like the default bookshelf,
	--but with added depth so you can see the covers of the books and the inside of the shelf.
	minetest.register_node("voxelmodel:bookshelf", {
		description = "Voxelmodel Bookshelf",

		groups = {oddly_breakable_by_hand = 1},

		paramtype = "light",
		paramtype2 = "facedir",

		drawtype = "mesh",
		mesh = "voxelmodel.obj",
		tiles = {"voxelmodel_bookshelf.png"},
		inventory_image = "voxelmodel_bookshelf_inv.png",
		wield_image = "voxelmodel_bookshelf_inv.png",
	})
end
--]]

--The cat is a very basic entity meant to demonstrate some of the possibilities of voxelmodel-based animation,
--As well as an example of how entities can use voxelmodel in general.
--Its behavior is limited to alternating between wandering and standing still in 3 second intervals
--And sometimes blinking.
-- i will leave it in as an easter egg or something idk
minetest.register_entity("voxelmodel:cat", {
	initial_properties = {
		physical = true,
		visual = "mesh",
		mesh = "voxelmodel.obj",
		textures = { "voxelmodel_cat_idle.png" },
		visual_size = { x = 10, y = 10 },
		automatic_face_movement_dir = 90,
		backface_culling = false,
		static_save = false,
	},

	--Every cat is spawned with the following:
	on_activate = function(self)
		--A walk timer that counts up with dtime. When it reaches 3, the cat either starts walking, or stops walking.
		self.walk_timer = 0
		self.walking = false

		--A frame animation timer that counts up with dtime. When it reaches 0.1, the cat switches to the next frame.
		--This is necessary because animating a mesh's texture automatically doesn't seem possible.
		self.frame_timer = 0
		self.frame = 1

		--A blink timer that counts down with dtime. The cooldown between blinks is a random number in the range [4, 7] seconds.
		--When it reaches 0, the cat starts blinking. While blinking, the timer is reset to 0.4 seconds.
		--When it reaches 0 again, the cat opens its eyes again, and the cooldown begins again.
		self.blink_timer = math.random(4, 7)
		self.blinking = false

		--Enable gravity by giving the cat a downwards acceleration of -9.81
		self.object:set_acceleration({ x = 0, y = -9.81, z = 0 })
	end,

	--On each globalstep...
	on_step = function(self, dtime, moveresult)
		--First check the blink timer.
		self.blink_timer = self.blink_timer - dtime

		if self.blink_timer <= 0 then
			--Invert the blinking boolean.
			self.blinking = not self.blinking

			if self.blinking then
				--If it should blink now, do so by setting its texture mod to an overlay.
				self.object:set_texture_mod("^voxelmodel_cat_blink.png")
				self.blink_timer = 0.4
			else
				--Otherwise, clear the texture mod.
				self.object:set_texture_mod("")
				self.blink_timer = math.random(4, 7)
			end
		end

		--If it is currently meant to be walking...
		if self.walking then
			--Check its animation frame timer (as it isn't animated when idle)
			self.frame_timer = self.frame_timer + dtime

			if self.frame_timer >= 0.1 then
				self.frame_timer = self.frame_timer - 0.1

				--Increment the frame, but reset it to 1 if it goes too high
				self.frame = self.frame + 1
				if self.frame > 5 then
					self.frame = 1
				end

				--Replace the base texture repeatedly to make it animate.
				self.object:set_properties({ textures = { "voxelmodel_cat_walk_" .. self.frame .. ".png" } })
			end
		end

		--Check the walk timer...
		self.walk_timer = self.walk_timer + dtime

		if self.walk_timer >= 3 then
			self.walk_timer = self.walk_timer - 3

			--Invert the walking variable.
			self.walking = not self.walking

			if self.walking then
				--If it should start walking now...

				--First, get a random decimal between 0 and 2.
				local vx = math.random() * 2
				--Set the z velocity to be the inverse of the x velocity, so overall velocity is always 2.
				local vz = 2 - vx

				--The velocities of either axis have independent 50% chances to move in the opposite direction.
				--This overall has an evenly random chance to move in any possible horizontal direction.
				if math.random(2) == 1 then vx = -vx end
				if math.random(2) == 1 then vz = -vz end

				--Get the previous velocity in order to preserve vertical velocity.
				local vel = self.object:get_velocity()
				--Then, change the velocity to the newfound values.
				self.object:set_velocity({ x = vx, y = vel.y, z = vz })
			else
				--Otherwise, give it the idle texture and halt its horizontal velocity.
				self.object:set_properties({ textures = { "voxelmodel_cat_idle.png" } })

				local vel = self.object:get_velocity()
				self.object:set_velocity({ x = 0, y = vel.y, z = 0 })
			end
		end
	end,

	--Make the cat instantly die if you dare to hit it, you monster.
	on_punch = function(self)
		self.object:remove()
	end,
})


--This craftitem is used to spawn cats.
minetest.register_craftitem("voxelmodel:cat", {
	description = "Voxelmodel Cat",
	groups = { not_in_creative_inventory = 1 },
	inventory_image = "voxelmodel_cat_inv.png",
	wield_image = "voxelmodel_cat_inv.png",

	on_place = function(itemstack, placer, pointed_thing)
		pointed_thing.above.y = pointed_thing.above.y + 0.1
		minetest.add_entity(pointed_thing.above, "voxelmodel:cat")

		if not minetest.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item()
		end

		return itemstack
	end
})

--A very basic voxelnode with a very easily "readable" texture. If you study this first, it shouldn't be too hard to picture how its texture works.

minetest.register_node("voxelmodel:voxel", {
	description = "Test voxel",

	groups = { oddly_breakable_by_hand = 1, not_in_creative_inventory = 1 },

	paramtype = "light",
	sunlight_propogates = true,
	use_texture_alpha = "clip",
	drawtype = "mesh",
	mesh = "voxelmodel.obj",
	tiles = { "voxelmodel_voxel_example.png" },
})


--An example of an animated node. The flame on the torch's tip will visibly wave around.
--There would be an option to override default torches, but I didn't feel like making wall or ceiling models.
--[[
minetest.register_node("voxelmodel:torch", {
	description = "Voxelmodel Torch",

	groups = { oddly_breakable_by_hand = 1 },

	paramtype = "light",
	sunlight_propogates = true,
	light_source = 12,

	drawtype = "mesh",
	mesh = "voxelmodel.obj",
	tiles = { { name = "voxelmodel_torch.png", animation = { type = "sheet_2d", frames_w = 5, frames_h = 1, frame_length = 0.333 } } },
	inventory_image = "voxelmodel_torch_inv.png",
	wield_image = "voxelmodel_torch_inv.png",

	walkable = false,
})
]]
