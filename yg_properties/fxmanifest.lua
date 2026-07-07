fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'yg_properties'
description 'Player housing & business'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/config.lua',
  'shared/shared.lua',
}

client_scripts {
  'client/gizmo.lua',
  'client/main.lua',
  'client/objects.lua',
  'client/builder.lua',
  'client/edit.lua',
  'client/buildmode.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/main.lua',
  'server/build.lua',
  'server/extra.lua',
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js',
  'html/img/**/*', -- emlakçı kartları / mülk detayları için kendi eklediğin görseller (html/img/README.txt'e bak)

  -- object_gizmo'dan AYNI MEKANİZMAYLA (GPL-3.0) port edilen client/gizmo.lua
  -- bu binary buffer yardımcısını `require 'client.dataview'` ile yüklüyor.
  -- client_scripts'e DEĞİL files'a konulmalı (otomatik çalışmasın, sadece
  -- require ile talep üzerine yüklensin) — orijinal object_gizmo'da da öyle.
  'client/dataview.lua',

  -- ===================================================================
  --  SHELL MODELLERİ (qb-interior'a artık gerek yok)
  --  Tek yapman gereken: qb-interior resource klasöründeki
  --    stream/starter_shells_k4mb1.ytyp
  --  dosyasını buradaki stream/ klasörüne kopyalamak. Kodu (client/main.lua
  --  NativeShells tablosu) qb-interior'un export mantığını birebir kendi
  --  içinde uyguluyor; qb-interior resource'u hiç kurulu/başlamış olmasa
  --  da shell_id'li mekanlar çalışır.
  -- ===================================================================
  'stream/**/*',
}

-- Her .ytyp'i otomatik kaydeder (glob destekli) — yeni dosya eklediğinde
-- burada hiçbir şey değiştirmene gerek yok.
data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'

-- Lynx Shells gibi .ymap ile SABİT bir dünya konumuna yerleştirilen
-- paketler için gerekli — bu olmadan ymap hiç yüklenmez, model görünmez
-- kalır (sadece tanımlı olur, dünyada hiçbir yerde durmaz).
this_is_a_map 'yes'

dependencies {
  'qb-core',
  'ox_lib',
  'oxmysql',
  -- object_gizmo KALDIRILDI — client/gizmo.lua kendi gizmomuz, dışarıdan
  -- hiçbir resource'a gerek yok (sadece NUI + native'ler).
}

-- NOT: target sistemi olarak ox_target VEYA qb-target'tan hangisi açıksa
-- otomatik onu kullanır (client/main.lua içindeki Bridge) — ikisinden
-- biri server'da başlamış olmalı, ikisi de fxmanifest dependencies'e
-- eklenmedi ki sadece biri kurulu olan sunucularda script hata vermesin.
