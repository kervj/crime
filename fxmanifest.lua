fx_version 'cerulean'
games { 'gta5' }
shared_script 'config.lua'
lua54 'yes'

ui_page "html/index.html"
files {
    'html/index.html',
    'html/style.css',
    'html/reset.css'
}

client_scripts {
    'client.lua',
}

server_scripts {
	'server.lua',
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
}