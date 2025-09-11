exports('log', function(category, who, action, payload)
  local lic = who
  if type(who)=='number' then lic = GetPlayerIdentifierByType(who, 'license') end
  local entry = {ts=Util.now(), license=lic, category=category, action=action, payload=payload or {}}
  print(('[AUDIT] %s | %s | %s | %s'):format(category, tostring(lic), action, json.encode(payload or {})))
  TriggerEvent('fivecore-mongo:insertAudit', entry)
end)
