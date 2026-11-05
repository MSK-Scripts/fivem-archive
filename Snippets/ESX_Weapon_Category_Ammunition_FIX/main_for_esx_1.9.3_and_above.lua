function StartServerSyncLoops()
	if not Config.OxInventory then
		-- keep track of ammo

		local currentWeapon = {}
		for k, v in ipairs(ESX.PlayerData.loadout) do
			local weaponName = string.upper(v.name)

			currentWeapon[weaponName] = {}
			currentWeapon[weaponName].ammo = v.ammo
			currentWeapon[weaponName].name = weaponName
		end

		RegisterNetEvent('esx:setWeaponAmmo')
		AddEventHandler('esx:setWeaponAmmo', function(weaponName, weaponAmmo)
			local weaponName = weaponName:upper()	
					
			currentWeapon[weaponName].ammo = weaponAmmo
			SetPedAmmo(ESX.PlayerData.ped, GetHashKey(weaponName), weaponAmmo)
		end)

		RegisterNetEvent('msk_weaponammo:updateAmmo')
		AddEventHandler('msk_weaponammo:updateAmmo', function(weaponName, ammoToAdd)
			local weaponName = weaponName:upper()

			if not currentWeapon[weaponName] then return end
			currentWeapon[weaponName].ammo = currentWeapon[weaponName].ammo + ammoToAdd
		end)

		AddEventHandler('esx:addInventoryItem', function(itemLabel)
			ESX.TriggerServerCallback('esx:getPlayerData', function(data)
				for k, v in ipairs(data.loadout) do
					if v.label == itemLabel then
						local weaponName = v.name:upper()
						local f1, f2 = weaponName:find('WEAPON_') 
						if not f1 or not f2 then return end

						if f1 == 1 and f2 == 7 then
							if not currentWeapon[weaponName] then
								currentWeapon[weaponName] = {name = weaponName, ammo = v.ammo}
							else
								currentWeapon[weaponName].ammo = v.ammo
							end
						end

						break
					end
				end
			end)
		end)

		AddEventHandler('esx:removeInventoryItem', function(itemName)
			ESX.TriggerServerCallback('esx:getPlayerData', function(data)
				for k, v in ipairs(data.loadout) do
					if v.label == itemLabel then
						local weaponName = v.name:upper()
						local f1, f2 = weaponName:find('WEAPON_') 
						if not f1 or not f2 then return end

						if f1 == 1 and f2 == 7 then
							if currentWeapon[weaponName] then
								currentWeapon[weaponName] = nil
							end
						end

						break
					end
				end
			end)
		end)

		CreateThread(function()			
			while ESX.PlayerLoaded do
				local sleep = 1500

				if IsPedArmed(ESX.PlayerData.ped, 4) then
					sleep = 1000
					local weaponHash = GetSelectedPedWeapon(ESX.PlayerData.ped)

					if weaponHash ~= -1569615261 then
						local weapon = ESX.GetWeaponFromHash(weaponHash)

						if weapon then
							if not currentWeapon[weapon.name] then
								currentWeapon[weapon.name] = {name = weapon.name, ammo = GetAmmoInPedWeapon(ESX.PlayerData.ped, weaponHash)}
							else
								if currentWeapon[weapon.name].ammo ~= GetAmmoInPedWeapon(ESX.PlayerData.ped, weaponHash) then
									TriggerServerEvent('esx:updateWeaponAmmo', weapon.name, currentWeapon[weapon.name].ammo)
								end
							end

						end
					end
				end

				Wait(sleep)
			end
		end)

		CreateThread(function()
			while ESX.PlayerLoaded do
				local sleep = 0

				if IsPedArmed(ESX.PlayerData.ped, 4) and IsPedShooting(ESX.PlayerData.ped) then
					local weaponHash = GetSelectedPedWeapon(ESX.PlayerData.ped)

					if weaponHash ~= -1569615261 then
						local weapon = ESX.GetWeaponFromHash(weaponHash)

						if weapon then
							currentWeapon[weapon.name].ammo = currentWeapon[weapon.name].ammo - 1
							TriggerServerEvent('esx:updateWeaponAmmo', weapon.name, currentWeapon[weapon.name].ammo)
						end
					end
				end

				Wait(sleep)
			end
		end)
	end
end