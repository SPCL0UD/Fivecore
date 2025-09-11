RegisterCommand('farmacia', function()
  local pos = GetEntityCoords(PlayerPedId())
  for _, f in ipairs(Config.Farmacia.ubicaciones) do
    if #(pos - f.coords) < 2.0 then
      SetNuiFocus(true,true)
      SendNUIMessage({ action='abrirFarmacia' })
      return
    end
  end
  TriggerEvent('chat:addMessage', { args = { '^1Farmacia', 'No estás en una farmacia autorizada.' } })
end)

RegisterNUICallback('buscarRecetas', function(data, cb)
  TriggerServerEvent('pharmacy:buscarRecetas', data.citizenId)
  cb('ok')
end)

RegisterNUICallback('venderMedicamento', function(data, cb)
  TriggerServerEvent('pharmacy:venderMedicamento', data.citizenId, data.item)
  cb('ok')
end)

RegisterNetEvent('pharmacy:recetasEncontradas', function(recetas)
  SendNUIMessage({ action='mostrarRecetas', recetas=recetas })
end)
