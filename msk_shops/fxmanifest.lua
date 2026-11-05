fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_shops'
description 'Advanced Shopsystem with NativeUI'
version '2.8.1'

lua54 'yes'

escrow_ignore {
	'config.lua',
	'translation.lua',
	'server_discordlog.lua'
}

shared_scripts {
	'@es_extended/imports.lua',
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
	'server.lua',
	'server_*.lua'
}

dependencies {
	'es_extended',
	'oxmysql',
	'msk_core'
}