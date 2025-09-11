RegisterNUICallback('close', function(_, cb)
  SetNuiFocus(false, false)
  cb('ok')
end)

RegisterNUICallback('selectJob', function(data, cb)
  TriggerServerEvent('jobcenter:setJob', data.id)
  SetNuiFocus(false, false)
  cb('ok')
end)
-- NUI: abrir/cerrar
local uiOpen = false

