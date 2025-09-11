RegisterNUICallback('searchRecords', function(data, cb)
  TriggerServerEvent('ems:requestRecords', data.id)
  cb('ok')
end)

RegisterNetEvent('ems:receiveRecords', function(records)
  SendNUIMessage({ action='records:show', records=records })
end)
