-- Obtener job actual
exports('getJob', function(src)
    local p = exports['fivecore']:state(src)
    return p and p.job or nil
end)

-- Cambiar job
exports('setJob', function(src, jobName, grade)
    if not Config.Jobs[jobName] then return false, "Job no existe" end
    local p = exports['fivecore']:state(src)
    if not p then return false, "Jugador no encontrado" end

    grade = grade or 0
    if not Config.Jobs[jobName].grades[grade] then grade = 0 end

    p.job = { name = jobName, grade = grade, duty = Config.Jobs[jobName].defaultDuty }
    exports['fivecore']:log('jobs', src, 'setJob', { job = jobName, grade = grade })
    TriggerClientEvent('fivecore:job:update', src, p.job)
    TriggerEvent('fivecore:jobChanged', src)
    return true
end)

-- Cambiar duty
exports('setDuty', function(src, duty)
    local p = exports['fivecore']:state(src)
    if not p or not p.job then return false end
    p.job.duty = duty and true or false
    exports['fivecore']:log('jobs', src, 'setDuty', { duty = p.job.duty })
    TriggerClientEvent('fivecore:job:update', src, p.job)
    TriggerEvent('fivecore:jobChanged', src)
    return true
end)

