local allow = {
  ['fivecore-inventory:move']=true,
  ['fivecore-weapons:buy']=true,
  ['fivecore-jobs:complete']=true,
  ['fivecore-weapons:reportLoadout']=true,
  ['fivecore:ac:flag']=true,
}

AddEventHandler('__cfx_internal:serverEventReceived', function(name, src, payload)
  if not allow[name] then CancelEvent() end
end)

exports('guard', function(src, rateKey, extraCheck)
  if type(src)~='number' or src<=0 or not DoesPlayerExist(src) then return false,'src' end
  if not exports['fivecore']:check(src, rateKey) then return false,'rate' end
  if extraCheck and not extraCheck() then return false,'check' end
  return true
end)

exports('guardSigned', function(src, rateKey, payload, extraCheck)
  if type(src)~='number' or src<=0 or not DoesPlayerExist(src) then return false,'src' end
  if not exports['fivecore']:check(src, rateKey) then return false,'rate' end
  if not payload or not exports['fivecore']:consume(src, payload.nonce) then return false,'nonce' end
  local tok = exports['fivecore']:sessionToken(src)
  if not tok or payload.token ~= tok then return false,'token' end
  if extraCheck and not extraCheck() then return false,'check' end
  return true
end)
