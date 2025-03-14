jumpdrive.register_after_jump(function(from_area, to_area)
  local delta_vector = vector.subtract(to_area.pos1, from_area.pos1)
  local pos1 = from_area.pos1
  local pos2 = from_area.pos2

  local list = areas:getAreasIntersectingArea(pos1, pos2)
  local dirty = false

  local queue_move = {}
  for id, area in pairs(list) do
    local xMatch = area.pos1.x >= pos1.x and area.pos2.x <= pos2.x
    local yMatch = area.pos1.y >= pos1.y and area.pos2.y <= pos2.y
    local zMatch = area.pos1.z >= pos1.z and area.pos2.z <= pos2.z

    if not jumpdrive.is_area_protected(vector.add(area.pos1, delta_vector), vector.add(area.pos2, delta_vector), area.owner) then
      minetest.log("action", "[jumpdrive] moving area " .. id)

      queue_move[#queue_move + 1] = {
        id,
        area,
        vector.add(area.pos1, delta_vector),
        vector.add(area.pos2, delta_vector)
      }
    end
  end
  for _, v in pairs(queue_move) do
    dirty = true
    areas:move(unpack(v))
  end

  if dirty then
    areas:save()
  end
end)
