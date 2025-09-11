local ropaCivil = nil

RegisterCommand('entrarservicio', function()
  ropaCivil = exports['fivecore']:getAppearance(PlayerId())
  exports['fivecore']:setAppearance(PlayerId(), {
    torso = 55, undershirt = 58, pants = 35, shoes = 25
  })
  TriggerEvent('chat:addMessage', { args = { '^2Servicio', 'Has entrado en servicio.' } })
end)

RegisterCommand('salirservicio', function()
  if ropaCivil then
    exports['fivecore']:setAppearance(PlayerId(), ropaCivil)
    ropaCivil = nil
    TriggerEvent('chat:addMessage', { args = { '^2Servicio', 'Has salido de servicio.' } })
  end
end)
-- Alternar uniforme
RegisterCommand('uniforme', function()
    if ropaCivil then
        exports['fivecore']:setAppearance(PlayerId(), ropaCivil)
        ropaCivil = nil
        TriggerEvent('chat:addMessage', { args = { '^2Servicio', 'Has salido de servicio.' } })
    else
        ropaCivil = exports['fivecore']:getAppearance(PlayerId())
        exports['fivecore']:setAppearance(PlayerId(), {
        torso = 55, undershirt = 58, pants = 35, shoes = 25
        })
        TriggerEvent('chat:addMessage', { args = { '^2Servicio', 'Has entrado en servicio.' } })
    end
end)

