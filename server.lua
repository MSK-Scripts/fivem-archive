local isBlackout = false -- msk_blackout
AddEventHandler('msk_blackout:powerOn', blackoutPowerOn)
AddEventHandler('msk_blackout:powerOff', blackoutPowerOff)

ESX.RegisterCommand('msk_blackmoney', {'admin'}, function(xPlayer, args, showError)
	local blackmoney = xPlayer.getAccount('black_money')
	local hasItem = xPlayer.getInventoryItem(Config.neededItem)

	if blackmoney and blackmoney.money > 0 and hasItem and hasItem.count > 0 then
		xPlayer.removeInventoryItem(Config.neededItem, 1)
		xPlayer.triggerEvent('msk_blackmoney:startBlackmoney', Config.startPoint.coords)
	end
end, false)

ESX.RegisterCommand('msk_blackmoney_skip', {'admin'}, function(xPlayer, args, showError)
	xPlayer.triggerEvent('msk_blackmoney:skipSkillCheck', Config.Locations['wash_money'].moneyCut.coords)
end, false)

RegisterNetEvent('msk_blackmoney:notifyJobs')
AddEventHandler('msk_blackmoney:notifyJobs', function()
	if not Config.notifyJobs.enable then return end
	if isBlackout then return end
	
	Wait(Config.notifyJobs.dispatchDelay * 1000)
	local xPlayers = ESX.GetPlayers()

    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

        if MSK.Table_Contains(Config.notifyJobs.jobs, xPlayer.job.name) then
			if not isBlackout then
				Config.Notification(xPlayer.source, 'Jemand versucht gerade Schwarzgeld zu waschen')
				TriggerClientEvent('msk_blackmoney:sendJobBlipNotify', xPlayer.source)
			end
        end
    end
end)

RegisterNetEvent('msk_blackmoney:getMoneyAfterWashing')
AddEventHandler('msk_blackmoney:getMoneyAfterWashing', function()
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	local blackmoney = xPlayer.getAccount('black_money')
	if not blackmoney or (blackmoney and blackmoney.money == 0) then return end

	xPlayer.removeAccountMoney('black_money', blackmoney.money)

	local hasItem = false
	if Config.BlackmoneyItems.enable then 
		for k, v in ipairs(Config.BlackmoneyItems.items) do
			logging('debug', v.item, v.percent)
			local getItem = xPlayer.getInventoryItem(v.item)

			if getItem and getItem.count > 0 then
				hasItem = v.percent
				break
			end
		end
	end

	local percent
	if hasItem then
		if hasItem < 10 then
			percent = '0.0' .. hasItem
		elseif hasItem >= 10 and hasItem < 100 then
			percent = '0.' .. hasItem
		else
			percent = '1'
		end
	else
		if Config.Percent < 10 then
			percent = '0.0' .. Config.Percent
		elseif Config.Percent >= 10 and Config.Percent < 100 then
			percent = '0.' .. Config.Percent
		else
			percent = '1'
		end
	end

	local amount = blackmoney.money * tonumber(percent)
	amount = MSK.Round(amount)

	xPlayer.addAccountMoney('money', blackmoney.money - amount)

	Config.Notification(src, ('Du hast erfolgreich $%s Schwarzgeld zu $%s umgewandelt.'):format(blackmoney.money, blackmoney.money - amount))
end)

RegisterNetEvent('msk_blackmoney:removeItem')
AddEventHandler('msk_blackmoney:removeItem', function(item)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	xPlayer.removeInventoryItem(item, 1)
end)

MSK.RegisterCallback('msk_blackmoney:getBlackmoney', function(source, cb)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	cb(xPlayer.getAccount('black_money'))
end)

blackoutPowerOn = function()
	if not Config.MSK_Blackout then return end
    isBlackout = false
end

blackoutPowerOff = function()
	if not Config.MSK_Blackout then return end
    isBlackout = true
end

logging = function(code, ...)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, ...)
    end
end