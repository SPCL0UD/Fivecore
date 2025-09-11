RegisterNetEvent('police:enviarCarcel', function(target, minutos)
  TriggerClientEvent('police:carcel', target, minutos)
end)
-- Enviar a la cárcel
RegisterNetEvent('police:carcel', function(minutos) 
  local ped = PlayerPedId()
  local jailPos = vector3(1678.32, 2512.16, 45.56) -- Posición de la cárcel
  SetEntityCoords(ped, jailPos.x, jailPos.y, jailPos.z)
  FreezeEntityPosition(ped, true)
  exports['progressbar']:Progress({label='Cumpliendo condena', duration=minutos*60000})
  FreezeEntityPosition(ped, false)
end)