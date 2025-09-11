Config = {}

Config.TruckerHubs = {
    {
        name = "Depósito Los Santos",
        type = "legal",
        coords = vector3(1200.0, -3250.0, 5.0),
        levels = {
            [1] = { xp = 0,   cargos = { 'paquete_peq', 'caja_ligera' } },
            [2] = { xp = 100, cargos = { 'caja_mediana', 'palet' } },
            [3] = { xp = 300, cargos = { 'contenedor', 'carga_pesada' } },
            [4] = { xp = 600, cargos = { 'mega_carga' } }
        }
    },
    {
        name = "Puerto de Paleto",
        type = "legal",
        coords = vector3(-200.0, 6200.0, 31.0),
        levels = {
            [1] = { xp = 0,   cargos = { 'paquete_peq', 'caja_ligera' } },
            [2] = { xp = 150, cargos = { 'caja_mediana', 'palet' } },
            [3] = { xp = 400, cargos = { 'contenedor', 'carga_pesada' } },
            [4] = { xp = 800, cargos = { 'mega_carga' } }
        }
    },
    {
        name = "Almacén Ilegal Sandy",
        type = "ilegal",
        coords = vector3(1500.0, 3500.0, 35.0),
        mafiaOnly = true,
        levels = {
            [1] = { xp = 0,   cargos = { 'droga_peq', 'armas_ligeras' } },
            [2] = { xp = 200, cargos = { 'droga_grande', 'armas_pesadas' } },
            [3] = { xp = 500, cargos = { 'carga_cartel' } }
        }
    }
}

Config.CargosLegal = {
    paquete_peq   = { label = 'Paquete pequeño', pay = 200, xp = 10, rent = 50, loadTime = 5 },
    caja_ligera   = { label = 'Caja ligera', pay = 300, xp = 15, rent = 75, loadTime = 7 },
    caja_mediana  = { label = 'Caja mediana', pay = 500, xp = 25, rent = 100, loadTime = 10 },
    palet         = { label = 'Palet', pay = 800, xp = 40, rent = 150, loadTime = 15 },
    contenedor    = { label = 'Contenedor', pay = 1200, xp = 60, rent = 200, loadTime = 20 },
    carga_pesada  = { label = 'Carga pesada', pay = 2000, xp = 100, rent = 300, loadTime = 30 },
    mega_carga    = { label = 'Mega carga', pay = 3500, xp = 200, rent = 500, loadTime = 40 }
}

Config.CargosIlegal = {
    droga_peq     = { label = 'Droga pequeña', pay = 500, xp = 20, rent = 100, loadTime = 5 },
    armas_ligeras = { label = 'Armas ligeras', pay = 1000, xp = 40, rent = 150, loadTime = 10 },
    droga_grande  = { label = 'Droga grande', pay = 2000, xp = 80, rent = 200, loadTime = 15 },
    armas_pesadas = { label = 'Armas pesadas', pay = 4000, xp = 150, rent = 300, loadTime = 20 },
    carga_cartel  = { label = 'Carga del cartel', pay = 8000, xp = 300, rent = 500, loadTime = 30 }
}

Config.MafiaJobs = { 'mafia', 'cartel', 'banda' }
Config.RequiredLicense = "driver_license"

Config.Destinos = {
  -- legales
  paquete_peq   = vector3(-47.0, -1757.0, 29.4),
  caja_ligera   = vector3(25.7, -1347.3, 29.5),
  caja_mediana  = vector3(374.2, 327.8, 103.6),
  palet         = vector3(1163.4, -323.8, 69.2),
  contenedor    = vector3(-1222.9, -907.2, 12.3),
  carga_pesada  = vector3(-1487.6, -379.1, 40.2),
  mega_carga    = vector3(2557.2, 382.2, 108.6),
  -- ilegales
  droga_peq     = vector3(1391.9, 3607.5, 34.9),
  armas_ligeras = vector3(1542.4, 6326.0, 23.1),
  droga_grande  = vector3(1973.9, 3819.6, 33.5),
  armas_pesadas = vector3(1742.3, 3327.1, 41.2),
  carga_cartel  = vector3(1408.0, 1138.0, 114.3),
}

-- Parámetros de carga
Config.Load = {
  ticksRequired = 10,      -- cuántos “viajes” hay que hacer para completar la carga
  groupBonus    = 0.15,    -- bonus de progreso por miembro adicional (15% c/u)
  tickTimeout   = 3500,    -- ms entre ticks recomendados (evita spam)
  maxDistance   = 50.0     -- validación de distancia zona de carga/entrega
}
Config.TruckModelsByLevel = {
  [1] = 'mule3',
  [2] = 'mule4',
  [3] = 'pounder',
  [4] = 'pounder2'
}

-- Modelo opcional por carga (sobre-escribe el del nivel si existe)
Config.TruckModelByCargo = {
  -- ['paquete_peq'] = 'mule',
  -- ['carga_cartel'] = 'pounder2',
}

Config.Route = {
  maxRouteDistance = 550.0,  -- si supera esta distancia del punto objetivo, cuenta advertencia
  maxWarnings = 3,
  warnCooldownMs = 8000      -- mínimo entre advertencias
}

Config.AntiVDM = {
  capsuleRadius = 2.2,
  forwardMeters = 6.0,
  heightOffset = 1.0,
  brake = true,              -- frenar en seco
  limitSpeed = 10.0          -- o limitar velocidad en m/s si preferís
}
Config.Payment = {
  baseRate = 1.0,            -- multiplicador base
  damagePenalty = 0.5,       -- penalización por daños (50% del pago si el camión está muy dañado)
  damageThreshold = 300.0    -- umbral de daño (salud del vehículo por debajo del cual se aplica la penalización)
}