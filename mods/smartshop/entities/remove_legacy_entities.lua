minetest.register_entity("smartshop:item", {
	on_activate = function(self)
		self.object:remove()
	end,
})
