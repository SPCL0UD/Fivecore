local activeJobs = activeJobs or {}   -- [src] = { hub, cargo, type, mode, members, leader, loadTicks, stage, loadPoint, dest, truckNetId, truckPlate, lastWarnAt }
local groups     = groups or {}       -- [groupId] = { leader, members = { [src]=true }, job = nil }
local invites    = invites or {}      -- invites[target] = groupId
local NEXT_GROUP_ID = 1

local function isMafia(job)
  for _, j in ipairs(Config.MafiaJobs or {}) do
    if job == j then return true end
  end
  return false
end

local function newGroup(leader)
  local id = NEXT_GROUP_ID
  NEXT_GROUP_ID = NEXT_GROUP_ID + 1
  groups[id] = { leader = leader, members = { [leader] = true }, job = nil }
  return id
end

local function getGroupOf(src)
  for gid, g in pairs(groups) do
    if g.members[src] then return gid, g end
  end
  return nil, nil
end

local function broadcast(members, event, ...)
  for _, pid in ipairs(members) do
    TriggerClientEvent(event, pid, ...)
  end
end

local function failJobFor(job, reason)
  if not job then return end
  broadcast(job.members, 'trucker:clearRoute')
  broadcast(job.members, 'chat:addMessage', { args = { '^1Camionero', 'Trabajo fallido: '..reason } })
  -- Eliminar camión en clientes de los miembros
  if job.truckNetId then
    broadcast(job.members, 'trucker:deleteAssignedTruck', job.truckNetId)
  end
  for _, pid in ipairs(job.members) do
    activeJobs[pid] = nil
  end
end

-- Mostrar hubs según permisos y enviar XP
RegisterNetEvent('trucker:requestHubs', function()
  local src = source
  local p = exports['fivecore']:state(src); if not p then return end
  local hubs = {}
  for i, hub in ipairs(Config.TruckerHubs or {}) do
    if hub.type == 'legal' or (hub.type == 'ilegal' and isMafia(p.job.name)) then
      table.insert(hubs, { index = i, name = hub.name, type = hub.type, coords = hub.coords, levels = hub.levels })
    end
  end
  TriggerClientEvent('trucker:showHubs', src, hubs, p.truckerXP or 0)
end)

-- Iniciar trabajo: crea estado, spawnea camión, ruta a CARGA
RegisterNetEvent('trucker:startFromHub', function(hubIndex, cargoId, mode)
  local src = source
  local p = exports['fivecore']:state(src); if not p then return end
  mode = mode or 'solo'

  local hub = Config.TruckerHubs[hubIndex]; if not hub then return end
  if hub.type == 'ilegal' and not isMafia(p.job.name) then return end

  local cargo = (hub.type == 'legal' and Config.CargosLegal[cargoId]) or Config.CargosIlegal[cargoId]
  if not cargo then return end

  if p.money.cash < cargo.rent then
    TriggerClientEvent('chat:addMessage', src, { args = { '^1Camionero', 'No tienes dinero para alquilar el camión.' } })
    return
  end
  p.money.cash = p.money.cash - cargo.rent

  local dest = Config.Destinos[cargoId] or hub.coords
  local loadPoint = hub.coords

  local members = { src }
  local leader = src

  if mode == 'group' then
    local gid, g = getGroupOf(src)
    if not gid then gid = newGroup(src); g = groups[gid] end
    members = {}
    for pid,_ in pairs(g.members) do table.insert(members, pid) end
    leader = g.leader
    g.job = { hub = hubIndex, cargoId = cargoId }
    -- sincronizar UI grupo
    local uiMembers = {}
    for pid,_ in pairs(g.members) do table.insert(uiMembers, { id=pid, name=GetPlayerName(pid), role=(pid==g.leader and 'Líder' or 'Miembro') }) end
    broadcast(members, 'trucker:updateGroup', { members = uiMembers })
  end

  -- Modelo del camión según carga o nivel “estimado” por XP
  local model = Config.TruckModelByCargo[cargoId]
  if not model then
    local xp = p.truckerXP or 0
    local thresholds = {0,100,300,600,1000}
    local level = 1
    for i=1,#thresholds do if xp >= thresholds[i] then level = i end end
    model = Config.TruckModelsByLevel[level] or 'mule3'
  end

  -- Estado inicial para cada miembro
  for _, pid in ipairs(members) do
    activeJobs[pid] = {
      hub = hubIndex, cargo = cargo, type = hub.type, mode = mode,
      members = members, leader = leader,
      loadTicks = 0, stage = 'loading',
      loadPoint = loadPoint, dest = dest,
      truckNetId = nil, truckPlate = nil,
      lastWarnAt = 0
    }
    TriggerClientEvent('trucker:startClientJob', pid, cargo, hub.type)
  end

  -- Spawn del camión SOLO en el líder; luego se replica por red
  TriggerClientEvent('trucker:spawnTruckClient', leader, model, loadPoint)
  broadcast(members, 'trucker:setRoute', loadPoint, true)

  -- Alerta a policía si es ilegal
  if hub.type == 'ilegal' then
    TriggerEvent('police:alertTrucker', src, cargo.label)
  end
end)

-- El líder reporta el NetId/plate del camión spawneado
RegisterNetEvent('trucker:truckSpawned', function(netId, plate)
  local src = source
  local job = activeJobs[src]; if not job then return end
  for _, pid in ipairs(job.members) do
    if activeJobs[pid] then
      activeJobs[pid].truckNetId = netId
      activeJobs[pid].truckPlate = plate
      -- asignar permisos de uso al grupo (side client)
      TriggerClientEvent('trucker:bindTruckToGroup', pid, netId)
    end
  end
end)

-- Destrucción, ruta fallida, desconexión
RegisterNetEvent('trucker:truckDestroyed', function()
  local src = source
  local job = activeJobs[src]; if job then failJobFor(job, 'El camión fue destruido') end
end)

RegisterNetEvent('trucker:routeFail', function()
  local src = source
  local job = activeJobs[src]; if job then failJobFor(job, 'No seguiste la ruta asignada') end
end)

AddEventHandler('playerDropped', function()
  local src = source
  local job = activeJobs[src]
  if job then failJobFor(job, 'Un miembro se desconectó') end
end)

-- Carga: comienzo y ticks (con bonus grupal)
local lastTick = {}
RegisterNetEvent('trucker:load:start', function()
  local src = source
  local job = activeJobs[src]; if not job or job.stage ~= 'loading' then return end
  TriggerClientEvent('chat:addMessage', src, { args = { '^2Camionero', 'Comenzaste la carga.' } })
end)

RegisterNetEvent('trucker:load:tick', function()
  local src = source
  local now = GetGameTimer()
  local job = activeJobs[src]; if not job or job.stage ~= 'loading' then return end
  lastTick[src] = lastTick[src] or 0
  if now - lastTick[src] < (Config.Load.tickTimeout or 3000) then return end
  lastTick[src] = now

  -- Validar distancia a punto de carga
  local ped = GetPlayerPed(src)
  local px,py,pz = table.unpack(GetEntityCoords(ped))
  local dist = #(vector3(px,py,pz) - job.loadPoint)
  if dist > (Config.Load.maxDistance or 50.0) then return end

  local membersCount = #job.members
  local baseTicks = Config.Load.ticksRequired or 10
  local bonus = (membersCount>1) and ((membersCount-1)*(Config.Load.groupBonus or 0.15)) or 0.0
  local effTicks = math.max(1, math.floor(baseTicks / (1.0 + bonus)))

  -- Sumar para todos
  for _, pid in ipairs(job.members) do
    local j = activeJobs[pid]
    if j and j.stage == 'loading' then
      j.loadTicks = math.min(effTicks, (j.loadTicks or 0) + 1)
      local pct = math.floor((j.loadTicks / effTicks) * 100)
      TriggerClientEvent('trucker:updateActive', pid, { load = pct })
      if j.loadTicks >= effTicks then
        j.stage = 'delivery'
        TriggerClientEvent('trucker:setRoute', pid, j.dest, false)
        TriggerClientEvent('chat:addMessage', pid, { args = { '^2Camionero', 'Carga completa. Dirígete al destino.' } })
      end
    end
  end
end)

-- Finalizar entrega (validación distancia)
RegisterNetEvent('trucker:finishJob', function()
  local src = source
  local job = activeJobs[src]; if not job or job.stage ~= 'delivery' then return end

  local ped = GetPlayerPed(src)
  local px,py,pz = table.unpack(GetEntityCoords(ped))
  local dist = #(vector3(px,py,pz) - job.dest)
  if dist > (Config.Load.maxDistance or 50.0) then return end

  local share = 1 / math.max(1, #job.members)
  for _, pid in ipairs(job.members) do
    local p = exports['fivecore']:state(pid)
    if p then
      p.money.cash = (p.money.cash or 0) + math.floor(job.cargo.pay * share)
      p.truckerXP = (p.truckerXP or 0) + math.floor(job.cargo.xp * share)
      TriggerClientEvent('trucker:updateXP', pid, { xp = p.truckerXP })
      TriggerClientEvent('trucker:updateActive', pid, { deliver = 100 })
      TriggerClientEvent('trucker:clearRoute', pid)
      TriggerClientEvent('chat:addMessage', pid, { args = { '^2Camionero', ('Entrega finalizada. Pago: $%d | XP: %d'):format(math.floor(job.cargo.pay*share), math.floor(job.cargo.xp*share)) } })
      -- Borrar camión del cliente
      if job.truckNetId then
        TriggerClientEvent('trucker:deleteAssignedTruck', pid, job.truckNetId)
      end
      activeJobs[pid] = nil
    end
  end

  -- Limpiar vínculo de grupo actual
  local gid, g = getGroupOf(src)
  if g then g.job = nil end
end)

-- Cancelar trabajo manual
RegisterNetEvent('trucker:cancelJob', function()
  local src = source
  local job = activeJobs[src]; if not job then return end
  failJobFor(job, 'Cancelado por el jugador')
end)

-- Alerta a policía (blip + waypoint en clientes policía)
RegisterNetEvent('police:alertTrucker', function(truckerSrc, cargoLabel)
  local coords = GetEntityCoords(GetPlayerPed(truckerSrc))
  for _, id in ipairs(GetPlayers()) do
    local p = exports['fivecore']:state(id)
    if p and p.job.name == 'police' then
      TriggerClientEvent('police:receiveTruckerAlert', id, coords, cargoLabel)
    end
  end
end)

