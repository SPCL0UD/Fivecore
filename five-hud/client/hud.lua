RegisterNetEvent('fivecore:hud:update', function(cash, bank, crypto, job)
    SendNUIMessage({
        action = 'updateHUD',
        cash   = string.format("%d", cash),
        bank   = string.format("%d", bank),
        crypto = string.format("%.2f", crypto),
        jobLabel = job and Config.Jobs[job.name] and Config.Jobs[job.name].label or 'Sin trabajo',
        jobGradeLabel = job and Config.Jobs[job.name] and Config.Jobs[job.name].grades[job.grade] and Config.Jobs[job.name].grades[job.grade].name or ''
    })
end)

AddEventHandler('onClientMapStart', function()
    TriggerServerEvent('fivecore:hud:requestUpdate')
end)

-- Toggle HUD con F7
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 168) then
            SendNUIMessage({ action = 'toggleHUD' })
        end
    end
end)

