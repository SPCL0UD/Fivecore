Config = {
  SnapshotIntervalSec = 120,
  AntiNPCCleanupMs = 750,

  Accounts = {
    cash   = { label = "Efectivo",      round = true,  visible = true,  default = 0 },
    bank   = { label = "Banco",         round = true,  visible = true,  default = 500 },
    crypto = { label = "Criptomoneda",  round = false, visible = true,  default = 0.0 },
  },

  Permissions = {
    groups = { 'god', 'admin', 'mod', 'leo', 'ems', 'user' },
    defaultGroup = 'user',
    hierarchy = { god=5, admin=4, mod=3, leo=2, ems=2, user=1 }
  },

  RateRules = {
    ['inv:move']     = {cap=10, refill=10, window=10},
    ['shop:buy']     = {cap=3,  refill=3,  window=10},
    ['job:complete'] = {cap=5,  refill=5,  window=60},
    ['wep:report']   = {cap=6,  refill=6,  window=60},
    ['ac:flag']      = {cap=10, refill=10, window=60},
  },

  Items = {
    Items["localizador_vehicular"] = {
  label = "Chip de Localización",
  description = "Dispositivo GPS oculto para rastrear vehículos sospechosos.",
  weight = 1,
  stackable = true,
  usable = false
 },

 Items["bodycam"] = {
  label = "Bodycam Policial",
  description = "Cámara corporal para transmisión en tiempo real.",
  weight = 1,
  stackable = false,
  usable = false
 },

 Items["camara_policial"] = {
  label = "Cámara Policial",
  description = "Dispositivo para capturar fotos de sospechosos.",
  weight = 1,
  stackable = false,
  usable = false
 },

 Items["chaleco"] = {
  label = "Chaleco de Kevlar",
  description = "Protección balística para oficiales.",
  weight = 2,
  stackable = false,
  usable = true
 },

 Items["esposas"] = {
  label = "Esposas",
  description = "Restringe el movimiento de un sospechoso.",
  weight = 1,
  stackable = true,
  usable = true
 },

 Items["ariete"] = {
  label = "Ariete",
  description = "Herramienta para abrir puertas durante allanamientos.",
  weight = 3,
  stackable = false,
  usable = true
 },

 Items["cinturon_policia"] = {
  label = "Cinturón Policial",
  description = "Equipamiento táctico con funda y accesorios.",
  weight = 1,
  stackable = false,
  usable = false
 },
    ['bread']         = { label='Pan', stack=true,  weight=100 },
    ['water']         = { label='Agua', stack=true, weight=100 },
    ['phone']         = { label='Teléfono', stack=false, weight=300 },
    ['bandage']       = { label='Venda', stack=true, weight=50 },
    ['weapon_pistol'] = { label='Pistola', stack=false, weight=1500, weapon=true },
    ['weapon_knife']  = { label='Cuchillo', stack=false, weight=500, weapon=true },
  },

  WeaponCatalog = {
    pistol = { item='weapon_pistol', label='Pistola', price=10000, shop=vector3(22.0, -1105.0, 29.8) }
  }
},

Config.Jobs = {
    unemployed = {
        label = "Desempleado",
        type = "none",
        defaultDuty = false,
        grades = {
            [0] = { name = "Sin trabajo", payment = 0 }
        }
    },
    police = {
        label = "Policía",
        type = "leo",
        defaultDuty = true,
        grades = {
            [0] = { name = "Cadete", payment = 500 },
            [1] = { name = "Oficial", payment = 800 },
            [2] = { name = "Sargento", payment = 1200 },
            [3] = { name = "Teniente", payment = 1600 },
            [4] = { name = "Comisario", payment = 2000 }
        }
    },
    ambulance = {
        label = "EMS",
        type = "ems",
        defaultDuty = true,
        grades = {
            [0] = { name = "Paramédico", payment = 500 },
            [1] = { name = "Médico", payment = 900 },
            [2] = { name = "Jefe Médico", payment = 1500 }
        }
    },
    mechanic = {
        label = "Mecánico",
        type = "mechanic",
        defaultDuty = true,
        grades = {
            [0] = { name = "Aprendiz", payment = 400 },
            [1] = { name = "Oficial", payment = 700 },
            [2] = { name = "Jefe de Taller", payment = 1100 }
        }
    }
}

