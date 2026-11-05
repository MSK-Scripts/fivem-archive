fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_simcard'
description 'Change your phonenumber'
version '4.0.1'

lua54 'yes'

escrow_ignore {
	'config.lua',
	'translation.lua',
	'client/*.lua',
	'server/server.lua',
	'server/server_functions.lua',
	'server/server_discordlog.lua',
}

shared_scripts {
	'@msk_core/import.lua',
	'translation.lua',
	'config.lua'
}

client_scripts {
	'@NativeUI/NativeUI.lua',
	'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

dependencies {
	'oxmysql',
	'msk_core'
}