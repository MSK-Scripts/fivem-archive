AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() and Config.useStorage then
		--MySQL.query.await("DROP TABLE msk_shops")
		local createTable = MySQL.query.await("CREATE TABLE IF NOT EXISTS msk_shops (`shopId` varchar(50) NOT NULL DEFAULT '', `items` longtext DEFAULT NULL, PRIMARY KEY (`shopId`));")
		
		if createTable and createTable.warningStatus == 0 then
			logging('debug', '^2 Successfully^3 created^2 table^3 msk_shops ^0')
		end

		local alterTable = MySQL.query.await("ALTER TABLE msk_shops ADD COLUMN IF NOT EXISTS `shopId` varchar(50) NOT NULL DEFAULT '', ADD COLUMN IF NOT EXISTS `items` longtext DEFAULT NULL;")
		local shops = MySQL.query.await("SELECT * FROM msk_shops")
		if not shops then return end
		if shops[1] and shops[1].name then MySQL.query.await("ALTER TABLE msk_shops DROP PRIMARY KEY;") end

		for shopId, v in pairs(Config.Shops) do
			logging('debug', '^2', shopId, v, '^0')
			itemStorage[shopId] = {}
			local doesShopIdExist = doesShopIdExist(shops, shopId)

			if not doesShopIdExist then
				logging('error', '^1 Shop ^3 ' .. shopId .. ' ^1 not exists, inserting shop... ^0')
				local insertShop = MySQL.query.await("INSERT INTO msk_shops (shopId) VALUES ('" .. shopId .. "');")

				local shopItems = {}
				for k, item in pairs(v.items) do
					logging('debug', 'Creating itemStorage', shopId, item.name, item.amount)
					table.insert(shopItems, {name = item.name, amount = 200})
					itemStorage[shopId][item.name] = {item = item.name, amount = 200}
				end

				local insertItems = MySQL.query.await('UPDATE msk_shops SET items = @items WHERE shopId = @shopId', {
					['@shopId'] = shopId,
					['@items'] = json.encode(shopItems)
				})

				if insertShop then
					logging('debug', '^2 Successfully ^3 inserted ^2 Shop ^3 ' .. shopId .. ' ^2 in ^3 msk_shops ^0')
				end
			else
				for k, item in pairs(v.items) do
					local doesItemExist = doesItemExist(shops, shopId, item.name)

					if not doesItemExist then
						logging('error', '^1 Item ^3 ' .. item.name .. ' ^1 not exists, inserting item... ^0')
						itemStorage[shopId][item.name] = {item = item.name, amount = 200}
						logging('debug', '^2 Successfully ^3 inserted ^2 Item ^3 ' .. item.name .. ' ^2 in table ^3 itemStorage ^0')
					end
				end

				for k, shop in pairs(shops) do
					if shop.shopId == shopId and shop.items then
						local items = json.decode(shop.items)

						for _, item in pairs(items) do
							logging('debug', 'Reading itemStorage', shopId, item.name, item.amount)
							itemStorage[shopId][item.name] = {item = item.name, amount = item.amount}
						end
					end
				end
			end
		end

		MySQL.query.await("DELETE FROM msk_shops WHERE shopId = '';")
		if shops[1] and shops[1].name then MySQL.query.await("ALTER TABLE msk_shops ADD PRIMARY KEY (shopId);") end
		MySQL.query.await("ALTER TABLE msk_shops DROP COLUMN IF EXISTS name, DROP COLUMN IF EXISTS amount;")
	end
end)

doesItemExist = function(shops, shopId, item)
	for k, shop in pairs(shops) do
		if shop.shopId == shopId and shop.items then
			local items = json.decode(shop.items)

			for i, v in pairs(items) do
				if item == v.name then
					return true
				end
			end
		end
	end
	return false
end

doesShopIdExist = function(shops, shopId)
	for k, v in pairs(shops) do
		if v.shopId == shopId then
			return true
		end
	end
	return false
end

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.logging(code, ...)
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
        PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/VERSIONS/main/Shop.json', function(errorCode, jsonString, headers)
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
        end)
    else
        print(resourceName .. '^2 ✓ Resource loaded^0')
    end
end
GithubUpdater()