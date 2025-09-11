local assignedTruck = nil
local routeWarnings = 0
local currentTarget = nil

RegisterNetEvent('garbage:spawnTruck', function(model, coords)
    local mhash = GetHashKey(model)
    RequestModel(mhash)
    while not HasModelLoaded(mhash) do Wait(0) end

    local veh = CreateVehicle(mhash, coords.x, coords.y, coords.z, 0.0, true, false)
    SetVehicleOnGroundProperly(veh)
    SetVehicleNumberPlateText(veh, "GARB"..math.random(100,999))
    SetVehicleEngineOn(veh, true, true, false)
    assignedTruck = veh
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
end)

RegisterNetEvent('garbage:setPoint', function(coords)
    currentTarget = coords
    SetNewWaypoint(coords.x, coords.y)
end)

RegisterNetEvent('garbage:setDump', function(coords)
    currentTarget = coords
    SetNewWaypoint(coords.x, coords.y)
end)

-- Control de ruta
CreateThread(function()
    while true do
        Wait(3000)
        if assignedTruck and currentTarget then
            local dist = #(GetEntityCoords(assignedTruck) - currentTarget)
            if dist > Config.Route.maxRouteDistance then
                routeWarnings = routeWarnings + 1
                TriggerEvent('chat:addMessage', { args = { '^3Basurero', ('Advertencia: vuelve a la ruta (%d/%d)'):format(routeWarnings, Config.Route.maxWarnings) } })
                if routeWarnings >= Config.Route.maxWarnings then
                    TriggerEvent('chat:addMessage', { args = { '^1Basurero', 'Trabajo cancelado por desviarte demasiado.' } })
                    DeleteVehicle(assignedTruck)
                    assignedTruck = nil
                end
            end
        end
    end
end)

-- Anti-VDM
CreateThread(function()
    while true do
        Wait(100)
        if assignedTruck and GetPedInVehicleSeat(assignedTruck, -1) == PlayerPedId() then
            local from = GetEntityCoords(assignedTruck)
            local to = GetOffsetFromEntityInWorldCoords(assignedTruck, 0.0, Config.AntiVDM.forwardMeters, 0.0)
            local ray = StartShapeTestCapsule(from.x, from.y, from.z + Config.AntiVDM.heightOffset, to.x, to.y, to.z + Config.AntiVDM.heightOffset, Config.AntiVDM.capsuleRadius, 10, assignedTruck, 7)
            local _, hit, _, _, ent = GetShapeTestResult(ray)
            if hit == 1 and IsEntityAPed(ent) then
                SetVehicleForwardSpeed(assignedTruck, 0.0)
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 72, true)
            end
        end
    end
end)
RegisterNetEvent('garbage:deleteTruck', function()
    if assignedTruck then
        SetEntityAsMissionEntity(assignedTruck, true, true)
        DeleteVehicle(assignedTruck)
        assignedTruck = nil
    end
end)
local function playBagAnim()
    local ped = PlayerPedId()
    local bagModel = `prop_cs_rub_binbag_01`
    RequestModel(bagModel)
    while not HasModelLoaded(bagModel) do Wait(0) end
    local bag = CreateObject(bagModel, GetEntityCoords(ped), true, true, false)
    AttachEntityToEntity(bag, ped, GetPedBoneIndex(ped, 57005), 0.15, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)

    RequestAnimDict("anim@heists@narcotics@trash")
    while not HasAnimDictLoaded("anim@heists@narcotics@trash") do Wait(0) end

    -- Cámara recogida
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, GetEntityCoords(ped) + vector3(1.5, 1.5, 1.0))
    PointCamAtEntity(cam, ped, 0.0, 0.0, 0.0, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)

    TaskPlayAnim(ped, "anim@heists@narcotics@trash", "pickup", 3.0, -1, -1, 49, 0, 0, 0, 0)
    Wait(2000)

    -- Cámara lanzamiento
    SetCamCoord(cam, GetEntityCoords(ped) + vector3(-1.5, 1.5, 1.0))
    PointCamAtEntity(cam, assignedTruck or ped, 0.0, 0.0, 0.0, true)
    TaskPlayAnim(ped, "anim@heists@narcotics@trash", "throw_b", 3.0, -1, -1, 49, 0, 0, 0, 0)
    Wait(1500)

    ClearPedTasks(ped)
    DeleteObject(bag)

    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, false)
end

local warnCooldown = 0
local activePoint = nil
local activePointBlip = nil
local drawMarker = false

-- Recibir punto activo
RegisterNetEvent('garbage:setActivePoint', function(coords, idx, total)
    activePoint = coords
    drawMarker = true

    -- Blip en mapa
    if DoesBlipExist(activePointBlip) then RemoveBlip(activePointBlip) end
    activePointBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(activePointBlip, 318) -- icono de basura
    SetBlipScale(activePointBlip, 0.8)
    SetBlipColour(activePointBlip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(("Punto de recogida (%d/%d)"):format(idx, total))
    EndTextCommandSetBlipName(activePointBlip)
    SetBlipRoute(activePointBlip, true)
    SetBlipRouteColour(activePointBlip, 5)
end
    -- Contenedor físico
    if DoesEntityExist(activeBin) then DeleteObject(activeBin) end
    local binModel = `prop_dumpster_02a`
    RequestModel(binModel)
    while not HasModelLoaded(binModel) do Wait(0) end
    activeBin = CreateObject(binModel, coords.x, coords.y, coords.z - 1.0, true, true, false)
    SetEntityHeading(activeBin, math.random(0, 360))
    FreezeEntityPosition(activeBin, true)

    -- Basura decorativa aleatoria
    local trashProps = { `prop_binbag_01`, `prop_binbag_02`, `prop_cs_cardbox_01`, `prop_cs_cardbox_02` }
    for i=1, math.random(1,3) do
        local model = trashProps[math.random(#trashProps)]
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end
        local offset = vector3(math.random(-1,1)*0.5, math.random(-1,1)*0.5, 0.0)
        local obj = CreateObject(model, coords.x+offset.x, coords.y+offset.y, coords.z-1.0, true, true, false)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
    end
end)
-- Dibujar marcador y texto flotante
CreateThread(function()
    while true do
        Wait(0)
        if drawMarker and activePoint then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local dist = #(coords - activePoint)
            if dist < 50.0 then
                DrawMarker(1, activePoint.x, activePoint.y, activePoint.z - 1.0, 0,0,0, 0,0,0, 1.0,1.0,0.5, 0,255,0,150, false,true,2,nil,nil,false)
            end
            if dist < 2.0 then
                Draw3DText(activePoint.x, activePoint.y, activePoint.z + 1.0, "~g~[E]~w~ Recoger bolsa")
                if IsControlJustPressed(0, 38) then -- E
                    playBagAnim()
                    TriggerServerEvent('garbage:bagLoaded')
                end
            end
        end
    end
end)

-- Función para texto 3D
function Draw3DText(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
-- Limpiar punto activo al terminar trabajo
RegisterNetEvent('garbage:clearPoint', function()
    activePoint = nil
    drawMarker = false
    if DoesBlipExist(activePointBlip) then
        SetBlipRoute(activePointBlip, false)
        RemoveBlip(activePointBlip)
        activePointBlip = nil
    end
end)
RegisterNetEvent('garbage:playFinishCinematic', function()
    if not assignedTruck then return end
    local truckCoords = GetEntityCoords(assignedTruck)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, truckCoords + vector3(5.0, 5.0, 3.0))
    PointCamAtEntity(cam, assignedTruck, 0.0, 0.0, 0.0, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, true)

    -- Simular descarga
    SetVehicleDoorOpen(assignedTruck, 5, false, false)
    Wait(3000)
    SetVehicleDoorShut(assignedTruck, 5, false)
    RenderScriptCams(false, true, 1000, true, true)
    DestroyCam(cam, false)
end)
