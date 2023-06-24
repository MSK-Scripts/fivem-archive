Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, message)
    else -- clientside
        MSK.Notification(message)
    end
end
----------------------------------------------------------------
Config.Hotkey = 38
Config.Percent = 15 -- Amount = Blackmoney - Config.Percent
Config.neededItem = 'lockpick'

Config.notifyJobs = {
    enable = true, -- Set false if you don't want to notify specific jobs when Skillcheck was successfull
    blip = {enable = true, color = 1},
    dispatchDelay = 45, -- in seconds
    dispatchTime = 5, -- in minutes
    jobs = {'police', 'justice'}
}

Config.allowed = {
    enable = false, -- If false then everybody can use it
    jobs = {
        -- ['jobname'] = grade
        ['ndrangheta'] = 6,
        ['cardealer'] = 7,
    },
    character = {
        'char1:56832d3e10297ff3fa871b62b7ebab8b95e469b7', -- Musiker15 // Michael Reynold
        'char1:99c8ab5aff4633b863521be4ae9fa43ebce941e5', -- CMD // Andi Wand
    }
}

Config.BlackmoneyItems = {
    enable = true, 
    items = {
        {item = 'iron', percent = 0}, -- With this item you only lose 0% not 15%
    }
}
----------------------------------------------------------------
Config.startPoint = {
    distance = 10.0,
    coords = vec3(-338.94, -2444.44, 7.3),
    blip = {enable = false, label = 'Schwarzgeld waschen', id = 238, color = 1, scale = 0.8},
    marker = {enable = true, type = 1, size = {a = 1.0, b = 1.0, c = 0.6}, color = {a = 102, b = 0, c = 128}}
}

Config.Locations = {
    ['startWashmoney'] = vec4(1138.08, -3198.8, -39.66, 35.8),
    ['wash_money'] = {
        distance = 10.0, -- distance between player and location
        marker = {enable = true, distance = 1.5, type = 0, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 0, c = 0}},
        printCoords = {
            ['1'] = {coords = vec3(1132.37, -3197.28, -39.67), time = 8 --[[in seconds]]},
            ['2'] = {coords = vec3(1130.8, -3197.25, -39.67), time = 8 --[[in seconds]]},
            ['3'] = {coords = vec3(1129.25, -3197.27, -39.67), time = 8 --[[in seconds]]},
            ['4'] = {coords = vec3(1127.71, -3197.27, -39.67), time = 8 --[[in seconds]]},
        },
        moneyPrintEnd = {coords = vec3(1126.09, -3197.11, -39.67), time = 10 --[[in seconds]]},
        moneyCut = {coords = vec3(1122.09, -3197.8, -40.39), time = 10 --[[in seconds]]},
        moneyCount = {coords = vec3(1116.66, -3195.67, -40.4), time = 10 --[[in seconds]]},
    },
}
----------------------------------------------------------------
Config.SkillCheck = {
    difficulty = { -- Only if Config.Skillbar = 'oxlib'
        ['1'] = 'easy', -- 'easy', 'medium', 'hard'
        ['2'] = 'easy', -- 'easy', 'medium', 'hard'
        ['3'] = 'easy' -- 'easy', 'medium', 'hard'
    },
    inputs = {'w', 'a', 's', 'd'}, -- Only if Config.Skillbar = 'oxlib'
    animation = {
        enable = true, -- Set false to disable animation while SkillCheck
        dict = 'missheistfbisetup1',
        anim = 'hassle_intro_loop_f'
    },
    percent = 50 -- Probability to remove the lockpick Config.neededItem
}