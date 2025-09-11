RegisterNetEvent('police:esposar', function()
  local p = PlayerPedId()
  RequestAnimDict("mp_arresting")
  while not HasAnimDictLoaded("mp_arresting") do Wait(0) end
  TaskPlayAnim(p, "mp_arresting", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
end)

RegisterNetEvent('police:carcel', function(minutos)
  local coords = Config.Base.jail
  SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
  FreezeEntityPosition(PlayerPedId(), true)
  exports['progressbar']:Progress({label='Cumpliendo condena...', duration=minutos*60000})
  FreezeEntityPosition(PlayerPedId(), false)
end)
