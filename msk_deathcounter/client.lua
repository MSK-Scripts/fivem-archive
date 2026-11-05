ESX = exports["es_extended"]:getSharedObject()

if Config.countDeath then
    AddEventHandler('esx:onPlayerDeath', function(data)
	    TriggerServerEvent('msk_deathcounter:countDeaths')
    end)
end

RegisterCommand('deathcounter', function(source, args, raw)
    ESX.TriggerServerCallback('msk_deathcounter:getGroup', function(isAllowed)
        if isAllowed then
            if args[1] ~= nil and args[2] == nil and args[3] == nil then -- /deathcounter ID
                ESX.TriggerServerCallback('msk_deathcounter:getPlayerDeaths', function(deaths)
                    Config.Notification(nil, Translation[Config.Locale]['playerID'] .. args[1] .. Translation[Config.Locale]['playerID2'] .. deaths .. Translation[Config.Locale]['playerID3'] .. Config.maxDeaths)
                end, args[1])
            elseif args[1] ~= nil and args[2] == "reset" and args[3] == nil then -- /deathcounter ID reset
                TriggerServerEvent('msk_deathcounter:resetPlayerDeaths', args[1])
            elseif args[1] ~= nil and args[2] == "set" and args[3] ~= nil then -- /deathcounter ID set deathcount
                TriggerServerEvent('msk_deathcounter:setPlayerDeaths', args[1], args[3])
            else
                Config.Notification(nil, Translation[Config.Locale]['incorrect_usage'])
            end
        end
    end)
end)

logging = function(code, ...)
	if not Config.Debug then return end

	if code == 'error' then
        print(script, '[^1ERROR^0]', ...)
    elseif code == 'debug' then
        print(script, '[^3DEBUG^0]', ...)
    end
end