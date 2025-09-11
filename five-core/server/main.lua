-- Rotación periódica de tokens de sesión
CreateThread(function()
  while true do
    Wait(15*60*1000)
    for _, id in ipairs(GetPlayers()) do
      exports['fivecore']:rotateToken(tonumber(id))
    end
  end
end)
