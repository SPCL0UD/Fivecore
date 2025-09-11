local buckets = {}

exports('check', function(src, key)
  local r = Config.RateRules[key]; if not r then return true end
  local p = buckets[src] or {}; buckets[src] = p
  local b = p[key] or {tokens=r.cap, last=Util.now()}; p[key]=b
  local elapsed = Util.now() - b.last
  if elapsed >= r.window then
    local steps = math.floor(elapsed / r.window)
    b.tokens = math.min(r.cap, b.tokens + steps * r.refill)
    b.last = Util.now()
  end
  if b.tokens <= 0 then return false end
  b.tokens = b.tokens - 1
  return true
end)
