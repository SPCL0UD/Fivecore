RegisterNetEvent('police:abrirArmeria', function()
  local src = source
  local p = exports['fivecore']:state(src)
  if not p then return end
  local stashId = "armory_" .. p.job
  TriggerClientEvent('inventory:openStash', src, stashId)
end)
