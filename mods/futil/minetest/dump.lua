-- adapted from https://github.com/minetest/minetest/blob/master/builtin/common/misc_helpers.lua
-- but tables are sorted

local function sorter(a, b)
	local ta, tb = type(a), type(b)
	if ta ~= tb then
		return ta < tb
	end
	if ta == "function" or ta == "userdata" or ta == "thread" or ta == "table" then
		return tostring(a) < tostring(b)
	else
		return a < b
	end
end

local keywords = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["goto"] = true, -- Lua 5.2
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

local function is_valid_identifier(str)
	if not str:find("^[a-zA-Z_][a-zA-Z0-9_]*$") or keywords[str] then
		return false
	end
	return true
end

local function basic_dump(o)
	local tp = type(o)
	if tp == "number" then
		return tostring(o)
	elseif tp == "string" then
		return string.format("%q", o)
	elseif tp == "boolean" then
		return tostring(o)
	elseif tp == "nil" then
		return "nil"
		-- Uncomment for full function dumping support.
		-- Not currently enabled because bytecode isn't very human-readable and
		-- dump's output is intended for humans.
		--elseif tp == "function" then
		--      return string.format("loadstring(%q)", string.dump(o))
	elseif tp == "userdata" then
		return tostring(o)
	else
		return string.format("<%s>", tp)
	end
end

function futil.dump(o, indent, nested, level)
	local t = type(o)
	if not level and t == "userdata" then
		-- when userdata (e.g. player) is passed directly, print its metatable:
		return "userdata metatable: " .. futil.dump(getmetatable(o))
	end
	if t ~= "table" then
		return basic_dump(o)
	end

	-- Contains table -> true/nil of currently nested tables
	nested = nested or {}
	if nested[o] then
		return "<circular reference>"
	end
	nested[o] = true
	indent = indent or "\t"
	level = level or 1

	local ret = {}
	local dumped_indexes = {}
	for i, v in ipairs(o) do
		ret[#ret + 1] = futil.dump(v, indent, nested, level + 1)
		dumped_indexes[i] = true
	end
	for k, v in futil.table.pairs_by_key(o, sorter) do
		if not dumped_indexes[k] then
			if type(k) ~= "string" or not is_valid_identifier(k) then
				k = "[" .. futil.dump(k, indent, nested, level + 1) .. "]"
			end
			v = futil.dump(v, indent, nested, level + 1)
			ret[#ret + 1] = k .. " = " .. v
		end
	end
	nested[o] = nil
	if indent ~= "" then
		local indent_str = "\n" .. string.rep(indent, level)
		local end_indent_str = "\n" .. string.rep(indent, level - 1)
		return string.format("{%s%s%s}", indent_str, table.concat(ret, "," .. indent_str), end_indent_str)
	end
	return "{" .. table.concat(ret, ", ") .. "}"
end
