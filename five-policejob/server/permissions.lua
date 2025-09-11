function PuedeUsarItem(playerId, item)
  local p = exports['fivecore']:state(playerId)
  if not p then return false end
  local rango = p.job
  local permisos = Config.PermisosPolicia[rango]
  if not permisos then return false end
  for _, permitido in ipairs(permisos.usar) do
    if permitido == item then return true end
  end
  return false
end

exports('PuedeUsarItem', PuedeUsarItem)
function PuedeAccederStash(playerId, stashId)
  local p = exports['fivecore']:state(playerId)
  if not p then return false end
  local rango = p.job
  local permisos = Config.PermisosPolicia[rango]
  if not permisos then return false end
  for _, permitido in ipairs(permisos.stash) do
    if permitido == stashId then return true end
  end
  return false
end