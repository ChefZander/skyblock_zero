futil.check_version({ year = 2024, month = 2, day = 8 }) -- FakeInventory:remove correction

smartshop = fmod.create()

smartshop.dofile("privs")
smartshop.dofile("resources")
smartshop.dofile("util")
smartshop.dofile("api", "init")
smartshop.dofile("nodes", "init")
smartshop.dofile("entities", "init")
smartshop.dofile("compat", "init")

smartshop.dofile("crafting")
