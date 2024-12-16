-- this will allow us to more easily extend behavior e.g. interacting directly w/ inventory bags

local class = futil.class1

--------------------

local inv_class = smartshop.inv_class
local player_inv_class = class(inv_class)
smartshop.player_inv_class = player_inv_class

--------------------

function player_inv_class:_init(player)
	self.player = player
	self.name = player:get_player_name()
	inv_class._init(self, player:get_inventory())
end

function smartshop.api.get_player_inv(player, strict_meta)
	return player_inv_class(player, strict_meta)
end
