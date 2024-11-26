local modlib, setmetatable, pairs, assert, error, table_insert, table_concat, tonumber, tostring, math_huge, string, type, next
	= modlib, setmetatable, pairs, assert, error, table.insert, table.concat, tonumber, tostring, math.huge, string, type, next

local _ENV = {}
setfenv(1, _ENV)

-- See https://tools.ietf.org/id/draft-ietf-json-rfc4627bis-09.html#unichars and https://json.org

-- Null
-- TODO consider using userdata (for ex. by using newproxy)
do
	local metatable = {}
	-- eq is not among the metamethods, len won't work on 5.1
	for _, metamethod in pairs{"add", "sub", "mul", "div", "mod", "pow", "unm", "concat", "len", "lt", "le", "index", "newindex", "call"} do
		metatable["__" .. metamethod] = function() return error("attempt to " .. metamethod .. " a null value") end
	end
	null = setmetatable({}, metatable)
end

local metatable = {__index = _ENV}
_ENV.metatable = metatable
function new(self)
	return setmetatable(self, metatable)
end

local whitespace = modlib.table.set{"\t", "\r", "\n", " "}
local decoding_escapes = {
	['"'] = '"',
	["\\"] = "\\",
	["/"] = "/",
	b = "\b",
	f = "\f",
	n = "\n",
	r = "\r",
	t = "\t"
	-- TODO is this complete?
}

-- Set up a DFA for number syntax validations
local number_dfa
do -- as a RegEx: (0|(1-9)(0-9)*)[.(0-9)+[(e|E)[+|-](0-9)+]]; does not need to handle the first sign
	-- TODO proper DFA utilities
	local function set_transitions(state, transitions)
		for chars, next_state in pairs(transitions) do
			for char in chars:gmatch"." do
				state[char] = next_state
			end
		end
	end
	local onenine = "123456789"
	local digit = "0" .. onenine
	local e = "eE"
	local exponent = {final = true}
	set_transitions(exponent, {
		[digit] = exponent
	})
	local pre_exponent = {expected = "exponent"}
	set_transitions(pre_exponent, {
		[digit] = exponent
	})
	local exponent_sign = {expected = "exponent"}
	set_transitions(exponent_sign, {
		[digit] = exponent,
		["+"] = exponent,
		["-"] = exponent
	})
	local fraction_final = {final = true}
	set_transitions(fraction_final, {
		[digit] = fraction_final,
		[e] = exponent_sign
	})
	local fraction = {expected = "fraction"}
	set_transitions(fraction, {
		[digit] = fraction_final
	})
	local integer = {final = true}
	set_transitions(integer, {
		[digit] = integer,
		[e] = exponent_sign,
		["."] = fraction
	})
	local zero = {final = true}
	set_transitions(zero, {
		["."] = fraction
	})
	number_dfa = {}
	set_transitions(number_dfa, {
		[onenine] = integer,
		["0"] = zero
	})
end

local hex_digit_values = {}
for i = 0, 9 do
	hex_digit_values[tostring(i)] = i
end
for i = 0, 5 do
	hex_digit_values[string.char(("a"):byte() + i)] = 10 + i
	hex_digit_values[string.char(("A"):byte() + i)] = 10 + i
end

-- TODO SAX vs DOM
local utf8_char = modlib.utf8.char
function read(self, read_)
	local index = 0
	local char
	-- TODO support read functions which provide additional debug output (such as row:column)
	local function read()
		index = index + 1
		char = read_()
		return char
	end
	local function syntax_error(errmsg)
		-- TODO ensure the index isn't off
		error("syntax error: " .. index .. ": " .. errmsg)
	end
	local function syntax_assert(value, errmsg)
		if not value then
			syntax_error(errmsg or "assertion failed!")
		end
		return value
	end
	local function skip_whitespace()
		while whitespace[char] do
			read()
		end
	end
	-- Forward declaration
	local value
	local function number()
		local state = number_dfa
		local num = {}
		while true do
			-- Will work for nil too
			local next_state = state[char]
			if not next_state then
				if not state.final then
					if state == number_dfa then
						syntax_error"expected a number"
					end
					syntax_error("invalid number: expected " .. state.expected)
				end
				return assert(tonumber(table_concat(num)))
			end
			table_insert(num, char)
			state = next_state
			read()
		end
	end
	local function utf8_codepoint(codepoint)
		return syntax_assert(utf8_char(codepoint), "invalid codepoint")
	end
	local function string()
		local chars = {}
		local high_surrogate
		while true do
			local string_char, next_high_surrogate
			if char == '"' then
				if high_surrogate then
					table_insert(chars, utf8_codepoint(high_surrogate))
				end
				return table_concat(chars)
			end
			if char == "\\" then
				read()
				if char == "u" then
					local codepoint = 0
					for i = 3, 0, -1 do
						codepoint = syntax_assert(hex_digit_values[read()], "expected a hex digit") * (16 ^ i) + codepoint
					end
					if high_surrogate and codepoint >= 0xDC00 and codepoint <= 0xDFFF then
						-- TODO strict mode: throw an error for single surrogates
						codepoint = 0x10000 + (high_surrogate - 0xD800) * 0x400 + codepoint - 0xDC00
						-- Don't write the high surrogate
						high_surrogate = nil
					end
					if codepoint >= 0xD800 and codepoint <= 0xDBFF then
						next_high_surrogate = codepoint
					else
						string_char = utf8_codepoint(codepoint)
					end
				else
					string_char = syntax_assert(decoding_escapes[char], "invalid escape sequence")
				end
			else
				-- TODO check whether the character is one that must be escaped ("strict" mode)
				string_char = syntax_assert(char, "unclosed string")
			end
			if high_surrogate then
				table_insert(chars, utf8_codepoint(high_surrogate))
			end
			high_surrogate = next_high_surrogate
			if string_char then
				table_insert(chars, string_char)
			end
			read()
		end
	end
	local element
	local funcs = {
		['-'] = function()
			return -number()
		end,
		['"'] = string,
		["{"] = function()
			local dict = {}
			skip_whitespace()
			if char == "}" then return dict end
			while true do
				syntax_assert(char == '"', "key expected")
				read()
				local key = string()
				read()
				skip_whitespace()
				syntax_assert(char == ":", "colon expected, got " .. char)
				local val = element()
				dict[key] = val
				if char == "}" then return dict end
				syntax_assert(char == ",", "comma expected")
				read()
				skip_whitespace()
			end
		end,
		["["] = function()
			local list = {}
			skip_whitespace()
			if char == "]" then return list end
			while true do
				table_insert(list, value())
				skip_whitespace()
				if char == "]" then return list end
				syntax_assert(char == ",", "comma expected")
				read()
				skip_whitespace()
			end
		end,
	}
	local function expect_word(word, value)
		local msg = word .. " expected"
		funcs[word:sub(1, 1)] = function()
			syntax_assert(char == word:sub(2, 2), msg)
			for i = 3, #word do
				read()
				syntax_assert(char == word:sub(i, i), msg)
			end
			return value
		end
	end
	expect_word("true", true)
	expect_word("false", false)
	expect_word("null", self.null)
	function value()
		syntax_assert(char, "value expected")
		local func = funcs[char]
		if func then
			-- Advance after first char
			read()
			local val = func()
			-- Advance after last char
			read()
			return val
		end
		if char >= "0" and char <= "9" then
			return number()
		end
		syntax_error"value expected"
	end
	function element()
		read()
		skip_whitespace()
		local val = value()
		skip_whitespace()
		return val
	end
	-- TODO consider asserting EOF as read() == nil, perhaps controlled by a parameter
	return element()
end

local encoding_escapes = modlib.table.flip(decoding_escapes)
-- Solidus does not need to be escaped
encoding_escapes["/"] = nil
-- Control characters. Note: U+0080 to U+009F and U+007F are not considered control characters.
for byte = 0, 0x1F do
	encoding_escapes[string.char(byte)] = string.format("u%04X", byte)
end
modlib.table.map(encoding_escapes, function(str) return "\\" .. str end)
local function escape(str)
	return str:gsub(".", encoding_escapes)
end
function write(self, value, write)
	local null = self.null
	local written_strings = self.cache_escaped_strings and setmetatable({}, {__index = function(self, str)
		local escaped_str = escape(str)
		self[str] = escaped_str
		return escaped_str
	end})
	local function string(str)
		write'"'
		write(written_strings and written_strings[str] or escape(str))
		return write'"'
	end
	local dump
	local function write_kv(key, value)
		assert(type(key) == "string", "not a dictionary")
		string(key)
		write":"
		dump(value)
	end
	function dump(value)
		if value == null then
			-- TODO improve null check (checking for equality doesn't allow using nan as null, for instance)
			return write"null"
		end
		if value == true then
			return write"true"
		end
		if value == false then
			return write"false"
		end
		local type_ = type(value)
		if type_ == "number" then
			assert(value == value, "unsupported number value: nan")
			assert(value ~= math_huge, "unsupported number value: inf")
			assert(value ~= -math_huge, "unsupported number value: -inf")
			return write(("%.17g"):format(value))
		end
		if type_ == "string" then
			return string(value)
		end
		if type_ == "table" then
			local table = value
			local len = #table
			if len == 0 then
				local first, value = next(table)
				write"{"
				if first ~= nil then
					write_kv(first, value)
				end
				for key, value in next, table, first do
					write","
					write_kv(key, value)
				end
				write"}"
			else
				assert(modlib.table.count(table) == len, "mixed list & hash part")
				write"["
				for i = 1, len - 1 do
					dump(table[i])
					write","
				end
				dump(table[len])
				write"]"
			end
			return
		end
		error("unsupported type: " .. type_)
	end
	dump(value)
end

-- TODO get rid of this paste of write_file and write_string (see modlib.luon)

function write_file(self, value, file)
	return self:write(value, function(text)
		file:write(text)
	end)
end

function write_string(self, value)
	local rope = {}
	self:write(value, function(text)
		table_insert(rope, text)
	end)
	return table_concat(rope)
end

-- TODO read_path (for other serializers too)

function read_file(self, file)
	local value = self:read(function()
		return file:read(1)
	end)
	-- TODO consider file:close()
	return value
end

function read_string(self, string)
	-- TODO move the string -> one char read func pattern to modlib.text
	local index = 0
	local value = self:read(function()
		index = index + 1
		if index > #string then
			return
		end
		return string:sub(index, index)
	end)
	-- We just expect EOF for strings
	assert(index > #string, "EOF expected")
	return value
end

return _ENV