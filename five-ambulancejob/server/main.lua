RegisterNetEvent('ems:revive', function(target)
  TriggerClientEvent('ems:clientRevive', target)
end)

RegisterNetEvent('ems:applyTreatment', function(target, treatment)
  TriggerClientEvent('ems:clientApplyTreatment', target, treatment)
end)
RegisterNetEvent('ems:revive', function(target)
  TriggerClientEvent('ems:clientRevive', target)
  local p = exports['fivecore']:state(target)
  if p then
    p.medicXP = (p.medicXP or 0) + 10
  end
end)

RegisterNetEvent('ems:applyTreatment', function(target, treatment)
  TriggerClientEvent('ems:clientApplyTreatment', target, treatment)
  local p = exports['fivecore']:state(target)
  if p then
    p.medicXP = (p.medicXP or 0) + 5
  end
end)
-- Registrar muerte
RegisterNetEvent('ems:registerDeath', function(citizenId, reason)
  local src = source
  local p = exports['fivecore']:state(src)
  if not p then return end
  p.deaths = p.deaths or {}
  table.insert(p.deaths, { reason = reason, date = os.date("%d/%m/%Y %H:%M") })
  if #p.deaths > 10 then table.remove(p.deaths, 1) end -- mantener solo las últimas 10
end)