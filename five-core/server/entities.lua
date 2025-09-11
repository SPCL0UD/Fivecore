local ALLOWED_PICKUPS = {} -- si tienes loot legítimo, whitelistea aquí

local counts = {}
local LIMITS = { prop=20, veh=5, ped=5 }

AddEventHandler('entityCreating', function(entity)
  local eType = GetEntityType(entity)
  if eType == 3 then
    local model = GetEntityModel(entity)
    if not ALLOWED_PICKUPS[model] then
      CancelEvent()
    end
  end

  local owner = NetworkGetEntityOwner(entity)
  if owner and owner > 0 then
    local key = (eType==1 and 'ped') or (eType==2 and 'veh') or 'prop'
    counts[owner] = counts[owner] or {ped=0,veh=0,prop=0}
    counts[owner][key] = counts[owner][key] + 1
    if counts[owner][key] > (LIMITS[key] or 10) then
      CancelEvent()
      exports['fivecore']:log('security', owner, 'entity_limit', {type=key, count=counts[owner][key]})
      counts[owner][key] = counts[owner][key] - 1
    end
  end
end)
