local locks = {}

exports('withLock', function(key, fn)
  while locks[key] do Wait(0) end
  locks[key] = true
  local ok, err = pcall(fn)
  locks[key] = nil
  return ok, err
end)
