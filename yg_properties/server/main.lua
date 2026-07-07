local QBCore = exports['qb-core']:GetCoreObject()

-- ✅ OPTİMİZASYON: Localized & cached functions
local GetPlayers = GetPlayers
local GetPlayerRoutingBucket = GetPlayerRoutingBucket
local TriggerClientEvent = TriggerClientEvent
local tonumber_fn = tonumber
local json_encode = json.encode
local json_decode = json.decode
local ipairs_fn = ipairs
local pairs_fn = pairs

-- ✅ OPTİMİZASYON: Cache system
local propertyCache = {}
local cacheExpire = Config.CacheExpire or 30000

local function cacheProperty(propertyId, data)
  propertyCache[propertyId] = {
    data = data,
    expire = GetGameTimer() + cacheExpire
  }
end

local function getCachedProperty(propertyId)
  local cached = propertyCache[propertyId]
  if cached and GetGameTimer() < cached.expire then
    return cached.data
  end
  propertyCache[propertyId] = nil
  return nil
end

local function clearPropertyCache(propertyId)
  propertyCache[propertyId] = nil
end

-- =========
-- Helpers
-- =========
local function getPlayer(src)
  return QBCore.Functions.GetPlayer(src)
end

local function cid(src)
  local p = getPlayer(src)
  return p and p.PlayerData.citizenid or nil
end

local function isLockedValue(v)
  return v == true or v == 1 or v == '1'
end

local function decodeJsonObject(value, fallback)
  local ok, data = pcall(json_decode, value or '')
  if ok and type(data) == 'table' then
    return data
  end
  return fallback or {}
end

local function normalizeEmployees(raw)
  local list = decodeJsonObject(raw, {})
  local out = {}

  if type(list) ~= 'table' then
    return out
  end

  for k, v in pairs_fn(list) do
    if type(k) == 'string' and v == true then
      out[k] = true
    elseif type(v) == 'string' and v ~= '' then
      out[v] = true
    elseif type(v) == 'table' and v.citizenid and v.citizenid ~= '' then
      out[v.citizenid] = true
    end
  end

  return out
end

local function encodeEmployeesMap(map)
  return json_encode(map or {})
end

local function defaultPermissions()
  return {
    employeesCanEnter = true,
    employeesCanManage = false,
    employeesCanManageDoor = false,
    employeesCanSetEntryFee = false,
    employeesCanEditDescription = false,
    employeesCanBuild = false,
    employeesCanDeposit = false,
    employeesCanWithdraw = false,
    employeesCanManageEmployees = false
  }
end

local function normalizePermissions(raw)
  local base = defaultPermissions()
  local data = decodeJsonObject(raw, {})

  for k, v in pairs_fn(data) do
    base[k] = (v == true)
  end

  return base
end

local function getPropertyRow(propertyId)
  return MySQL.single.await([[
    SELECT id, owner_citizenid, employees, permissions, locked, entry_fee, stash_money, type, label, description, shell_id, ipl_id, weather, blackout, time_of_day, door_coords
    FROM yg_properties
    WHERE id = ?
    LIMIT 1
  ]], { propertyId })
end

local function isOwner(src, propertyId)
  local myCid = cid(src)
  if not myCid then return false end

  local prop = MySQL.single.await('SELECT owner_citizenid FROM yg_properties WHERE id = ?', { propertyId })
  return prop and prop.owner_citizenid == myCid
end

local function isEmployeeOf(src, propertyId)
  local myCid = cid(src)
  if not myCid then return false end

  local row = MySQL.single.await('SELECT employees FROM yg_properties WHERE id = ?', { propertyId })
  if not row then return false end

  local employees = normalizeEmployees(row.employees)
  return employees[myCid] == true
end

local function hasEmployeePermission(src, propertyId, permKey)
  local myCid = cid(src)
  if not myCid then return false end

  local row = MySQL.single.await('SELECT employees, permissions FROM yg_properties WHERE id = ?', { propertyId })
  if not row then return false end

  local employees = normalizeEmployees(row.employees)
  if employees[myCid] ~= true then return false end

  local perms = normalizePermissions(row.permissions)
  return perms[permKey] == true
end

local function hasKey(src, propertyId)
  local myCid = cid(src)
  if not myCid then return false end
  local row = MySQL.single.await('SELECT 1 FROM yg_property_keys WHERE property_id = ? AND citizenid = ? LIMIT 1', { propertyId, myCid })
  return row ~= nil
end

local function canAccessProperty(src, propertyId)
  if isOwner(src, propertyId) then return true end
  if hasKey(src, propertyId) then return true end
  return hasEmployeePermission(src, propertyId, 'employeesCanEnter')
end

local function canManageProperty(src, propertyId)
  if isOwner(src, propertyId) then return true end
  return hasEmployeePermission(src, propertyId, 'employeesCanManage')
end

local function isAdmin(src)
  return true
end

-- ✅ OPTİMİZASYON: Broadcast to bucket only
local function broadcastPropertyUpdate(propertyId, eventName, ...)
  local bucketId = Shared.BucketForProperty(propertyId)
  local players = GetPlayers()
  for _, src in ipairs_fn(players) do
    local s = tonumber_fn(src)
    if s and GetPlayerRoutingBucket(s) == bucketId then
      TriggerClientEvent(eventName, s, ...)
    end
  end
  clearPropertyCache(propertyId)
end

print('[yg_properties] server/main.lua loaded')

-- =========================
-- Core callbacks
-- =========================
lib.callback.register('yg_properties:server:getProperties', function(src)
  return MySQL.query.await([[
    SELECT id,type,price,label,description,locked,entry_fee,owner_citizenid,door_coords,interior_spawn,shell_id,shell_template_id,interior_kind,ipl_id,stash_point,wardrobe_point
    FROM yg_properties
  ]]) or {}
end)

-- ✅ EKLENDİ: Emlakçı haritasında mülkleri göstermek için — IPL
-- mülkleri için konumu Config.IPLInteriors'tan OTOMATİK türetiyoruz
-- (zaten var olan veri, admin'in bir şey yapmasına gerek yok). Shell
-- mülkleri için (rastgele/izole cepte spawn oldukları için gerçek bir
-- konumları yok) yg_catalog_locations tablosundaki admin-atanmış
-- konumu kullanıyoruz — hiçbiri yoksa o mülk haritada hiç görünmez,
-- ama katalogda/satın almada sorunsuz kalır.
lib.callback.register('yg_properties:server:getRealtorCategories', function(src)
  if not Config.RealtorCategories then return {} end

  local customLocs = {}
  local rows = MySQL.query.await('SELECT kind, ref_key, x, y FROM yg_catalog_locations') or {}
  for _, r in ipairs(rows) do
    customLocs[r.kind .. ':' .. tostring(r.ref_key)] = { x = tonumber_fn(r.x), y = tonumber_fn(r.y) }
  end

  local cats = {}
  for _, cat in ipairs(Config.RealtorCategories) do
    local newOptions = {}
    for _, opt in ipairs(cat.options or {}) do
      -- sığ kopya — orijinal Config tablosuna dokunmuyoruz
      local newOpt = {}
      for k, v in pairs(opt) do newOpt[k] = v end

      if opt.kind == 'ipl' and opt.ipl and Config.IPLInteriors and Config.IPLInteriors[opt.ipl] then
        local def = Config.IPLInteriors[opt.ipl]
        if def.spawn then
          newOpt.coords = { x = def.spawn.x, y = def.spawn.y }
        end
      elseif opt.kind == 'shell' and opt.shellId then
        local loc = customLocs['shell:' .. tostring(opt.shellId)]
        if loc then newOpt.coords = loc end
      end

      newOptions[#newOptions + 1] = newOpt
    end
    cats[#cats + 1] = { id = cat.id, label = cat.label, ptype = cat.ptype, options = newOptions }
  end
  return cats
end)

lib.callback.register('yg_properties:server:getProperty', function(src, propertyId)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return nil end

  -- ✅ OPTİMİZASYON: Check cache first
  local cached = getCachedProperty(propertyId)
  if cached then return cached end

  local row = MySQL.single.await([[
    SELECT
  id,type,price,label,description,locked,entry_fee,owner_citizenid,
  door_coords,interior_spawn,stash_money,employees,permissions,build_origin,shell_id,shell_template_id,interior_kind,ipl_id,stash_point,wardrobe_point,weather,blackout,time_of_day
  FROM yg_properties
    WHERE id = ?
    LIMIT 1
  ]], { propertyId })

  if not row then return nil end

  row.permissions = normalizePermissions(row.permissions)
  row.employees = normalizeEmployees(row.employees)

  cacheProperty(propertyId, row)
  return row
end)

-- ✅ EKLENDİ: Build Mode'da inşa edilip "shell olarak kaydet" ile
-- kaydedilmiş bir şablonun parça listesini döndürür (client, mülkün
-- shell_template_id'si varsa bunu çağırıp SpawnShellForProperty'de
-- her parçayı KENDİ göreli konumuna spawn ediyor).
lib.callback.register('yg_properties:server:getShellTemplate', function(src, templateId)
  templateId = tonumber_fn(templateId)
  if not templateId then return nil end

  local row = MySQL.single.await('SELECT id, label, data, piece_count FROM yg_shell_templates WHERE id = ?', { templateId })
  if not row then return nil end

  local ok, decoded = pcall(json.decode, row.data)
  if not ok or not decoded then return nil end

  return { id = row.id, label = row.label, pieces = decoded.pieces or {} }
end)

lib.callback.register('yg_properties:server:canEnter', function(src, propertyId)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return false end

  local prop = MySQL.single.await('SELECT id, locked, owner_citizenid, employees, permissions FROM yg_properties WHERE id = ?', { propertyId })
  if not prop then return false end

  if not prop.owner_citizenid or prop.owner_citizenid == '' then
    return true
  end

  if isLockedValue(prop.locked) then
    return canAccessProperty(src, propertyId)
  end

  return true
end)

lib.callback.register('yg_properties:server:canManage', function(src, propertyId)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return false end

  local prop = MySQL.single.await('SELECT id, owner_citizenid FROM yg_properties WHERE id = ?', { propertyId })
  if not prop then return false end
  if not prop.owner_citizenid or prop.owner_citizenid == '' then return false end

  return canManageProperty(src, propertyId)
end)

lib.callback.register('yg_properties:server:setInteriorSpawnHere', function(src, propertyId, enc)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return false end
  if not isOwner(src, propertyId) then return false end

  MySQL.update.await('UPDATE yg_properties SET interior_spawn = ? WHERE id = ?', { enc, propertyId })
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
  return true
end)

-- Depo (stash) noktası — sahibi içerideyken bastığı yere koyar; oradan target ile açılır.
lib.callback.register('yg_properties:server:setStashPointHere', function(src, propertyId, enc)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return false end
  if not isOwner(src, propertyId) then return false end

  MySQL.update.await('UPDATE yg_properties SET stash_point = ? WHERE id = ?', { enc, propertyId })
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  return true
end)

-- Gardırop noktası — aynı mantık, ayrı bir stash (kıyafet deposu) için.
lib.callback.register('yg_properties:server:setWardrobePointHere', function(src, propertyId, enc)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return false end
  if not isOwner(src, propertyId) then return false end

  MySQL.update.await('UPDATE yg_properties SET wardrobe_point = ? WHERE id = ?', { enc, propertyId })
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  return true
end)

-- =========================
-- Admin create
-- =========================
local function createProperty(src, pType, price, entryFee, shellId)
  local ped = GetPlayerPed(src)
  local coords = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)

  local player = getPlayer(src)
  if not player then return nil end

  local createdBy = player.PlayerData.citizenid
  local label = (pType == 'home') and (Config.DefaultLabelHome or 'Ev') or (Config.DefaultLabelBusiness or 'İş Yeri')

  local door = vector4(coords.x, coords.y, coords.z, heading)
  local employees = json_encode({})
  local perms = json_encode(Config.DefaultPermissions or defaultPermissions())

  shellId = tonumber_fn(shellId)
  if shellId and (not Config.PropertyShells or not Config.PropertyShells[shellId]) then
    shellId = nil
  end

  local insertId = MySQL.insert.await([[
    INSERT INTO yg_properties
      (type, label, price, entry_fee, owner_citizenid, created_by, door_coords, build_origin, interior_spawn, locked, employees, permissions, shell_id)
    VALUES
      (?, ?, ?, ?, NULL, ?, ?, ?, NULL, ?, ?, ?, ?)
  ]], {
    pType,
    label,
    price or 0,
    entryFee or 0,
    createdBy,
    Shared.EncodeVec4(door),
    Shared.EncodeVec4(vector4(0,0,0,0)),
    (Config.DefaultLocked and 1 or 0),
    employees,
    perms,
    shellId
  })

  if not insertId then return nil end
  return insertId
end

-- ✅ EKLENDİ: Emlakçı, istediği bir yere GİDİP, oradaki konumu bir
-- katalog shell'ine (rastgele/izole cepte spawn olduğu için gerçek bir
-- konumu olmayan mülkler) "harita pin'i" olarak atayabiliyor. IPL
-- mülklerine hiç gerek yok (onlarınki zaten Config.IPLInteriors'tan
-- otomatik geliyor).
QBCore.Commands.Add('mulklokasyon', 'Bir shell icin bulundugun konumu harita pini olarak ata', {
  { name = 'shellId', help = 'Config.NativeShells icindeki shell ID (sayi)' },
}, true, function(source, args)
  local player = QBCore.Functions.GetPlayer(source)
  if not player or not Shared.IsAdmin(player.PlayerData) then
    TriggerClientEvent('QBCore:Notify', source, 'Bu komutu kullanma yetkin yok.', 'error')
    return
  end

  local shellId = tonumber_fn(args[1])
  if not shellId then
    TriggerClientEvent('QBCore:Notify', source, 'Kullanım: /mulklokasyon <shellId>', 'error')
    return
  end

  local ped = GetPlayerPed(source)
  local coords = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)

  MySQL.query.await([[
    INSERT INTO yg_catalog_locations (kind, ref_key, x, y, z, heading, set_by)
    VALUES ('shell', ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE x = ?, y = ?, z = ?, heading = ?, set_by = ?
  ]], {
    tostring(shellId), coords.x, coords.y, coords.z, heading, player.PlayerData.citizenid,
    coords.x, coords.y, coords.z, heading, player.PlayerData.citizenid,
  })

  TriggerClientEvent('QBCore:Notify', source, ('Shell #%d için harita konumu kaydedildi (%.1f, %.1f).'):format(shellId, coords.x, coords.y), 'success')
end)

QBCore.Commands.Add('evolustur', 'Ev oluşturur', {
  { name = 'fiyat', help = 'Satın alma fiyatı' },
  { name = 'shell', help = 'Shell ID (opsiyonel)' },
  { name = 'sablon', help = 'Kaydedilmiş Shell Şablonu ID (opsiyonel, "shell" yerine)' },
}, false, function(source, args)
  local price = tonumber_fn(args[1] or '0') or 0
  local shellId = tonumber_fn(args[2])
  local templateId = tonumber_fn(args[3])

  if shellId and (not Config.PropertyShells or not Config.PropertyShells[shellId]) then
    TriggerClientEvent('QBCore:Notify', source, ('Geçersiz shell ID: %s'):format(shellId), 'error')
    return
  end

  local id = createProperty(source, 'home', price, 0, shellId)
  if id and templateId then
    -- ✅ EKLENDİ: Build Mode'da kaydedilmiş bir şablonu bu yeni mülke ata
    MySQL.update.await('UPDATE yg_properties SET shell_template_id = ? WHERE id = ?', { templateId, id })
  end
  if id then
    if templateId then
      TriggerClientEvent('QBCore:Notify', source, ('Ev oluşturuldu. ID: %s | Şablon: %s'):format(id, templateId), 'success')
    elseif shellId then
      TriggerClientEvent('QBCore:Notify', source, ('Ev oluşturuldu. ID: %s | Shell: %s'):format(id, shellId), 'success')
    else
      TriggerClientEvent('QBCore:Notify', source, ('Ev oluşturuldu. ID: %s'):format(id), 'success')
    end
    TriggerClientEvent('yg_properties:client:refresh', -1)
  else
    TriggerClientEvent('QBCore:Notify', source, 'Ev oluşturulamadı.', 'error')
  end
end)

QBCore.Commands.Add('isyeriolustur', 'İş yeri oluşturur (Admin)', {
  { name = 'fiyat', help = 'Satın alma fiyatı' },
  { name = 'giris', help = 'Giriş ücreti (opsiyonel)' },
  { name = 'shell', help = 'Shell ID (opsiyonel)' },
}, false, function(source, args)
  if not isAdmin(source) then return end
  
  local price = tonumber(args[1] or '0') or 0
  local entryFee = tonumber(args[2] or '0') or 0
  local shellId = tonumber(args[3])

  if shellId and (not Config.PropertyShells or not Config.PropertyShells[shellId]) then
    TriggerClientEvent('QBCore:Notify', source, ('Geçersiz shell ID: %s'):format(shellId), 'error')
    return
  end

  local id = createProperty(source, 'business', price, entryFee, shellId)
  if id then
    if shellId then
      TriggerClientEvent('QBCore:Notify', source, ('İş yeri oluşturuldu. ID: %s | Shell: %s'):format(id, shellId), 'success')
    else
      TriggerClientEvent('QBCore:Notify', source, ('İş yeri oluşturuldu. ID: %s'):format(id), 'success')
    end
    TriggerClientEvent('yg_properties:client:refresh', -1)
  else
    TriggerClientEvent('QBCore:Notify', source, 'İş yeri oluşturulamadı.', 'error')
  end
end)

-- =========================
-- Purchase
-- =========================
lib.callback.register('yg_properties:server:buyProperty', function(src, propertyId)
  local p = getPlayer(src)
  if not p then return false, 'player_not_found' end

  local prop = MySQL.single.await('SELECT id, price, owner_citizenid FROM yg_properties WHERE id = ?', { propertyId })
  if not prop then return false, 'property_not_found' end
  if prop.owner_citizenid then return false, 'already_owned' end

  local price = tonumber_fn(prop.price) or 0
  if price > 0 then
    local ok = p.Functions.RemoveMoney(Config.MoneyType, price, 'buy-property')
    if not ok then return false, 'not_enough_money' end
  end

  MySQL.update.await('UPDATE yg_properties SET owner_citizenid = ? WHERE id = ?', { p.PlayerData.citizenid, propertyId })
  clearPropertyCache(propertyId)
  TriggerClientEvent('yg_properties:client:refresh', -1)
  return true, 'ok'
end)

lib.callback.register('yg_properties:server:payEntryFee', function(src, propertyId)
  local p = getPlayer(src)
  if not p then return false, 'player_not_found' end

  local prop = MySQL.single.await('SELECT id, type, entry_fee, owner_citizenid FROM yg_properties WHERE id = ?', { propertyId })
  if not prop then return false, 'property_not_found' end
  if prop.type ~= 'business' then return true, 'ok' end

  if canAccessProperty(src, propertyId) then
    return true, 'ok'
  end

  local fee = tonumber_fn(prop.entry_fee) or 0
  if fee <= 0 then return true, 'ok' end

  local ok = p.Functions.RemoveMoney(Config.MoneyType, fee, 'business-entry-fee')
  if not ok then return false, 'not_enough_money' end

  MySQL.update.await('UPDATE yg_properties SET stash_money = stash_money + ? WHERE id = ?', { fee, propertyId })
  return true, 'ok'
end)

-- =========================
-- Buckets
-- =========================
RegisterNetEvent('yg_properties:server:enterBucket', function(propertyId)
  local src = source
  propertyId = tonumber_fn(propertyId) or 0
  if propertyId <= 0 then return end
  SetPlayerRoutingBucket(src, Shared.BucketForProperty(propertyId))
end)

RegisterNetEvent('yg_properties:server:exitBucket', function()
  SetPlayerRoutingBucket(source, 0)
end)

-- =========================
-- Command: open panel
-- =========================
QBCore.Commands.Add('mekanpanel', 'İçeride bulunduğun mekanın patron panelini açar', {}, false, function(source)
  TriggerClientEvent('yg_properties:client:openPanelCurrent', source)
end)

AddEventHandler('onServerResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(3000)
        
        local props = MySQL.query.await('SELECT id FROM yg_properties') or {}
        
        for _, prop in ipairs_fn(props) do
            local stashId = ('yg_property_%s'):format(prop.id)
            local label = ('Mülk #%s Stash'):format(prop.id)
            
            if exports.ox_inventory then
                exports.ox_inventory:RegisterStash(stashId, label, 50, 100000)
                print('[yg_properties] Stash registered: ' .. stashId)
            end
        end
    end
end)

RegisterNetEvent('yg_properties:server:setLabel', function(propertyId, label)
  local src = source
  propertyId = tonumber_fn(propertyId)
  label = tostring(label or ''):sub(1, 48)
  if not propertyId then return end

  if not isOwner(src, propertyId) then
    TriggerClientEvent('QBCore:Notify', src, 'Sadece sahip mekan adını değiştirebilir.', 'error')
    return
  end

  MySQL.update.await('UPDATE yg_properties SET label = ? WHERE id = ?', { label, propertyId })
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
end)

RegisterNetEvent('yg_properties:server:setDescription', function(propertyId, description)
  local src = source
  propertyId = tonumber_fn(propertyId)
  description = tostring(description or ''):sub(1, 512)
  if not propertyId then return end

  if not isOwner(src, propertyId) and not hasEmployeePermission(src, propertyId, 'employeesCanEditDescription') then
    TriggerClientEvent('QBCore:Notify', src, 'Açıklama değiştirme yetkin yok.', 'error')
    return
  end

  MySQL.update.await('UPDATE yg_properties SET description = ? WHERE id = ?', { description, propertyId })
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
end)

RegisterNetEvent('yg_properties:server:setLocked', function(propertyId, locked)
  local src = source
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return end

  if not isOwner(src, propertyId) and not hasEmployeePermission(src, propertyId, 'employeesCanManageDoor') then
    TriggerClientEvent('QBCore:Notify', src, 'Kilit yönetme yetkin yok!', 'error')
    return
  end

  local newLocked = isLockedValue(locked) and 1 or 0

  MySQL.update.await('UPDATE yg_properties SET locked = ? WHERE id = ?', { newLocked, propertyId })

  print(("[yg_properties] ID %s kilit durumu %s yapıldı."):format(propertyId, newLocked))

  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
end)

RegisterNetEvent('yg_properties:server:setEntryFee', function(propertyId, fee)
  local src = source
  propertyId = tonumber_fn(propertyId)
  fee = tonumber_fn(fee) or 0
  if not propertyId then return end

  if not isOwner(src, propertyId) and not hasEmployeePermission(src, propertyId, 'employeesCanSetEntryFee') then
    TriggerClientEvent('QBCore:Notify', src, 'Giriş ücretini değiştirme yetkin yok.', 'error')
    return
  end

  if fee < 0 then fee = 0 end
  if fee > 1000000 then fee = 1000000 end

  MySQL.update.await('UPDATE yg_properties SET entry_fee = ? WHERE id = ?', { fee, propertyId })

  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
end)

-- Sadece bu mülkün BUCKET'ındaki oyuncuları etkiler — SetOverrideWeather
-- client-taraflı bir native olduğu için zaten sadece çağrıldığı client'ı
-- etkiliyor (client/main.lua sadece bu mekana giren oyuncularda çağırıyor,
-- başka hiç kimseye TriggerClientEvent atmıyoruz).
local VALID_WEATHERS = {
  CLEAR = true, EXTRASUNNY = true, CLOUDS = true, OVERCAST = true, RAIN = true,
  CLEARING = true, THUNDER = true, SMOG = true, FOGGY = true, XMAS = true,
  SNOWLIGHT = true, BLIZZARD = true, SNOW = true, HALLOWEEN = true, NEUTRAL = true,
}
RegisterNetEvent('yg_properties:server:setWeather', function(propertyId, weather)
  local src = source
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return end

  if not isOwner(src, propertyId) then
    TriggerClientEvent('QBCore:Notify', src, 'Hava durumunu değiştirme yetkin yok.', 'error')
    return
  end

  -- boş string / 'default' -> NULL (mekan kendi hava durumunu zorlamasın, ambient kalsın)
  if weather == '' or weather == 'default' then
    weather = nil
  elseif not VALID_WEATHERS[tostring(weather):upper()] then
    return -- tanınmayan bir değer gönderildiyse sessizce yok say
  else
    weather = tostring(weather):upper()
  end

  MySQL.update.await('UPDATE yg_properties SET weather = ? WHERE id = ?', { weather, propertyId })

  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
end)

-- ✅ SetArtificialLightsState client-taraflı bir native — qb-weathersync'in
-- kendi "/blackout" komutunun kullandığı AYNI mekanizma. Biz bunu sadece
-- bu mekana GİRMİŞ olan client'larda çağırıyoruz (client/main.lua),
-- yani "sadece o bucket" isteği hava durumuyla AYNI şekilde doğal olarak
-- sağlanıyor — başka hiçbir oyuncuya TriggerClientEvent atmıyoruz.
RegisterNetEvent('yg_properties:server:setBlackout', function(propertyId, state)
  local src = source
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return end

  if not isOwner(src, propertyId) then
    TriggerClientEvent('QBCore:Notify', src, 'Karartmayı değiştirme yetkin yok.', 'error')
    return
  end

  MySQL.update.await('UPDATE yg_properties SET blackout = ? WHERE id = ?', { state and 1 or 0, propertyId })

  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
end)

-- ✅ NetworkOverrideClockTime — bu da client-taraflı, hava durumu/
-- karartma ile AYNI mantık: sadece mekana girmiş olan client'ta çağrılıyor.
RegisterNetEvent('yg_properties:server:setTime', function(propertyId, timeStr)
  local src = source
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return end

  if not isOwner(src, propertyId) then
    TriggerClientEvent('QBCore:Notify', src, 'Saati değiştirme yetkin yok.', 'error')
    return
  end

  if timeStr == '' or timeStr == 'default' then
    timeStr = nil
  else
    local h, m = tostring(timeStr):match('^(%d%d?):(%d%d)$')
    h, m = tonumber_fn(h), tonumber_fn(m)
    if not h or not m or h < 0 or h > 23 or m < 0 or m > 59 then return end
    timeStr = ('%02d:%02d'):format(h, m)
  end

  MySQL.update.await('UPDATE yg_properties SET time_of_day = ? WHERE id = ?', { timeStr, propertyId })

  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
end)

-- =========================
-- Employees + Permissions + Safe
-- =========================

-- Mülk Detayları panelinde gösterilecek görseli bulur — YENİ bir DB
-- alanı eklemeden, mülkün zaten sahip olduğu shell_id/ipl_id'yi
-- Config.RealtorCategories'teki seçeneklerle eşleştirip, o seçeneğin
-- (varsa) "img" alanını geri döndürür. Hiçbir seçenekte img tanımlı
-- değilse (şu an hiçbirinde yok, kullanıcı kendi ekleyecek) nil döner,
-- NUI o zaman eskisi gibi ikon gösterir.
local function ResolveCatalogImage(prop)
  if not Config.RealtorCategories then return nil end
  local shellId = tonumber_fn(prop.shell_id)
  local iplId = prop.ipl_id
  for _, cat in ipairs(Config.RealtorCategories) do
    for _, opt in ipairs(cat.options or {}) do
      if opt.img then
        if shellId and opt.kind == 'shell' and tonumber_fn(opt.shellId) == shellId then return opt.img end
        if iplId and opt.kind == 'ipl' and opt.ipl == iplId then return opt.img end
      end
    end
  end
  return nil
end

lib.callback.register('yg_properties:server:getManagementData', function(src, propertyId)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return nil end

  local prop = getPropertyRow(propertyId)
  if not prop then return nil end

  if not prop.owner_citizenid or prop.owner_citizenid == '' then
    return nil
  end

  if not canManageProperty(src, propertyId) then
    return nil
  end

  return {
    id = prop.id,
    owner_citizenid = prop.owner_citizenid,
    employees = normalizeEmployees(prop.employees),
    permissions = normalizePermissions(prop.permissions),
    stash_money = tonumber_fn(prop.stash_money) or 0,
    locked = isLockedValue(prop.locked),
    entry_fee = tonumber_fn(prop.entry_fee) or 0,
    type = prop.type,
    label = prop.label or 'Mekan',
    description = prop.description or '',
    weather = prop.weather,
    blackout = tonumber_fn(prop.blackout) == 1,
    time_of_day = prop.time_of_day,
    door_coords = prop.door_coords, -- ✅ EKLENDİ: Mülk Yönetim panelindeki Konum haritası için
    img = ResolveCatalogImage(prop), -- opsiyonel, html/img/README.txt'e bak
  }
end)

lib.callback.register('yg_properties:server:getPropertySafeMoney', function(src, propertyId)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return 0 end

  if not canManageProperty(src, propertyId) then
    return 0
  end

  local row = MySQL.single.await('SELECT stash_money FROM yg_properties WHERE id = ?', { propertyId })
  return row and (tonumber_fn(row.stash_money) or 0) or 0
end)

RegisterNetEvent('yg_properties:server:depositSafeMoney', function(propertyId, amount)
  local src = source
  propertyId = tonumber_fn(propertyId)
  amount = math.floor(tonumber_fn(amount) or 0)

  if not propertyId or amount <= 0 then return end

  if not isOwner(src, propertyId) and not hasEmployeePermission(src, propertyId, 'employeesCanDeposit') then
    TriggerClientEvent('QBCore:Notify', src, 'Kasaya para koyma yetkin yok.', 'error')
    return
  end

  local p = getPlayer(src)
  if not p then return end

  local ok = p.Functions.RemoveMoney(Config.MoneyType, amount, 'property-safe-deposit')
  if not ok then
    TriggerClientEvent('QBCore:Notify', src, 'Üzerinde yeterli para yok.', 'error')
    return
  end

  MySQL.update.await('UPDATE yg_properties SET stash_money = COALESCE(stash_money, 0) + ? WHERE id = ?', {
    amount, propertyId
  })

  TriggerClientEvent('QBCore:Notify', src, ('$%s kasaya koydun.'):format(amount), 'success')
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
end)

RegisterNetEvent('yg_properties:server:withdrawSafeMoney', function(propertyId, amount)
  local src = source
  propertyId = tonumber_fn(propertyId)
  amount = math.floor(tonumber_fn(amount) or 0)

  if not propertyId or amount <= 0 then return end

  if not isOwner(src, propertyId) and not hasEmployeePermission(src, propertyId, 'employeesCanWithdraw') then
    TriggerClientEvent('QBCore:Notify', src, 'Kasadan para çekme yetkin yok.', 'error')
    return
  end

  local p = getPlayer(src)
  if not p then return end

  local row = MySQL.single.await('SELECT stash_money FROM yg_properties WHERE id = ?', { propertyId })
  local safeMoney = row and (tonumber_fn(row.stash_money) or 0) or 0

  if safeMoney < amount then
    TriggerClientEvent('QBCore:Notify', src, 'Kasada yeterli para yok.', 'error')
    return
  end

  MySQL.update.await('UPDATE yg_properties SET stash_money = stash_money - ? WHERE id = ?', {
    amount, propertyId
  })

  p.Functions.AddMoney(Config.MoneyType, amount, 'property-safe-withdraw')
  TriggerClientEvent('QBCore:Notify', src, ('$%s kasadan çektin.'):format(amount), 'success')
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
end)

RegisterNetEvent('yg_properties:server:addEmployee', function(propertyId, targetCitizenId)
  local src = source
  propertyId = tonumber_fn(propertyId)
  targetCitizenId = tostring(targetCitizenId or ''):gsub('^%s+', ''):gsub('%s+$', '')

  if not propertyId or targetCitizenId == '' then return end

  if not isOwner(src, propertyId) and not hasEmployeePermission(src, propertyId, 'employeesCanManageEmployees') then
    TriggerClientEvent('QBCore:Notify', src, 'Çalışan yönetme yetkin yok.', 'error')
    return
  end

  local row = MySQL.single.await('SELECT owner_citizenid, employees FROM yg_properties WHERE id = ?', { propertyId })
  if not row then return end

  if row.owner_citizenid == targetCitizenId then
    TriggerClientEvent('QBCore:Notify', src, 'Sahibi çalışan yapamazsın.', 'error')
    return
  end

  local employees = normalizeEmployees(row.employees)
  employees[targetCitizenId] = true

  MySQL.update.await('UPDATE yg_properties SET employees = ? WHERE id = ?', {
    encodeEmployeesMap(employees), propertyId
  })

  TriggerClientEvent('QBCore:Notify', src, ('Çalışan eklendi: %s'):format(targetCitizenId), 'success')
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
end)

RegisterNetEvent('yg_properties:server:removeEmployee', function(propertyId, targetCitizenId)
  local src = source
  propertyId = tonumber_fn(propertyId)
  targetCitizenId = tostring(targetCitizenId or ''):gsub('^%s+', ''):gsub('%s+$', '')

  if not propertyId or targetCitizenId == '' then return end

  if not isOwner(src, propertyId) and not hasEmployeePermission(src, propertyId, 'employeesCanManageEmployees') then
    TriggerClientEvent('QBCore:Notify', src, 'Çalışan yönetme yetkin yok.', 'error')
    return
  end

  local row = MySQL.single.await('SELECT employees FROM yg_properties WHERE id = ?', { propertyId })
  if not row then return end

  local employees = normalizeEmployees(row.employees)
  employees[targetCitizenId] = nil

  MySQL.update.await('UPDATE yg_properties SET employees = ? WHERE id = ?', {
    encodeEmployeesMap(employees), propertyId
  })

  TriggerClientEvent('QBCore:Notify', src, ('Çalışan çıkarıldı: %s'):format(targetCitizenId), 'success')
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
end)

RegisterNetEvent('yg_properties:server:setPermission', function(propertyId, permKey, value)
  local src = source
  propertyId = tonumber_fn(propertyId)
  permKey = tostring(permKey or '')
  value = (value == true)

  if not propertyId or permKey == '' then return end

  if not isOwner(src, propertyId) then
    TriggerClientEvent('QBCore:Notify', src, 'İzinleri sadece sahip değiştirebilir.', 'error')
    return
  end

  local allowedKeys = {
    employeesCanEnter = true,
    employeesCanManage = true,
    employeesCanManageDoor = true,
    employeesCanSetEntryFee = true,
    employeesCanEditDescription = true,
    employeesCanBuild = true,
    employeesCanDeposit = true,
    employeesCanWithdraw = true,
    employeesCanManageEmployees = true
  }

  if not allowedKeys[permKey] then return end

  local row = MySQL.single.await('SELECT permissions FROM yg_properties WHERE id = ?', { propertyId })
  if not row then return end

  local perms = normalizePermissions(row.permissions)
  perms[permKey] = value

  MySQL.update.await('UPDATE yg_properties SET permissions = ? WHERE id = ?', {
    json_encode(perms), propertyId
  })

  TriggerClientEvent('QBCore:Notify', src, ('Yetki güncellendi: %s = %s'):format(permKey, tostring(value)), 'success')
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
end)
RegisterNetEvent('yg_properties:server:openStash', function(propertyId)
    local src = source
    propertyId = tonumber(propertyId)
    
    if not propertyId then 
        TriggerClientEvent('QBCore:Notify', src, 'Geçersiz mekan ID.', 'error')
        return 
    end

    local canAccess = false
    
    if isOwner(src, propertyId) then
        canAccess = true
    elseif hasEmployeePermission(src, propertyId, 'employeesCanDeposit') or 
           hasEmployeePermission(src, propertyId, 'employeesCanWithdraw') then
        canAccess = true
    end

    if not canAccess then
        TriggerClientEvent('QBCore:Notify', src, 'Stash\'a erişim yetkin yok.', 'error')
        return
    end

    -- ✅ OX_INVENTORY STASH AÇMA
    local stashId = ('yg_property_%d'):format(propertyId)
    local label = ('Mülk #%d Stash'):format(propertyId)
    
    -- Eğer stash kayıtlı değilse şimdi kaydet
    if exports.ox_inventory then
        exports.ox_inventory:RegisterStash(stashId, label, Config.StashSize or 50, Config.StashWeight or 100000, src)
    end
    
    TriggerClientEvent('yg_properties:client:openOxStash', src, stashId, label)
end)

RegisterNetEvent('yg_properties:server:openWardrobe', function(propertyId)
    local src = source
    propertyId = tonumber(propertyId)

    if not propertyId then
        TriggerClientEvent('QBCore:Notify', src, 'Geçersiz mekan ID.', 'error')
        return
    end

    local canAccess = false

    if isOwner(src, propertyId) then
        canAccess = true
    elseif hasEmployeePermission(src, propertyId, 'employeesCanDeposit') or
           hasEmployeePermission(src, propertyId, 'employeesCanWithdraw') then
        canAccess = true
    end

    if not canAccess then
        TriggerClientEvent('QBCore:Notify', src, 'Gardırop deposuna erişim yetkin yok.', 'error')
        return
    end

    -- ✅ OX_INVENTORY GARDIROP (kıyafet deposu) — stash'tan ayrı, kendi stash id'si
    local stashId = ('yg_property_wardrobe_%d'):format(propertyId)
    local label = ('Mülk #%d Gardırop'):format(propertyId)

    if exports.ox_inventory then
        exports.ox_inventory:RegisterStash(stashId, label, Config.WardrobeSize or 40, Config.WardrobeWeight or 80000, src)
    end

    TriggerClientEvent('yg_properties:client:openOxStash', src, stashId, label)
end)
