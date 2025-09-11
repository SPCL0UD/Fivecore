local inventoryOpen = false
local lastAction = 0
local actionCooldown = 300 -- ms

-- =========================
-- Funciones helper
-- =========================
local function canAct()
    local now = GetGameTimer()
    if now - lastAction < actionCooldown then return false end
    lastAction = now
    return true
end

-- =========================
-- Abrir / cerrar inventario
-- =========================
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 37) then -- TAB
            inventoryOpen = not inventoryOpen
            SetNuiFocus(inventoryOpen, inventoryOpen)
            SendNUIMessage({ action = 'toggleInventory' })
            if inventoryOpen then
                TriggerServerEvent('five-inventory:request')
            end
        end
    end
end)

-- =========================
-- Recibir datos del inventario
-- =========================
RegisterNetEvent('five-inventory:set', function(playerItems, otherItems, meta)
    SendNUIMessage({
        action = 'setInventory',
        player = playerItems or {},
        other  = otherItems or {},
        meta   = meta or {}
    })
end)

-- =========================
-- Cerrar desde NUI
-- =========================
RegisterNUICallback('closeInventory', function(_, cb)
    inventoryOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- =========================
-- Usar ítem
-- =========================
RegisterNUICallback('useItem', function(data, cb)
    if not canAct() then cb('cooldown') return end
    if type(data) ~= 'table' or type(data.slot) ~= 'number' then cb('invalid') return end
    TriggerServerEvent('five-inventory:useItem', data)
    cb('ok')
end)

-- =========================
-- Tirar ítem
-- =========================
RegisterNUICallback('dropItem', function(data, cb)
    if not canAct() then cb('cooldown') return end
    if type(data) ~= 'table' or type(data.slot) ~= 'number' or type(data.count) ~= 'number' then cb('invalid') return end
    TriggerServerEvent('five-inventory:dropItem', data)
    cb('ok')
end)

-- =========================
-- Mover ítem
-- =========================
RegisterNUICallback('moveItem', function(data, cb)
    if not canAct() then cb('cooldown') return end
    if type(data) ~= 'table' or type(data.from) ~= 'number' or type(data.toType) ~= 'string' then cb('invalid') return end
    TriggerServerEvent('five-inventory:moveItem', data)
    cb('ok')
end)

-- =========================
-- Drops: sync y recogida
-- =========================
local Drops = {}

RegisterNetEvent('five-inventory:drops:syncAll', function(drops)
    Drops = drops or {}
end)

RegisterNetEvent('five-inventory:drops:add', function(drop)
    Drops[drop.id] = drop
end)

RegisterNetEvent('five-inventory:drops:remove', function(id)
    Drops[id] = nil
end)

-- Texto 3D simple
local function draw3DText(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Loop de proximidad y recogida (E)
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local p = GetEntityCoords(ped)

        local nearestId, nearestDist, nearest = nil, 3.0, nil
        for id, d in pairs(Drops) do
            local dist = #(p - vector3(d.x, d.y, d.z))
            if dist < 15.0 then
                DrawMarker(20, d.x, d.y, d.z+0.4, 0,0,0, 0,0,0, 0.25,0.25,0.25, 120,180,255,150, false,true,2,nil,nil,false)
            end
            if dist < nearestDist then
                nearestDist, nearestId, nearest = dist, id, d
            end
        end

        if nearest then
            draw3DText(nearest.x, nearest.y, nearest.z+0.9, ("E - Recoger %dx %s"):format(nearest.count, nearest.label or nearest.item))
            if IsControlJustPressed(0, 38) and canAct() then -- E
                local sign = exports['fivecore']:sign
                TriggerServerEvent('five-inventory:pickup', sign({ dropId = nearestId }))
            end
        end
    end
end)
-- VEHÍCULO
RegisterNUICallback('requestVehicleInv', function(_, cb)
    TriggerServerEvent('five-inventory:vehicle:request')
    cb('ok')
end)

RegisterNUICallback('vehDoor', function(data, cb)
    TriggerServerEvent('five-inventory:vehicle:door', data.door)
    cb('ok')
end)

RegisterNUICallback('vehCruise', function(_, cb)
    TriggerServerEvent('five-inventory:vehicle:cruise')
    cb('ok')
end)

RegisterNUICallback('vehLimiter', function(_, cb)
    TriggerServerEvent('five-inventory:vehicle:limiter')
    cb('ok')
end)

RegisterNUICallback('vehDrift', function(_, cb)
    TriggerServerEvent('five-inventory:vehicle:drift')
    cb('ok')
end)

-- CERCANOS
RegisterNUICallback('requestNearby', function(_, cb)
    TriggerServerEvent('five-inventory:nearby:request')
    cb('ok')
end)

RegisterNUICallback('requestNearbyInv', function(data, cb)
    TriggerServerEvent('five-inventory:nearby:requestInv', data.id)
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    TriggerServerEvent('five-inventory:nearby:giveItem', data)
    cb('ok')
end)

RegisterNUICallback('frisk', function(data, cb)
    TriggerServerEvent('five-inventory:nearby:frisk', data.target)
    cb('ok')
end)

-- ROPA
RegisterNUICallback('toggleCloth', function(data, cb)
    TriggerServerEvent('five-inventory:clothes:toggle', data.part)
    cb('ok')
end)

-- UTILIDADES
RegisterNUICallback('openEditor', function(_, cb)
    TriggerServerEvent('five-inventory:utils:editor')
    cb('ok')
end)

RegisterNUICallback('utilAction', function(data, cb)
    TriggerServerEvent('five-inventory:utils:action', data.action)
    cb('ok')
end)

-- Eventos que el server dispara para que el cliente ejecute
RegisterNetEvent('five-inventory:vehicle:door', function(door)
    -- Aquí tu lógica para abrir/cerrar puertas
end)

RegisterNetEvent('five-inventory:vehicle:cruise', function()
    -- Activar/desactivar cruise control
end)

RegisterNetEvent('five-inventory:vehicle:limiter', function()
    -- Activar/desactivar limitador
end)

RegisterNetEvent('five-inventory:vehicle:drift', function()
    -- Activar/desactivar modo drift
end)

RegisterNetEvent('five-inventory:clothes:toggle', function(part)
    -- Alternar prenda en el ped local
end)

RegisterNetEvent('five-inventory:utils:editor', function()
    -- Abrir Rockstar Editor
end)

RegisterNetEvent('five-inventory:utils:action', function(action)
    -- Ejecutar animación/gesto según action
end)



