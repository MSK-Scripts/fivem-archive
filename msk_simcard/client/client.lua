if Config.Framework:match('ESX') then -- ESX Framework
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework:match('QBCore') then -- QBCore Framework
    QBCore = exports['qb-core']:GetCoreObject()
end

changeNumber = function()
    TriggerServerEvent('msk_simcard:changeNumber', genPhoneNumber(), Config.usableItem)
end
exports('changeNumber', changeNumber)
RegisterNetEvent('msk_simcard:useItem', changeNumber)

genPhoneNumber = function()
    local number = 0

    if Config.numberFormat == 'number' then
        if Config.StartingDigit.enable then
            number = Config.StartingDigit.value .. math.random(111111, 999999)
        else
            number = math.random(111111111, 999999999)
        end
    elseif Config.numberFormat == 'gc' then
        if Config.StartingDigit.enable then
            number = Config.StartingDigit.value .. math.random(1111, 9999)
        else
            number = math.random(111, 999) .. '-' .. math.random(1111, 9999)
        end
    elseif Config.numberFormat == 'canada' then
        if Config.StartingDigit.enable then
            number = Config.StartingDigit.value .. '-' .. math.random(111, 999) .. '-' .. math.random(1111, 9999)
        else
            number = math.random(111, 999) .. '-' .. math.random(111, 999) .. '-' .. math.random(1111, 9999)
        end
    else
        if Config.StartingDigit.enable then
            number = Config.StartingDigit.value .. math.random(111111, 999999)
        else
            number = math.random(111111111, 999999999)
        end
    end

    return number
end
exports('genPhoneNumber', genPhoneNumber)

logging = function(code, ...)
	if not Config.Debug then return end
    MSK.Logging(code, ...)
end