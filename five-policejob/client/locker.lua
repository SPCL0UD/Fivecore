RegisterCommand('lockerpolicia', function()
  local pos = GetEntityCoords(PlayerPedId())
  if #(pos - Config.Base.lockers) < 2.0 then
    local id = exports['fivecore']:state(PlayerId()).citizenid
    TriggerEvent('inventory:openLocker', 'police_' .. id)
  else
    TriggerEvent('chat:addMessage', { args = { '^1Locker', 'No estás en la zona de lockers.' } })
  end
end)
