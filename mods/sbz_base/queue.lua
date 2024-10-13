-- from https://github.com/minetest-mods/digilines/blob/7d4895d5d4a093041e3e6c8a8676f3b99bb477b7/internal.lua#L67
-- a generic queue

---@class Queue
---@field nextRead number
---@field nextWrite number
Queue = {}

---@return Queue
function Queue.new()
    return setmetatable({ nextRead = 1, nextWrite = 1 }, { __index = Queue })
end

---@return boolean
function Queue:is_empty()
    return self.nextRead == self.nextWrite
end

---Adds an object to the queue
---@param object any
function Queue:enqueue(object)
    local nextWrite = self.nextWrite
    self[nextWrite] = object
    self.nextWrite = nextWrite + 1
end

--- Pops an object from the queue
---@return any
function Queue:dequeue()
    local nextRead = self.nextRead
    local object = self[nextRead]
    self[nextRead] = nil
    self.nextRead = nextRead + 1
    return object
end
