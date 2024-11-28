-- Localize globals
local math, next, pairs, setmetatable, string, table, unpack = math, next, pairs, setmetatable, string, table, unpack

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

local metatable = {__index = _ENV}

-- Setting the metatable is fine as it does not contain single-character keys.
-- TODO (?) encapsulate in "root" field for better code quality?
function new(table) return setmetatable(table or {}, metatable) end

function insert(self, word, value, overwrite)
	for i = 1, word:len() do
		local char = word:sub(i, i)
		self[char] = self[char] or {}
		self = self[char]
	end
	local previous_value = self.value
	if not previous_value or overwrite then self.value = value or true end
	return previous_value
end

function remove(self, word)
	local branch, character = self, word:sub(1, 1)
	for i = 1, word:len() - 1 do
		local char = word:sub(i, i)
		if not self[char] then return end
		if self[char].value or next(self, next(self)) then
			branch = self
			character = char
		end
		self = self[char]
	end
	local char = word:sub(word:len())
	if not self[char] then return end
	self = self[char]
	local previous_value = self.value
	self.value = nil
	if branch and not next(self) then branch[character] = nil end
	return previous_value
end

--> value if found
--> nil else
function get(self, word)
	for i = 1, word:len() do
		local char = word:sub(i, i)
		self = self[char]
		if not self then return end
	end
	return self.value
end

function suggestion(self, remainder)
	local until_now = {}
	local subtries = { [self] = until_now }
	local suggestion, value
	while next(subtries) do
		local new_subtries = {}
		local leaves = {}
		for trie, word in pairs(subtries) do
			if trie.value then table.insert(leaves, { word = word, value = trie.value }) end
		end
		if #leaves > 0 then
			if remainder then
				local best_leaves = {}
				local best_score = 0
				for _, leaf in pairs(leaves) do
					local score = 0
					for i = 1, math.min(#leaf.word, string.len(remainder)) do
						-- calculate intersection
						if remainder:sub(i, i) == leaf.word[i] then score = score + 1 end
					end
					if score == best_score then table.insert(best_leaves, leaf)
					elseif score > best_score then best_leaves = { leaf } end
				end
				leaves = best_leaves
			end
			-- TODO select best instead of random
			local leaf = leaves[math.random(1, #leaves)]
			suggestion, value = table.concat(leaf.word), leaf.value
			break
		end
		for trie, word in pairs(subtries) do
			for char, subtrie in pairs(trie) do
				local word = { unpack(word) }
				table.insert(word, char)
				new_subtries[subtrie] = word
			end
		end
		subtries = new_subtries
	end
	return suggestion, value
end

--> value if found
--> nil, suggestion, value of suggestion else
function search(self, word)
	for i = 1, word:len() do
		local char = word:sub(i, i)
		if not self[char] then
			local until_now = word:sub(1, i - 1)
			local suggestion, value = suggestion(self, word:sub(i))
			return nil, until_now .. suggestion, value
		end
		self = self[char]
	end
	local value = self.value
	if value then return value end
	local until_now = word
	local suggestion, value = suggestion(self)
	return nil, until_now .. suggestion, value
end

function find_longest(self, query, query_offset)
	local leaf_pos = query_offset
	local last_leaf
	for i = query_offset, query:len() do
		local char = query:sub(i, i)
		self = self[char]
		if not self then break
		elseif self.value then
			last_leaf = self.value
			leaf_pos = i
		end
	end
	return last_leaf, leaf_pos
end

-- Export environment
return _ENV