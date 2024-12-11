function futil.class1(super)
	local class = {}
	class.__index = class -- this becomes the index "metamethod" of objects

	setmetatable(class, {
		__index = super and super.__index or super,
		__call = function(this_class, ...)
			local obj = setmetatable({}, this_class)
			local init = obj._init
			if init then
				init(obj, ...)
			end
			return obj
		end,
	})

	function class:is_a(class2)
		if class == class2 then
			return true
		end

		if super and super:is_a(class2) then
			return true
		end

		return false
	end

	return class
end

function futil.class(...)
	local class = {}
	class.__index = class

	local meta = {
		__call = function(this_class, ...)
			local obj = setmetatable({}, this_class)
			local init = obj._init
			if init then
				init(obj, ...)
			end
			return obj
		end,
	}

	local parents = { ... }
	class._parents = parents

	if #parents > 0 then
		function meta:__index(key)
			for i = #parents, 1, -1 do
				local parent = parents[i]
				local index = parent.__index
				local v
				if index then
					if type(index) == "function" then
						v = index(self, key)
					else
						v = index[key]
					end
				else
					v = parent[key]
				end
				if v then
					return v
				end
			end
		end
	end

	setmetatable(class, meta)

	function class:is_a(class2)
		if class == class2 then
			return true
		end

		for _, parent in ipairs(parents) do
			if parent:is_a(class2) then
				return true
			end
		end

		return false
	end

	return class
end
