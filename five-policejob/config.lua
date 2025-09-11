Config = {}

Config.Base = {
  name = "Comisaría Central",
  coords = vector3(425.1, -979.5, 30.7),
  garage = vector4(450.0, -975.0, 25.0, 90.0),
  jail = vector3(1775.0, 2590.0, 45.7),
  lockers = vector3(460.0, -990.0, 30.7),
  armory = vector3(452.0, -980.0, 30.7)
}

Config.Rangos = {
  cadete = { sueldo = 300, acceso = { 'pistol' } },
  oficial = { sueldo = 500, acceso = { 'pistol', 'taser' } },
  sargento = { sueldo = 700, acceso = { 'rifle', 'taser' } },
  teniente = { sueldo = 900, acceso = { 'rifle', 'smg', 'taser' } },
  comisario = { sueldo = 1200, acceso = { 'rifle', 'smg', 'taser', 'escopeta' } }
}

Config.Vehiculos = {
  cruiser = { label = "Patrullero", modelo = "police", rangos = { 'cadete', 'oficial', 'sargento', 'teniente', 'comisario' } },
  buffalo = { label = "Buffalo", modelo = "police2", rangos = { 'sargento', 'teniente', 'comisario' } },
  interceptor = { label = "Interceptor", modelo = "police3", rangos = { 'teniente', 'comisario' } }
}

Config.Multas = {
  exceso_velocidad = 300,
  conducción_peligrosa = 500,
  posesión_arma = 1000,
  agresión = 1500
}

Config.ItemsPolicia = {
  localizador_vehicular = true,
  bodycam = true,
  chaleco = true,
  esposas = true,
  ariete = true,
  cinturón = true
}
Config.ArmasPolicia = {
  pistol = { label = "Pistola", modelo = "weapon_pistol", ammo = 60 },
  taser = { label = "Taser", modelo = "weapon_stungun", ammo = 10 },
  rifle = { label = "Rifle", modelo = "weapon_carbinerifle", ammo = 120 },
  smg = { label = "Subfusil", modelo = "weapon_smg", ammo = 120 },
  escopeta = { label = "Escopeta", modelo = "weapon_pumpshotgun", ammo = 30 }
}
Config.Armory = {
  coords = vector3(452.0, -980.0, 30.7), -- puedes cambiar esta coordenada
  heading = 90.0,
  npcModel = 's_m_y_cop_01'
}
Config.ArmoryStash = "armory_police" -- ID del stash para la armería
Config.PermisosPolicia = {
  cadete = {
    usar = { "pistol", "bodycam", "chaleco", "esposas" }
  },
  oficial = {
    usar = { "pistol", "taser", "bodycam", "chaleco", "esposas", "ariete", "localizador_vehicular" }
  },
  sargento = {
    usar = { "rifle", "taser", "bodycam", "chaleco", "esposas", "ariete", "localizador_vehicular" }
  },
  teniente = {
    usar = { "rifle", "smg", "taser", "bodycam", "chaleco", "esposas", "ariete", "localizador_vehicular" }
  },
  comisario = {
    usar = { "rifle", "smg", "escopeta", "taser", "bodycam", "chaleco", "esposas", "ariete", "localizador_vehicular" }
  }
}
Config.LugaresInteraccion = {
  vector3(425.1, -979.5, 30.7),  -- entrada comisaría
  vector3(460.0, -990.0, 30.7),  -- taquilla
  vector3(450.0, -975.0, 25.0),  -- garage
  vector3(1775.0, 2590.0, 45.7), -- cárcel
    vector3(452.0, -980.0, 30.7)   -- armería
}