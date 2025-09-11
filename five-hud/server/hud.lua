local function sendHUDUpdate(src)
    local p = exports['fivecore']:state(src)
    if not p then return end
    TriggerClientEvent('fivecore:hud:update', src, p.money.cash, p.money.bank, p.money.crypto, p.job)
end

AddEventHandler('fivecore:moneyChanged', function(src)
    sendHUDUpdate(src)
end)

AddEventHandler('fivecore:jobChanged', function(src)
    sendHUDUpdate(src)
end)

RegisterNetEvent('fivecore:hud:requestUpdate', function()
    sendHUDUpdate(source)
end)
-- 