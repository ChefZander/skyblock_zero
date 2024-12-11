fmod.check_version({ year = 2023, month = 7, day = 14 }) -- async dofile

futil = fmod.create()

futil.dofile("util", "init")
futil.dofile("data_structures", "init") -- depends on util
futil.dofile("minetest", "init") -- depends on util and data_structures

if INIT == "game" then
	futil.async_dofile("init")
end
