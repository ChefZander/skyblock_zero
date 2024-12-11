local f = string.format

local SparseGraph = futil.class1()

function SparseGraph:_init(size)
	self._size = size or 0
	self._adj_by_vertex = futil.DefaultTable(function()
		return futil.Set()
	end)
end

function SparseGraph:size()
	return self._size
end

function SparseGraph:add_vertex()
	self._size = self._size + 1
end

function SparseGraph:add_edge(a, b)
	assert(1 <= a and a <= self._size, f("invalid vertex a %s", a))
	assert(1 <= b and b <= self._size, f("invalid vertex b %s", b))
	self._adj_by_vertex[a]:add(b)
end

function SparseGraph:has_edge(a, b)
	assert(1 <= a and a <= self._size, f("invalid vertex a %s", a))
	assert(1 <= b and b <= self._size, f("invalid vertex b %s", b))
	return self._adj_by_vertex[a]:contains(b)
end

futil.SparseGraph = SparseGraph
