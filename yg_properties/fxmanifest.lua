fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/config.lua',
  'shared/shared.lua',
  'shared/utils.lua',
}

client_scripts {
  'client/bridge.lua',
  'client/main.lua',
  'client/objects.lua',
  'client/builder.lua',
  'client/edit.lua',
  'client/interaction.lua',
  'client/property.lua',
  'client/doorbell.lua',
  'client/menu.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/database.lua',
  'server/keys.lua',
  'server/business.lua',
  'server/storage.lua',
  'server/property.lua',
  'server/main.lua',
  'server/build.lua',
  'server/tax.lua',
  'server/commands.lua',
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js',
}