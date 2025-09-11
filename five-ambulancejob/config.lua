Config = {}

Config.Bases = {
  {
    name = "Central Pillbox",
    garage = vector4(338.8, -571.0, 28.8, 160.0),
    er = vector3(309.9, -594.3, 43.3),
    heli = vector4(351.4, -587.1, 74.1, 70.0)
  }
}

Config.Vehicles = {
  ambulance = { model = 'ambulance', roles = {'emt','doctor'} },
  heli = { model = 'polmav', roles = {'doctor'} }
}

Config.Items = {
  bandage = { uses = 1, heal = {bleeding=1} },
  tourniquet = { uses = 1, heal = {bleeding=2} },
  morphine = { uses = 1, effects = {pain=-40, hr=+5, bp=-5} },
  epinephrine = { uses = 1, effects = {hr=+15, bp=+10} },
  defib = { uses = 1, revive = true }
}

Config.Vitals = {
  normal = { hr= {60,95}, bp = {110,140}, resp = {12,20}, spo2 = {96,100} },
  shock  = { hr= {110,160}, bp = {80,100}, resp = {18,30}, spo2 = {85,95} }
}

Config.Ranks = {
  emt = { label="Paramédico", perms={'basic'} },
  doctor = { label="Médico", perms={'advanced','surgery'} },
  farmaceutico = { label="Farmacéutico", perms={'pharmacy'} }
}

Config.Farmacia = {
  ubicaciones = {
    { name = "Farmacia Central", coords = vector3(312.5, -592.3, 43.3) }
  },
  precios = {
    bandage = 50,
    tourniquet = 100,
    morphine = 250,
    epinephrine = 300,
    defib = 500
  }
}

Config.Salary = {
  emt = 300,
  doctor = 600,
  farmaceutico = 250
}
