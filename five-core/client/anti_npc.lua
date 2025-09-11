CreateThread(function()
  while true do
    Wait(Config.AntiNPCCleanupMs)
    local handle, ped = FindFirstPed()
    local success
    repeat
      if DoesEntityExist(ped) and IsPedDeadOrDying(ped) then
        RemoveAllPedWeapons(ped, true)
      end
      success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
  end
end)
