RegisterServerEvent('fuel:pay')
AddEventHandler('fuel:pay', function(price)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local amount = ESX.Math.Round(price)

	if price > 0 then
		xPlayer.removeMoney(amount)
	end
end)

RegisterServerEvent('fuel:addWeapon')
AddEventHandler('fuel:addWeapon', function(weaponName, weaponAmmo, payAmount)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	xPlayer.addWeapon(weaponName:upper(), weaponAmmo)

	if payAmount and payAmount > 0 then
		xPlayer.removeMoney(ESX.Math.Round(payAmount))
	end
end)

RegisterServerEvent('fuel:removeWeapon')
AddEventHandler('fuel:removeWeapon', function(weaponName)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	xPlayer.removeWeapon(weaponName:upper())
end)

RegisterServerEvent('fuel:updateWeaponAmmo')
AddEventHandler('fuel:updateWeaponAmmo', function(weaponName, weaponAmmo)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	xPlayer.updateWeaponAmmo(weaponName:upper(), weaponAmmo)
end)