-- Localize globals
local getmetatable, AreaStore, ItemStack
	= getmetatable, AreaStore, ItemStack

-- Metatable lookup for classes specified in lua_api.txt, section "Class reference"
local AreaStoreMT = getmetatable(AreaStore())
local ItemStackMT = getmetatable(ItemStack"")
local metatables = {
	[AreaStoreMT] = {name = "AreaStore", method = AreaStoreMT.to_string},
	[ItemStackMT] = {name = "ItemStack", method = ItemStackMT.to_table},
	-- TODO expand
}

return modlib.luon.new{
	aux_write = function(_, value)
		local type = metatables[getmetatable(value)]
		if type then
			return type.name, type.method(value)
		end
	end,
	aux_read = {
		AreaStore = function(...)
			local store = AreaStore()
			store:from_string(...)
			return store
		end,
		ItemStack = ItemStack
	}
}