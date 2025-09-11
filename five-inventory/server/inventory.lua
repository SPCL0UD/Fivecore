local function getInventory(src, ownerType)
    if ownerType == 'player' then
        local p = exports['fivecore']:state(src)
        return p and p.inv or {}
    elseif ownerType == 'other' then
        -- Aquí puedes devolver inventario de cofres/maleteros
        return {}
    end
    return {}
end

local function setInventory(src, ownerType, inv)
    if ownerType == 'player' then
        local p = exports['fivecore']:state(src)
        if p then p.inv = inv end
    elseif ownerType == 'other' then
        -- Guardar inventario de otro contenedor
    end
end

-- Normaliza inventario: une duplicados stackeables
local function normalizeInventory(p)
    if not p then return end
    p.inv = p.inv or {}
    local totals, singles = {}, {}
    for _, slot in pairs(p.inv) do
        if slot and slot.name then
            local def = Config.Items[slot.name]
            if def and def.stack then
                totals[slot.name] = (totals[slot.name] or 0) + (slot.count or 0)
            else
                table.insert(singles, slot)
            end
        end
    end
    local compact, idx = {}, 1
    for _, s in ipairs(singles) do
        compact[idx] = s
        idx = idx + 1
    end
    for name, total in pairs(totals) do
        local def = Config.Items[name] or {}
        compact[idx] = { name = name, label = def.label, count = total, weight = def.weight or 0, stack = def.stack }
        idx = idx + 1
    end
    p.inv = compact
end

-- =========================
-- API segura
-- =========================

exports('addItem', function(src, itemName, count)
    if type(itemName) ~= 'string' or type(count) ~= 'number' or count <= 0 then return false end
    local p = exports['fivecore']:state(src)
    if not p then return false end
    p.inv = p.inv or {}
    local def = Config.Items[itemName]
    if not def then return false end

    if def.stack then
        for _, slot in pairs(p.inv) do
            if slot.name == itemName then
                slot.count = slot.count + count
                normalizeInventory(p)
                return true
            end
        end
    end

    table.insert(p.inv, { name = itemName, label = def.label, count = count, weight = def.weight or 0, stack = def.stack })
    normalizeInventory(p)
    return true
end)

exports('removeItem', function(src, itemName, count)
    if type(itemName) ~= 'string' or type(count) ~= 'number' or count <= 0 then return false end
    local p = exports['fivecore']:state(src)
    if not p then return false end
    p.inv = p.inv or {}

    for i, slot in ipairs(p.inv) do
        if slot.name == itemName then
            if slot.count > count then
                slot.count = slot.count - count
                normalizeInventory(p)
                return true
            elseif slot.count == count then
                table.remove(p.inv, i)
                normalizeInventory(p)
                return true
            else
                return false
            end
        end
    end
    return false
end)

exports('hasItem', function(src, itemName, count)
    if type(itemName) ~= 'string' then return false end
    local p = exports['fivecore']:state(src)
    if not p then return false end
    p.inv = p.inv or {}
    local total = 0
    for _, slot in pairs(p.inv) do
        if slot.name == itemName then
            total = total + slot.count
            if not count or total >= count then
                return true
            end
        end
    end
    return false
end)

-- =========================
-- Eventos protegidos
-- =========================

RegisterNetEvent('five-inventory:request', function()
    local src = source
    local p = exports['fivecore']:state(src)
    if not p then return end
    normalizeInventory(p)

    -- Calcular peso total
    local totalWeight, maxWeight = 0.0, Config.MaxWeight or 25000
    for _, slot in pairs(p.inv or {}) do
        local def = Config.Items[slot.name]
        if def and def.weight then
            totalWeight = totalWeight + (def.weight * (slot.count or 1))
        end
    end

    local meta = {
        name   = GetPlayerName(src),
        job    = p.job and (Config.Jobs[p.job.name] and Config.Jobs[p.job.name].label or p.job.name) or 'Sin trabajo',
        cash   = p.money and p.money.cash or 0,
        bank   = p.money and p.money.bank or 0,
        crypto = p.money and p.money.crypto or 0,
        weight = totalWeight / 1000, -- kg
        maxWeight = maxWeight / 1000
    }

    TriggerClientEvent('five-inventory:set', src, p.inv, {}, meta)
end)

RegisterNetEvent('five-inventory:useItem', function(data)
    local src = source
    if type(data) ~= 'table' or type(data.slot) ~= 'number' then return end
    local p = exports['fivecore']:state(src)
    if not p then return end
    normalizeInventory(p)

    local inv = getInventory(src, 'player')
    local slot = inv[data.slot + 1]
    if not slot then return end

    -- Ejemplo de uso
    if slot.name == 'bread' then
        TriggerClientEvent('chat:addMessage', src, { args = { '^2Sistema', 'Has comido pan.' } })
    elseif slot.name == 'water' then
        TriggerClientEvent('chat:addMessage', src, { args = { '^2Sistema', 'Has bebido agua.' } })
    end

    exports['five-inventory']:removeItem(src, slot.name, 1)
    normalizeInventory(p)
    TriggerClientEvent('five-inventory:set', src, p.inv, {}, {
        name   = GetPlayerName(src),
        job    = p.job and (Config.Jobs[p.job.name] and Config.Jobs[p.job.name].label or p.job.name) or 'Sin trabajo',
        cash   = p.money and p.money.cash or 0,
        bank   = p.money and p.money.bank or 0,
        crypto = p.money and p.money.crypto or 0,
        weight = 0, -- recalcular si quieres
        maxWeight = (Config.MaxWeight or 25000) / 1000
    })
end)

-- =========================
-- Sistema de drops seguro
-- =========================

_G.__drops = _G.__drops or {}
local DROP_TTL = 600
local NEXT_ID = 1

local function newDropId()
    local id = NEXT_ID
    NEXT_ID = NEXT_ID + 1
    return id
end

local function broadcastAdd(drop) TriggerClientEvent('five-inventory:drops:add', -1, drop) end
local function broadcastRemove(id) TriggerClientEvent('five-inventory:drops:remove', -1, id) end

CreateThread(function()
    while true do
        Wait(30000)
        local now = os.time()
        for id, d in pairs(_G.__drops) do
            if d.expires <= now then
                _G.__drops[id] = nil
                broadcastRemove(id)
            end
        end
    end
end)

RegisterNetEvent('five-inventory:dropItem', function(data)
    local src = source
    if type(data) ~= 'table' or type(data.slot) ~= 'number' or type(data.count) ~= 'number' then return end
    local p = exports['fivecore']:state(src)
    if not p then return end
    normalizeInventory(p)

    local inv = getInventory(src, 'player')
    local slot = inv[data.slot + 1]
    if not slot or data.count <= 0 or data.count > slot.count then return end

    local ok = exports['five-inventory']:removeItem(src, slot.name, data.count)
    if not ok then return end

    local ped = GetPlayerPed(src)
    if ped == 0 then return end
    local x, y, z = table.unpack(GetEntityCoords(ped))

    local def = Config.Items[slot.name] or { label = slot.name }
    local id = newDropId()
    local drop = {
        id = id,
        item = slot.name,
        label = def.label,
        count = data.count,
        x = x, y = y, z = z - 0.95,
        expires = os.time() + DROP_TTL
    }
    _G.__drops[id] = drop
    broadcastAdd(drop)
end)

-- Sincronizar todos los drops activos cuando el jugador abre el inventario
-- (o podés llamarlo en tu flujo de playerLoaded)
AddEventHandler('playerJoining', function()
    local src = source
    TriggerClientEvent('five-inventory:drops:syncAll', src, _G.__drops or {})
end)

-- También al pedir el inventario (garantiza que el NUI tenga todo)
-- Nota: si este Trigger ya existe, solo agregá la línea de syncAll dentro.
RegisterNetEvent('five-inventory:request', function()
    local src = source
    local p = exports['fivecore']:state(src)
    if not p then return end
    normalizeInventory(p)

    -- Calcular peso total
    local totalWeight, maxWeight = 0.0, Config.MaxWeight or 25000
    for _, slot in pairs(p.inv or {}) do
        local def = Config.Items[slot.name]
        if def and def.weight then
            totalWeight = totalWeight + (def.weight * (slot.count or 1))
        end
    end

    local meta = {
        name     = GetPlayerName(src),
        job      = p.job and (Config.Jobs[p.job.name] and Config.Jobs[p.job.name].label or p.job.name) or 'Sin trabajo',
        cash     = p.money and p.money.cash or 0,
        bank     = p.money and p.money.bank or 0,
        crypto   = p.money and p.money.crypto or 0,
        weight   = totalWeight / 1000, -- kg
        maxWeight= (Config.MaxWeight or 25000) / 1000
    }

    TriggerClientEvent('five-inventory:set', src, p.inv, {}, meta)
    TriggerClientEvent('five-inventory:drops:syncAll', src, _G.__drops or {})
end)

-- Recoger un drop del suelo (PROTEGIDO)
RegisterNetEvent('five-inventory:pickup', function(payload)
    local src = source
    -- Firma del núcleo FiveCore para evitar inyección
    local ok = exports['fivecore']:guardSigned(src, 'inv:pickup', payload, function() return true end)
    if not ok then return end

    local id = tonumber(payload and payload.dropId)
    if not id then return end

    local drop = _G.__drops and _G.__drops[id]
    if not drop then return end

    -- Validar distancia (server-side)
    local ped = GetPlayerPed(src); if ped == 0 then return end
    local px, py, pz = table.unpack(GetEntityCoords(ped))
    local dist = #(vector3(px,py,pz) - vector3(drop.x, drop.y, drop.z))
    if dist > 3.0 then return end

    -- Añadir al inventario (usa stackeo + normalización)
    local added = exports['five-inventory']:addItem(src, drop.item, drop.count)
    if not added then return end

    -- Eliminar el drop y avisar a todos
    _G.__drops[id] = nil
    TriggerClientEvent('five-inventory:drops:remove', -1, id)

    -- Refrescar inventario + meta
    local p = exports['fivecore']:state(src)
    if p then
        normalizeInventory(p)
        -- recalcular peso
        local totalWeight, maxWeight = 0.0, Config.MaxWeight or 25000
        for _, slot in pairs(p.inv or {}) do
            local def = Config.Items[slot.name]
            if def and def.weight then
                totalWeight = totalWeight + (def.weight * (slot.count or 1))
            end
        end
        local meta = {
            name     = GetPlayerName(src),
            job      = p.job and (Config.Jobs[p.job.name] and Config.Jobs[p.job.name].label or p.job.name) or 'Sin trabajo',
            cash     = p.money and p.money.cash or 0,
            bank     = p.money and p.money.bank or 0,
            crypto   = p.money and p.money.crypto or 0,
            weight   = totalWeight / 1000,
            maxWeight= (Config.MaxWeight or 25000) / 1000
        }
        TriggerClientEvent('five-inventory:set', src, p.inv, {}, meta)
    end
end)
-- VEHÍCULO: enviar inventarios de guantera y baúl
RegisterNetEvent('five-inventory:vehicle:request', function()
    local src = source
    -- Aquí deberías obtener el vehículo del jugador y sus inventarios
    -- Ejemplo: glove y trunk vacíos
    local glove = {}
    local trunk = {}
    TriggerClientEvent('five-inventory:setVehicleInv', src, { glove = glove, trunk = trunk })
end)

-- VEHÍCULO: abrir/cerrar puertas
RegisterNetEvent('five-inventory:vehicle:door', function(door)
    local src = source
    TriggerClientEvent('five-inventory:vehicle:door', src, door)
end)

-- VEHÍCULO: cruise, limitador, drift
RegisterNetEvent('five-inventory:vehicle:cruise', function() TriggerClientEvent('five-inventory:vehicle:cruise', source) end)
RegisterNetEvent('five-inventory:vehicle:limiter', function() TriggerClientEvent('five-inventory:vehicle:limiter', source) end)
RegisterNetEvent('five-inventory:vehicle:drift', function() TriggerClientEvent('five-inventory:vehicle:drift', source) end)

-- CERCANOS: listar jugadores a X metros
RegisterNetEvent('five-inventory:nearby:request', function()
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        if id ~= tostring(src) then
            local tPed = GetPlayerPed(id)
            local dist = #(coords - GetEntityCoords(tPed))
            if dist <= 5.0 then
                table.insert(list, { id = tonumber(id), name = GetPlayerName(id), dist = math.floor(dist) })
            end
        end
    end
    TriggerClientEvent('five-inventory:setNearby', src, { players = list })
end)

-- CERCANOS: inventario del otro jugador (cacheo)
RegisterNetEvent('five-inventory:nearby:requestInv', function(target)
    local src = source
    local p = exports['fivecore']:state(target)
    if not p then return end
    normalizeInventory(p)
    TriggerClientEvent('five-inventory:setNearbyInv', src, { inv = p.inv })
end)

-- CERCANOS: dar ítem
RegisterNetEvent('five-inventory:nearby:giveItem', function(data)
    local src = source
    local target = tonumber(data.target)
    if not target then return end
    local ok = exports['five-inventory']:removeItem(src, data.itemName, data.count)
    if ok then
        exports['five-inventory']:addItem(target, data.itemName, data.count)
        TriggerClientEvent('five-inventory:notify', src, 'Has dado '..data.count..'x '..data.itemName)
        TriggerClientEvent('five-inventory:notify', target, 'Has recibido '..data.count..'x '..data.itemName)
    end
end)

-- CERCANOS: cachear (solo muestra inventario)
RegisterNetEvent('five-inventory:nearby:frisk', function(target)
    local src = source
    local p = exports['fivecore']:state(target)
    if not p then return end
    normalizeInventory(p)
    TriggerClientEvent('five-inventory:setNearbyInv', src, { inv = p.inv })
end)

-- ROPA: alternar prendas
RegisterNetEvent('five-inventory:clothes:toggle', function(part)
    TriggerClientEvent('five-inventory:clothes:toggle', source, part)
end)

-- UTILIDADES: Rockstar Editor y gestos
RegisterNetEvent('five-inventory:utils:editor', function()
    TriggerClientEvent('five-inventory:utils:editor', source)
end)

RegisterNetEvent('five-inventory:utils:action', function(action)
    TriggerClientEvent('five-inventory:utils:action', source, action)
end)



