CreateThread(function()
  while true do
    Wait(600000)
    for _, id in ipairs(GetPlayers()) do
      local p = exports['fivecore']:state(tonumber(id))
      if p then
        local rango = p.job
        local sueldo = Config.Rangos[rango] and Config.Rangos[rango].sueldo
        if sueldo then
          p.money.cash = (p.money.cash or 0) + sueldo
          TriggerClientEvent('chat:addMessage', id, { args = { '^2Policía', ('Sueldo recibido: $%d'):format(sueldo) } })
        end
      end
    end
  end
end)
-- Pagar multa
RegisterNetEvent('police:pagarMulta', function(monto)
  local src = source
  local p = exports['fivecore']:state(src)
  if not p then return end
  if p.money.cash >= monto then
    p.money.cash = p.money.cash - monto
    TriggerClientEvent('chat:addMessage', src, { args = { '^2Policía', ('Has pagado una multa de $%d'):format(monto) } })
  else
    TriggerClientEvent('chat:addMessage', src, { args = { '^1Policía', 'No tienes suficiente dinero para pagar la multa.' } })
  end
end)