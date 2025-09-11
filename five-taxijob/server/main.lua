local activeTaxis = {} -- [src] = { stage, pickup, dropoff, pedModel, pago, nivel }

local function nivelPorXP(xp)
  if xp >= (Config.NivelesTaxi[3].xp or 300) then return 3
  elseif xp >= (Config.NivelesTaxi[2].xp or 100) then return 2
  else return 1 end
end

local function pickDestino()
  local a = Config.DestinosNPC[math.random(#Config.DestinosNPC)]
  local b = Config.DestinosNPC[math.random(#Config.DestinosNPC)]
  local tries = 0
  while b == a and tries < 5 do
    b = Config.DestinosNPC[math.random(#Config.DestinosNPC)]
    tries = tries + 1
  end
  return a, b
end

RegisterNetEvent('taxi:startJob', function(baseIndex)
  local src = source
  local p = exports['fivecore']:state(src); if not p then return end
  local base = Config.Bases[baseIndex]; if not base then return end

  local nivel = nivelPorXP(p.taxiXP or 0)
  local lvlData = Config.NivelesTaxi[nivel]
  TriggerClientEvent('taxi:spawnTaxi', src, lvlData.vehiculo, base.coords, nivel)
  TriggerClientEvent('taxi:waitForPassenger', src, nivel)
end)

RegisterNetEvent('taxi:requestNPC', function()
  local src = source
  local p = exports['fivecore']:state(src); if not p then return end

  local nivel = nivelPorXP(p.taxiXP or 0)
  local clientSetup = Config.ClientesPorNivel[ Config.NivelesTaxi[nivel].clientes ]
  if not clientSetup then return end

  local pedModel = clientSetup.modelos[math.random(#clientSetup.modelos)]
  local pago = math.random(clientSetup.pagoMin, clientSetup.pagoMax)
  local pickup, dropoff = pickDestino()

  activeTaxis[src] = {
    stage = 'pickup',
    pickup = pickup,
    dropoff = dropoff,
    pedModel = pedModel,
    pago = pago,
    nivel = nivel
  }

  TriggerClientEvent('taxi:setPickup', src, pickup, pedModel, nivel)
end)

RegisterNetEvent('taxi:pickupDone', function()
  local src = source
  local job = activeTaxis[src]; if not job then return end
  job.stage = 'dropoff'
  TriggerClientEvent('taxi:setDropoff', src, job.dropoff, job.nivel)
end)

RegisterNetEvent('taxi:dropoffDone', function()
  local src = source
  local job = activeTaxis[src]; if not job then return end
  local p = exports['fivecore']:state(src); if not p then return end

  local lvlData = Config.NivelesTaxi[job.nivel]
  local pagoFinal = (lvlData.tarifaBase or 0) + job.pago

  p.money.cash = (p.money.cash or 0) + pagoFinal
  p.taxiXP = (p.taxiXP or 0) + (Config.XPPerRide or 10)

  TriggerClientEvent('taxi:jobFinished', src, { pago = pagoFinal, xp = p.taxiXP })
  activeTaxis[src] = nil

  -- Si quiere seguir trabajando, vuelve a esperar pedido
  TriggerClientEvent('taxi:waitForPassenger', src, job.nivel)
end)

RegisterNetEvent('taxi:failJob', function(reason)
  local src = source
  if activeTaxis[src] then
    TriggerClientEvent('taxi:jobFailed', src, reason or 'Trabajo fallido.')
    activeTaxis[src] = nil
  end
end)

AddEventHandler('playerDropped', function()
  local src = source
  if activeTaxis[src] then
    activeTaxis[src] = nil
  end
end)
--[[
  Control de ruta y anti-VDM
  Inspirado en five-garbagejob
--]]
AddEventHandler('playerSpawned', function()
  local src = source
  local job = activeTaxis[src]; if not job then return end
    TriggerClientEvent('taxi:restoreRoute', src, job.stage, job.pickup, job.dropoff, job.nivel)
end)
local activeTaxis = activeTaxis or {} -- [src] = { stage, pickup, dropoff, pedModel, pago, nivel, startedAt, approxKm, vehHealth0 }

local function nivelPorXP(xp)
  if xp >= (Config.NivelesTaxi[3].xp or 300) then return 3
  elseif xp >= (Config.NivelesTaxi[2].xp or 100) then return 2
  else return 1 end
end

local function dist2d(a, b)
  local dx, dy = (a.x - b.x), (a.y - b.y)
  return math.sqrt(dx*dx + dy*dy)
end

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

-- SP: iniciar trabajo (sin cambios sustanciales)
RegisterNetEvent('taxi:startJob', function(baseIndex)
  local src = source
  local p = exports['fivecore']:state(src); if not p then return end
  local base = Config.Bases[baseIndex]; if not base then return end
  local nivel = nivelPorXP(p.taxiXP or 0)
  local lvlData = Config.NivelesTaxi[nivel]
  TriggerClientEvent('taxi:spawnTaxi', src, lvlData.vehiculo, base.coords, nivel)
  TriggerClientEvent('taxi:waitForPassenger', src, nivel)
end)

-- Petición de NPC (sellamos pickup y aprox. distancia de ruta)
RegisterNetEvent('taxi:requestNPC', function()
  local src = source
  local p = exports['fivecore']:state(src); if not p then return end
  local nivel = nivelPorXP(p.taxiXP or 0)
  local clientSetup = Config.ClientesPorNivel[ Config.NivelesTaxi[nivel].clientes ]
  if not clientSetup then return end

  local pedModel = clientSetup.modelos[math.random(#clientSetup.modelos)]
  local pago = math.random(clientSetup.pagoMin, clientSetup.pagoMax)

  -- puntos
  local pickup = Config.DestinosNPC[math.random(#Config.DestinosNPC)]
  local dropoff = Config.DestinosNPC[math.random(#Config.DestinosNPC)]
  local tries = 0
  while dropoff == pickup and tries < 5 do
    dropoff = Config.DestinosNPC[math.random(#Config.DestinosNPC)]
    tries = tries + 1
  end

  -- estimado "recto" + 30% margen (calles)
  local approxKm = (dist2d(pickup, dropoff) / 1000.0) * 1.3

  activeTaxis[src] = {
    stage = 'pickup',
    pickup = pickup,
    dropoff = dropoff,
    pedModel = pedModel,
    pago = pago,
    nivel = nivel,
    startedAt = nil,    -- se setea al pickupDone
    approxKm = approxKm,
    vehHealth0 = nil
  }

  TriggerClientEvent('taxi:setPickup', src, pickup, pedModel, nivel)
end)

-- Variables definidas en tu taxímetro:
-- meterLevel, odoMeters, rideStart, vehStartHealth, paparazziDamageLive

RegisterNUICallback('dropoffDone', function(_, cb)
  meterStop()

  -- snapshot
  local km = math.max(0.0, (odoMeters or 0.0) / 1000.0)
  local min = math.max(0.0, (GetGameTimer() - (rideStart or GetGameTimer())) / 60000.0)
  local vehHealthNow = assignedTaxi and GetEntityHealth(assignedTaxi) or (vehStartHealth or 1000)
  local vehDamagePct = 0.0
  if vehStartHealth and vehStartHealth > 0 then
    vehDamagePct = math.max(0, (vehStartHealth - vehHealthNow) / vehStartHealth * 100.0)
  end
  local paparazziPct = math.max(0, math.min(100, paparazziDamageLive or 0))

  -- enviar a server para cálculo y pago
  TriggerServerEvent('taxi:finishWithData', {
    nivel = meterLevel,
    km = km,
    min = min,
    vehDamagePct = vehDamagePct,
    paparazziPct = paparazziPct
  })

  -- bajar NPC visualmente y limpiar
  if currentPassenger and assignedTaxi then
    TaskLeaveVehicle(currentPassenger, assignedTaxi, 256)
    SetTimeout(1200, function()
      if DoesEntityExist(currentPassenger) then DeleteEntity(currentPassenger) end
      currentPassenger = nil
    end)
  end

  cb('ok')
end)
RegisterNUICallback('pickupDone', function(_, cb)
  meterStop()
    if currentPassenger and assignedTaxi then
        TaskEnterVehicle(currentPassenger, assignedTaxi, 20000, 0, 1.0, 1, 0)
    end
    local src = source
    local job = activeTaxis[src]; if not job then return end
    job.stage = 'dropoff'
    job.startedAt = GetGameTimer()
    local veh = assignedTaxi
    if veh and DoesEntityExist(veh) then
      job.vehHealth0 = GetEntityHealth(veh)
    end
    TriggerClientEvent('taxi:setDropoff', src, job.dropoff, job.nivel)
    cb('ok')
end)

-- Recalcular tarifa server-authoritative
local function calcFareServer(nivel, km, min, vehDamagePct, paparazziPct)
  local T = Config.Taximetro
  local L = T.niveles[nivel] or T.niveles[1]
  km = math.max(0, km); min = math.max(0, min)
  vehDamagePct = clamp(vehDamagePct, 0, 100)
  paparazziPct = clamp(paparazziPct, 0, 100)

  local base = L.base
  local distCost = math.floor(L.porKm * km)
  local timeCost = math.floor(L.porMin * min)
  local subtotal = math.floor((base + distCost + timeCost) * (L.vipMul or 1.0))

  -- tip
  local tipPct = 0
  if vehDamagePct <= (T.propina.damageTipThreshold or 10) then tipPct = tipPct + (T.propina.limpioBonusPct or 10) end
  local etaMin = km * (T.etaMinPorKm or 2.0)
  if min <= etaMin then tipPct = tipPct + (T.propina.rapidoBonusPct or 10) end
  tipPct = math.min(tipPct, T.propina.maxPct or 20)
  local tip = math.floor(subtotal * (tipPct/100))

  -- pen
  local penDamage = math.floor(vehDamagePct * (T.penalizacion.porDamagePct or 0.8))
  local penPaps = math.floor(paparazziPct * (T.penalizacion.paparazziPct or 0.5))
  local penRaw = penDamage + penPaps
  local penCap = math.floor(subtotal * ((T.penalizacion.maxPct or 60)/100))
  local pen = math.min(penRaw, penCap)

  local total = math.max(0, subtotal + tip - pen)
  return {
    base = base, distCost = distCost, timeCost = timeCost,
    tip = tip, pen = pen, total = total
  }
end

-- Final con datos del cliente (servidor valida/limita)
RegisterNetEvent('taxi:finishWithData', function(data)
  local src = source
  local job = activeTaxis[src]; if not job or job.stage ~= 'dropoff' then return end
  local p = exports['fivecore']:state(src); if not p then return end

  -- Inputs saneados
  local km = tonumber(data.km) or 0.0
  local min = tonumber(data.min) or 0.0
  local vehDamagePct = tonumber(data.vehDamagePct) or 0.0
  local paparazziPct = tonumber(data.paparazziPct) or 0.0

  -- Validaciones suaves
  -- km no menor al 30% de “línea recta * 1.0” ni mayor a 4x del estimado (evita extremos)
  local minKm = (dist2d(job.pickup, job.dropoff) / 1000.0) * 0.3
  local maxKm = math.max(1.0, (job.approxKm or 1.0) * 4.0)
  km = clamp(km, minKm, maxKm)

  -- min no menor a km * 0.5 (evita “teleports”) ni mayor a km * 10 (excesivo)
  local minMin = km * 0.5
  local maxMin = km * 10.0
  min = clamp(min, minMin, maxMin)

  -- daño: si no tenemos salud inicial, confiamos en client (mejor si lo sellás con pickupDoneSeal)
  vehDamagePct = clamp(vehDamagePct, 0, 100)
  paparazziPct = clamp(paparazziPct, 0, 100)

  local fare = calcFareServer(job.nivel, km, min, vehDamagePct, paparazziPct)

  -- Pago + XP
  p.money.cash = (p.money.cash or 0) + fare.total
  p.taxiXP = (p.taxiXP or 0) + (Config.XPPerRide or 10)

  TriggerClientEvent('taxi:jobFinished', src, { pago = fare.total, xp = p.taxiXP })

  activeTaxis[src] = nil
  TriggerClientEvent('taxi:waitForPassenger', src, job.nivel)
end)

-- Fallo
RegisterNetEvent('taxi:failJob', function(reason)
  local src = source
  if activeTaxis[src] then
    TriggerClientEvent('taxi:jobFailed', src, reason or 'Trabajo fallido.')
    activeTaxis[src] = nil
  end
end)
-- Desconexión
AddEventHandler('playerDropped', function()
    local src = source
    if activeTaxis[src] then
        activeTaxis[src] = nil
    end
    end)
-- Control de ruta: advertencias por salirse del rango
AddEventHandler('playerSpawned', function()
    local src = source
    local job = activeTaxis[src]; if not job then return end
        TriggerClientEvent('taxi:restoreRoute', src, job.stage, job.pickup, job.dropoff, job.nivel)
    end)
local activeTaxis = activeTaxis or {} -- [src] = { stage, pickup, dropoff, pedModel, pago, nivel, startedAt, approxKm, vehHealth0 }
local function nivelPorXP(xp)
  if xp >= (Config.NivelesTaxi[3].xp or 300) then return 3
  elseif xp >= (Config.NivelesTaxi[2].xp or 100) then return 2
  else return 1 end
end
local function dist2d(a, b)
  local dx, dy = (a.x - b.x), (a.y - b.y)
  return math.sqrt(dx*dx + dy*dy)
end
local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end
-- Limpieza al morir o desconectarse
AddEventHandler('playerDropped', function()
  local src = source
  if activeTaxis[src] then
    activeTaxis[src] = nil
  end
end)