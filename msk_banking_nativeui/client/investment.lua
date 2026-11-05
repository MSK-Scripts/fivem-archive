if Config.Investment.enable then
    CreateThread(function()
        while ESX.PlayerLoaded do
            Wait(Config.Investment.time * 1000 * 60 * 60) -- in hours

            TriggerServerEvent('msk_banking:executeInvestment')
        end
    end)
end