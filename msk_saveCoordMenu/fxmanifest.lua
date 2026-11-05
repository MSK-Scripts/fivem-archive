fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_saveCoordMenu'
description 'Adminmenu to save coords in a menu'
version '1.4'

lua54 'yes'

shared_scripts {
	'@msk_core/import.lua',
	'translation.lua',
	'config.lua'
}

client_scripts {
	'@NativeUI/NativeUI.lua',
	'client.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server_discordlog.lua',
	'server.lua'
}

dependencies {
	'es_extended',
	'oxmysql',
	'msk_core'
}