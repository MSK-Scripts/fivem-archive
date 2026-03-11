Config = {}
----------------------------------------------------------------
Config.Locale = 'de' -- 'de', 'en'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
-- Add the Webhook Link in server_discordlog.lua
Config.DiscordLog = true
Config.botColor = "6205745"
Config.botName = "MSK Shops"
Config.botAvatar = "https://i.imgur.com/PizJGsh.png"
----------------------------------------------------------------
Config.Hotkey = 38 -- default: 38 = E // Change the Key in translation.lua too
Config.npcVoice = {
    enable = true, -- The NPC will say something to you
    inRange = 5.0,
    outRange = 5.0
}

Config.defaultTextUI = true -- Set false if you want to use a custom textui

Config.openTextUI = function(currentShop)
    exports['okokTextUI']:Open(Translation[Config.Locale]['open_shop_textui']:format(currentShop.label), 'darkblue', 'left')
    -- exports["esx_textui"]:TextUI(Translation[Config.Locale]['open_shop_textui']:format(currentShop.label), 'info')
end

Config.closeTextUI = function()
    exports['okokTextUI']:Close()
    -- exports["esx_textui"]:HideUI()
end
----------------------------------------------------------------
-- It's like a Storagesystem for all Shops configured below.
-- You can set an max Amount of every item in database. If the amount is 0 then you cant buy this item anymore but still sell it.
-- Default Amount is 200 that will be set if the item is not in database and has to inserted.
-- Items will be uploaded to database automatically so you don't have to do anything :)

Config.useStorage = true -- Set true if you want to use that Feature
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, info)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'MSK Shops', message, info)
    else -- clientside
        MSK.Notification('MSK Shops', message, info)
    end
end
----------------------------------------------------------------
Config.Shops = {
    ['24/7'] = {
        label = '24/7 Shop',
        customBanner = {enable = true, removeTitle = true, banner = 'shopui_title_conveniencestore', x = 512, y = 128},
        -- Set license type to 'license' or 'item'
        license = {enable = true, type = 'license', label = 'Weaponlicense', name = 'weapon', method = {'money', 'bank'}, price = 500, buyLicense = true},
        addon_account = {enable = false, society = 'society_police'}, -- Money will be added/removed to/from the society account
        jobs = {enable = false, jobs = {
            {job = 'police', grade = 0},
        }},
        pedmodel = {enable = true, model = 's_m_y_airworker', distance = 20.0},
        text3d = {enable = true, label = '~g~Open 24/7 Shop', size = 0.8},
        marker = {enable = true, distance = 5.0, type = 27, size = {a = 0.6, b = 0.6, c = 0.6}, color = {a = 255, b = 255, c = 255}},
        blip = {enable = true, id = 59, color = 2, scale = 0.8},
        locations = {
            {x = 1727.71, y = 6415.24, z = 35.04, h = 242.06}, -- Paleto Bay
            {x = 1697.65, y = 4923.14, z = 42.063, h = 352.85}, -- Grapeseed
            {x = 1959.97, y = 3739.96, z = 32.34, h = 288.98}, -- Sandy Shores
            {x = 549.25, y = 2671.34, z = 42.156, h = 82.59}, -- Grand Senora
            {x = 24.44, y = -1347.33, z = 29.5, h = 266.37}, -- Near Unicorn
            {x = -1070.54, y = -2836.5, z = 27.7, h = 283.93}, -- Airport MLO
            {x = 372.48, y = 326.74, z = 103.57, h = 248.65}, -- Power Street bei 574
            {x = 2556.94, y = 380.71, z = 108.62, h = 342.38},
            {x = -3039.04, y = 584.18, z = 7.91, h = 357.0},
            {x = -3242.54, y = 999.74, z = 12.830, h = 336.15},
            {x = 1134.12, y = -982.77, z = 46.42, h = 279.46},
            {x = -1222.16, y = -908.53, z = 12.33, h = 23.5},
            {x = -1486.21, y = -377.92, z = 40.163, h = 126.46},
            {x = -2966.28, y = 390.67, z = 15.043, h = 85.91},
            {x = -47.08, y = -1758.46, z = 29.421, h = 53.42},
            {x = 1164.883, y = -323.38, z = 69.21, h = 106.81},
            {x = -705.9601, y = -914.250, z = 19.215, h = 110.24},
            {x = -1819.8, y = 793.92, z = 138.09, h = 154.0},
            {x = 1392.69, y = 3606.548, z = 34.980, h = 186.81}, -- Sandy Shores
            {x = 1166.14, y = 2710.830, z = 38.157, h = 168.31}, -- Grand Senora
            {x = 2677.75, y = 3279.35, z = 55.22, h = 325.98}, -- East Highway
        },
        items = { 
            -- Set 'type' to 'item' or 'weapon' // If 'weapon' then add 'ammo = 100' // Write Weapons always in BIG LETTERS!! // example: "WEAPON_PISTOL"
            -- Set 'license' to true or false // If 'false' you dont need the license to buy this item. // If 'true' you need to buy the license first
            -- Set 'price' or 'sellPrice' to false to disable buy or sell function
            -- Set 'jobRank' to false or to the number of the rank that can buy this item. // jobRank = 0 means that Rank 0 and everyone above can buy or sell

            {type = "item", label = "Bread", name = "bread", method = {'money', 'bank'}, jobRank = 0, license = true, price = 60, sellPrice = 30},
            {type = "item", label = "Hamburger", name = "hamburger", method = {'money', 'bank'}, jobRank = 0, license = false, price = 80, sellPrice = 40},
            {type = "item", label = "Water", name = "water", method = {'money', 'bank'}, jobRank = 0, license = false, price = 45, sellPrice = 20},
            {type = "item", label = "Icetea", name = "icetea", method = {'money', 'bank'}, jobRank = 0, license = false, price = 55, sellPrice = 25},
            {type = "item", label = "Fruitjuice", name = "jusfruit", method = {'money', 'bank'}, jobRank = 0, license = false, price = 50, sellPrice = 25},
            {type = "item", label = "Phone", name = "phone", method = {'money', 'bank'}, jobRank = 0, license = false, price = 1200, sellPrice = 600},
            {type = "item", label = "Bandage", name = "bandage", method = {'money', 'bank'}, jobRank = 0, license = false, price = 76, sellPrice = 40},
            {type = "item", label = "Beer", name = "beer", method = {'money', 'bank'}, jobRank = 0, license = false, price = 85, sellPrice = 40},
            {type = "item", label = "Contract", name = "contract", method = {'money', 'bank'}, jobRank = 0, license = false, price = 150, sellPrice = 80},
            {type = "item", label = "Backpack", name = "bag", method = {'money', 'bank'}, jobRank = 0, license = false, price = 500, sellPrice = 300},
        }
    },
    ['weaponshop'] = {
        label = 'Weaponshop',
        customBanner = {enable = true, removeTitle = true, banner = 'shopui_title_gunclub', x = 512, y = 128},
        -- Set license type to 'license' or 'item'
        license = {enable = true, type = 'license', label = 'Weaponlicense', name = 'weapon', method = {'money', 'bank'}, price = 1500, buyLicense = true},
        addon_account = {enable = false, society = 'society_police'}, -- Money will be added/removed to/from the society account
        jobs = {enable = false, jobs = {
            {job = 'police', grade = 0},
        }},
        pedmodel = {enable = true, model = 's_m_y_airworker', distance = 20.0},
        text3d = {enable = true, label = '~g~Open Weaponshop', size = 0.8},
        marker = {enable = true, distance = 5.0, type = 27, size = {a = 0.6, b = 0.6, c = 0.6}, color = {a = 255, b = 255, c = 255}},
        blip = {enable = true, id = 110, color = 81, scale = 0.8},
        locations = { -- You can set multiple locations
            {x = -661.767, y = -933.6132, z = 21.81, h = 153.07},   -- PLZ: 8140
            {x = 809.73, y = -2159.09, z = 29.61, h= 334.48},       -- PLZ: 9275
            {x = 1692.75, y = 3761.53, z = 34.68, h = 201.25},      -- PLZ: 3018
            {x = -331.18, y = 6085.64, z = 31.45, h = 192.75},      -- PLZ: 1034
            {x = 253.59, y = -51.44, z = 69.93, h = 51.02},         -- PLZ: 7121
            {x = 23.1, y = -1105.6, z = 29.8, h = 164.4},          -- PLZ: 8168
            {x = 253.72, y = -51.23, z = 69.93, z = 51.02},         -- PLZ: 7121
            {x = -1118.44, y = 2700.46, z = 18.54, h = 201.25},     -- PLZ: 5004
            {x = 841.49, y = -1035.32, z = 28.18, h = 342.99},      -- PLZ: 8194
        },
        items = { 
            -- Set 'type' to 'item' or 'weapon' // If 'weapon' then add 'ammo = 100' // Write Weapons always in BIG LETTERS!! // example: "WEAPON_PISTOL"
            -- Set 'license' to true or false // If 'false' you dont need the license to buy this item. // If 'true' you need to buy the license first
            -- Set 'price' or 'sellPrice' to false to disable buy or sell function
            -- Set 'jobRank' to false or to the number of the rank that can buy this item. // jobRank = 0 means that Rank 0 and everyone above can buy or sell

            {type = "item", label = "Pistolenmagazin", name = "pistolclip", method = {'money', 'bank'}, jobRank = 0, license = false, price = 100, sellPrice = 50},
            {type = "weapon", label = "Flashlight", name = "WEAPON_FLASHLIGHT", method = {'money', 'bank'}, ammo = 1, jobRank = 0, license = false, price = 100, sellPrice = 50},
            {type = "weapon", label = "Knife", name = "WEAPON_KNIFE", method = {'money', 'bank'}, ammo = 1, jobRank = 0, license = false, price = 100, sellPrice = 50},
            {type = "weapon", label = "Bat", name = "WEAPON_BAT", method = {'money', 'bank'}, ammo = 1, jobRank = 0, license = false, price = 100, sellPrice = 50},
            {type = "weapon", label = "Switchblade", name = "WEAPON_SWITCHBLADE", method = {'money', 'bank'}, ammo = 1, jobRank = 0, license = true, price = 200, sellPrice = 100},
            {type = "weapon", label = "Pistol", name = "WEAPON_PISTOL", method = {'money', 'bank'}, ammo = 100, jobRank = 0, license = true, price = 350, sellPrice = 2000},
            {type = "weapon", label = "SMG", name = "WEAPON_SMG", method = {'money', 'bank', 'black_money'}, ammo = 100, jobRank = 0, license = true, price = 5000, sellPrice = 3000},
        }
    },
    ['baumarkt'] = {
        label = 'Baumarkt',
        customBanner = {enable = true, removeTitle = false, banner = 'banner_blue', x = 512, y = 128},
        -- Set license type to 'license' or 'item'
        license = {enable = false, type = 'license', label = 'Weaponlicense', name = 'weapon', method = {'money', 'bank'}, price = 500, buyLicense = true},
        addon_account = {enable = false, society = 'society_police'}, -- Money will be added/removed to/from the society account
        jobs = {enable = false, jobs = {
            {job = 'police', grade = 0},
        }},
        pedmodel = {enable = true, model = 's_m_y_airworker', distance = 20.0},
        text3d = {enable = true, label = '~g~Open YouTools', size = 0.8},
        marker = {enable = true, distance = 5.0, type = 27, size = {a = 0.6, b = 0.6, c = 0.6}, color = {a = 255, b = 255, c = 255}},
        blip = {enable = true, id = 59, color = 2, scale = 0.8},
        locations = {
            {x = 2749.29, y = 3483.47, z = 55.67, h = 70.64}, -- East Highway
        },
        items = {
            -- Set 'type' to 'item' or 'weapon' // If 'weapon' then add 'ammo = 100' // Write Weapons always in BIG LETTERS!! // example: "WEAPON_PISTOL"
            -- Set 'license' to true or false // If 'false' you dont need the license to buy this item. // If 'true' you need to buy the license first
            -- Set 'price' or 'sellPrice' to false to disable buy or sell function
            -- Set 'jobRank' to false or to the number of the rank that can buy this item. // jobRank = 0 means that Rank 0 and everyone above can buy or sell

            {type = "item", label = "Drill", name = "drill", method = {'money', 'bank'}, jobRank = 0, license = false, price = 2500, sellPrice = 1800},
            {type = "item", label = "Oxygenmask", name = "oxygenmask", method = {'money', 'bank'}, jobRank = 0, license = false, price = 5000, sellPrice = 3000},
            {type = "item", label = "Lockpick", name = "lockpick", method = {'money', 'bank'}, jobRank = 0, license = false, price = 1500, sellPrice = 800},
            {type = "item", label = "Repairkit", name = "fixtool", method = {'money', 'bank'}, jobRank = 0, license = false, price = 1500, sellPrice = 800},
            {type = "item", label = "Cuffs", name = "cuffs", method = {'money', 'bank', 'black_money'}, jobRank = 0, license = false, price = 1120, sellPrice = 700},
            {type = "item", label = "Bottle", name = "glasbottle", method = {'money', 'bank'}, jobRank = 0, license = false, price = 10, sellPrice = 6},
            {type = "weapon", label = "Parachute", name = "GADGET_PARACHUTE", method = {'money', 'bank'}, jobRank = 0, license = false, ammo = 1, price = 500, sellPrice = 300},
        }
    },
}