local playerGroups = {}

exports('setGroup', function(license, group)
  playerGroups[license] = group
end)

exports('getGroup', function(src)
  local license = GetPlayerIdentifierByType(src, 'license')
  return license and playerGroups[license] or Config.Permissions.defaultGroup
end)

exports('hasPerm', function(src, needed)
  local current = exports['fivecore']:getGroup(src)
  local h = Config.Permissions.hierarchy
  return (h[current] or 0) >= (h[needed] or 0)
end)
