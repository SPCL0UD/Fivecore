local armoryNPC = nil
local nearArmory = false

CreateThread(function()
  local model = Config.Armory.npcModel
  RequestModel(model)
  while not HasModelLoaded(model) do Wait(0) end

  armoryNPC = CreatePed(4, model, Config.Armory.coords.x, Config.Armory.coords.y, Config.Armory.coords.z - 1.0, Config.Armory.heading, false, true)
  SetEntityInvincible(armoryNPC, true)
  FreezeEntityPosition(armoryNPC, true)
  TaskStartScenarioInPlace(armoryNPC, "WORLD_HUMAN_GUARD_STAND", 0, true)
end)

CreateThread(function()
  while true do
    Wait(500)
    local pos = GetEntityCoords(PlayerPedId())
    nearArmory = #(pos - Config.Armory.coords) < 2.0
  end
end)

CreateThread(function()
  while true do
    Wait(0)
    if nearArmory then
      DrawText3D(Config.Armory.coords + vector3(0, 0, 1.0), "[E] Abrir armería")
      if IsControlJustReleased(0, 38) then -- Tecla E
        TriggerServerEvent('police:abrirArmeria')
      end
    end
  end
end)

function DrawText3D(coords, text)
  local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(true)
  AddTextComponentString(text)
  DrawText(x, y)
end
-- Abrir stash de la armería
RegisterNetEvent('police:abrirStashArmeria', function()
  TriggerEvent('inventory:openStash', Config.ArmoryStash, {
    maxweight = 200000,
    slots = 50,
    label = "Armería Policía"
  })
end)
