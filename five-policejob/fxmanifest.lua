fx_version 'cerulean'
game 'gta5'

author 'FiveCore'
description 'Trabajo de policía completo para FiveCore'
version '1.0.0'

shared_scripts {
  'config.lua',
  'shared/police_defs.lua'
}

server_scripts {
  'server/main.lua',
  'server/billing.lua',
  'server/jail.lua',
  'server/dispatch.lua',
  'server/salary.lua',
  'server/records.lua',
  'server/tracking.lua',
  'server/armory.lua'
}

client_scripts {
  'client/main.lua',
  'client/actions.lua',
  'client/tablet.lua',
  'client/garage.lua',
  'client/uniform.lua',
  'client/locker.lua',
  'client/tracking.lua',
  'client/armory.lua'
}

ui_page 'html/tablet.html'

files {
  'html/tablet.html',
  'html/tablet.css',
  'html/tablet.js'
}

