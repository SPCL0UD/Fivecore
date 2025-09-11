RegisterCommand('tabletpolicial', function()
  SetNuiFocus(true,true)
  SendNUIMessage({ action='abrirTablet' })
end)