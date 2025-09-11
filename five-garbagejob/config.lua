Config = {}

Config.Depositos = {
    { name = "Depósito Central", coords = vector3(-321.5, -1545.3, 31.0) },
    { name = "Depósito Norte", coords = vector3(1543.2, 3510.5, 35.0) }
}

Config.Niveles = {
    [1] = { xp = 0,   rutas = { 'ruta_corta_1', 'ruta_corta_2' } },
    [2] = { xp = 100, rutas = { 'ruta_media_1', 'ruta_media_2' } },
    [3] = { xp = 300, rutas = { 'ruta_larga_1', 'ruta_larga_2' } }
}

Config.Rutas = {
    ruta_corta_1 = {
        label = "Centro - Ruta 1",
        puntos = {
            vector3(-300.0, -1500.0, 31.0),
            vector3(-250.0, -1450.0, 31.0),
            vector3(-200.0, -1400.0, 31.0)
        },
        pago = 200, xp = 10
    },
    ruta_media_1 = {
        label = "Centro - Ruta Media",
        puntos = {
            vector3(-300.0, -1500.0, 31.0),
            vector3(-400.0, -1600.0, 31.0),
            vector3(-500.0, -1700.0, 31.0),
            vector3(-600.0, -1800.0, 31.0)
        },
        pago = 400, xp = 25
    }
    -- Añade más rutas...
}

Config.Vertederos = {
    vector3(-350.0, -1560.0, 25.0)
}

Config.TruckModel = "trash2"

Config.Route = {
    maxRouteDistance = 300.0,
    maxWarnings = 3
}

Config.AntiVDM = {
    capsuleRadius = 2.0,
    forwardMeters = 5.0,
    heightOffset = 1.0
}
