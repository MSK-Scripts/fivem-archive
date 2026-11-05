fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_armor'
description 'Multiple Armor Vests with Save Status function'
version '2.8.5'

lua54 'yes'

escrow_ignore {
	'config.lua',
	'locales/*.lua',
	'client.lua',
	'server.lua'
}

shared_script {
	'@es_extended/imports.lua',
	'@msk_core/import.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua',
	'server_encrypted.lua'
}

dependencies {
	'es_extended',
	'oxmysql',
	'msk_core'
}