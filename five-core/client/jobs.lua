RegisterNetEvent('fivecore:job:update', function(job)
    -- Aquí puedes actualizar HUD, notificaciones, etc.
    print(("Nuevo trabajo: %s (%s) - Duty: %s"):format(
        Config.Jobs[job.name].label,
        Config.Jobs[job.name].grades[job.grade].name,
        tostring(job.duty)
    ))
end)
