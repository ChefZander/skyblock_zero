local function tokenize(s)
	local tokens = {}

	local i = 1
	local j = 1

	while true do
		if s:sub(j, j) == "" then
			if i < j then
				table.insert(tokens, s:sub(i, j - 1))
			end
			return tokens
		elseif s:sub(j, j):byte() == 27 then
			if i < j then
				table.insert(tokens, s:sub(i, j - 1))
			end

			i = j
			local n = s:sub(i + 1, i + 1)

			if n == "(" then
				local m = s:sub(i + 2, i + 2)
				local k = s:find(")", i + 3, true)
				if not k then
					futil.log("error", "strip_translation: couldn't tokenize %q", s)
					return {}
				end
				if m == "T" then
					table.insert(tokens, {
						type = "translation",
						domain = s:sub(i + 4, k - 1),
					})
				elseif m == "c" then
					table.insert(tokens, {
						type = "color",
						color = s:sub(i + 4, k - 1),
					})
				elseif m == "b" then
					table.insert(tokens, {
						type = "bgcolor",
						color = s:sub(i + 4, k - 1),
					})
				else
					futil.log("error", "strip_translation: couldn't tokenize %q", s)
					return {}
				end
				i = k + 1
				j = k + 1
			elseif n == "F" then
				table.insert(tokens, {
					type = "start",
				})
				i = j + 2
				j = j + 2
			elseif n == "E" then
				table.insert(tokens, {
					type = "stop",
				})
				i = j + 2
				j = j + 2
			else
				futil.log("error", "strip_translation: couldn't tokenize %q", s)
				return {}
			end
		else
			j = j + 1
		end
	end
end

local function parse(tokens, i, parsed)
	parsed = parsed or {}
	i = i or 1
	while i <= #tokens do
		local token = tokens[i]
		if type(token) == "string" then
			table.insert(parsed, token)
			i = i + 1
		elseif token.type == "color" or token.type == "bgcolor" then
			table.insert(parsed, token)
			i = i + 1
		elseif token.type == "translation" then
			local contents = {
				type = "translation",
				domain = token.domain,
			}
			i = i + 1
			contents, i = parse(tokens, i, contents)
			if i == -1 then
				return "", -1
			end
			table.insert(parsed, contents)
		elseif token.type == "start" then
			local contents = {
				type = "escape",
			}
			i = i + 1
			contents, i = parse(tokens, i, contents)
			if i == -1 then
				return "", -1
			end
			table.insert(parsed, contents)
		elseif token.type == "stop" then
			i = i + 1
			return parsed, i
		else
			futil.log("error", "strip_translation: couldn't parse %s", dump(token):gsub("%s+", ""))
			return "", -1
		end
	end
	return parsed, i
end

local function unparse_and_strip_translation(parsed, parts)
	parts = parts or {}
	for _, part in ipairs(parsed) do
		if type(part) == "string" then
			table.insert(parts, part)
		else
			if part.type == "bgcolor" then
				table.insert(parts, ("\27(b@%s)"):format(part.color))
			elseif part.type == "color" then
				table.insert(parts, ("\27(c@%s)"):format(part.color))
			elseif part.domain then
				unparse_and_strip_translation(part, parts)
			else
				unparse_and_strip_translation(part, parts)
			end
		end
	end

	return parts
end

local function erase_after_newline(parsed, erasing)
	local single_line_parsed = {}

	for _, piece in ipairs(parsed) do
		if type(piece) == "string" then
			if not erasing then
				if piece:find("\n") then
					erasing = true
					local single_line = piece:match("^([^\n]*)\n")
					table.insert(single_line_parsed, single_line)
				else
					table.insert(single_line_parsed, piece)
				end
			end
		elseif piece.type == "bgcolor" or piece.type == "color" then
			table.insert(single_line_parsed, piece)
		elseif piece.type == "escape" then
			table.insert(single_line_parsed, erase_after_newline(piece, erasing))
		elseif piece.type == "translation" then
			local stuff = erase_after_newline(piece, erasing)
			stuff.domain = piece.domain
			table.insert(single_line_parsed, stuff)
		else
			futil.log("error", "strip_translation: couldn't erase_after_newline %s", dump(parsed):gsub("%s+", ""))
			return {}
		end
	end

	return single_line_parsed
end

local function unparse(parsed, parts)
	parts = parts or {}
	for _, part in ipairs(parsed) do
		if type(part) == "string" then
			table.insert(parts, part)
		else
			if part.type == "bgcolor" then
				table.insert(parts, ("\27(b@%s)"):format(part.color))
			elseif part.type == "color" then
				table.insert(parts, ("\27(c@%s)"):format(part.color))
			elseif part.domain then
				table.insert(parts, ("\27(T@%s)"):format(part.domain))
				unparse(part, parts)
				table.insert(parts, "\27E")
			else
				table.insert(parts, "\27F")
				unparse(part, parts)
				table.insert(parts, "\27E")
			end
		end
	end

	return parts
end

function futil.strip_translation(msg)
	local tokens = tokenize(msg)
	local parsed = parse(tokens)
	return table.concat(unparse_and_strip_translation(parsed), "")
end

function futil.get_safe_short_description(item)
	item = type(item) == "userdata" and item or ItemStack(item)
	local description = item:get_description()
	local tokens = tokenize(description)
	local parsed = parse(tokens)
	local single_line_parsed = erase_after_newline(parsed)
	local single_line = table.concat(unparse(single_line_parsed), "")
	return single_line
end
