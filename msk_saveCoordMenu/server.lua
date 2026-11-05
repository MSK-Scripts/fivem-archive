-- Notifications, TextUI and progress bars use the table forms of msk_core 4.1.0.
-- An older msk_core shows broken notifications, so say it loudly on start.
MSK.Check.Dependency('msk_core', '4.1.0', true)

ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		local createTable = MySQL.query.await("CREATE TABLE IF NOT EXISTS msk_saveCoords (`identifier` varchar(80) NOT NULL, `coords` longtext DEFAULT NULL, PRIMARY KEY (`identifier`));")

		if createTable.warningStatus == 0 then
			logging('debug', '^2 Successfully ^3 created ^2 table ^3 msk_saveCoords ^0')
		end

		logging('debug', '^2 Sync msk_saveCoords table ^0')
		MySQL.Async.fetchAll('SELECT * FROM users', {}, function(results)
            for k,v in pairs(results) do
                local charGroup = results[k].group
                local charIdentifier = results[k].identifier

				for k2,rank in pairs(Config.Ranks) do
					if rank == charGroup then
						MySQL.Async.fetchAll('SELECT * FROM msk_saveCoords WHERE identifier = @identifier', {
							['@identifier'] = charIdentifier
						}, function(results2)
							if #results2 == 0 then
								MySQL.Sync.execute('INSERT INTO msk_saveCoords (identifier) VALUES (@identifier)', {
									['@identifier'] = charIdentifier
								})
							end
						end)
					end
				end
            end
        end)
	end
end)

if Config.ESX == '1.1' then
	RegisterCommand(Config.Command, function(source)
		local src = source
		local xPlayer = ESX.GetPlayerFromId(src)

		if table.contains(Config.Ranks, xPlayer.group) then
			xPlayer.triggerEvent('msk_saveCoordsMenu:openMenu')
		else
			MSK.Notification(src, { message = 'Du hast nicht die Berechtigung diesen Befehl auszuführen!' })
		end
	end)
elseif Config.ESX == 'legacy' then
	ESX.RegisterCommand(Config.Command, Config.Ranks, function(xPlayer, args, showError)
		xPlayer.triggerEvent('msk_saveCoordsMenu:openMenu')
	end, false)
end

MSK.RegisterCallback('msk_saveCoordsMenu:checkCoords', function(source, cb)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	MySQL.Async.fetchAll('SELECT coords FROM msk_saveCoords WHERE identifier = @identifier', { 
		["@identifier"] = xPlayer.identifier
	}, function(result)
		
		if result[1] and result[1].coords then
			local cCoords = json.decode(result[1].coords)
			logging('debug', 'CALLBACK', result[1].coords)

			cb(cCoords)
		else
			cb(nil)
		end
	end)
end)

RegisterServerEvent('msk_saveCoordsMenu:addCoords') 
AddEventHandler('msk_saveCoordsMenu:addCoords', function(name, coords)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	MySQL.Async.fetchAll('SELECT coords FROM msk_saveCoords WHERE identifier = @identifier', { 
		["@identifier"] = xPlayer.identifier
	}, function(result)
		
		if result[1] and result[1].coords then
			logging('debug', 'ADD COORDS')

			local cCoords = json.decode(result[1].coords)
			cCoords.coords = table.insert(cCoords, {name = name, coords = coords})

			MySQL.Async.execute("UPDATE msk_saveCoords SET coords = @coords WHERE identifier = @identifier", {
				["@identifier"] = xPlayer.identifier,
				["@coords"] = json.encode(cCoords)
			})

			MSK.Notification(src, { message = 'Koordinaten erfolgreich hinzugefügt' })
		else
			logging('debug', 'ADD COORDS')
			logging('debug', 'result[1].coords == nil')

			local cCoords = {{name = name, coords = coords}}
			MySQL.Async.execute("UPDATE msk_saveCoords SET coords = @coords WHERE identifier = @identifier", {
				["@identifier"] = xPlayer.identifier,
				["@coords"] = json.encode(cCoords)
			})

			MSK.Notification(src, { message = 'Koordinaten erfolgreich hinzugefügt' })
		end
	end)
end)

RegisterServerEvent('msk_saveCoordsMenu:deleteCoords') 
AddEventHandler('msk_saveCoordsMenu:deleteCoords', function(name, coords)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	MySQL.Async.fetchAll('SELECT coords FROM msk_saveCoords WHERE identifier = @identifier', { 
		["@identifier"] = xPlayer.identifier
	}, function(result)
		
		if result[1] and result[1].coords then
			logging('debug', 'DELETE COORDS')
			local cCoords = json.decode(result[1].coords)

			for k,v in pairs(cCoords) do
				logging('debug', k, vector3(v.coords.x, v.coords.y, v.coords.z), v.name) -- 1, vector3(x, y, z), Name

				if v.name == name then
					logging('debug', 'v.name == name')

					table.remove(cCoords, k)
					logging('debug', string.format('Dataset removed at Key: %s, with Name: %s, Coords: %s', k, v.name, vector3(v.coords.x, v.coords.y, v.coords.z)))

					MySQL.Async.execute("UPDATE msk_saveCoords SET coords = @coords WHERE identifier = @identifier", {
						["@identifier"] = xPlayer.identifier,
						["@coords"] = json.encode(cCoords)
					})
		
					MSK.Notification(src, { message = 'Koordinaten erfolgreich gelöscht' })
					break
				end
			end
		end
	end)
end)

RegisterServerEvent('msk_saveCoordsMenu:sendDiscordLog') 
AddEventHandler('msk_saveCoordsMenu:sendDiscordLog', function(location, coords)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	sendDiscordLog(xPlayer, location, tostring(coords))
end)

---- Functions ----

function table.contains(table, value)
	for k, v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

logging = function(code, msg, msg2, msg3)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, msg, msg2, msg3)
    end
end

---- GitHub Updater ----

GithubUpdater = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata( GetCurrentResourceName(), "version" )
    end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^4["..GetCurrentResourceName().."]^0"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/VERSIONS/main/VERSION_SAVECOORDMENU', function(Error, NewestVersion, Header)
            print("###############################")
            if CurrentVersion == NewestVersion then
                print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= NewestVersion then
                print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
                print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/MSK-Scripts/msk_saveCoordMenu^0')
            end
            print("###############################")
        end)
    else
        print("###############################")
        print(resourceName .. '^2 ✓ Resource loaded^0')
        print("###############################")
    end
end
GithubUpdater()