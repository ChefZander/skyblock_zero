local class = futil.class
local clone_fake_inventory = smartshop.util.clone_fake_inventory

--------------------

local inv_class = smartshop.inv_class
local tmp_inv_class = class(inv_class)
smartshop.tmp_inv_class = tmp_inv_class

--------------------

function tmp_inv_class:_init(inv)
	inv_class._init(self, clone_fake_inventory(inv))
end

function tmp_inv_class:destroy()
	self.inv = nil
end
