RegisterNetEvent('police:arrestar', function(target)
  TriggerClientEvent('police:esposar', target)
end)

RegisterNetEvent('police:cachear', function(target)
  local p = exports['fivecore']:state(target)
  if not p then return end
  TriggerClientEvent('chat:addMessage', source, { args = { '^2Cacheo', json.encode(p.inventory) } })
end)

