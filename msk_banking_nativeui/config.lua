Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.Debug = true
Config.VersionChecker = true
----------------------------------------------------------------
-- Add the Webhook Link in server_discordlog.lua
Config.DiscordLog = true
Config.botColor = "6205745" -- https://www.mathsisfun.com/hexadecimal-decimal-colors.html
Config.botName = "MSK Scripts"
Config.botAvatar = "https://i.imgur.com/PizJGsh.png"
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, typ)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'MSK Banking', message, typ, 5000)
    else -- clientside
        MSK.Notification('MSK Banking', message, typ, 5000)
    end
end
----------------------------------------------------------------
Config.Hotkey = 38 -- default: 38 = E // Change the Key in translation.lua too

Config.npcVoice = {
    enable = true, -- The NPC will say something to you
    inRange = 5.0,
    outRange = 5.0
}
----------------------------------------------------------------
Config.defaultTextUI = true -- Set false if you want to use a custom textui

Config.openTextUI = function(currentBank, atmText)
    if currentBank then -- If you open the Bank
        exports['okokTextUI']:Open(Translation[Config.Locale]['open_bank_textui']:format(currentBank.label), 'darkblue', 'left')
    else -- If you open the ATM
        exports['okokTextUI']:Open(atmText, 'darkblue', 'left')
    end
end

Config.closeTextUI = function()
    exports['okokTextUI']:Close()
end
----------------------------------------------------------------
Config.CustomBanner = true -- Set true to enable Custom Banner
Config.removeTitle = false -- If Custom Banner enabled, it will remove the Title from the NativeUI

Config.bannerBank = function(currentBank) -- Banner for Bank
    if currentBank.label == 'Fleeca Bank' then
        return Sprite.New('banner_fleeca', 'banner_fleeca', 0, 0, 512, 128) -- Banner for Fleeca Bank (banner_fleeca)
    elseif currentBank.label == 'Pacific Standard Bank' then
        return Sprite.New('banner_pacific', 'banner_pacific', 0, 0, 512, 128) -- Banner for Pacific Standard Bank (banner_pacific)
    elseif currentBank.label == 'Blain County Bank' then
        return Sprite.New('banner_pacific', 'banner_pacific', 0, 0, 512, 128) -- Banner for Blain County Bank (banner_pacific)
    end

    return Sprite.New('banner_blue', 'banner_blue', 0, 0, 512, 128) -- Banner if not one of the banks above
end

Config.bannerATM = function() -- Banner for ATMs (banner_atm)
    return Sprite.New('banner_atm', 'banner_atm', 0, 0, 512, 128)
end
----------------------------------------------------------------
-- This is only for PIN Input at ATMs
Config.MSKNumpad = {
    enable = true, -- If set to true then MSK.Numpad, if set to false then MSK.Input
    showPIN = false -- If you want to show the PIN at UI or not
}
----------------------------------------------------------------
-- Players can invest an amount of money and get some money ever X time ontop of the invested money
-- Example: If 10.000$ invested you get 1% every 3 hours, so after 3 hours you have 10.100$
Config.Investment = {
    enable = true, -- Set false if you don't want that Feature
    atATM = false, -- Set true if you also want the Investment at the Bank
    time = 3, -- in hours
    dynamic = {
        enable = true, -- Set false if you dont't want a chance to get money or lose money
        chance = 60 -- default: 60% that you get Money from Investment and 40% that you lose money
    },
    percentage = {
        -- Set both to the same number if you dont want random percentage
        min = 1, -- min: 1%
        max = 3 -- max: 100%
    },
    notification = true -- Set false if you don't want notifications if get or lost money
}
----------------------------------------------------------------
Config.Bills = {
    enable = true, -- Set false if you dont want to use Bills at the Bank
    atATM = false, -- Set true if you also want the Bills at the ATM
}

Config.okokBilling = {
    enable = false, -- Set true if you use okokBilling
    scriptname = 'okokBilling'
}
----------------------------------------------------------------
Config.Transactions = true -- Set false if you dont want transactions

Config.mainAccount = {
    enable = false, -- Set true if you want to use that Feature
    amount = 60000, -- Amount that the player gets on his Mainaccount if he created his Mainaccount
    price = 150 -- Price to create a Mainaccount
}

Config.bankAccounts = {
    enable = true, -- If set to true, the Player can create a second Bankaccount
    price = 500 -- Price for a new Second Bank Account
}

Config.PIN = {
    enable = true, -- Set false to disable the PIN Feature
    price = 50, -- Price for change the PIN
    length = 4 -- Max length of the PIN
}

Config.IBAN = {
    enable = true, -- Set false if you dont want that Players can change the IBAN themself
    delete = true, -- Set false if you dont want that Players can delete there second Bank Account
    prefix = 'SA', -- IBAN looks like this SAXXXXXX
    length = 6, -- default: 6 // max length for Custom IBAN // IBAN looks like this SAXXXXXX
    design = false, -- If false then numbers ONLY // If true then numbers and letters
    price = 500 -- default: $500
}

Config.Bankcard = {
    enable = true, -- If false then you dont need a Bankcard to open an ATM and you cant buy them in the Bank
    item = 'bankcard', -- Set the item that you want to use
    price = 100 -- default: $100 // Set the price that Players have to pay for a new Bankcard
}

Config.Animation = { -- Only for ATMs not for Banks
    enable = true, -- Set false if you dont want animations

    scenario = 'PROP_HUMAN_ATM',

    useBankcardProp = false, -- You'll need this: https://forum.cfx.re/t/free-props-wallet-props-cards-and-key-car/5039912
    bankcardProp = 'alcaprop_fleeca_card',

    useCashProp = true, -- Will be attached for a second when closing the ATM Menu
    cashProp = 'xs_prop_arena_cash_pile_s',
}

Config.Society = {
    enable = true, -- Set false if you dont want society accounts

    addon_account = true, -- Set true if you want to use esx_addon_account and NOT the Build-In System (view documentation how the Build-In System works)
    addon_account_sync_money = true, -- Set true if you want to sync addon_account and msk_banking money (Only if job is not already set in database)

    atATM = true, -- Set true if you want to access the society account at the ATM

    jobs = {
        -- IBAN always looks like Prefix + IBAN // Example: SALSPD
        -- Please insert the iban without prefix
        ['police'] = {label = 'LSPD', iban = 'LSPD', grade_name = {'boss', 'boss2'}},
        ['ambulance'] = {label = 'LSMC', iban = 'LSMC', grade_name = {'boss', 'boss2'}},
        ['mechanic'] = {label = 'LSC', iban = 'LSC', grade_name = {'boss', 'boss2'}},
    }
}
----------------------------------------------------------------
Config.ATMDistance = 1.5
Config.ATMs = {
    models = {-870868698, -1126237515, -1364697528, 506770882},
    robbery = {
        enable = true, -- Set false to disable ATM Robbery
        hotkey = 47, -- default: 47 = G
        timeout = 5, -- in minutes // Timeout until the next robbery
        neededItem = {enable = true, item = 'lockpick'},
        probability = {
            enable = true, -- Set false to disable probability
            percent = 50, -- probability of an ink cartridge bursting
            removeMoney = {enable = true, percent = 0.2 --[[0.1 = 10%]]} -- default: 20% of the money will be removed if an ink cartridge bursts
        },
        money = {
            method = 'money', -- 'money', 'bank', 'black_money'
            maxTimes = 5, -- Max Times to get Money // Set to 5 means that you get money 5 times
            interval = 10, -- in seconds // Interval to get money
            minAmount = 1000,
            maxAmount = 5000
        },
        jobs = {
            neededCops = 1, -- default: 2 Cops needed
            notifyJobs = {'police', 'fib'}, -- This Jobs will get a notify
            notifyDelay = {enable = false, delay = 10 --[[in seconds]]},
            blacklistJobs = {'police', 'fib', 'ambulance'} -- This Jobs can't rob an ATM
        },
        animation = {
            action = 'scenario', -- 'animation' or 'scenario'
            scenario = "WORLD_HUMAN_WELDING", -- only if action = 'scenario'
            dict = 'anim@amb@prop_human_atm@interior@male@enter', -- only if action = 'animation'
            anim = 'enter', -- only if action = 'animation'
        }
    }
}

Config.BankDistance = 2.5
Config.MarkerDistance = 5.0
Config.PedDistance = 15.0
Config.Banks = {
    -- !!! Some NPC Peds are NOT talking to you so test it with diffrent NPCs yourself !!!
    {label = 'Fleeca Bank', location = vector4(148.09, -1041.66, 29.37, 341.17), blip = {enable = true, id = 108, color = 5, scale = 0.8}, pedmodel = {enable = true, model = 'a_f_y_business_01'}, draw3dtext = {enable = true, label = '~g~Open Bank', size = 0.8}, marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}},
    {label = 'Fleeca Bank', location = vector4(-1211.95, -332.01, 37.78, 22.44), blip = {enable = true, id = 108, color = 5, scale = 0.8}, pedmodel = {enable = true, model = 's_f_y_airhostess_01'}, draw3dtext = {enable = true, label = '~g~Open Bank', size = 0.8}, marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}},
    {label = 'Fleeca Bank', location = vector4(-2961.14, 481.48, 15.7, 87.36), blip = {enable = true, id = 108, color = 5, scale = 0.8}, pedmodel = {enable = true, model = 's_f_y_airhostess_01'}, draw3dtext = {enable = true, label = '~g~Open Bank', size = 0.8}, marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}},
    {label = 'Fleeca Bank', location = vector4(312.28, -279.98, 54.16, 335.8), blip = {enable = true, id = 108, color = 5, scale = 0.8}, pedmodel = {enable = true, model = 's_f_y_airhostess_01'}, draw3dtext = {enable = true, label = '~g~Open Bank', size = 0.8}, marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}},
    {label = 'Fleeca Bank', location = vector4(-351.34, -51.24, 49.04, 336.09), blip = {enable = true, id = 108, color = 5, scale = 0.8}, pedmodel = {enable = true, model = 's_f_y_airhostess_01'}, draw3dtext = {enable = true, label = '~g~Open Bank', size = 0.8}, marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}},
    {label = 'Fleeca Bank', location = vector4(1176.34, 2708.21, 38.09, 179.69), blip = {enable = true, id = 108, color = 5, scale = 0.8}, pedmodel = {enable = true, model = 's_f_y_airhostess_01'}, draw3dtext = {enable = true, label = '~g~Open Bank', size = 0.8}, marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}},
    {label = 'Blain County Bank', location = vector4(-111.24, 6470.02, 31.63, 133.32), blip = {enable = true, id = 108, color = 5, scale = 0.8}, pedmodel = {enable = true, model = 's_f_m_shop_high'}, draw3dtext = {enable = true, label = '~g~Open Bank', size = 0.8}, marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}},
    {label = 'Pacific Standard Bank', location = vector4(248.92, 224.3, 106.29, 157.51), blip = {enable = true, id = 108, color = 5, scale = 0.8}, pedmodel = {enable = true, model = 's_f_m_shop_high'}, draw3dtext = {enable = true, label = '~g~Open Bank', size = 0.8}, marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}},
}
----------------------------------------------------------------
exports('Config', function()
    return Config
end)