-- ============================================================
--  yg_properties — EK SERVER ÖZELLİKLERİ
--  Keys (anahtar sistemi) + zil + relog'da evde doğma + NUI emlakçı.
--  qb-interior GEREKMEZ (shell'ler client'ta native oluşturulur).
-- ============================================================
local QBCore = exports['qb-core']:GetCoreObject()
local tonum = tonumber

local function getPlayer(src) return QBCore.Functions.GetPlayer(src) end
local function cid(src) local p = getPlayer(src); return p and p.PlayerData.citizenid or nil end
local function pname(src)
  local p = getPlayer(src); if not p then return 'Bilinmeyen' end
  local c = p.PlayerData.charinfo or {}
  return ((c.firstname or '') .. ' ' .. (c.lastname or '')):gsub('^%s+', '')
end
local function isOwnerCid(propertyId, myCid)
  if not myCid then return false end
  local row = MySQL.single.await('SELECT owner_citizenid FROM yg_properties WHERE id = ?', { propertyId })
  return row and row.owner_citizenid == myCid
end
local function bucketOf(propertyId) return Shared.BucketForProperty(propertyId) end

-- ============================================================
--  KEYS
-- ============================================================
lib.callback.register('yg_properties:server:getKeys', function(src, propertyId)
  propertyId = tonum(propertyId); if not propertyId then return {} end
  if not isOwnerCid(propertyId, cid(src)) then return {} end
  return MySQL.query.await('SELECT citizenid, name FROM yg_property_keys WHERE property_id = ?', { propertyId }) or {}
end)

-- give a key to a player by SERVER ID (or to nearest if target omitted handled client-side)
lib.callback.register('yg_properties:server:giveKey', function(src, propertyId, targetId)
  propertyId = tonum(propertyId); targetId = tonum(targetId)
  if not propertyId or not targetId then return false, 'bad' end
  if not isOwnerCid(propertyId, cid(src)) then return false, 'not_owner' end

  local tCid = cid(targetId); if not tCid then return false, 'no_target' end

  local cnt = MySQL.single.await('SELECT COUNT(*) AS c FROM yg_property_keys WHERE property_id = ?', { propertyId })
  if cnt and tonum(cnt.c) and tonum(cnt.c) >= (Config.Keys.maxHolders or 10) then return false, 'full' end

  MySQL.insert.await('INSERT IGNORE INTO yg_property_keys (property_id, citizenid, name) VALUES (?, ?, ?)',
    { propertyId, tCid, pname(targetId) })
  TriggerClientEvent('QBCore:Notify', targetId, 'Bir mülkün anahtarı sana verildi.', 'success')
  return true, pname(targetId)
end)

lib.callback.register('yg_properties:server:removeKey', function(src, propertyId, targetCid)
  propertyId = tonum(propertyId)
  if not propertyId or not targetCid then return false end
  if not isOwnerCid(propertyId, cid(src)) then return false end
  MySQL.update.await('DELETE FROM yg_property_keys WHERE property_id = ? AND citizenid = ?', { propertyId, targetCid })
  return true
end)

-- "My Keys" tab: properties where I'm a key holder or owner
lib.callback.register('yg_properties:server:getMyKeys', function(src)
  local myCid = cid(src); if not myCid then return {} end
  return MySQL.query.await([[
    SELECT p.id, p.label, p.type, p.door_coords,
           (p.owner_citizenid = ?) AS is_owner
    FROM yg_properties p
    LEFT JOIN yg_property_keys k ON k.property_id = p.id AND k.citizenid = ?
    WHERE p.owner_citizenid = ? OR k.citizenid = ?
  ]], { myCid, myCid, myCid, myCid }) or {}
end)

-- ============================================================
--  DOORBELL / KNOCK
-- ============================================================
RegisterNetEvent('yg_properties:server:knock', function(propertyId)
  local src = source
  propertyId = tonum(propertyId); if not propertyId then return end
  local b = bucketOf(propertyId)
  local who = pname(src)
  for _, pid in ipairs(GetPlayers()) do
    local s = tonum(pid)
    if s and GetPlayerRoutingBucket(s) == b then
      TriggerClientEvent('yg_properties:client:doorbell', s, who)
    end
  end
end)

-- ============================================================
--  RELOG — evdeysen tekrar girince evde doğ
-- ============================================================
local function recordInside(src, propertyId)
  local c = cid(src); if not c then return end
  MySQL.insert('INSERT INTO yg_property_inside (citizenid, property_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE property_id = VALUES(property_id)', { c, propertyId })
end
local function clearInside(src)
  local c = cid(src); if not c then return end
  MySQL.update('DELETE FROM yg_property_inside WHERE citizenid = ?', { c })
end

-- piggyback on the existing enter/exit events
AddEventHandler('yg_properties:server:enterBucket', function(propertyId)
  local src = source; propertyId = tonum(propertyId) or 0
  if propertyId > 0 then recordInside(src, propertyId) end
end)
AddEventHandler('yg_properties:server:exitBucket', function()
  clearInside(source)
end)

-- on load: if a record exists & property still exists, send player back inside
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
  local src = Player.PlayerData.source
  local c = Player.PlayerData.citizenid
  CreateThread(function()
    Wait(4000)
    local row = MySQL.single.await('SELECT property_id FROM yg_property_inside WHERE citizenid = ?', { c })
    if not row then return end
    local prop = MySQL.single.await('SELECT id FROM yg_properties WHERE id = ?', { row.property_id })
    if not prop then MySQL.update('DELETE FROM yg_property_inside WHERE citizenid = ?', { c }); return end
    SetPlayerRoutingBucket(src, bucketOf(row.property_id))
    TriggerClientEvent('yg_properties:client:respawnInside', src, row.property_id)
  end)
end)

-- ============================================================
--  NUI EMLAKÇI — kategoriden seçip bulunduğun yere mülk yerleştir
-- ============================================================
lib.callback.register('yg_properties:server:getRealtorCategories', function(src)
  -- Haritada pin gösterebilmek için, kind='ipl' olan seçeneklere GERÇEK
  -- dünya koordinatlarını (Config.IPLInteriors[ipl].spawn) ekliyoruz.
  -- kind='shell' olanların sabit bir konumu yok (oyuncunun durduğu yere
  -- kuruluyor), o yüzden onlara coords eklenmiyor — NUI tarafı bunu
  -- "konum satın alma sonrası belirlenir" olarak gösteriyor.
  local out = {}
  for _, cat in ipairs(Config.RealtorCategories or {}) do
    local newCat = { id = cat.id, label = cat.label, ptype = cat.ptype, options = {} }
    for _, opt in ipairs(cat.options or {}) do
      local newOpt = {
        label = opt.label, price = opt.price, entryFee = opt.entryFee,
        kind = opt.kind, ipl = opt.ipl, shellId = opt.shellId,
        img = opt.img, -- opsiyonel: config'te "img = 'eclipse_1.jpg'" verilmişse html/img/ altından gösterilir
      }
      if opt.kind == 'ipl' and opt.ipl and Config.IPLInteriors and Config.IPLInteriors[opt.ipl] then
        local def = Config.IPLInteriors[opt.ipl]
        if def.spawn then
          newOpt.coords = { x = def.spawn.x, y = def.spawn.y }
        end
      end
      newCat.options[#newCat.options + 1] = newOpt
    end
    out[#out + 1] = newCat
  end
  return out
end)

lib.callback.register('yg_properties:server:realtorCreate', function(src, catId, optIndex)
  local player = getPlayer(src); if not player then return false, 'no_player' end
  -- Bu örnekte herkes oluşturabilir; istersen Shared.IsAdmin ile kısıtla:
  -- if not Shared.IsAdmin(player.PlayerData) then return false, 'no_perm' end

  local cat
  for _, c in ipairs(Config.RealtorCategories or {}) do if c.id == catId then cat = c break end end
  if not cat then return false, 'bad_cat' end
  local opt = cat.options and cat.options[tonum(optIndex)]
  if not opt then return false, 'bad_opt' end

  local ped = GetPlayerPed(src)
  local coords = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)
  local door = Shared.EncodeVec4(vector4(coords.x, coords.y, coords.z, heading))
  local origin = Shared.EncodeVec4(vector4(0, 0, 0, 0))
  local label = (cat.ptype == 'home') and (Config.DefaultLabelHome or 'Ev') or (Config.DefaultLabelBusiness or 'İş Yeri')

  local shellId, iplId, kind = nil, nil, opt.kind
  if opt.kind == 'shell' then shellId = tonum(opt.shellId)
  elseif opt.kind == 'ipl' then iplId = opt.ipl end

  local id = MySQL.insert.await([[
    INSERT INTO yg_properties
      (type, label, price, entry_fee, owner_citizenid, created_by, door_coords, build_origin, interior_spawn, locked, employees, permissions, shell_id, interior_kind, ipl_id)
    VALUES (?, ?, ?, ?, NULL, ?, ?, ?, NULL, 0, '{}', ?, ?, ?, ?)
  ]], {
    cat.ptype, opt.label or label, tonum(opt.price) or 0, tonum(opt.entryFee) or 0,
    player.PlayerData.citizenid, door, origin,
    json.encode(Config.DefaultPermissions or {}),
    shellId, kind, iplId
  })

  if not id then return false, 'db' end
  TriggerClientEvent('yg_properties:client:refresh', -1)
  return true, id
end)

-- ============================================================
--  SATIŞ — sahibi mülkü satar (yarı fiyat geri), anahtarlar/iç kayıt temizlenir
-- ============================================================
lib.callback.register('yg_properties:server:sellProperty', function(src, propertyId)
  propertyId = tonum(propertyId); if not propertyId then return false, 'bad' end
  local myCid = cid(src); if not myCid then return false, 'no_player' end
  local prop = MySQL.single.await('SELECT id, price, owner_citizenid FROM yg_properties WHERE id = ?', { propertyId })
  if not prop then return false, 'no_prop' end
  if prop.owner_citizenid ~= myCid then return false, 'not_owner' end

  local refund = math.floor((tonum(prop.price) or 0) * 0.5)
  local player = getPlayer(src)
  if refund > 0 and player then player.Functions.AddMoney(Config.MoneyType or 'bank', refund, 'property-sold') end

  MySQL.update.await('UPDATE yg_properties SET owner_citizenid = NULL WHERE id = ?', { propertyId })
  MySQL.update.await('DELETE FROM yg_property_keys WHERE property_id = ?', { propertyId })
  MySQL.update.await('DELETE FROM yg_property_inside WHERE property_id = ?', { propertyId })
  TriggerClientEvent('QBCore:Notify', src, ('Mülk satıldı. İade: $%s'):format(refund), 'success')
  TriggerClientEvent('yg_properties:client:refresh', -1)
  return true, refund
end)

print('[yg_properties] server/extra.lua loaded (keys + doorbell + relog + realtor + sell)')

-- ============================================================
--  OTOMATİK MIGRATION — tablo/kolon eksikse kendini onarır
--  (SQL'i elle çalıştırmasan bile "Unknown column 'name'" hatası gitmez)
-- ============================================================
CreateThread(function()
  pcall(function()
    MySQL.query.await([[
      CREATE TABLE IF NOT EXISTS `yg_property_keys` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `property_id` INT NOT NULL,
        `citizenid` VARCHAR(64) NOT NULL,
        `name` VARCHAR(64) DEFAULT NULL,
        PRIMARY KEY (`id`),
        UNIQUE KEY `prop_cid` (`property_id`,`citizenid`),
        KEY `property_id` (`property_id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
  end)
  pcall(function()
    MySQL.query.await([[
      CREATE TABLE IF NOT EXISTS `yg_property_inside` (
        `citizenid` VARCHAR(64) NOT NULL,
        `property_id` INT NOT NULL,
        PRIMARY KEY (`citizenid`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
  end)
  -- kolon zaten varsa hata verir; pcall yutar (IF NOT EXISTS her sürümde yok)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_property_keys` ADD COLUMN `name` VARCHAR(64) DEFAULT NULL") end)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_properties` ADD COLUMN `interior_kind` VARCHAR(16) DEFAULT 'shell'") end)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_properties` ADD COLUMN `ipl_id` VARCHAR(48) DEFAULT NULL") end)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_properties` ADD COLUMN `stash_point` TEXT DEFAULT NULL") end)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_properties` ADD COLUMN `wardrobe_point` TEXT DEFAULT NULL") end)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_properties` ADD COLUMN `weather` VARCHAR(24) DEFAULT NULL") end)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_properties` ADD COLUMN `blackout` TINYINT(1) DEFAULT 0") end)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_properties` ADD COLUMN `time_of_day` VARCHAR(5) DEFAULT NULL") end)
  pcall(function() MySQL.query.await("ALTER TABLE `yg_properties` ADD COLUMN `shell_template_id` INT DEFAULT NULL") end)
  pcall(function() MySQL.query.await([[
    CREATE TABLE IF NOT EXISTS `yg_shell_templates` (
        `id`             INT          NOT NULL AUTO_INCREMENT,
        `label`          VARCHAR(80)  NOT NULL,
        `owner_citizenid` VARCHAR(50) DEFAULT NULL,
        `data`           LONGTEXT     NOT NULL,
        `piece_count`    INT          NOT NULL DEFAULT 0,
        `created_at`     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ]]) end)
  pcall(function() MySQL.query.await([[
    CREATE TABLE IF NOT EXISTS `yg_catalog_locations` (
        `id`         INT          NOT NULL AUTO_INCREMENT,
        `kind`       VARCHAR(10)  NOT NULL,
        `ref_key`    VARCHAR(50)  NOT NULL,
        `x`          FLOAT        NOT NULL,
        `y`          FLOAT        NOT NULL,
        `z`          FLOAT        DEFAULT NULL,
        `heading`    FLOAT        DEFAULT NULL,
        `set_by`     VARCHAR(50)  DEFAULT NULL,
        `updated_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`),
        UNIQUE KEY `kind_ref` (`kind`, `ref_key`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ]]) end)
  print('[yg_properties] migration check tamam')
end)
