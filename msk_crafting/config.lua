Config = {}
----------------------------------------------------------------
Config.Locale = 'de' -- 'de', 'en'
Config.Debug = true
Config.VersionChecker = true
----------------------------------------------------------------
-- Add the Webhook Link in server_discordlog.lua
Config.DiscordLog = true
Config.botColor = "6205745" -- https://www.mathsisfun.com/hexadecimal-decimal-colors.html
Config.botDescription = "Someone has crafted an item"
Config.botName = "MSK Scripts"
Config.botAvatar = "https://i.imgur.com/PizJGsh.png"
----------------------------------------------------------------
Config.Hotkey = 38 -- default: 38 = E // Change the Key in translation.lua too
Config.npcVoice = {
    enable = true, -- The NPC will say something to you
    inRange = 5.0,
    outRange = 5.0
}
Config.defaultTextUI = true -- Set false if you want to use a custom textui

Config.openTextUI = function(currentCrafting)
    exports['okokTextUI']:Open(Translation[Config.Locale]['open_crafting_textui']:format(currentCrafting.label), 'darkblue', 'left')
    -- exports["esx_textui"]:TextUI(Translation[Config.Locale]['open_crafting_textui']:format(currentCrafting.label), 'info')
end

Config.closeTextUI = function()
    exports['okokTextUI']:Close()
    -- exports["esx_textui"]:HideUI()
end
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'MSK Crafting', message)
    else -- clientside
        MSK.Notification('MSK Crafting', message)
    end
end
----------------------------------------------------------------
-- !!! This function is CLIENTSIDE !!! --
-- You need a progressBar with a STOP function
Config.progressBarSTART = function(time, text) -- time is miliseconds // To make it seconds do: time * 1000 // an_progBar makes miliseconds to seconds itself
    -- https://github.com/aymannajim/an_progBar
    exports['an_progBar']:run(time, text, '#5eb131') -- You can add a color like: exports['an_progBar']:run(time, text, '#5eb131')
end
Config.progressBarSTOP = function()
    -- https://github.com/aymannajim/an_progBar
    exports['an_progBar']:stop()
end
----------------------------------------------------------------
-- !!! This function is CLIENTSIDE !!! --
-- This is only necessary if you set count = 'self' below
Config.Input = function(item, ingredients)
    local input = CreateDialog('Set the Amount you want to craft')
    Config.Submit(input, item, ingredients)
end

Config.Submit = function(input, item, ingredients)
    if input and tonumber(input) then
        item.count = tonumber(input)
        TriggerServerEvent('msk_crafting:craft', item, ingredients, true)
        item.count = 'self' -- !! Do NOT delete this line, otherwise you'll break the script !!
    else
        Config.Notification(nil, Translation[Config.Locale]['no_number'])
    end
end
----------------------------------------------------------------
Config.Crafting = {
    ["craft_1"] = { -- Unique Crafting ID
        label = 'Werkbank',
        customBanner = {enable = true, removeTitle = false, banner = 'banner_blue', x = 512, y = 128},
        -- type = 'license' or 'item'
        -- name = 'licensetype' or 'itemname'
        -- buyLicense = true or false // Set false if you don't want that player can buy a license at the Craftingpoint
        license = {enable = true, buyLicense = true, type = 'license', label = 'Weaponlicense', name = 'weapon', price = 100},
        jobs = {enable = false, jobs = { -- You can set multiple jobs
            {job = 'police', grade = 0},
        }},
        pedmodel = {enable = true, model = 's_m_y_airworker', distance = 20.0},
        text3d = {enable = true, label = '~g~Open Werkbank', size = 0.8},
        marker = {enable = true, distance = 5.0, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}},
        blip = {enable = true, id = 238, color = 26, scale = 0.8},
        locations = { -- You can set multiple locations
            {x = -2095.67, y = 2829.51, z = 32.96, h = 81.99},
            {x = -2094.87, y = 2835.52, z = 32.96, h = 86.35},
        },
        items = {
            -- type = 'item' or 'weapon'
            -- name = 'itemname' or 'WEAPON_NAME'
            -- license = true or false // true = need a license to craft // false = don't need a license to craft
            -- probability = number between 1 and 100 OR false
            -- count = {min = 1, max = 3} OR count = 1 OR count = 'self' // With count = 'self' the players can set an custom amount
            -- time = 5 // 5 seconds * count // If you set time = 5 and count = 2 then it takes 10 seconds
            {type = 'item', label = 'Schutzweste', name = 'bulletproof', probability = false, license = false, count = {min = 1, max = 3}, time = 5, 
                ingredients = {
                    {label = 'Aramid', name = 'aramid', count = 8},
                    {label = 'Keramik', name = 'ceramic', count = 2},
                }
            },
            {type = 'weapon', label = 'Pistole', name = 'WEAPON_PISTOL', ammo = 100, probability = 60, license = true, count = 1, time = 30, 
                ingredients = {
                    {label = 'Eisen', name = 'iron', count = 12},
                }
            },
            {type = 'item', label = 'Schutzweste2', name = 'bulletproof2', probability = false, license = false, count = 'self', time = 5, 
                ingredients = {
                    {label = 'Aramid', name = 'aramid', count = 4},
                    {label = 'Keramik', name = 'ceramic', count = 1},
                }
            },
        }
    },
    ["craft_2"] = { -- Unique Crafting ID
        label = 'Werkbank 2',
        customBanner = {enable = true, removeTitle = false, banner = 'banner_blue', x = 512, y = 128},
        license = {enable = true, buyLicense = true, type = 'license', label = 'Weaponlicense', name = 'weapon', price = 100},
        jobs = {enable = false, jobs = { -- You can set multiple jobs
            {job = 'police', grade = 0},
        }},
        pedmodel = {enable = true, model = 's_m_y_airworker', distance = 20.0},
        text3d = {enable = true, label = '~g~Open Werkbank', size = 0.8},
        marker = {enable = true, distance = 5.0, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}},
        blip = {enable = true, id = 238, color = 26, scale = 0.8},
        locations = { -- You can set multiple locations
            {x = -2083.87, y = 2955.92, z = 33.01, h = 332.27},
        },
        items = {
            {type = 'item', label = 'Schutzweste', name = 'bulletproof', probability = false, license = false, count = {min = 1, max = 3}, time = 5, 
                ingredients = {
                    {label = 'Aramid', name = 'aramid', count = 8},
                    {label = 'Keramik', name = 'ceramic', count = 2},
                }
            },
            {type = 'weapon', label = 'Pistole', name = 'WEAPON_PISTOL', ammo = 100, probability = 60, license = true, count = 1, time = 30, 
                ingredients = {
                    {label = 'Eisen', name = 'iron', count = 12},
                }
            },
            {type = 'item', label = 'Schutzweste2', name = 'bulletproof2', probability = false, license = false, count = 'self', time = 5, 
                ingredients = {
                    {label = 'Aramid', name = 'aramid', count = 4},
                    {label = 'Keramik', name = 'ceramic', count = 1},
                }
            },
        }
    },
}