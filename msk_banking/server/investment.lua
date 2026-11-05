if not Investment then Investment = {} end

RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer, isNew)
    if not Config.Investment.enable then return end

    if xPlayer.setMeta then
        xPlayer.setMeta('msk_banking_invest', os.time())
    elseif xPlayer.set then
        xPlayer.set('msk_banking_invest', os.time())
    end

    local data = MySQL.query.await('SELECT * FROM msk_banking WHERE identifier = ?', {xPlayer.identifier})
    if data and data[1] and data[1].invest then 
        Investment[xPlayer.identifier] = {amount = MSK.Round(tonumber(data[1].invest))} 
    end
end)

RegisterNetEvent('esx:playerLogout')
AddEventHandler('esx:playerLogout', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    saveDiffInvestment(xPlayer)
end)

RegisterNetEvent('esx:playerDropped', function(playerId, reason)
	local src = playerId
	local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    saveDiffInvestment(xPlayer)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    logging('debug', 'onResourceStop')
    executeInvestmentOnRestart()
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
    logging('debug', 'serverShuttingDown')
    executeInvestmentOnRestart()
end)

RegisterNetEvent('msk_banking:executeInvestment', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    executeInvestment(xPlayer)
end)

executeInvestment = function(xPlayer)
    local meta = nil
    if xPlayer.getMeta then 
        meta = xPlayer.getMeta('msk_banking_invest')
    elseif xPlayer.get then
        meta = xPlayer.get('msk_banking_invest')
    end
    local diff = os.difftime(os.time(), meta) / 60
    if diff < (Config.Investment.time * 60) then return end

    if xPlayer.setMeta then 
        xPlayer.setMeta('msk_banking_invest', os.time())
    elseif xPlayer.set then
        xPlayer.set('msk_banking_invest', os.time())
    end

    local invest = getInvestment({player = xPlayer})
    local percentage = math.random(Config.Investment.percentage.min, Config.Investment.percentage.max)
    local percent = percentage / 100
    local amount = MSK.Round(invest * percent)
    logging('debug', 'Investment Percentage', percentage)

    if Config.Investment.dynamic.enable then
        local dynamic = math.random(1, 100)
        logging('debug', 'Investment Dynamic', dynamic)

        if dynamic <= Config.Investment.dynamic.chance then
            logging('debug', percent, amount, invest + amount)
            saveInvestment(xPlayer, invest + amount)
            if Config.Investment.notification then Config.Notification(xPlayer.source, Translation[Config.Locale]['investment_add']:format(amount), 'info') end
        else
            logging('debug', percent, amount, invest - amount)
            saveInvestment(xPlayer, invest - amount)
            if Config.Investment.notification then Config.Notification(xPlayer.source, Translation[Config.Locale]['investment_remove']:format(amount), 'info') end
        end
    else
        logging('debug', percent, amount, invest + amount)
        saveInvestment(xPlayer, invest + amount)
        if Config.Investment.notification then Config.Notification(xPlayer.source, Translation[Config.Locale]['investment_add']:format(amount), 'info') end
    end
end

-- Executes if player disconnect
saveDiffInvestment = function(xPlayer)
    if not Config.Investment.enable then return end
    local meta = nil
    logging('debug', 'Saving Banking Investment of PlayerID: ' .. xPlayer.source)

    if xPlayer.getMeta then 
        meta = xPlayer.getMeta('msk_banking_invest')
    elseif xPlayer.get then
        meta = xPlayer.get('msk_banking_invest')
    end

    if meta then
        local diff = os.difftime(os.time(), meta) / 60
        
        local invest = getInvestment({player = xPlayer})
        local percentage = math.random(Config.Investment.percentage.min, Config.Investment.percentage.max) / 100
        local diffpercent = ((100 / (Config.Investment.time * 60)) * diff) / 100
        local amount = MSK.Round(invest * percentage)
        local endamount = MSK.Round(diffpercent * amount)

        saveInvestment(xPlayer, invest + endamount)
    end
end

executeInvestmentOnRestart = function()
    if not Config.Investment.enable then return end
    logging('debug', 'Saving Banking Investments...')

    for k, playerId in pairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        
        if xPlayer.getMeta then 
            meta = xPlayer.getMeta('msk_banking_invest')
        elseif xPlayer.get then
            meta = xPlayer.get('msk_banking_invest')
        end

        if meta then
            local diff = os.difftime(os.time(), meta) / 60

            local invest = getInvestment({player = xPlayer}) -- 1000
            local percentage = math.random(Config.Investment.percentage.min, Config.Investment.percentage.max) / 100 -- 1%
            local diffpercent = ((100 / (Config.Investment.time * 60)) * diff) / 100 -- 0.5
            local amount = MSK.Round(invest * percentage) -- 10
            local endamount = MSK.Round(diffpercent * amount) -- 5

            -- logging('debug', endamount)
            saveInvestment(xPlayer, invest + endamount)
        end
    end
end

MSK.Register('msk_banking:getInvestment', function(source)
    local src = source
    local invest = getInvestment({source = src})

    return invest
end)

getInvestment = function(player)
    if not player then return end
    local xPlayer

    if player.source then
        xPlayer = ESX.GetPlayerFromId(player.source)
    elseif player.identifier then
        xPlayer = ESX.GetPlayerFromIdentifier(player.identifier)
    elseif player.player then
        xPlayer = player.player
    end

    return MSK.Round(Investment[xPlayer.identifier]?.amount or 0) or 0
end
exports('getInvestment', getInvestment)

saveInvestment = function(xPlayer, amount)
    if not Investment[xPlayer.identifier] then
        Investment[xPlayer.identifier] = {amount = MSK.Round(amount or 0)}
    else
        Investment[xPlayer.identifier].amount = MSK.Round(amount or 0) or getInvestment({player = xPlayer})
    end

    MySQL.query('UPDATE msk_banking SET invest = @invest WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
        ['@invest'] = Investment[xPlayer.identifier].amount,
    })
end