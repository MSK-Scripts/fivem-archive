fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_deathcounter'
description 'Deathcounter for myMultichar'
version '2.5'

lua54 'yes'

escrow_ignore {
    'config.lua',
    'translation.lua',
    'client.lua',
    'server_discordlog.lua',
    'server.lua'
}

shared_scripts {
    'config.lua',
    'translation.lua'
}
  
client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server_discordlog.lua',
    'server.lua'
}

dependencies {
	'es_extended',
    'oxmysql',
    'myMultichar'
}