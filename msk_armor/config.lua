Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
-- Exports (serverside)

-- exports.msk_armor:saveStatus({source = playerId}, playerHealth, playerArmor)
-- exports.msk_armor:saveStatus({identifier = playerIdentifier}, playerHealth, playerArmor)
-- exports.msk_armor:saveStatus({player = xPlayer}, playerHealth, playerArmor)
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'MSK Amror', message)
    else -- clientside
        MSK.Notification('MSK Amror', message)
    end
end
----------------------------------------------------------------
Config.Hotkey = {
    enable = false, -- Set true to enable the Hotkey
    key = 38, -- Set the Control you want to use
    item = 'bulletproof' -- Set the item that you want to use via Hotkey
}

Config.LoadStatus = { 
    health = true, -- Set false if you don't want to restore health after player connect
    armor = true, -- Set false if you don't want to restore armor after player connect
    restoreVest = true -- Set false if you don't want to restore the ArmorVest after player connect
}

Config.Refresh = {
    enable = true, -- Checks the current Armor status and removes the Vest if armor = 0
    time = 10, -- in seconds (default: 10 seconds)
    debug = false, -- Set true if you want to get a print in console // recommended: false (SPAM Alert)
}

Config.alreadySet = true -- Set to false if you don't want that the Vest Skin will change if the Player has already a Vest Skin
Config.giveNoBProof = true -- Set false if you don't want that you get the 'nobproof' item after using a 'bulletproof' item
Config.giveBackVest = true -- Set true if you want to give the item back if armor = 100%
Config.saveSkin = true -- Set false if you have Skin problems on playerConnect
------------------------------------------------------------
-- Animation for put on the Vest
Config.Animations = {
    dict = 'clothingtie',
    anim = 'try_tie_neutral_a',
    time = 2 -- in seconds (default: 2 seconds)
}
----------------------------------------------------------------
-- This Skin will be only set if the Player doesn't have already a Vest Skin and no item is set in msk_armor database table
-- If you dont want to use this then set Config.LoadStatus.restoreVest = false
Config.defaultSkin = {
    male = {
        ['bproof_1'] = 11, 
        ['bproof_2'] = 1
    },
    female = {
        ['bproof_1'] = 3, 
        ['bproof_2'] = 1
    },
}
----------------------------------------------------------------
Config.Armories = {
    ['bulletproof'] = { -- Item
        label = 'Bulletproof Vest',
        percent = 100,
        skin = {
            enable = true, -- Set false to disable change Vest Skin
            male = {
                ['bproof_1'] = 11,
                ['bproof_2'] = 1,
            },
            female = {
                ['bproof_1'] = 3,
                ['bproof_2'] = 1,
            },
        },
        removeItem = true,
        jobs = {enable = false, jobs = {'none'}} -- If enable = false then everyone can use that item
    },
    ['bulletproof2'] = { -- Item
        label = 'Bulletproof Vest',
        percent = 50,
        skin = {
            enable = true, -- Set false to disable change Vest Skin
            male = {
                ['bproof_1'] = 11,
                ['bproof_2'] = 1,
            },
            female = {
                ['bproof_1'] = 3,
                ['bproof_2'] = 1,
            },
        },
        removeItem = true,
        jobs = {enable = false, jobs = {'none'}} -- If enable = false then everyone can use that item
    },
    ['bulletproofpolice'] = { -- Item
        label = 'Police Bulletproof Vest',
        percent = 100,
        skin = {
            enable = true, -- Set false to disable change Vest Skin
            male = {
                ['bproof_1'] = 12,
                ['bproof_2'] = 3,
            },
            female = {
                ['bproof_1'] = 13,
                ['bproof_2'] = 1,
            },
        },
        removeItem = true,
        jobs = {enable = true, jobs = {'police'}} -- If enable = true then only the specific job can use that item
    },
}