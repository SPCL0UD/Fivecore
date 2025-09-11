fx_version 'cerulean'
game 'gta5'

author 'FiveCore'
description 'Trabajo de médico ultra realista con farmacia, historia clínica, cirugías y más'
version '1.0.0'

shared_scripts {
  'config.lua',
  'shared/medical_defs.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/main.lua',
  'server/billing.lua',
  'server/pharmacy.lua',
  'server/records.lua',
  'server/salary.lua'
}

client_scripts {
  'client/main.lua',
  'client/medical.lua',
  'client/hospital.lua',
  'client/pharmacy.lua',
  'client/tablet.lua',
  'client/stretcher.lua'
}

ui_page 'html/monitor.html'

files {
  'html/monitor.html',
  'html/monitor.css',
  'html/monitor.js',
  'html/tablet.html',
  'html/tablet.css',
  'html/tablet.js',
  'html/pharmacy.html',
  'html/pharmacy.css',
  'html/pharmacy.js'
}
