
-- callback for after-jump actions

local after_jump_callbacks = {}

function jumpdrive.register_after_jump(callback)
  table.insert(after_jump_callbacks, callback)
end

function jumpdrive.fire_after_jump(from_area, to_area)
  for _, callback in ipairs(after_jump_callbacks) do
    callback(from_area, to_area)
  end
end
