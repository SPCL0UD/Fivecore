local uiOpen = false
local routeBlip = nil
local assignedTruck = nil
local truckNetId = nil
local routeWarnings = 0
local warnCooldown = 0
local currentTarget = nil   -- vector3 del objetivo actual (carga o destino)
local isLoadPhase = true

-- Mostrar hubs
RegisterCommand('trucker', function()
  TriggerServerEvent('trucker:requestHubs')
end)

RegisterNetEvent('trucker:showHubs', function(hubs, xp)
  SetNuiFocus(true, true); uiOpen = true
  SendNUIMessage({ action = 'showHubs', hubs = hubs, xp = xp })
end)

-- Iniciar trabajo: UI activa
RegisterNetEvent('trucker:startClientJob', function(cargo, jobType)
  SetNuiFocus(true, true); uiOpen = true
  SendNUIMessage({ action = 'showTruckerUI', cargo = cargo, jobType = jobType })
  routeWarnings = 0
  isLoadPhase = true
end)

-- Rutas amarillas
local function setRouteToCoord(coords, isLoadPoint)
  currentTarget = vector3(coords.x+0.0, coords.y+0.0, coords.z+0.0)
  if DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
  routeBlip = AddBlipForCoord(currentTarget.x, currentTarget.y, currentTarget.z)
  SetBlipSprite(routeBlip, isLoadPoint and 478 or 568)
  SetBlipScale(routeBlip, 0.9)
  SetBlipColour(routeBlip, 5)            -- Amarillo
  SetBlipRoute(routeBlip, true)
  SetBlipRouteColour(routeBlip, 5)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(isLoadPoint and "Punto de Carga" or "Destino de Entrega")
  EndTextCommandSetBlipName(routeBlip)
  isLoadPhase = isLoadPoint
end

function clearRoute()
  currentTarget = nil
  if DoesBlipExist(routeBlip) then
    SetBlipRoute(routeBlip, false)
    RemoveBlip(routeBlip)
    routeBlip = nil
  end
end

RegisterNetEvent('trucker:setRoute', function(coords, isLoadPoint)
  setRouteToCoord(coords, isLoadPoint)
end)

RegisterNetEvent('trucker:clearRoute', function()
  clearRoute()
end)

-- Spawn del camión en el líder
RegisterNetEvent('trucker:spawnTruckClient', function(model, coords)
  local mhash = GetHashKey(model)
  RequestModel(mhash); while not HasModelLoaded(mhash) do Wait(0) end

  local veh = CreateVehicle(mhash, coords.x, coords.y, coords.z, 0.0, true, false)
  SetVehicleOnGroundProperly(veh)
  local plate = ("TRK%s"):format(math.random(100,999))
  SetVehicleNumberPlateText(veh, plate)
  SetVehicleEngineOn(veh, true, true, false)
  SetEntityAsMissionEntity(veh, true, true)
  local nid = NetworkGetNetworkIdFromEntity(veh)
  SetNetworkIdExistsOnAllMachines(nid, true)
  SetNetworkIdCanMigrate(nid, true)

  assignedTruck = veh
  truckNetId = nid
  TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

  -- Avisar al server el NetId y plate
  TriggerServerEvent('trucker:truckSpawned', nid, plate)
end)

-- Permitir que todos los miembros controlen el camión
RegisterNetEvent('trucker:bindTruckToGroup', function(netId)
  truckNetId = netId
  local veh = NetworkGetEntityFromNetworkId(netId)
  if veh ~= 0 then
    assignedTruck = veh
  end
end)

-- Borrado remoto del camión (fallo/fin)
RegisterNetEvent('trucker:deleteAssignedTruck', function(netId)
  local veh = NetworkGetEntityFromNetworkId(netId)
  if veh ~= 0 and DoesEntityExist(veh) then
    if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
      TaskLeaveVehicle(PlayerPedId(), veh, 16)
      Wait(500)
    end
    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)
  end
  if assignedTruck and DoesEntityExist(assignedTruck) then
    DeleteVehicle(assignedTruck)
  end
  assignedTruck = nil
  truckNetId = nil
end)

-- Monitor de destrucción del camión
CreateThread(function()
  while true do
    Wait(1500)
    if assignedTruck and DoesEntityExist(assignedTruck) then
      if GetEntityHealth(assignedTruck) <= 0 or IsEntityDead(assignedTruck) then
        TriggerServerEvent('trucker:truckDestroyed')
        assignedTruck = nil
      end
    end
  end
end)

-- Control de ruta y advertencias
CreateThread(function()
  while true do
    Wait(2500)
    if assignedTruck and DoesEntityExist(assignedTruck) and currentTarget then
      local pos = GetEntityCoords(assignedTruck)
      local dist = #(pos - currentTarget)
      if dist > (Config.Route.maxRouteDistance or 550.0) then
        local now = GetGameTimer()
        if now - (warnCooldown or 0) > (Config.Route.warnCooldownMs or 8000) then
          warnCooldown = now
          routeWarnings = routeWarnings + 1
          TriggerEvent('chat:addMessage', { args = { '^3Camionero', ('Advertencia: vuelve a la ruta (%d/%d)'):format(routeWarnings, Config.Route.maxWarnings or 3) } })
          if routeWarnings >= (Config.Route.maxWarnings or 3) then
            TriggerServerEvent('trucker:routeFail')
            if assignedTruck then
              SetEntityAsMissionEntity(assignedTruck, true, true)
              DeleteVehicle(assignedTruck)
            end
            assignedTruck = nil
            clearRoute()
          end
        end
      else
        -- dentro de rango, reset suave
        routeWarnings = math.max(0, routeWarnings - 1)
      end
    end
  end
end)

-- Anti-VDM: freno preventivo
CreateThread(function()
  while true do
    Wait(75)
    if assignedTruck and DoesEntityExist(assignedTruck) and GetPedInVehicleSeat(assignedTruck, -1) == PlayerPedId() then
      local s = Config.AntiVDM or {}
      local from = GetEntityCoords(assignedTruck)
      local to = GetOffsetFromEntityInWorldCoords(assignedTruck, 0.0, (s.forwardMeters or 6.0), 0.0)
      local ray = StartShapeTestCapsule(from.x, from.y, from.z + (s.heightOffset or 1.0), to.x, to.y, to.z + (s.heightOffset or 1.0), (s.capsuleRadius or 2.2), 10, assignedTruck, 7)
      local _, hit, _, _, ent = GetShapeTestResult(ray)
      if hit == 1 and ent ~= 0 then
        if IsEntityAPed(ent) then
          if s.brake then
            SetVehicleForwardSpeed(assignedTruck, 0.0)
          else
            local vel = GetEntityVelocity(assignedTruck)
            local v = vector3(vel.x, vel.y, vel.z)
            local speed = #(v)
            if speed > (s.limitSpeed or 10.0) then
              SetVehicleForwardSpeed(assignedTruck, s.limitSpeed or 10.0)
            end
          end
          DisableControlAction(0, 71, true) -- acelerar
          DisableControlAction(0, 72, true) -- frenar
        end
      end
    end
  end
end)

-- UI: actualizaciones
RegisterNetEvent('trucker:updateActive', function(data)
  SendNUIMessage({ action = 'updateActive', load = data.load, deliver = data.deliver })
  if data.load and data.load >= 100 then
    isLoadPhase = false -- ahora el target será el destino
  end
end)

RegisterNetEvent('trucker:updateXP', function(data)
  SendNUIMessage({ action = 'updateXP', xp = data.xp })
end)

RegisterNetEvent('trucker:updateGroup', function(payload)
  SendNUIMessage({ action = 'updateGroup', members = payload.members })
end)

-- NUI callbacks ya definidos en tu interfaz:
-- closeUI, selectHubCargo, startLoading, loadTick, finishJob, cancelJob, groupCreate, groupInvite, groupLeave
RegisterNUICallback('closeUI', function(_, cb) SetNuiFocus(false,false); uiOpen=false; cb('ok') end)
RegisterNUICallback('selectHubCargo', function(data, cb)
  TriggerServerEvent('trucker:startFromHub', tonumber(data.hubIndex), data.cargoId, data.mode or 'solo'); cb('ok')
end)
RegisterNUICallback('startLoading', function(_, cb)
  TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_BUM_STANDING", 0, true)
  TriggerServerEvent('trucker:load:start'); cb('ok')
end)
RegisterNUICallback('loadTick', function(_, cb) TriggerServerEvent('trucker:load:tick'); cb('ok') end)
RegisterNUICallback('finishJob', function(_, cb)
  TriggerServerEvent('trucker:finishJob')
  ClearPedTasksImmediately(PlayerPedId()); cb('ok')
end)
RegisterNUICallback('cancelJob', function(_, cb)
  TriggerServerEvent('trucker:cancelJob')
  ClearPedTasksImmediately(PlayerPedId()); clearRoute(); cb('ok')
end)
RegisterNUICallback('groupCreate', function(_, cb) TriggerServerEvent('trucker:group:create'); cb('ok') end)
RegisterNUICallback('groupInvite', function(data, cb) TriggerServerEvent('trucker:group:invite', tonumber(data.id)); cb('ok') end)
RegisterNUICallback('groupLeave', function(_, cb) TriggerServerEvent('trucker:group:leave'); cb('ok') end)

-- Policía (blip + waypoint)
RegisterNetEvent('police:receiveTruckerAlert', function(coords, cargoLabel)
  local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
  SetBlipSprite(blip, 161); SetBlipScale(blip, 1.0); SetBlipColour(blip, 1)
  BeginTextCommandSetBlipName("STRING"); AddTextComponentString("Posible Transporte Ilegal"); EndTextCommandSetBlipName(blip)
  SetNewWaypoint(coords.x, coords.y)
  Citizen.SetTimeout(90000, function() if DoesBlipExist(blip) then RemoveBlip(blip) end end)
  TriggerEvent('chat:addMessage', { args = { '^1Policía', ('Alerta: %s'):format(cargoLabel) } })
end)

