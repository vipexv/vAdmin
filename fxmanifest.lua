fx_version "cerulean"
lua54 'yes'
game 'gta5'


author 'vipex [Discord: vipex.v]'
description 'Advanced NUI Based Admin Menu.'
ui_page 'web/build/index.html'

shared_scripts {
	"config.lua",
	-- "@ox_lib/init.lua", -- Enable only if using ox_lib
	"shared/locale.lua",
	"locales/en.lua",
	'shared/utils.lua'
}

client_script "client/**/*"

server_scripts {
	"server/webhooks.lua",
	'server/sv_utils.lua',
	'server/Classes/**/*',
	"server/main.lua",
	"server/commands.lua"
}

files {
	'web/build/index.html',
	'web/build/**/*',
}

-- dependency "ox_lib" -- Enable only if using ox_lib
