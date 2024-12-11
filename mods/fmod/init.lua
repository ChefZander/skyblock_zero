local f = string.format

local get_current_modname = minetest.get_current_modname
local get_modpath = minetest.get_modpath

local our_modname = get_current_modname()
local our_modpath = get_modpath(our_modname)

local build_has = dofile(our_modpath .. DIR_DELIM .. "build_has.lua")
local get_settings = dofile(our_modpath .. DIR_DELIM .. "get_settings.lua")
local parse_version = dofile(our_modpath .. DIR_DELIM .. "parse_version.lua")

local function create(fork, extra_private_state)
	local modname = get_current_modname()
	local modpath = get_modpath(modname)
	local S = minetest.get_translator(modname)
	local F = minetest.formspec_escape

	local mod_conf = Settings(modpath .. DIR_DELIM .. "mod.conf")
	assert(modname == mod_conf:get("name"), "mod name mismatch")

	local version = parse_version(mod_conf:get("version"))

	local private_state = {
		-- minetest.request_insecure_environment() can't be used here
		-- minetest.request_http_api() can't be used here
		mod_storage = INIT == "game" and minetest.get_mod_storage(),
	}

	if extra_private_state then
		for k, v in pairs(extra_private_state) do
			private_state[k] = v
		end
	end

	return {
		modname = modname,
		modpath = modpath,

		title = mod_conf:get("title") or modname,
		description = mod_conf:get("description"),
		author = mod_conf:get("author"),
		license = mod_conf:get("license"),
		media_license = mod_conf:get("media_license"),
		website = mod_conf:get("website") or mod_conf:get("url"),
		version = version,
		fork = fork or "flux",

		S = S,
		FS = function(...)
			return F(S(...))
		end,

		has = build_has(mod_conf),
		settings = get_settings(modname),

		check_version = function(required, reason)
			if type(required) == "table" then
				required = os.time(required)
			end
			local calling_modname = minetest.get_current_modname() or "UNKNOWN"
			if reason then
				assert(
					version >= required,
					f(
						"%s requires a newer version of %s because %q; please update it.\n"
							.. "go to the main game menu, click the content tab, browse online content, and update all.\n"
							.. "(have %s, require %s)",
						calling_modname,
						modname,
						reason,
						version,
						required
					)
				)
			else
				assert(
					version >= required,
					f(
						"%s requires a newer version of %s; please update it.\n"
							.. "go to the main game menu, click the content tab, browse online content, and update all.\n"
							.. "(have %s, require %s)",
						calling_modname,
						modname,
						version,
						required
					)
				)
			end
		end,

		check_minetest_version = function(major, minor, patch, other, reason)
			local mt_version = minetest.get_version()
			-- TODO: figure out how to allow various "projects" (e.g. Minetest, Multicraft) properly
			-- TODO: we perhaps want to allow depending on multiple projects, so this is complicated.
			local mt_major, mt_minor, mt_patch = mt_version.string:match("^(%d+)%.(%d+)%.(%d+)")
			if not (mt_major and mt_minor and mt_patch) then
				error(
					f(
						"%s is not compatible w/ minetest %s because we don't understand the version",
						modname,
						mt_version.string
					)
				)
			end
			mt_major = tonumber(mt_major)
			mt_minor = tonumber(mt_minor)
			mt_patch = tonumber(mt_patch)
			local check = true
			if mt_major < major then
				check = false
			elseif mt_major == major then
				if mt_minor < minor then
					check = false
				elseif mt_minor == minor then
					if mt_patch < patch then
						check = false
					end
				end
			end
			if not check then
				if reason then
					error(
						f("%s requires at least minetest %i.%i.%i because it %q", modname, major, minor, patch, reason)
					)
				else
					error(f("%s requires at least minetest %i.%i.%i", modname, major, minor, patch))
				end
			end
		end,

		log = function(level, messagefmt, ...)
			return minetest.log(level, f("[%s] %s", modname, f(messagefmt, ...)))
		end,

		chat_send_player = INIT == "game" and function(player, messagefmt, ...)
			if player.get_player_name then
				player = player:get_player_name()
			end

			minetest.chat_send_player(player, f("[%s] %s", modname, S(messagefmt, ...)))
		end,

		chat_send_all = INIT == "game" and function(message, ...)
			minetest.chat_send_all(f("[%s] %s", modname, S(message, ...)))
		end,

		dofile = function(...)
			assert(modname == get_current_modname(), "attempt to call dofile from external mod")
			local filename = table.concat({ modpath, ... }, DIR_DELIM) .. ".lua"
			local loader = assert(loadfile(filename))
			return loader(private_state)
		end,

		async_dofile = function(...)
			assert(modname == get_current_modname(), "attempt to call async_dofile from external mod")
			local filename = table.concat({ modpath, ... }, DIR_DELIM) .. ".lua"
			return minetest.register_async_dofile(filename)
		end,
	},
		private_state
end

fmod = create()
fmod.create = create

if INIT == "game" then
	fmod.async_dofile("init")
end
