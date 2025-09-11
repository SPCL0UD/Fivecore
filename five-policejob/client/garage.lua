RegisterCommand('garagepolicia', function()
  local rango = exports['fivecore']:state(PlayerId()).job
  for _, v in pairs(Config.Vehiculos) do
    if table.contains(v.rangos, rango) then
      local m = GetHashKey(v.modelo)
      RequestModel(m) while not HasModelLoaded(m) do Wait(0) end
      local pos = Config.Base.garage
      local veh = CreateVehicle(m, pos.x, pos.y, pos.z, pos.w, true, false)
      TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
      local netId = NetworkGetNetworkIdFromEntity(veh)
      TriggerServerEvent('police:registrarPatrulla', netId)
      break
    end
  end
end)
