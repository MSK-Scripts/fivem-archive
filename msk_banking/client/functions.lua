NearATM = function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for i = 1, #Config.ATMs.models do
        local atm = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, Config.ATMDistance + 1.0, Config.ATMs.models[i], false, false, false)

        if DoesEntityExist(atm) then
            local dist = #(playerCoords - GetEntityCoords(atm))

            if dist <= 2.5 then
                currentATM = atm
            end
	        
	        if dist <= Config.ATMDistance then
                currentATM = atm
	            return true
	        end
	    end
    end

    return false
end

removeObject = function(object)
    if not object then return end
    if not DoesEntityExist(object) then return end
    logging('debug', 'removeObject', object)
    DeleteObject(object)
end

checkPin = function()
    local pin = MSK.Trigger('msk_banking:getPIN')

    if pin then
        if Config.MSKNumpad.enable then
            MSK.Numpad.Open(pin, Config.MSKNumpad.showPIN, function(isCorrect)
                if isCorrect then
                    openATM()
                end
            end)
        else
            MSK.Input.Open(Translation[Config.Locale]['get_pin'], 'PIN', function(input)
                if not input then return end
            
                if tonumber(input) then
                    if tonumber(input) == pin then
                        openATM()
                    else
                        Config.Notification(nil, Translation[Config.Locale]['wrong_pin'], 'error')
                    end
                else
                    Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
                end
            end)
        end
    else
        ClearPedTasks(PlayerPedId())
        Config.Notification(nil, Translation[Config.Locale]['no_pin_found'], 'error')
    end
end
exports('checkPin', checkPin)

getBankingInfo = function(bank)
    local hasBankcard = false

    if bank then
        hasBankcard = MSK.Trigger('msk_banking:hasBankcard')
    else
        hasBankcard = true
    end

    local mainAccount = MSK.Trigger('msk_banking:getMainAccount') -- identifier, cash, bank, iban, account
    local secondAccount = MSK.Trigger('msk_banking:getSecondAccount') -- identifier, bank, iban, account

    if mainAccount.iban then
        bankAccount = true
    else
        bankAccount = false
    end

    return mainAccount, secondAccount, hasBankcard
end
exports('getBankingInfo', getBankingInfo) -- exports.msk_banking:getBankingInfo(isBank --[[boolean]])

getSocietyInfo = function(jobname)
    local job = MSK.Trigger('msk_banking:getSocietyAccounts', jobname or ESX.PlayerData.job.name) -- identifier, name, bank, iban, label
    return job
end
exports('getSocietyInfo', getSocietyInfo) -- exports.msk_banking:getSocietyInfo()

reopenNativeUI = function(isBank)
    if _menuPool then _menuPool:CloseAllMenus() end
    local mainAccount, secondAccount, hasBankcard = getBankingInfo(isBank)

    if isBank then
        openBankMenu(mainAccount, secondAccount, hasBankcard) -- client.lua
    else
        openATMMenu(mainAccount, secondAccount, hasBankcard) -- client.lua
    end
end

setCustomBanner = function(menu, background)
    if not Config.CustomBanner then return end
    menu:SetBannerSprite(background, true)
end

canAccessSociety = function()
    local canAccess = false

    if Config.Society.atATM or currentBank then
        canAccess = true
    end

    if Config.Society.enable and canAccess then
        while not ESX.PlayerData.job do Wait(0) end
        local hasJob = hasPlayerJob()

        if hasJob then
            if hasPlayerJobGrade(hasJob.grade_name, ESX.PlayerData.job.grade_name) then
                return true
            end
        end
    end

    return false
end

hasPlayerJob = function()
    if Config.Society.jobs[ESX.PlayerData.job.name] then
        return Config.Society.jobs[ESX.PlayerData.job.name]
    end
    return false
end

hasPlayerJobGrade = function(grades, grade)
    for k, v in pairs(grades) do
        if v == grade then
            return true
        end
    end
    return false
end

genNumber = function()
    if not Config.IBAN.design then -- Only Numbers // example: 123456
        return math.random(111111, 999999)
    else -- Numbers and Letters // example: 63FH2C
        return math.random(00, 99) .. string.upper(MSK.GetRandomLetter(2)) .. math.random(0, 9) .. string.upper(MSK.GetRandomLetter(1))
    end
end

getCartridgeBursted = function(playerId)
	return MSK.Trigger('msk_banking:getCartridgeBursted', playerId)
end
exports('getCartridgeBursted', getCartridgeBursted)

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end