CreateThread(function()
    while true do
        Wait(10 * 60 * 1000) -- cada 10 minutos
        for _, id in ipairs(GetPlayers()) do
            local src = tonumber(id)
            local job = exports['fivecore']:getJob(src)
            if job and job.duty and Config.Jobs[job.name] then
                local pay = Config.Jobs[job.name].grades[job.grade].payment or 0
                if pay > 0 then
                    exports['fivecore']:addMoney(src, 'bank', pay, 'salary')
                    TriggerEvent('fivecore:moneyChanged', src)
                end
            end
        end
    end
end)
