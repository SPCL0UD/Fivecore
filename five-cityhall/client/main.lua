local npc = nil

CreateThread(function()
  local model = Config.JobCenter.npcModel
  RequestModel(model)
  while not HasModelLoaded(model) do Wait(0) end

  npc = CreatePed(4, model, Config.JobCenter.coords.x, Config.JobCenter.coords.y, Config.JobCenter.coords.z - 1.0, Config.JobCenter.heading, false, true)
  SetEntityInvincible(npc, true)
  FreezeEntityPosition(npc, true)
  TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, true)
end)

CreateThread(function()
  while true do
    Wait(0)
    local pos = GetEntityCoords(PlayerPedId())
    if #(pos - Config.JobCenter.coords) < 2.0 then
      DrawText3D(Config.JobCenter.coords + vector3(0, 0, 1.0), "[E] Ver trabajos disponibles")
      if IsControlJustReleased(0, 38) then
        SetNuiFocus(true, true)
        SendNUIMessage({ action = "open", jobs = Config.Jobs })
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
RegisterNUICallback('close', function(_, cb)
  SetNuiFocus(false, false)
  cb('ok')
end)