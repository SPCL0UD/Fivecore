local assignedTaxi, routeBlip, currentTarget
local routeWarnings, warnCooldown = 0, 0
local currentPassenger = nil
local currentNivel = 1

-- Blip de base (opcional)
CreateThread(function()
  local b = AddBlipForCoord(-1616.0, -1025.0, 13.1)
  SetBlipSprite(b, 198) SetBlipDisplay(b, 4) SetBlipScale(b, 0.8) SetBlipColour(b, 5) SetBlipAsShortRange(b, true)
  BeginTextCommandSetBlipName("STRING") AddTextComponentString("Base Taxi - Pier Del Perro") EndTextCommandSetBlipName(b)
end)

-- Comando rápido para abrir NUI y pedir trabajo
RegisterCommand('taxi', function()
  SendNUIMessage({ action='showUI', xp=0, nivel=currentNivel })
  SetNuiFocus(true,true)
end)

-- Spawn del taxi con tuneo/colores según nivel
RegisterNetEvent('taxi:spawnTaxi', function(vehData, coords, nivel)
  currentNivel = nivel
  local mhash = GetHashKey(vehData.modelo)
  RequestModel(mhash) while not HasModelLoaded(mhash) do Wait(0) end
  local veh = CreateVehicle(mhash, coords.x, coords.y, coords.z, 0.0, true, false)
  SetVehicleOnGroundProperly(veh)
  SetVehicleNumberPlateText(veh, ("TAXI%d"):format(math.random(100,999)))
  SetVehicleEngineOn(veh, true, true, false)

  if vehData.color then
    -- negro sólido
    SetVehicleColours(veh, 0, 0)
    SetVehicleCustomPrimaryColour(veh, vehData.color[1], vehData.color[2], vehData.color[3])
    SetVehicleCustomSecondaryColour(veh, vehData.color[1], vehData.color[2], vehData.color[3])
  end

  if vehData.tuneo then
    SetVehicleModKit(veh, 0)
    for i=0,16 do
      local cnt = GetNumVehicleMods(veh, i)
      if cnt and cnt > 0 then SetVehicleMod(veh, i, cnt-1, false) end
    end
    ToggleVehicleMod(veh, 18, true) -- turbo
    SetVehicleTyresCanBurst(veh, false)
    SetVehicleWindowTint(veh, 2)
  end

  assignedTaxi = veh
  TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
  -- Mostrar UI
  SendNUIMessage({ action='showUI', nivel=nivel })
end)

-- Esperar pasajero
RegisterNetEvent('taxi:waitForPassenger', function(nivel)
  currentNivel = nivel
  SendNUIMessage({ action='setStage', stage='waiting', nivel=nivel })
end)

-- Recoger: spawn del NPC y ruta al pickup
RegisterNetEvent('taxi:setPickup', function(coords, pedModel, nivel)
  currentNivel = nivel
  setRoute(coords, "Recoger pasajero")

  RequestModel(pedModel) while not HasModelLoaded(pedModel) do Wait(0) end
  local ped = CreatePed(4, GetHashKey(pedModel), coords.x, coords.y, coords.z, 0.0, true, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  SetEntityInvincible(ped, true)
  FreezeEntityPosition(ped, true)
  currentPassenger = ped
  SendNUIMessage({ action='setStage', stage='pickup', nivel=nivel })
end)

-- Destino: ruta al dropoff y activar paparazzis si corresponde
RegisterNetEvent('taxi:setDropoff', function(coords, nivel)
  setRoute(coords, "Destino del pasajero")
  SendNUIMessage({ action='setStage', stage='dropoff', nivel=nivel })
  if nivel >= 2 then startPaparazziEvent() end
end)

-- Finalización
RegisterNetEvent('taxi:jobFinished', function(payload)
  stopPaparazziEvent()
  clearRoute()
  if DoesEntityExist(currentPassenger) then DeleteEntity(currentPassenger) end
  currentPassenger = nil
  SendNUIMessage({ action='jobFinished', pago = payload.pago, xp = payload.xp })
end)

-- Fallo
RegisterNetEvent('taxi:jobFailed', function(reason)
  stopPaparazziEvent()
  clearRoute()
  if DoesEntityExist(currentPassenger) then DeleteEntity(currentPassenger) end
  currentPassenger = nil
  if assignedTaxi and DoesEntityExist(assignedTaxi) then
    SetEntityAsMissionEntity(assignedTaxi, true, true)
    DeleteVehicle(assignedTaxi)
  end
  assignedTaxi = nil
  SendNUIMessage({ action='jobFailed', reason = reason })
end)

-- Helpers de ruta
function setRoute(coords, label)
  currentTarget = vector3(coords.x+0.0, coords.y+0.0, coords.z+0.0)
  if DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
  routeBlip = AddBlipForCoord(currentTarget.x, currentTarget.y, currentTarget.z)
  SetBlipSprite(routeBlip, 280) SetBlipScale(routeBlip, 0.9) SetBlipColour(routeBlip, 5)
  SetBlipRoute(routeBlip, true) SetBlipRouteColour(routeBlip, 5)
  BeginTextCommandSetBlipName("STRING") AddTextComponentString(label) EndTextCommandSetBlipName(routeBlip)
end

function clearRoute()
  currentTarget = nil
  if DoesBlipExist(routeBlip) then SetBlipRoute(routeBlip, false) RemoveBlip(routeBlip) routeBlip=nil end
end

-- Control de ruta y advertencias
CreateThread(function()
  while true do
    Wait(2500)
    if assignedTaxi and currentTarget then
      local dist = #(GetEntityCoords(assignedTaxi) - currentTarget)
      if dist > (Config.Route.maxRouteDistance or 300.0) then
        local now = GetGameTimer()
        if now - (warnCooldown or 0) > (Config.Route.warnCooldownMs or 8000) then
          warnCooldown = now
          routeWarnings = (routeWarnings or 0) + 1
          TriggerEvent('chat:addMessage', { args = { '^3Taxi', ('Advertencia: vuelve a la ruta (%d/%d)'):format(routeWarnings, Config.Route.maxWarnings or 3) } })
          if routeWarnings >= (Config.Route.maxWarnings or 3) then
            TriggerServerEvent('taxi:failJob', 'Te desviaste demasiado de la ruta')
            routeWarnings = 0
          end
        end
      else
        routeWarnings = math.max(0, (routeWarnings or 0) - 1)
      end
    end
  end
end)

-- Anti-VDM
CreateThread(function()
  while true do
    Wait(75)
    if assignedTaxi and GetPedInVehicleSeat(assignedTaxi, -1) == PlayerPedId() then
      local s = Config.AntiVDM
      local from = GetEntityCoords(assignedTaxi)
      local to = GetOffsetFromEntityInWorldCoords(assignedTaxi, 0.0, s.forwardMeters, 0.0)
      local ray = StartShapeTestCapsule(from.x, from.y, from.z + s.heightOffset, to.x, to.y, to.z + s.heightOffset, s.capsuleRadius, 10, assignedTaxi, 7)
      local _, hit, _, _, ent = GetShapeTestResult(ray)
      if hit == 1 and IsEntityAPed(ent) then
        if s.brake then SetVehicleForwardSpeed(assignedTaxi, 0.0) end
        DisableControlAction(0, 71, true) -- acelerar
        DisableControlAction(0, 72, true) -- frenar
      end
    end
  end
end)

-- NUI callbacks
RegisterNUICallback('closeUI', function(_, cb) SetNuiFocus(false,false) cb('ok') end)
RegisterNUICallback('startJob', function(data, cb)
  TriggerServerEvent('taxi:startJob', 1) cb('ok')
end)
RegisterNUICallback('requestNPC', function(_, cb)
  TriggerServerEvent('taxi:requestNPC') cb('ok')
end)
RegisterNUICallback('pickupDone', function(_, cb)
  -- Hacer entrar al pasajero si existe y estamos cerca del taxi
  if currentPassenger and assignedTaxi then
    FreezeEntityPosition(currentPassenger, false)
    TaskEnterVehicle(currentPassenger, assignedTaxi, -1, 0, 1.0, 1, 0)
    -- Pequeño delay y notificar
    SetTimeout(2000, function() TriggerServerEvent('taxi:pickupDone') end)
  else
    TriggerServerEvent('taxi:pickupDone')
  end
  cb('ok')
end)
RegisterNUICallback('dropoffDone', function(_, cb)
  -- Hacer bajar al pasajero
  if currentPassenger and assignedTaxi then
    TaskLeaveVehicle(currentPassenger, assignedTaxi, 256)
    SetTimeout(1500, function()
      if DoesEntityExist(currentPassenger) then DeleteEntity(currentPassenger) end
      currentPassenger = nil
      TriggerServerEvent('taxi:dropoffDone')
    end)
  else
    TriggerServerEvent('taxi:dropoffDone')
  end
  cb('ok')
end)

-- Paparazzis
local papVeh, papPed, paparazziActive = nil, nil, false
local paparazziDamage = 0

function startPaparazziEvent()
  if paparazziActive then return end
  paparazziActive = true
  paparazziDamage = 0
  SendNUIMessage({ action='damageBar', show=true, value=0 })

  CreateThread(function()
    while paparazziActive do
      Wait(Config.Paparazzi.tickIntervalMs or 2000)
      if not assignedTaxi or not DoesEntityExist(assignedTaxi) then break end

      -- spawn si no existe
      if not DoesEntityExist(papVeh) then
        local v = GetHashKey(Config.Paparazzi.vehicle)
        local p = GetHashKey(Config.Paparazzi.ped)
        RequestModel(v) while not HasModelLoaded(v) do Wait(0) end
        RequestModel(p) while not HasModelLoaded(p) do Wait(0) end

        local side = math.random(Config.Paparazzi.spawnSide.min, Config.Paparazzi.spawnSide.max)
        local forward = math.random(Config.Paparazzi.spawnForward.min, Config.Paparazzi.spawnForward.max)
        local sp = GetOffsetFromEntityInWorldCoords(assignedTaxi, side+0.0, forward+0.0, 0.0)

        papVeh = CreateVehicle(v, sp.x, sp.y, sp.z, GetEntityHeading(assignedTaxi), true, false)
        SetVehicleOnGroundProperly(papVeh)
        papPed = CreatePedInsideVehicle(papVeh, 4, p, -1, true, false)
        SetBlockingOfNonTemporaryEvents(papPed, true)
        TaskVehicleChase(papPed, assignedTaxi)
      end

      -- calcular “acoso”
      if DoesEntityExist(papVeh) and DoesEntityExist(assignedTaxi) then
        local dist = #(GetEntityCoords(papVeh) - GetEntityCoords(assignedTaxi))
        if dist <= (Config.Paparazzi.distanceAggro or 10.0) then
          paparazziDamage = math.min(100, paparazziDamage + (Config.Paparazzi.tickDamage or 10))
          SendNUIMessage({ action='updateDamageBar', value=paparazziDamage })
          if paparazziDamage >= 100 then 
            TriggerServerEvent('taxi:failJob', 'El cliente canceló por acoso de paparazzis')
            break
          end
        end
      end
    end
    cleanupPaparazzi()
  end)
end

function stopPaparazziEvent()
  paparazziActive = false
  cleanupPaparazzi()
  SendNUIMessage({ action='damageBar', show=false })
end

function cleanupPaparazzi()
  if DoesEntityExist(papPed) then DeleteEntity(papPed) end
  if DoesEntityExist(papVeh) then DeleteVehicle(papVeh) end
  papPed, papVeh = nil, nil
end
-- Variables del taxímetro
local meterActive = false
local meterLevel = 1
local odoMeters = 0.0
local lastPos = nil
local rideStart = 0
local vehStartHealth = nil
local paparazziDamageLive = 0 -- si ya tienes esa barra, sincronízala aquí con SendNUIMessage({action:'updateDamageBar', value = x})

-- Arrancar taxímetro (cuando el pasajero sube y empieza el dropoff)
function meterStart(level)
  meterLevel = level or 1
  meterActive = true
  odoMeters = 0.0
  lastPos = GetEntityCoords(assignedTaxi or PlayerPedId())
  rideStart = GetGameTimer()
  vehStartHealth = (assignedTaxi and GetEntityHealth(assignedTaxi)) or 1000
  SendNUIMessage({ action = 'meter:show', show = true })
end

-- Parar taxímetro (al finalizar)
function meterStop()
  meterActive = false
  SendNUIMessage({ action = 'meter:show', show = false })
end

-- Helper: calcula costos y envía a NUI
local function meterUpdateUI()
  local tcfg = Config.Taximetro
  local lvl = tcfg.niveles[meterLevel] or tcfg.niveles[1]
  local km = math.max(0.0, odoMeters / 1000.0)
  local min = math.max(0.0, (GetGameTimer() - rideStart) / 60000.0)

  local base = lvl.base
  local distCost = math.floor(lvl.perKm * km)
  local timeCost = math.floor(lvl.perMin * min)
  local subtotal = math.floor((base + distCost + timeCost) * (lvl.vipMul or 1.0))

  -- Propina
  local tipPct = 0
  -- daño del vehículo
  local vehHealthNow = (assignedTaxi and GetEntityHealth(assignedTaxi)) or vehStartHealth
  local vehDamagePct = math.max(0, ((vehStartHealth or 1000) - (vehHealthNow or 1000)) / (vehStartHealth or 1000) * 100)
  if vehDamagePct <= (tcfg.propina.damageTipThreshold or 10) then tipPct = tipPct + (tcfg.propina.limpioBonusPct or 10) end
  -- rapidez vs ETA
  local etaMin = km * (tcfg.etaMinPorKm or 2.0)
  if min <= etaMin then tipPct = tipPct + (tcfg.propina.rapidoBonusPct or 10) end
  tipPct = math.min(tipPct, tcfg.propina.maxPct or 20)
  local tip = math.floor(subtotal * (tipPct/100))

  -- Penalización (daño + paparazzi)
  local penDamage = math.floor((vehDamagePct) * (tcfg.penalizacion.porDamagePct or 0.8))
  local penPaps   = math.floor((paparazziDamageLive or 0) * (tcfg.penalizacion.paparazziPct or 0.5))
  local penRaw = penDamage + penPaps
  local penCap = math.floor(subtotal * ((tcfg.penalizacion.maxPct or 60)/100))
  local pen = math.min(penRaw, penCap)

  local total = math.max(0, subtotal + tip - pen)

  SendNUIMessage({
    action='meter:update',
    base = base, distCost=distCost, timeCost=timeCost,
    km = km, min = min, tip = tip, pen = pen, total = total
  })

  return total
end

-- Odometer loop
CreateThread(function()
  while true do
    Wait(250)
    if meterActive and (assignedTaxi and DoesEntityExist(assignedTaxi)) then
      local pos = GetEntityCoords(assignedTaxi)
      if lastPos then odoMeters = odoMeters + #(pos - lastPos) end
      lastPos = pos
      meterUpdateUI()
    end
  end
end)
-- Sincronizar daño de paparazzis
CreateThread(function()
  while true do
    Wait(1000)
    if meterActive and paparazziActive then
      if paparazziDamageLive ~= paparazziDamage then
        paparazziDamageLive = paparazziDamage
        SendNUIMessage({ action='updateDamageBar', value=paparazziDamageLive })
        meterUpdateUI() -- recalcular penalización
      end
    end
  end
end)
RegisterNUICallback('pickupDone', function(_, cb)
  -- ... tu lógica para subir al pasajero
  TriggerServerEvent('taxi:pickupDone')
  cb('ok')
end)

RegisterNetEvent('taxi:setDropoff', function(coords, nivel)
  setRoute(coords, "Destino del pasajero")
  SendNUIMessage({ action='setStage', stage='dropoff', nivel=nivel })
  meterStart(nivel)          -- INICIA EL TAXÍMETRO AQUÍ
  if nivel >= 2 then startPaparazziEvent() end
end)
RegisterNUICallback('dropoffDone', function(_, cb)
  meterStop()                -- PARA EL TAXÍMETRO
  -- ... tu lógica de bajar y avisar al server
  cb('ok')
end)

RegisterNetEvent('taxi:jobFinished', function(payload)
  stopPaparazziEvent()
  meterStop()
  clearRoute()
  -- ... resto
end)

RegisterNetEvent('taxi:jobFailed', function(reason)
  stopPaparazziEvent()
  meterStop()
  clearRoute()
  -- ... resto
end)
--[[
  Control de ruta y anti-VDM
  Inspirado en five-garbagejob
]]
