ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resource)
	if GetCurrentResourceName() ~= 'msk_crafting' then
		print('^1Please rename the Script to^3 msk_crafting^0!')
		print('^1Server will be shutdown^0!')
		Wait(100)
		os.exit()
  end

	if resource == GetCurrentResourceName() then
    local items = ESX.Items or {}

		for k, v in pairs(Config.Crafting) do
			for k2, item in pairs(v.items) do
				if item.type == 'item' then
					for k3, ingredients in pairs(item.ingredients) do
						local contains = table.contains(items, ingredients.name)
						if not contains then
							error('^1 Item ^3 ' .. ingredients.name .. ' ^1 not exists in Database! ^1 Look at the ^3 config.lua ^0')
						end
					end
				end
			end
		end
	end
end)

RegisterServerEvent('msk_crafting:buyLicense')
AddEventHandler('msk_crafting:buyLicense', function(license, method) -- license = type, label, name, price
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local account = xPlayer.getAccount(method)

	if account.money >= license.price then
		if license.type == 'license' then
			xPlayer.removeAccountMoney(method, license.price)
			TriggerEvent('esx_license:addLicense', src, license.name)
			Config.Notification(src, Translation[Config.Locale]['bought_license']:format(license.label))
		elseif license.type == 'item' then
			xPlayer.removeAccountMoney(method, license.price)
			xPlayer.addInventoryItem(license.name, 1)
			Config.Notification(src, Translation[Config.Locale]['bought_license']:format(license.label))
		end
	else
		if method == 'money' then
			Config.Notification(src, Translation[Config.Locale]['not_enough_money'])
		elseif method == 'bank' then
			Config.Notification(src, Translation[Config.Locale]['not_enough_money_bank'])
		end
	end
end)

RegisterServerEvent('msk_crafting:craft')
AddEventHandler('msk_crafting:craft', function(item, neededItems, own)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local hasItems = true

    logging('debug', item.type, item.label, item.count)

    for k, v in pairs(neededItems) do
        local hasItem = xPlayer.getInventoryItem(v.name)

		if own then
			logging('debug', 'Benötigt', v.name, v.count * item.count)
		else
			logging('debug', 'Benötigt', v.name, v.count)
		end

		if hasItem then
			logging('debug', 'Inventar', hasItem.name, hasItem.count)
		end

		if own then
			if not hasItem or hasItem.count < v.count * item.count then
				hasItems = false
			end
		else
			if not hasItem or hasItem.count < v.count then
				hasItems = false
			end
		end
    end

	logging('debug', 'hasItems:', hasItems)

    if hasItems then
		local canCarryItem

		if type(item.count) == 'table' then
			if item.type == 'item' then
				canCarryItem = xPlayer.canCarryItem(item.name, item.count.max)
			else
				canCarryItem = true
			end
		elseif type(item.count) == 'number' then
			if item.type == 'item' then
				canCarryItem = xPlayer.canCarryItem(item.name, item.count)
			else
				canCarryItem = true
			end
		end

        if canCarryItem then
            xPlayer.triggerEvent('msk_crafting:checkDistance', item, neededItems, own)
        else
            Config.Notification(src, Translation[Config.Locale]['full_space'])
        end
    else
        Config.Notification(src, Translation[Config.Locale]['not_enough_items'])
    end
end)

RegisterServerEvent('msk_crafting:startCrafting')
AddEventHandler('msk_crafting:startCrafting', function(item, neededItems, own, random)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local chance = math.random(100)

	for k, v in pairs(neededItems) do
		if own then
			xPlayer.removeInventoryItem(v.name, v.count * item.count)
		else
			xPlayer.removeInventoryItem(v.name, v.count)
		end
	end

	if (not item.probability) or (chance <= item.probability) then
		if item.type == 'item' then
			if type(item.count) == 'table' then
				logging('debug', 'Random Count:', random)
				xPlayer.addInventoryItem(item.name, random)
				sendDiscordLog(xPlayer.name, item.label, random, item.type)
			else
				xPlayer.addInventoryItem(item.name, item.count)
				sendDiscordLog(xPlayer.name, item.label, item.count, item.type)
			end
		elseif item.type == 'weapon' then
			xPlayer.addWeapon(string.upper(item.name), item.ammo)
			sendDiscordLog(xPlayer.name, string.upper(item.name), item.ammo, item.type)
		end
	end
end)

MSK.RegisterCallback('msk_crafting:checkLicenseItem', function(source, cb, license) -- license = type, label, name, price
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if license.type == 'item' then
		local hasItem = xPlayer.getInventoryItem(license.name)

		if hasItem and hasItem.count >= 1 then
			cb(true)
		else
			cb(false)
		end
	end
end)

---- Functions ----

function table.contains(items, item)
	for k, v in pairs(items) do
		if v.name == item then
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

GithubUpdater = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata(GetCurrentResourceName(), "version")
    end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^0[^2"..GetCurrentResourceName().."^0]"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/VERSIONS/main/Crafting.json', function(errorCode, jsonString, headers)
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