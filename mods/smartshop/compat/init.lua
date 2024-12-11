smartshop.compat = {}

if smartshop.has.currency and smartshop.settings.change_currency then
	smartshop.dofile("compat", "currency")
end

if smartshop.has.mesecons then
	smartshop.dofile("compat", "mesecons")
end

if smartshop.has.mesecons_mvps then
	smartshop.dofile("compat", "mesecons_mvps")
end

smartshop.dofile("compat", "pipeworks")
