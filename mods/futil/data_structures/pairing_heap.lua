-- https://en.wikipedia.org/wiki/Pairing_heap
-- https://www.cs.cmu.edu/~sleator/papers/pairing-heaps.pdf
-- https://www.cise.ufl.edu/~sahni/dsaaj/enrich/c13/pairing.htm

local inf = math.huge

local function add_child(node1, node2)
	node2.parent = node1
	node2.sibling = node1.child
	node1.child = node2
end

local function meld(node1, node2)
	if node1 == nil or node1.value == nil then
		return node2
	elseif node2 == nil or node2.value == nil then
		return node1
	elseif node1.priority > node2.priority then
		add_child(node1, node2)
		return node1
	else
		add_child(node2, node1)
		return node2
	end
end

local function merge_pairs(node)
	if node.value == nil or not node.sibling then
		return
	end

	local sibling = node.sibling
	local siblingsibling = sibling.sibling

	node.sibling = nil
	sibling.sibling = nil

	node = meld(node, sibling)

	if siblingsibling then
		return meld(node, merge_pairs(siblingsibling))
	else
		return node
	end
end

local function cut(node)
	local parent = node.parent

	if parent.child == node then
		parent.child = node.sibling
	else
		parent = parent.child
		local sibling = parent.sibling
		while sibling ~= node do
			parent = sibling
			sibling = parent.sibling
		end
		parent.sibling = node.sibling
	end

	node.parent = nil
	node.sibling = nil
end

local function need_to_move(node, new_priority)
	local cur_priority = node.priority
	if cur_priority < new_priority then
		-- priority increase, make sure we don't dominate our parent
		local parent = node.parent
		return (parent and new_priority > parent.priority)
	elseif cur_priority > new_priority then
		-- priority decrease, make sure our children don't dominate us
		local child = node.child
		while child and child ~= node do
			if child.priority > new_priority then
				return true
			end
			child = child.sibling
		end
		return false
	else
		return false
	end
end

local PairingHeap = futil.class1()

function PairingHeap:_new()
	self._nodes_by_value = {}
	self._size = 0
end

function PairingHeap:size()
	return self._size
end

function PairingHeap:peek()
	local hn = self._max_node

	if not hn then
		error("empty")
	end

	return hn.value, hn.priority
end

function PairingHeap:remove(value)
	self:set_priority(value, inf)
	return self:pop()
end

function PairingHeap:pop()
	local max = self._max_node

	if not max then
		error("empty")
	end

	local child = max.child
	if child then
		self._max_node = merge_pairs(child)
	end

	local value = max._value

	self._nodes_by_value[value] = nil
	self._size = self._size - 1

	return value
end

function PairingHeap:get_priority(value)
	return self._nodes_by_value[value].priority
end

function PairingHeap:set_priority(value, priority)
	local cur_node = self._nodes_by_value[value]
	if cur_node then
		local need_to = need_to_move(cur_node, priority)

		if need_to then
			cut(cur_node)
			self._max_node = meld(cur_node, self._max_node)
		else
			cur_node.priority = priority
		end
	else
		local node = { value = value, priority = priority }
		self._nodes_by_value[value] = node
		self._max_node = meld(self._max_node, node)
		self._size = self._size + 1
	end
end

futil.PairingHeap = PairingHeap
