RegisterNetEvent('jobcenter:setJob', function(job)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return end

  Player.Functions.SetJob(job, 0)
  TriggerClientEvent('QBCore:Notify', src, "Has sido contratado como " .. job, "success")
end)
