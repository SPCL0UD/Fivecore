local activeGarbage = {} -- [src] = { groupId, ruta, idx, bolsasTotal, bolsasCargadas, stage, members = {}, truckNet }
local groups = {}        -- [groupId] = { leader, members = {} }
local nextGroupId = 1

local function newGroup(leader)
    local id = nextGroupId
    nextGroupId = nextGroupId + 1
    groups[id] = { leader = leader, members = { leader } }
    return id
end

local function getGroupOf(src)
    for gid, g in pairs(groups) do
        for _, m in ipairs(g.members) do
            if m == src then return gid, g end
        end
    end
    return nil, nil
end

local function broadcastGroup(gid, event, ...)
    local g = groups[gid]
    if not g then return end
    for _, pid in ipairs(g.members) do
        TriggerClientEvent(event, pid, ...)
    end
end

-- Crear grupo
RegisterNetEvent('garbage:groupCreate', function()
    local src = source
    if getGroupOf(src) then return end
    local gid = newGroup(src)
    TriggerClientEvent('garbage:groupUpdate', src, groups[gid])
end)

-- Invitar a grupo
RegisterNetEvent('garbage:groupInvite', function(target)
    local src = source
    local gid, g = getGroupOf(src)
    if not gid or g.leader ~= src then return end
    if not getGroupOf(target) then
        table.insert(g.members, target)
        TriggerClientEvent('garbage:groupUpdate', target, g)
        broadcastGroup(gid, 'garbage:groupUpdate', g)
    end
end)

-- Iniciar trabajo (individual o grupal)
RegisterNetEvent('garbage:startJob', function(depositoIndex, rutaId)
    local src = source
    local p = exports['fivecore']:state(src)
    local ruta = Config.Rutas[rutaId]
    if not ruta then return end

    local gid, g = getGroupOf(src)
    local members = { src }
    if gid then members = g.members end

    for _, pid in ipairs(members) do
        activeGarbage[pid] = {
            groupId = gid,
            ruta = ruta,
            idx = 1,
            bolsasTotal = ruta.bolsas,
            bolsasCargadas = 0,
            stage = 'collection',
            members = members
        }
        TriggerClientEvent('garbage:startClientJob', pid, { label = ruta.label, bolsas = ruta.bolsas, pago = ruta.pago, xp = ruta.xp })
        TriggerClientEvent('garbage:spawnTruck', pid, Config.TruckModel, Config.Depositos[depositoIndex].coords)
        TriggerClientEvent('garbage:setPoint', pid, ruta.puntos[1], 1, #ruta.puntos)
    end
end)

-- Cargar bolsa
RegisterNetEvent('garbage:bagLoaded', function()
    local src = source
    local job = activeGarbage[src]
    if not job then return end

    -- Sumar a todos los miembros
    for _, pid in ipairs(job.members) do
        if activeGarbage[pid] then
            activeGarbage[pid].bolsasCargadas = math.min(job.bolsasTotal, activeGarbage[pid].bolsasCargadas + 1)
            local pct = math.floor((activeGarbage[pid].bolsasCargadas / job.bolsasTotal) * 100)
            TriggerClientEvent('garbage:updateProgress', pid, { pointsPct = pct })
            -- Avanzar punto si corresponde
            if activeGarbage[pid].bolsasCargadas >= job.bolsasTotal then
                activeGarbage[pid].stage = 'dump'
                TriggerClientEvent('garbage:setDump', pid, Config.Vertederos[1])
            end
        end
    end
end)

-- Finalizar
RegisterNetEvent('garbage:finishJob', function()
    local src = source
    local job = activeGarbage[src]
    if not job then return end
    local share = 1 / #job.members
    for _, pid in ipairs(job.members) do
        local p = exports['fivecore']:state(pid)
        if p then
            p.money.cash = (p.money.cash or 0) + math.floor(job.ruta.pago * share)
            p.garbageXP = (p.garbageXP or 0) + math.floor(job.ruta.xp * share)
            TriggerClientEvent('garbage:jobFinished', pid, { pago = math.floor(job.ruta.pago * share), xp = p.garbageXP })
            activeGarbage[pid] = nil
        end
    end
end)
-- Abandonar trabajo
RegisterNetEvent('garbage:leaveJob', function()
    local src = source
    local job = activeGarbage[src]
    if not job then return end
    local gid, g = getGroupOf(src)
    if gid and g.leader == src then
        -- Líder abandona: cancelar para todos
        for _, pid in ipairs(job.members) do
            TriggerClientEvent('garbage:jobCancelled', pid)
            activeGarbage[pid] = nil
        end
        groups[gid] = nil
    else
        -- Miembro abandona solo él
        TriggerClientEvent('garbage:jobCancelled', src)
        activeGarbage[src] = nil
        if gid and g then
            for i, m in ipairs(g.members) do
                if m == src then
                    table.remove(g.members, i)
                    break
                end
            end
            broadcastGroup(gid, 'garbage:groupUpdate', g)
        end
    end
    TriggerClientEvent('garbage:deleteTruck', src)
end)
-- Enviar punto activo a todos los miembros
local function setActivePointForGroup(job, idx)
    local coords = job.ruta.puntos[idx]
    for _, pid in ipairs(job.members) do
        TriggerClientEvent('garbage:setActivePoint', pid, coords, idx, #job.ruta.puntos)
    end
end

-- Al iniciar trabajo
RegisterNetEvent('garbage:startJob', function(depositoIndex, rutaId)
    local src = source
    local p = exports['fivecore']:state(src)
    local ruta = Config.Rutas[rutaId]
    if not ruta then return end

    local gid, g = getGroupOf(src)
    local members = { src }
    if gid then members = g.members end

    for _, pid in ipairs(members) do
        activeGarbage[pid] = {
            groupId = gid,
            ruta = ruta,
            idx = 1,
            bolsasTotal = ruta.bolsas,
            bolsasCargadas = 0,
            stage = 'collection',
            members = members
        }
        TriggerClientEvent('garbage:startClientJob', pid, { label = ruta.label, bolsas = ruta.bolsas, pago = ruta.pago, xp = ruta.xp })
        TriggerClientEvent('garbage:spawnTruck', pid, Config.TruckModel, Config.Depositos[depositoIndex].coords)
    end

    -- Enviar primer punto a todos
    setActivePointForGroup(activeGarbage[src], 1)
end

-- Al cargar bolsa y pasar de punto
RegisterNetEvent('garbage:bagLoaded', function()
    local src = source
    local job = activeGarbage[src]
    if not job then return end

    job.bolsasCargadas = math.min(job.bolsasTotal, job.bolsasCargadas + 1)
    local bolsasPerPoint = math.floor(job.bolsasTotal / #job.ruta.puntos)
    local expectedAtThisPoint = job.idx * bolsasPerPoint

    if job.bolsasCargadas >= expectedAtThisPoint and job.idx < #job.ruta.puntos then
        job.idx = job.idx + 1
        setActivePointForGroup(job, job.idx)
    elseif job.bolsasCargadas >= job.bolsasTotal then
        job.stage = 'dump'
        for _, pid in ipairs(job.members) do
            TriggerClientEvent('garbage:setDump', pid, Config.Vertederos[1])
        end
    end

    -- Actualizar progreso a todos
    local pct = math.floor((job.bolsasCargadas / job.bolsasTotal) * 100)
    for _, pid in ipairs(job.members) do
        TriggerClientEvent('garbage:updateProgress', pid, { pointsPct = pct })
    end
end)
-- Al finalizar en vertedero
RegisterNetEvent('garbage:finishJob', function()
    local src = source
    local job = activeGarbage[src]
    if not job then return end
    local share = 1 / #job.members
    for _, pid in ipairs(job.members) do
        local p = exports['fivecore']:state(pid)
        if p then
            p.money.cash = (p.money.cash or 0) + math.floor(job.ruta.pago * share)
            p.garbageXP = (p.garbageXP or 0) + math.floor(job.ruta.xp * share)
            TriggerClientEvent('garbage:jobFinished', pid, { pago = math.floor(job.ruta.pago * share), xp = p.garbageXP })
            activeGarbage[pid] = nil
        end
    end
end)