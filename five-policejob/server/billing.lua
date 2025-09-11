RegisterNetEvent('police:multar', function(target, tipo)
  local p = exports['fivecore']:state(target)
  if not p then return end
  local monto = Config.Multas[tipo] or 500
  if p.money.cash >= monto then
    p.money.cash = p.money.cash - monto
    TriggerClientEvent('chat:addMessage', target, { args = { '^1Multa', ('Has sido multado con $%d'):format(monto) } })
  else
    TriggerClientEvent('chat:addMessage', source, { args = { '^1Multa', 'El ciudadano no tiene suficiente dinero.' } })
  end
end)
