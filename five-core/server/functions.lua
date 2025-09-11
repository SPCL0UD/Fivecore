function HasItem(playerId, itemName)
  local p = exports['fivecore']:state(playerId)
  if not p or not p.inventory then return false end
  for _, item in ipairs(p.inventory) do
    if item.name == itemName and item.count > 0 then
      return true
    end
  end
  return false
end

exports('HasItem', HasItem)
local groups = {}
local NEXT_GROUP_ID = 1