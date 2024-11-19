-- Localize globals
local assert, math, modlib, setmetatable, string, table
	= assert, math, modlib, setmetatable, string, table

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

function upper_first(text) return text:sub(1, 1):upper() .. text:sub(2) end

function lower_first(text) return text:sub(1, 1):lower() .. text:sub(2) end

function starts_with(text, prefix) return text:sub(1, #prefix) == prefix end

function ends_with(text, suffix) return text:sub(-#suffix) == suffix end

function contains(str, substr, plain)
	return not not str:find(substr, 1, plain == nil and true or plain)
end

function trim_spacing(text)
	return text:match"^%s*(.-)%s*$"
end

local inputstream_metatable = {
	__index = {
		read = function(self, count)
			local cursor = self.cursor + 1
			self.cursor = self.cursor + count
			local text = self.text:sub(cursor, self.cursor)
			return text ~= "" and text or nil
		end,
		seek = function(self) return self.cursor end
	}
}
--> inputstream "handle"; only allows reading characters (given a count), seeking does not accept any arguments
function inputstream(text)
	return setmetatable({text = text, cursor = 0}, inputstream_metatable)
end

function hexdump(text)
	local dump = {}
	for index = 1, text:len() do
		dump[index] = ("%02X"):format(text:byte(index))
	end
	return table.concat(dump)
end

function spliterator(str, delim, plain)
	assert(delim ~= "")
	local last_delim_end = 0

	-- Iterator of possibly empty substrings between two matches of the delimiter
	-- To exclude empty strings, filter the iterator or use `:gmatch"[...]+"` instead
	return function()
		if not last_delim_end then
			return
		end

		local delim_start, delim_end = str:find(delim, last_delim_end + 1, plain)
		local substr
		if delim_start then
			substr = str:sub(last_delim_end + 1, delim_start - 1)
		else
			substr = str:sub(last_delim_end + 1)
		end
		last_delim_end = delim_end
		return substr
	end
end

function split(text, delimiter, limit, plain)
	limit = limit or math.huge
	local parts = {}
	local occurences = 1
	local last_index = 1
	local index = string.find(text, delimiter, 1, plain)
	while index and occurences < limit do
		table.insert(parts, string.sub(text, last_index, index - 1))
		last_index = index + string.len(delimiter)
		index = string.find(text, delimiter, index + string.len(delimiter), plain)
		occurences = occurences + 1
	end
	table.insert(parts, string.sub(text, last_index))
	return parts
end

function split_without_limit(text, delimiter, plain)
	return split(text, delimiter, nil, plain)
end

split_unlimited = split_without_limit

--! Does not support Macintosh pre-OSX CR-only line endings
--! Deprecated in favor of the `lines` iterator below
function split_lines(text, limit)
	return modlib.text.split(text, "\r?\n", limit, true)
end

-- When reading from a file, directly use `io.lines` instead
-- Lines are possibly empty substrings separated by CR, LF or CRLF
-- A trailing linefeed is ignored
function lines(str)
	local line_start = 1
	-- Line iterator
	return function()
		if line_start > #str then
			return
		end
		local linefeed_start, _, linefeed = str:find("([\r\n][\r\n]?)", line_start)
		local line
		if linefeed_start then
			line = str:sub(line_start, linefeed_start - 1)
			line_start = linefeed_start + (linefeed == "\r\n" and 2 or 1)
		else
			line = str:sub(line_start)
			line_start = #str + 1
		end
		return line
	end
end


local zero = string.byte"0"
local nine = string.byte"9"
local letter_a = string.byte"A"
local letter_f = string.byte"F"

function is_hexadecimal(byte)
	return byte >= zero and byte <= nine or byte >= letter_a and byte <= letter_f
end

magic_charset = "[" .. ("%^$+-*?.[]()"):gsub(".", "%%%1") .. "]"

function escape_pattern(text)
	return text:gsub(magic_charset, "%%%1")
end

escape_magic_chars = escape_pattern

local keywords = modlib.table.set{"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"}
keywords["goto"] = true -- Lua 5.2 (LuaJIT) support

function is_keyword(text)
	return keywords[text]
end

function is_identifier(text)
	return (not keywords[text]) and text:match"^[A-Za-z_][A-Za-z%d_]*$"
end

local function inextchar(text, i)
	if i >= #text then return end
	i = i + 1
	return i, text:sub(i, i)
end

function ichars(text, start)
	-- Iterator over `index, character`
	return inextchar, text, (start or 1) - 1
end

local function inextbyte(text, i)
	if i >= #text then return end
	i = i + 1
	return i, text:byte(i, i)
end

function ibytes(text, start)
	-- Iterator over `index, byte`
	return inextbyte, text, (start or 1) - 1
end

local function _random_bytes(count)
	if count == 0 then return end
	return math.random(0, 0xFF), _random_bytes(count - 1)
end

function random_bytes(
	-- number, how many random bytes the string should have, defaults to 1
	-- limited by stack size
	count
)
	count = count or 1
	return string.char(_random_bytes(count))
end

-- Export environment
return _ENV
