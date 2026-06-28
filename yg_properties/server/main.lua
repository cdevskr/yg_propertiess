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
    SELECT id, owner_citizenid, employees, permissions, locked, entry_fee, stash_money, type, label, description
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

local function canAccessProperty(src, propertyId)
  local myCid = cid(src)
  if isOwner(src, propertyId) then return true end
  if myCid and HasPropertyKey and HasPropertyKey(propertyId, myCid) then return true end
  if myCid and IsBusinessEmployee and IsBusinessEmployee(propertyId, myCid) then return true end
  return hasEmployeePermission(src, propertyId, 'employeesCanEnter')
end

local function canManageProperty(src, propertyId)
  local myCid = cid(src)
  if isOwner(src, propertyId) then return true end
  if myCid and HasBusinessPermission then
    if HasBusinessPermission(propertyId, myCid, 'canManageStaff')
      or HasBusinessPermission(propertyId, myCid, 'canManageStash')
      or HasBusinessPermission(propertyId, myCid, 'canLock')
      or HasBusinessPermission(propertyId, myCid, 'canDecorate') then
      return true
    end
  end
  return hasEmployeePermission(src, propertyId, 'employeesCanManage')
end

local function isAdmin(src)
  if QBCore.Functions.HasPermission then
    return QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god')
  end
  return false
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
    SELECT id,type,price,rent_price,tenure,rent_due,tax_due,label,description,locked,entry_fee,owner_citizenid,door_coords,interior_spawn,shell_id
    FROM yg_properties
  ]]) or {}
end)

lib.callback.register('yg_properties:server:getProperty', function(src, propertyId)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return nil end

  -- ✅ OPTİMİZASYON: Check cache first
  local cached = getCachedProperty(propertyId)
  if cached then return cached end

  local row = MySQL.single.await([[
    SELECT
  id,type,price,rent_price,tenure,rent_due,tax_due,label,description,locked,entry_fee,owner_citizenid,
  door_coords,interior_spawn,stash_money,employees,permissions,build_origin,shell_id,realtor_citizenid,realtor_name
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
      (type, label, price, rent_price, entry_fee, owner_citizenid, created_by, door_coords, build_origin, interior_spawn, locked, employees, permissions, shell_id, realtor_citizenid, realtor_name)
    VALUES
      (?, ?, ?, ?, ?, NULL, ?, ?, ?, NULL, ?, ?, ?, ?, ?, ?)
  ]], {
    pType,
    label,
    price or 0,
    0,
    entryFee or 0,
    createdBy,
    Shared.EncodeVec4(door),
    Shared.EncodeVec4(vector4(0,0,0,0)),
    (Config.DefaultLocked and 1 or 0),
    employees,
    perms,
    shellId,
    createdBy,
    player.PlayerData.charinfo and (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or createdBy
  })

  if not insertId then return nil end
  return insertId
end

QBCore.Commands.Add('evolustur', 'Ev oluşturur', {
  { name = 'fiyat', help = 'Satın alma fiyatı' },
  { name = 'shell', help = 'Shell ID (opsiyonel)' },
}, false, function(source, args)
  local price = tonumber_fn(args[1] or '0') or 0
  local shellId = tonumber_fn(args[2])

  if shellId and (not Config.PropertyShells or not Config.PropertyShells[shellId]) then
    TriggerClientEvent('QBCore:Notify', source, ('Geçersiz shell ID: %s'):format(shellId), 'error')
    return
  end

  local id = createProperty(source, 'home', price, 0, shellId)
  if id then
    if shellId then
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
  if prop.owner_citizenid and prop.owner_citizenid ~= '' then return false, 'already_owned' end

  local basePrice = tonumber_fn(prop.price) or 0
  local charge = basePrice
  if Config.Commission and Config.Commission.enabled and Config.Commission.fromBuyer then
    charge = charge + math.floor(basePrice * ((Config.Commission.percent or 0) / 100.0))
  end

  if charge > 0 then
    local ok = p.Functions.RemoveMoney(Config.Currency, charge, 'buy-property')
    if not ok then return false, 'not_enough_money' end
  end

  local now = Utils.now()
  MySQL.update.await('UPDATE yg_properties SET owner_citizenid = ?, tenure = ?, locked = 1, rent_due = NULL, tax_due = ? WHERE id = ?', {
    p.PlayerData.citizenid,
    'buy',
    (Config.Tax and Config.Tax.enabled) and (now + (Config.Tax.interval or (7 * 24 * 60 * 60))) or nil,
    propertyId
  })
  if ProcessPropertyCommission then
    ProcessPropertyCommission(propertyId, Config.Commission and Config.Commission.fromBuyer and charge or basePrice)
  end
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

  local ok = p.Functions.RemoveMoney(Config.Currency, fee, 'business-entry-fee')
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
        
        local props = MySQL.query.await('SELECT id, type FROM yg_properties') or {}
        
        for _, prop in ipairs_fn(props) do
            local stashId = ('yg_property_%s'):format(prop.id)
            local label = ('Mülk #%s Stash'):format(prop.id)
            local stashCfg = (prop.type == 'business' and Config.Storage and Config.Storage.business) or (Config.Storage and Config.Storage.house) or { slots = 50, weight = 100000 }
            
            if exports.ox_inventory then
                exports.ox_inventory:RegisterStash(stashId, label, stashCfg.slots or 50, stashCfg.weight or 100000)
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

  local myCid = cid(src)
  if not isOwner(src, propertyId)
     and not hasEmployeePermission(src, propertyId, 'employeesCanManageDoor')
     and not (myCid and HasPropertyKey and HasPropertyKey(propertyId, myCid))
     and not (myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canLock')) then
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

  local myCid = cid(src)
  if not isOwner(src, propertyId)
     and not hasEmployeePermission(src, propertyId, 'employeesCanSetEntryFee')
     and not (myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canManageStaff')) then
    TriggerClientEvent('QBCore:Notify', src, 'Giriş ücretini değiştirme yetkin yok.', 'error')
    return
  end

  if fee < 0 then fee = 0 end
  local maxFee = (Config.Business and Config.Business.entryFeeMax) or 1000000
  if fee > maxFee then fee = maxFee end

  MySQL.update.await('UPDATE yg_properties SET entry_fee = ? WHERE id = ?', { fee, propertyId })

  broadcastPropertyUpdate(propertyId, 'yg_properties:client:propertyUpdated', propertyId)
  broadcastPropertyUpdate(propertyId, 'yg_properties:client:refresh')
end)

-- =========================
-- Employees + Permissions + Safe
-- =========================

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

  local myCid = cid(src)
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
    business_rights = {
      canManageStash = myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canManageStash') or false,
      canLock = myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canLock') or false,
      canDecorate = myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canDecorate') or false,
      canManageStaff = myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canManageStaff') or false,
    }
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

  local myCid = cid(src)
  if not isOwner(src, propertyId)
     and not hasEmployeePermission(src, propertyId, 'employeesCanDeposit')
     and not (myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canManageStash')) then
    TriggerClientEvent('QBCore:Notify', src, 'Kasaya para koyma yetkin yok.', 'error')
    return
  end

  local p = getPlayer(src)
  if not p then return end

  local ok = p.Functions.RemoveMoney(Config.Currency, amount, 'property-safe-deposit')
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

  local myCid = cid(src)
  if not isOwner(src, propertyId)
     and not hasEmployeePermission(src, propertyId, 'employeesCanWithdraw')
     and not (myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canManageStaff')) then
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

  p.Functions.AddMoney(Config.Currency, amount, 'property-safe-withdraw')
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
    
    local myCid = cid(src)
    local prop = MySQL.single.await('SELECT type FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })

    if isOwner(src, propertyId) then
        canAccess = true
    elseif prop and prop.type == 'business' then
        if hasEmployeePermission(src, propertyId, 'employeesCanDeposit') or 
           hasEmployeePermission(src, propertyId, 'employeesCanWithdraw') or
           (myCid and HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canManageStash')) then
            canAccess = true
        end
    elseif myCid and HasPropertyKey and HasPropertyKey(propertyId, myCid) then
        canAccess = true
    end

    if not canAccess then
        TriggerClientEvent('QBCore:Notify', src, 'Stash\'a erişim yetkin yok.', 'error')
        return
    end

    -- ✅ OX_INVENTORY STASH AÇMA
    local stashId = ('yg_property_%d'):format(propertyId)
    local label = ('Mülk #%d Stash'):format(propertyId)
    local stashCfg = (prop and prop.type == 'business' and Config.Storage and Config.Storage.business) or (Config.Storage and Config.Storage.house) or { slots = Config.StashSize or 50, weight = Config.StashWeight or 100000 }
    
    -- Eğer stash kayıtlı değilse şimdi kaydet
    if exports.ox_inventory then
        exports.ox_inventory:RegisterStash(stashId, label, stashCfg.slots or 50, stashCfg.weight or 100000, src)
    end
    
    TriggerClientEvent('yg_properties:client:openOxStash', src, stashId, label)
end)
