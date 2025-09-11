CreateThread(function()
  while true do
    Wait(600000) -- cada 10 minutos
    for _, id in ipairs(GetPlayers()) do
      local p = exports['fivecore']:state(tonumber(id))
      if p then
        local job = p.job
        local pay = Config.Salary[job]
        if pay then
          p.money.cash = (p.money.cash or 0) + pay
          TriggerClientEvent('chat:addMessage', id, { args = { '^2EMS', ('Sueldo recibido: $%d'):format(pay) } })
        end
      end
    end
  end
end)
-- Pagar a todos los miembros al finalizar ruta
RegisterNetEvent('ems:payAll', function(share)
  local src = source
  local job = activeRoutes[src]
  if not job then return end
  for _, pid in ipairs(job.members) do
    local p = exports['fivecore']:state(pid)
    if p then
      p.money.cash = (p.money.cash or 0) + math.floor(job.route.pay * share)
      p.emsXP = (p.emsXP or 0) + math.floor(job.route.xp * share)
      TriggerClientEvent('ems:jobFinished', pid, { pay = math.floor(job.route.pay * share), xp = p.emsXP })
      activeRoutes[pid] = nil
    end
  end
end)