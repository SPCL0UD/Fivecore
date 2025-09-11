local lastRastreo = {}
local lastPatrullas = {}
local lastBodycams = {}

-- Actualización periódica del mapa
CreateThread(function()
    while true do
        Wait(5000) -- cada 5 segundos
        TriggerServerEvent('police:solicitarRastreo')
        TriggerServerEvent('police:solicitarPatrullas')
        TriggerServerEvent('police:solicitarBodycams')
    end
end)

-- Recibe vehículos rastreados con chip
RegisterNetEvent('police:actualizarRastreo', function(data)
    lastRastreo = data or {}
    actualizarMapaTablet()
end)

-- Recibe patrullas activas
RegisterNetEvent('police:actualizarPatrullas', function(data)
    lastPatrullas = data or {}
    actualizarMapaTablet()
end)

-- Recibe bodycams activas
RegisterNetEvent('police:actualizarBodycams', function(data)
    lastBodycams = data or {}
    actualizarMapaTablet()
end)

-- Enviar datos al NUI
function actualizarMapaTablet()
    SendNUIMessage({
        action = 'tablet:mapUpdate',
        rastreados = lastRastreo,
        patrullas = lastPatrullas,
        bodycams = lastBodycams
    })
end

-- Comando para implantar chip localizador en vehículo
RegisterCommand('implantar_localizador', function()
    local veh = GetVehicleInDirection()
    if veh and exports['fivecore']:hasItem('localizador_vehicular') then
        local netId = NetworkGetNetworkIdFromEntity(veh)
        TriggerServerEvent('police:implantarLocalizador', netId)
        TriggerEvent('chat:addMessage', { args = { '^2Policía', 'Localizador implantado en el vehículo.' } })
    else
        TriggerEvent('chat:addMessage', { args = { '^1Error', 'No tienes el ítem o no hay vehículo frente a ti.' } })
    end
end)

local bodycamActiva = false

CreateThread(function()
  while true do
    Wait(5000)
    local tieneBodycam = exports['fivecore']:hasItem('bodycam')
    if tieneBodycam and not bodycamActiva then
      TriggerServerEvent('police:activarBodycam')
      bodycamActiva = true
    elseif not tieneBodycam and bodycamActiva then
      TriggerServerEvent('police:desactivarBodycam')
      bodycamActiva = false
    end
  end
end)


-- Utilidad: detectar vehículo frente al jugador
function GetVehicleInDirection()
    local p = PlayerPedId()
    local coords = GetEntityCoords(p)
    local fwd = GetOffsetFromEntityInWorldCoords(p, 0.0, 3.0, 0.0)
    local ray = StartShapeTestRay(coords.x, coords.y, coords.z, fwd.x, fwd.y, fwd.z, 10, p, 0)
    local _, hit, _, _, veh = GetShapeTestResult(ray)
    return hit == 1 and veh or nil
end
