local VehiculosRastreados = {}
local PatrullasActivas = {}
local BodycamsActivas = {}

RegisterNetEvent('police:implantarLocalizador', function(vehNetId)
  local veh = NetworkGetEntityFromNetworkId(vehNetId)
  if not veh then return end
  local placa = GetVehicleNumberPlateText(veh)
  VehiculosRastreados[vehNetId] = { placa = placa, coords = GetEntityCoords(veh) }
end)

RegisterNetEvent('police:registrarPatrulla', function(vehNetId)
  local src = source
  local veh = NetworkGetEntityFromNetworkId(vehNetId)
  if not veh then return end
  local placa = GetVehicleNumberPlateText(veh)
  PatrullasActivas[vehNetId] = { placa = placa, coords = GetEntityCoords(veh) }
    TriggerClientEvent('police:updatePatrullas', -1, PatrullasActivas)
end)
local BodycamsActivas = {}

RegisterNetEvent('police:activarBodycam', function()
  local src = source
  BodycamsActivas[src] = true
end)

RegisterNetEvent('police:desactivarBodycam', function()
  local src = source
  BodycamsActivas[src] = nil
end)

RegisterNetEvent('police:solicitarBodycams', function()
  local src = source
  local cams = {}
  for id in pairs(BodycamsActivas) do
    local p = exports['fivecore']:state(id)
    if p then
      cams[#cams+1] = {
        nombre = p.name,
        coords = GetEntityCoords(GetPlayerPed(id))
      }
    end
  end
  TriggerClientEvent('police:actualizarBodycams', src, cams)
end)
-- Funciones de grupos y trabajos
local activeJobs = {}  -- [playerId] = { gid, members = {}, job = 'delivery', ... } etc