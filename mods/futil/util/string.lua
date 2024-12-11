futil.string = {}

function futil.string.truncate(s, max_length, suffix)
	suffix = suffix or "..."

	if s:len() > max_length then
		return s:sub(1, max_length - suffix:len()) .. suffix
	else
		return s
	end
end

function futil.string.lc_cmp(a, b)
	return a:lower() < b:lower()
end

function futil.string.startswith(s, start, start_i, end_i)
	return s:sub(start_i or 0, end_i or #s):sub(1, #start) == start
end

local escape_pattern = "([%(%)%.%%%+%-%*%?%[%^%$])"
local function escape_regex(str)
	return str:gsub(escape_pattern, "%%%1")
end

local glob_patterns = {
	["?"] = ".",
	["*"] = ".*",
}

local function transform_pattern(pattern)
	local parts = {}
	local start = 1
	for i = 1, #pattern do
		local glob_pattern = glob_patterns[pattern:sub(i)]
		if glob_pattern then
			if start < i then
				parts[#parts + 1] = escape_regex(pattern:sub(start, i - 1))
			end
			parts[#parts + 1] = glob_pattern
			start = i + 1
		end
	end
	if start < #pattern then
		parts[#parts + 1] = escape_regex(pattern:sub(start, #pattern))
	end
	return table.concat(parts, "")
end

function futil.string.globmatch(str, pattern)
	return str:match(transform_pattern(pattern))
end

futil.GlobMatcher = futil.class1()

function futil.GlobMatcher:_init(pattern)
	self._pattern = transform_pattern(pattern)
end

function futil.GlobMatcher:match(str)
	return str:match(self._pattern)
end
