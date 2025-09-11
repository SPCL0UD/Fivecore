RegisterNetEvent('ems:bill', function(target, tipo)
  local p = exports['fivecore']:state(target)
  if not p then return end

  local precio = tipo == 'revive' and 500 or 300

  -- Verificamos que tenga suficiente dinero
  if (p.money and p.money.cash or 0) < precio then
    TriggerClientEvent('chat:addMessage', target, { args = { '^1Hospital', 'No tienes suficiente dinero para pagar el servicio médico.' } })
    return
  end

  -- Descontamos el dinero
  p.money.cash = p.money.cash - precio

  -- Confirmación al jugador
  TriggerClientEvent('chat:addMessage', target, { args = { '^2Hospital', ('Has pagado $%d por el servicio médico.'):format(precio) } })
end)
-- Facturar a un jugador (llamado desde el cliente)
-- tipo: 'revive' o 'treatment'
RegisterNetEvent('ems:bill', function(target, tipo)
  local p = exports['fivecore']:state(target)
  if not p then return end
    local precio = tipo == 'revive' and 500 or 300
    -- Verificamos que tenga suficiente dinero
    if (p.money and p.money.cash or 0) < precio then
      TriggerClientEvent('chat:addMessage', target, { args = { '^1Hospital', 'No tienes suficiente dinero para pagar el servicio médico.' } })
      return
    end
    -- Descontamos el dinero
    p.money.cash = p.money.cash - precio
    -- Confirmación al jugador

    TriggerClientEvent('chat:addMessage', target, { args = { '^2Hospital', ('Has pagado $%d por el servicio médico.'):format(precio) } })
end)
