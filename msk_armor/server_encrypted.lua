AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		local createTable = MySQL.query.await("CREATE TABLE IF NOT EXISTS msk_armor (`identifier` varchar(80) NOT NULL, `item` varchar(255) DEFAULT NULL, PRIMARY KEY (`identifier`));")
        local alterTable = MySQL.query.await("ALTER TABLE users ADD COLUMN IF NOT EXISTS `armour` TINYINT(3) NOT NULL DEFAULT '0', ADD COLUMN IF NOT EXISTS `health` INT(3) NOT NULL DEFAULT '200';")
        local item_nobproof = MySQL.query.await("SELECT * FROM items WHERE name = @name", {['@name'] = 'nobproof'})
        local items = MySQL.query.await("SELECT name FROM items")

		if createTable and createTable.warningStatus < 1 then
			logging('debug', '^2 Successfully ^3 created ^2 table ^3 msk_armor ^0')
		end

        if alterTable and alterTable.warningStatus < 2 then
			logging('debug', '^2 Successfully ^3 altered ^2 table ^3 users ^0')
		end

        if not item_nobproof[1] then
			logging('debug', '^1 Item ^3 nobproof ^1 not exists, inserting item... ^0')
			local insertItem = MySQL.query.await("INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('nobproof', 'Bulletproof Vest', 1, 0, 1);")
			if insertItem then
				logging('debug', '^2 Successfully ^3 inserted ^2 Item ^3 nobproof ^2 in ^3 items ^0')
			end
		end

		if items then
			for k, v in pairs(Config.Armories) do
				local contains = table.contains(items, k)

				if not contains then
					logging('debug', '^1 Item ^3 ' .. v.label .. ' ^1 not exists, inserting item... ^0')
					local insertItem = MySQL.query.await("INSERT INTO items (name, label, weight, rare, can_remove) VALUES ('" .. k .. "', '" .. v.label .. "', 1, 0, 1);")
					if insertItem then
						logging('debug', '^2 Successfully ^3 inserted ^2 Item ^3 ' .. v.label .. ' ^2 in ^3 items ^0')
					end
				end
			end
		end
	end
end)

function table.contains(items, item)
	for k, v in pairs(items) do
		if v.name == item then
			return true
		end
	end
	return false
end

GithubUpdater = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata(GetCurrentResourceName(), "version")
    end

	isVersionIncluded = function(Versions, cVersion)
		for k, v in pairs(Versions) do
			if v.version == cVersion then
				return true
			end
		end

		return false
	end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^0[^2"..GetCurrentResourceName().."^0]"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/VERSIONS/main/Armor.json', function(errorCode, jsonString, headers)
            print("###############################")
			if not jsonString then print(resourceName .. '^1Update Check failed! ^3Please Update to the latest Version: ^9https://keymaster.fivem.net/^0') print("###############################") return end
			
			local decoded = json.decode(jsonString)
            local version = decoded[1].version

            if CurrentVersion == version then
                print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= version then
                print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
                print('^5Latest Version: ^2' .. version .. '^0 - ^6Download here: ^9https://keymaster.fivem.net/^0')
				print('')
				if not string.find(CurrentVersion, 'beta') then
					for i=1, #decoded do 
						if decoded[i]['version'] == CurrentVersion then
							break
						elseif not isVersionIncluded(decoded, CurrentVersion) then
							print('^1You are using the ^3BETA VERSION^1 of ^0' .. resourceName)
							break
						end

						if decoded[i]['changelogs'] then
							print('^3Changelogs v' .. decoded[i]['version'] .. '^0')

							for _, c in ipairs(decoded[i]['changelogs']) do
								print(c)
							end
						end
					end
				else
					print('^1You are using the ^3BETA VERSION^1 of ^0' .. resourceName)
				end
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