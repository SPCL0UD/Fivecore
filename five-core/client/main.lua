local FC = { token = nil }

RegisterNetEvent('fivecore:session', function(token)
  FC.token = token
end)

exports('sign', function(payload)
  payload = payload or {}
  payload.token = FC.token
  payload.nonce = tostring(math.random(10^9, 9*10^9))..tostring(GetGameTimer())
  return payload
end)

-- Detección soft de invulnerabilidad (report)
CreateThread(function()
  while true do
    Wait(8000)
    local ped = PlayerPedId()
    if GetPlayerInvincible(PlayerId()) then
      SetEntityInvincible(ped, false)
      TriggerServerEvent('fivecore:ac:flag', exports['fivecore']:sign({type='invincible'}))
    end
  end
end)
