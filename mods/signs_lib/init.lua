-- This mod provides the visible text on signs library used by Home Decor
-- and perhaps other mods at some point in the future.  Forked from thexyz's/
-- PilzAdam's original text-on-signs mod and rewritten by Vanessa Ezekowitz
-- and Diego Martinez

signs_lib = {}

signs_lib.path = minetest.get_modpath(minetest.get_current_modname())

signs_lib.S = minetest.get_translator(minetest.get_current_modname())

signs_lib.edit_priv = minetest.settings:get("signs_lib.edit_priv") or "signslib_edit"

dofile(signs_lib.path.."/encoding.lua")
dofile(signs_lib.path.."/api.lua")
dofile(signs_lib.path.."/standard_signs.lua")
dofile(signs_lib.path.."/compat.lua")
