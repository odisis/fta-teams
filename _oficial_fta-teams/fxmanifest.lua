shared_script "@fta-jobs/shared.lua"
fx_version 'adamant'
game 'gta5'

ui_page 'web/build/index.html' 
ui_page_preload 'yes'

files {
  'config/shared/*.lua',

	'web/build/*.*',
  'web/build/**/*.*'
}

shared_scripts {
  'utils/utils.lua',
	'utils/Tools.lua',
	'utils/Proxy.lua',
	'utils/Tunnel.lua'
}

client_scripts {
  'client/main.lua',
  'client/dev.lua',
  'client/modules/*.lua',
  'client/web/*.lua',
}

server_scripts {
  'server/main.lua',
  'server/dev.lua',
  'server/modules/*.lua',
  'server/api/*.lua',
}

dependencies {
  '/onesync',
  '/server:2843'
}

ignore_server_scripts {
  'token.lua'
}