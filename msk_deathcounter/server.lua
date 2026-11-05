ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
        local alterTable = MySQL.query.await("ALTER TABLE users ADD COLUMN IF NOT EXISTS `deaths` TINYINT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS `isDead` TINYINT NULL DEFAULT NULL;")

        if alterTable then
			print('^2 Successfully ^3 altered ^2 table ^3 users ^0')
		end
    end
end)

---- Command ----

RegisterCommand(Config.resetCommand, function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if isAllowed(xPlayer.getGroup()) then
        MySQL.query('SELECT identifier FROM users', {}, function(results)
            for k2,v2 in pairs(results) do
                local identifier = results[k2].identifier

                MySQL.query('SELECT * FROM users WHERE identifier = @identifier', {
                    ['@identifier'] = identifier
                }, function(result)
                    for k3,v3 in pairs(result) do
                        if result[k3].isDead == nil then
                            MySQL.query('UPDATE users SET deaths = @deaths WHERE identifier = @identifier', {
                                ['@deaths'] = 0,
                                ['@identifier'] = result[k3].identifier
                            })
                        elseif result[k3].isDead ~= nil then
                            MySQL.query('UPDATE users SET deaths = @deaths, isDead = @isDead WHERE isDead = @dead', {
                                ['@dead'] = 1,
                                ['@deaths'] = Config.maxDeaths - Config.blockedCount,
                                ['@isDead'] = NULL
                            })
                        end
                    end
                end)
            end
        end)
    end
end)

---- Events ----

RegisterServerEvent("msk_deathcounter:countDeaths")
AddEventHandler("msk_deathcounter:countDeaths", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.query('SELECT * FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        local playerDeaths = result[1].deaths + 1

        if Config.maxDeaths <= playerDeaths then
            locked = 1
        else
            locked = NULL
        end

        sendDiscordLog(xPlayer, playerDeaths, Config.maxDeaths)

        MySQL.query('UPDATE users SET deaths = @deaths, isDead = @isDead WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@deaths'] = playerDeaths,
            ['@isDead'] = locked
        })
    end)
end)

RegisterServerEvent("msk_deathcounter:resetPlayerDeaths")
AddEventHandler("msk_deathcounter:resetPlayerDeaths", function(playerId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer ~= nil then
        MySQL.query('UPDATE users SET deaths = @deaths, isDead = @locked WHERE identifier = @identifier',{
            ['@identifier'] = xPlayer.identifier,
            ['@deaths'] = 0,
            ['@locked'] = NULL
        })

        Config.Notification(src, Translation[Config.Locale]['playerID_success'] .. playerId .. Translation[Config.Locale]['playerID_success2'])
    else
        Config.Notification(src, Translation[Config.Locale]['player_not_existing'])
    end
end)

RegisterServerEvent("msk_deathcounter:setPlayerDeaths")
AddEventHandler("msk_deathcounter:setPlayerDeaths", function(playerId, deaths)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer ~= nil then
        MySQL.query('UPDATE users SET deaths = @deaths, isDead = @locked WHERE identifier = @identifier',{
            ['@identifier'] = xPlayer.identifier,
            ['@deaths'] = deaths,
            ['@locked'] = NULL
        })

        Config.Notification(src, Translation[Config.Locale]['playerID_set'] .. playerId .. Translation[Config.Locale]['playerID_set2'] .. deaths .. Translation[Config.Locale]['playerID_set3'])
    else
        Config.Notification(src, Translation[Config.Locale]['player_not_existing'])
    end
end)

---- Server Callbacks ----

ESX.RegisterServerCallback('msk_deathcounter:getGroup', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	cb(isAllowed(xPlayer.getGroup()))
end)

ESX.RegisterServerCallback("msk_deathcounter:getPlayerDeaths", function(source, cb, playerId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local callback

    if xPlayer then
        MySQL.query('SELECT deaths FROM users WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            if result[1] == 0 or result[1] == nil then
                callback = 0
            else
                callback = result[1].deaths
            end

            cb(callback)
        end)
    else
        Config.Notification(src, Translation[Config.Locale]['player_not_existing'])
    end
end)

---- Functions ----

isAllowed = function(playerGroup)
    for k, group in pairs(Config.Groups) do
        if group == playerGroup then
            return true
        end
    end
    return false
end

logging = function(code, ...)
	if not Config.Debug then return end
    
	if code == 'error' then
        print(script, '[^1ERROR^0]', ...)
    elseif code == 'debug' then
        print(script, '[^3DEBUG^0]', ...)
    end
end

---- GitHub Updater ----

function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end

local CurrentVersion = GetCurrentVersion()
local resourceName = "^4["..GetCurrentResourceName().."]^0"

if Config.VersionChecker then
	PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/VERSIONS/main/VERSION_DEATHCOUNTER', function(Error, NewestVersion, Header)
		print("###############################")
    	if CurrentVersion == NewestVersion then
	    	print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
    	elseif CurrentVersion ~= NewestVersion then
        	print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
	    	print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/MSK-Scripts/msk_deathcounter^0')
    	end
		print("###############################")
	end)
else
	print("###############################")
	print(resourceName .. '^2 ✓ Resource loaded^0')
	print("###############################")
end