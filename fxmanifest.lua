shared_script "@fta-jobs/shared.lua"
fx_version 'adamant'
game 'gta5'

ui_page 'web/build/index.html' 
ui_page_preload 'yes'

files {
	'web/build/*.*',
  'web/build/**/*.*'
}

shared_scripts {
  '@vrp/lib/Utils.lua',
  '@vrp/config/Groups.lua',
  '@vrp/config/Item.lua',
  'lib/utils.lua',
  'config/shared/*.lua',
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