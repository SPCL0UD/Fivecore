Config = {}

-- Base: Pier de Del Perro Beach
Config.Bases = {
  { name = "Parada Pier Del Perro Beach", coords = vector3(-1616.0, -1025.0, 13.1) }
}

-- Destinos posibles para NPC (ejemplo, agrega más)
Config.DestinosNPC = {
  vector3(215.8, -810.0, 30.7),
  vector3(-537.2, -217.4, 37.6),
  vector3(1212.4, -472.0, 66.2),
  vector3(-1040.7, -2744.3, 21.4),
  vector3(-34.9, -1102.4, 26.4),
  vector3(323.5, -204.2, 54.1),
  vector3(-1535.0, -575.0, 25.7),
  vector3(-1332.7, -1162.1, 4.6)
}

-- Clientes por nivel (modelos ped)
Config.ClientesPorNivel = {
  [1] = {
    label = "Clientes comunes",
    pagoMin = 50, pagoMax = 100,
    modelos = {
      "a_m_m_business_01", "a_f_m_bevhills_01", "a_m_m_skater_01",
      "a_f_y_tourist_01", "a_m_y_beach_01", "a_f_y_bevhills_02"
    }
  },
  [2] = {
    label = "Clientes especiales",
    pagoMin = 150, pagoMax = 250,
    modelos = {
      "ig_siemonyetarian", -- Simeon
      "ig_dale",           -- David
      "ig_sol",            -- Solomon Richards
      "s_f_y_hooker_01",   -- dama de la noche
      "ig_djblamadon", "ig_djblamrupert" -- DJs
    }
  },
  [3] = {
    label = "Clientes VIP",
    pagoMin = 300, pagoMax = 500,
    modelos = {
      "ig_drdre", "ig_martinmadrazo", "ig_michael", "ig_franklin",
      "ig_lestercrest", "ig_bankman", "ig_ron", "ig_tracydisanto",
      "ig_jimmydisanto", "ig_amandadeSanta", "a_m_m_golfer_01", "a_m_y_tennis_01"
    }
  }
}

-- Niveles de taxi: vehículo, tuneo y requisitos
Config.NivelesTaxi = {
  [1] = {
    xp = 0,
    vehiculo = { modelo = "taxi", tuneo = false, color = nil }, -- taxi vanilla, sin tuneo
    clientes = 1, tarifaBase = 15, dificultad = nil
  },
  [2] = {
    xp = 100,
    vehiculo = { modelo = "jubilee", tuneo = true, color = {0,0,0} }, -- negro
    clientes = 2, tarifaBase = 20, dificultad = "paparazzi"
  },
  [3] = {
    xp = 300,
    vehiculo = { modelo = "jester4", tuneo = true, color = {0,0,0} }, -- negro
    clientes = 3, tarifaBase = 30, dificultad = "paparazzi"
  }
}

-- Ruta/anti-VDM
Config.Route = {
  maxRouteDistance = 300.0,
  maxWarnings = 3,
  warnCooldownMs = 8000
}

Config.AntiVDM = {
  capsuleRadius = 2.0,
  forwardMeters = 5.0,
  heightOffset = 1.0,
  brake = true
}

-- XP por viaje
Config.XPPerRide = 10

-- Paparazzi
Config.Paparazzi = {
  vehicle = "futo",
  ped = "a_m_m_paparazzi_01",
  spawnForward = { min = 30, max = 45 },
  spawnSide = { min = -15, max = 15 },
  distanceAggro = 10.0,
  tickDamage = 10,          -- cuanto sube la barra por tick si están cerca
  tickIntervalMs = 2000,    -- cada cuánto chequea y sube daño
  cleanupDelayMs = 30000    -- si se pierden, se borran y respawnean
}

Config.Taximetro = {
  -- Valores en dólares. Distancia en km, tiempo en minutos.
  niveles = {
    [1] = { base = 25, porKm = 35, porMin = 10, vipMul = 1.0 },
    [2] = { base = 40, porKm = 55, porMin = 15, vipMul = 1.15 }, -- Jubilee (negro, tuneado)
    [3] = { base = 60, porKm = 80, porMin = 20, vipMul = 1.30 }  -- Jester4 (negro, tuneado)
  },
  -- Propina: se suma al final como porcentaje del subtotal (base+km+min) limitado por top
  propina = {
    maxPct = 20,              -- % máximo de propina
    limpioBonusPct = 10,      -- % si daño total <= umbral
    rapidoBonusPct = 10,      -- % si tiempo <= ETA objetivo
    damageTipThreshold = 10,  -- % de daño permitido para tener “limpio”
  },
  -- Penalización por daños/acosado
  penalizacion = {
    porDamagePct = 0.8,       -- quita $ por cada 1% de daño (ej: 0.8 = $0.8 por %)
    paparazziPct = 0.5,       -- quita $ por cada 1% en barra de paparazzi
    maxPct = 60               -- tope de penalización sobre subtotal (%)
  },
  -- Estimación de tiempo objetivo: km * factorMinPorKm
  etaMinPorKm = 2.0
}

