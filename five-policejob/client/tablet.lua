RegisterNUICallback('registrarSospechoso', function(data, cb)
  TriggerServerEvent('police:registrarSospechoso', data.name, data.id)
  cb('ok')
end)

RegisterNUICallback('capturarFoto', function(_, cb)
  if exports['fivecore']:hasItem('camara_policial') then
    exports['screenshot']:take(function(url)
      TriggerServerEvent('police:guardarFotoSospechoso', url)
    end)
  else
    TriggerEvent('chat:addMessage', { args = { '^1Error', 'No tienes una cámara policial.' } })
  end
  cb('ok')
end)


RegisterNUICallback('contratarPolicia', function(data, cb)
  TriggerServerEvent('police:contratarCadete', data.name, data.id)
  cb('ok')
end)
-- Tablet: abrir/cerrar
local uiOpen = false
