fx_version "cerulean"
lua54 'yes'
game 'gta5'


author 'vipex [Discord: vipex.v]'
description 'Advanced NUI Based Admin Menu Built Using React/Typescript.'
ui_page 'web/build/index.html'

shared_scripts {
	"config.lua",
	"@ox_lib/init.lua",
	"shared/locale.lua",
	"locales/en.lua",
	'shared/utils.lua'
}

client_script "client/**/*"

server_scripts {
	"server/webhooks.lua",
	"server/main.lua"
}

files {
	'web/build/index.html',
	'web/build/**/*',
}

dependency "ox_lib"
