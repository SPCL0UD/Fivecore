RegisterNetEvent('police:911', function(coords, mensaje)
  TriggerClientEvent('police:despacho', -1, { coords = coords, mensaje = mensaje })
end)
-- Avisar a todos los policías conectados
RegisterNetEvent('police:alertDispatch', function(mensaje)
  TriggerClientEvent('police:despacho', -1, { coords = nil, mensaje = mensaje })
end)