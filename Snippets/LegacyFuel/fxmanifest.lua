fx_version 'bodacious'
game 'gta5'

author 'InZidiuZ edited by Musiker15'
description 'Legacy Fuel'
version '1.3'

shared_scripts {
	'@es_extended/imports.lua',
	'@msk_core/import.lua',
	'config.lua'
}

-- What to run
client_scripts {
	'functions/functions_client.lua',
	'source/fuel_client.lua'
}

server_scripts {
	'source/fuel_server.lua'
}

exports {
	'GetFuel',
	'SetFuel'
}