local FichasSospechosos = {}

RegisterNetEvent('police:registrarSospechoso', function(name, id)
  FichasSospechosos[id] = FichasSospechosos[id] or { nombre = name, delitos = {}, foto = nil }
end)

RegisterNetEvent('police:guardarFotoSospechoso', function(url)
  local src = source
  local p = exports['fivecore']:state(src)
  if p then
    local id = p.lastSospechosoID
    if FichasSospechosos[id] then
      FichasSospechosos[id].foto = url
    end
  end
end)

RegisterNetEvent('police:contratarCadete', function(name, id)
  local p = exports['fivecore']:stateByCitizenId(id)
  if p then
    p.job = 'cadete'
    TriggerClientEvent('chat:addMessage', source, { args = { '^2Contratación', name .. ' ha sido contratado como cadete.' } })
  end
end)
-- Obtener ficha de sospechoso
RegisterNetEvent('police:getFichaSospechoso', function(id, cb)
  cb(FichasSospechosos[id])
end)