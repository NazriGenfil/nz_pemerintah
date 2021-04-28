fx_version 'bodacious'
games { 'gta5' }

author 'Nazri Genfil'
description 'Script pemerintah yang sudah termasuk pajak.'
version '1.0.0'

server_scripts {
	'config.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/main.lua',
    -- 'server/pajak.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua',
    -- 'client/pajak.lua'
}