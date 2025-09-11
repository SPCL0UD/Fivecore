local Recetas = {} -- [citizenId] = { {item, cantidad, medico, fecha} }

RegisterNetEvent('ems:emitirReceta', function(targetId, item, cantidad)
  local src = source
  local medico = GetPlayerName(src)
  local pTarget = exports['fivecore']:state(targetId)
  if not pTarget then return end
  local cid = pTarget.citizenid
  Recetas[cid] = Recetas[cid] or {}
  table.insert(Recetas[cid], {
    item = item,
    cantidad = cantidad,
    medico = medico,
    fecha = os.date("%d/%m/%Y %H:%M")
  })
  TriggerClientEvent('chat:addMessage', targetId, { args = { '^2Receta', ('%dx %s recetado por Dr. %s'):format(cantidad, item, medico) } })
end)

RegisterNetEvent('pharmacy:buscarRecetas', function(citizenId)
  local src = source
  local recetas = Recetas[citizenId] or {}
  TriggerClientEvent('pharmacy:recetasEncontradas', src, recetas)
end)

RegisterNetEvent('pharmacy:venderMedicamento', function(citizenId, item)
  local src = source
  local pTarget = exports['fivecore']:stateByCitizenId(citizenId)
  local pPharma = exports['fivecore']:state(src)
  if not pTarget or not pPharma then return end

  local recetas = Recetas[citizenId] or {}
  local recetaValida = false
  for _, r in ipairs(recetas) do
    if r.item == item and r.cantidad > 0 then
      recetaValida = true
      r.cantidad = r.cantidad - 1
      break
    end
  end

  if not recetaValida then
    TriggerClientEvent('chat:addMessage', src, { args = { '^1Farmacia', 'No hay receta válida para este medicamento.' } })
    return
  end

  local precio = Config.Farmacia.precios[item] or 100
  if pTarget.money.cash < precio then
    TriggerClientEvent('chat:addMessage', src, { args = { '^1Farmacia', 'El paciente no tiene suficiente dinero.' } })
    return
  end

  pTarget.money.cash = pTarget.money.cash - precio
  pPharma.money.cash = pPharma.money.cash + precio

  table.insert(pTarget.inventory, { name = item, count = 1 })

  TriggerClientEvent('chat:addMessage', src, { args = { '^2Farmacia', ('%s vendido por $%d'):format(item, precio) } })
end)
