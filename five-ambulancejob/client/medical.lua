local vitals = { hr=80, bp=120, spo2=98, resp=16, pain=0, hp=100 }

RegisterNetEvent('ems:clientRevive', function()
  local p = PlayerPedId()
  NetworkResurrectLocalPlayer(GetEntityCoords(p), GetEntityHeading(p), true, true, false)
  SetEntityHealth(p, 125)
  vitals.hp = 60
  vitals.hr = 90
  vitals.spo2 = 96
  SendNUIMessage({ action='monitor:update', vitals=vitals })
end)

RegisterNetEvent('ems:clientApplyTreatment', function(t)
  if t.type == 'bandage' then
    exports['progressbar']:Progress({label='Vendando...', duration=4000})
    vitals.spo2 = math.min(100, vitals.spo2 + 3)
    vitals.pain = math.max(0, vitals.pain - 10)
  elseif t.type == 'tourniquet' then
    exports['progressbar']:Progress({label='Aplicando torniquete...', duration=3500})
    vitals.spo2 = math.min(100, vitals.spo2 + 6)
  elseif t.type == 'morphine' then
    exports['progressbar']:Progress({label='Inyectando morfina...', duration=3000})
    vitals.pain = math.max(0, vitals.pain - 40)
    vitals.resp = math.max(8, vitals.resp - 2)
  end
  SendNUIMessage({ action='monitor:update', vitals=vitals })
end)

RegisterCommand('ems_bandage', function()
  local t = lib.getClosestPlayer(2.0)
  if t then TriggerServerEvent('ems:applyTreatment', GetPlayerServerId(t), { type='bandage' }) end
end)

RegisterCommand('ems_tourniquet', function()
  local t = lib.getClosestPlayer(2.0)
  if t then TriggerServerEvent('ems:applyTreatment', GetPlayerServerId(t), { type='tourniquet' }) end
end)

RegisterCommand('ems_morphine', function()
  local t = lib.getClosestPlayer(2.0)
  if t then TriggerServerEvent('ems:applyTreatment', GetPlayerServerId(t), { type='morphine' }) end
end)
RegisterCommand('ems_defib', function()
  local t = lib.getClosestPlayer(2.0)
  if t then TriggerServerEvent('ems:revive', GetPlayerServerId(t)) end
end)