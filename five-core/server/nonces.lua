local seen = {}

local function rememberLocal(license, nonce)
  local k = license..':'..nonce
  if seen[k] then return false end
  seen[k] = true
  SetTimeout(5*60*1000, function() seen[k]=nil end)
  return true
end

exports('consume', function(src, nonce)
  if not nonce or #tostring(nonce) < 10 then return false end
  local license = GetPlayerIdentifierByType(src, 'license'); if not license then return false end
  if not rememberLocal(license, nonce) then return false end
  TriggerEvent('fivecore-mongo:insertNonce', {license=license, nonce=nonce, ts=Util.now()})
  return true
end)
