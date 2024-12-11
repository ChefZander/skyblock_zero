-- luacheck: globals mesecon

for _, variant in ipairs(smartshop.nodes.shop_node_names) do
	mesecon.register_mvps_stopper(variant)
end

for _, variant in ipairs(smartshop.nodes.storage_node_names) do
	mesecon.register_mvps_stopper(variant)
end
