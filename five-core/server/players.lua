local players = {}
local DATA_DIR = ('%s/data/players/'):format(GetResourcePath(GetCurrentResourceName()))

local function ensureDir()
  -- normalmente ya existe, pero por si acaso
end

local function loadSnapshot(license)
  local f = io.open(DATA_DIR..license..'.json', 'r')
  if not f then return {} end
  local txt = f:read('*a'); f:close()
  local ok, data = pcall(json.decode, txt)
  return ok and data or {}
end

local function saveSnapshot(license, data)
  local path = DATA_DIR..license..'.json'
  local f = assert(io.open(path, 'w'))
  f:write(json.encode(data)); f:close()
  TriggerEvent('fivecore-mongo:insertPlayerSnapshot', {license=license, data=data, ts=Util.now()})
end

local function newToken()
  return ('%08x%08x'):format(math.random(0,0xffffffff), math.random(0,0xffffffff))
end

local function scheduleAutosave(src)
  local p = players[src]; if not p then return end
  SetTimeout(Config.SnapshotIntervalSec*1000, function()
    local q = players[src]
    if q then
      saveSnapshot(q.license, {money=q.money, inv=q.inv, job=q.job})
      scheduleAutosave(src)
    end
  end)
end

AddEventHandler('playerConnecting', function(name, setKick, def)
  def.defer()
  local src = source
  local license = GetPlayerIdentifierByType(src, 'license')
  if not license then def.done('No license'); return end

  local finished = false
  TriggerEvent('fivecore-mongo:isBanned', license, function(isBanned, reason)
    if isBanned then def.done('Baneado: '..(reason or '')) return end
    local data = loadSnapshot(license)
   players[src] = {
    license = license,
    token = newToken(),
    money = {},
    inv = data.inv or {},
    job = data.job or { name = 'unemployed', grade = 0, duty = Config.Jobs['unemployed'].defaultDuty }
    }

-- Inicializar cuentas
   for acc, cfg in pairs(Config.Accounts) do
    players[src].money[acc] = data.money and data.money[acc] or cfg.default or 0
    end
    TriggerClientEvent('fivecore:session', src, players[src].token)
    scheduleAutosave(src)
    finished = true
    def.done()
  end)

  SetTimeout(5000, function() if not finished then def.done() end end)
end)

AddEventHandler('playerDropped', function()
  local src = source
  local p = players[src]; if not p then return end
  saveSnapshot(p.license, {money=p.money, inv=p.inv, job=p.job})
  players[src] = nil
end)

-- Exports del core
exports('state', function(src) return players[src] end)
exports('saveNow', function(src)
  local p = players[src]; if not p then return end
  saveSnapshot(p.license, {money=p.money, inv=p.inv, job=p.job})
end)
exports('sessionToken', function(src)
  local p = players[src]; return p and p.token or nil
end)
exports('rotateToken', function(src)
  local p = players[src]; if not p then return nil end
  p.token = newToken()
  TriggerClientEvent('fivecore:session', src, p.token)
  return p.token
end)
