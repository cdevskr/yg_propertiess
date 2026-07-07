local QBCore = exports['qb-core']:GetCoreObject()

-- ✅ OPTİMİZASYON: Localized functions
local GetPlayers = GetPlayers
local GetPlayerRoutingBucket = GetPlayerRoutingBucket
local TriggerClientEvent = TriggerClientEvent
local tostring_fn = tostring
local tonumber_fn = tonumber
local ipairs_fn = ipairs

local function getPlayer(src) return QBCore.Functions.GetPlayer(src) end
local function cid(src)
  local p = getPlayer(src)
  return p and p.PlayerData.citizenid or nil
end

local function canBuild(citizenid, propertyId)
  local prop = MySQL.single.await('SELECT owner_citizenid, employees, permissions FROM yg_properties WHERE id = ?', { propertyId })
  if not prop then return false end
  if prop.owner_citizenid == citizenid then return true end

  local perms = json.decode(prop.permissions or '{}') or {}
  if not perms.employeesCanBuild then return false end

  local employees = json.decode(prop.employees or '[]') or {}
  for _, v in ipairs_fn(employees) do
    if v == citizenid then return true end
  end
  return false
end

-- ✅ EKLENDİ: Build Mode'da inşa edilen bir mekanı (duvarlar, zeminler,
-- kapılı duvarlar — hepsi) TEK bir bütün "shell" olarak veritabanına
-- kaydediyor. Her parçanın konumunu, mülkün build_origin'ine (Build
-- modunun zaten kullandığı sabit referans noktası) GÖRE (relative)
-- saklıyoruz — böylece bu şablon, HERHANGİ bir yeni mülk için farklı
-- bir "cep" koordinatında yeniden spawn edildiğinde parçalar birbirine
-- göre AYNI dizilimde kalır, tıpkı Eclipse Rooftop/riverhouse gibi
-- (ama onlardan farklı olarak her parça KENDİ göreli konumunu koruyor,
-- hepsi aynı noktaya üst üste binmiyor).
RegisterNetEvent('yg_properties:server:saveAsShellTemplate', function(propertyId, label)
  local src = source
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return end

  local citizenid = cid(src)
  if not citizenid or not canBuild(citizenid, propertyId) then
    TriggerClientEvent('QBCore:Notify', src, 'Bu mekanı shell olarak kaydetme yetkin yok.', 'error')
    return
  end

  local prop = MySQL.single.await('SELECT build_origin FROM yg_properties WHERE id = ?', { propertyId })
  if not prop or not prop.build_origin or prop.build_origin == '' then
    TriggerClientEvent('QBCore:Notify', src, 'Bu mekanın bir build_origin\'i yok — önce Build modunda en az bir parça yerleştirmiş olman gerekiyor.', 'error')
    return
  end

  local ok, origin = pcall(Shared.DecodeVec4, prop.build_origin)
  if not ok or not origin then
    TriggerClientEvent('QBCore:Notify', src, 'build_origin okunamadı.', 'error')
    return
  end

  local objects = MySQL.query.await('SELECT model, coords, rotation FROM yg_property_objects WHERE property_id = ?', { propertyId })
  if not objects or #objects == 0 then
    TriggerClientEvent('QBCore:Notify', src, 'Bu mekanda hiç yerleştirilmiş obje yok.', 'error')
    return
  end

  local pieces = {}
  for _, row in ipairs_fn(objects) do
    local c = json.decode(row.coords or 'null')
    local r = json.decode(row.rotation or 'null')
    if c and c.x then
      pieces[#pieces + 1] = {
        model = row.model,
        dx = c.x - origin.x,
        dy = c.y - origin.y,
        dz = c.z - origin.z,
        rx = r and r.x or 0.0,
        ry = r and r.y or 0.0,
        rz = r and r.z or 0.0,
      }
    end
  end

  if #pieces == 0 then
    TriggerClientEvent('QBCore:Notify', src, 'Hiçbir parçanın konumu okunamadı.', 'error')
    return
  end

  local templateId = MySQL.insert.await(
    'INSERT INTO yg_shell_templates (label, owner_citizenid, data, piece_count) VALUES (?, ?, ?, ?)',
    { label or ('Shell #' .. propertyId), citizenid, json.encode({ pieces = pieces }), #pieces }
  )

  TriggerClientEvent('QBCore:Notify', src, ('Shell şablonu kaydedildi (ID: %d, %d parça). shared/config.lua\'da Config.NativeShells\'e shellId olarak eklemek için bu ID\'yi kullan.'):format(templateId, #pieces), 'success')
  print(('[yg_properties] Shell şablonu kaydedildi: id=%d label=%s parça=%d'):format(templateId, label or '?', #pieces))
end)

-- ✅ OPTİMİZASYON: Bucket event broadcasting
local function TriggerClientEventInBucket(eventName, bucketId, ...)
  bucketId = tonumber_fn(bucketId) or 0
  local players = GetPlayers()
  for _, src in ipairs_fn(players) do
    local s = tonumber_fn(src)
    if s and GetPlayerRoutingBucket(s) == bucketId then
      TriggerClientEvent(eventName, s, ...)
    end
  end
end

local function safeModelName(model)
  model = tostring_fn(model or '')
  model = model:gsub('%s+', '')
  if model == '' or #model > 80 then return nil end
  return model
end

lib.callback.register('yg_properties:server:getPropertyObjects', function(src, propertyId)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return {} end

  return MySQL.query.await([[
    SELECT id, model, coords, rotation, frozen, metadata
    FROM yg_property_objects
    WHERE property_id = ?
  ]], { propertyId }) or {}
end)

lib.callback.register('yg_properties:server:addObjectCb', function(src, propertyId, data)
  propertyId = tonumber_fn(propertyId)
  if not propertyId then return false, 'bad_property' end

  local citizenid = cid(src)
  if not citizenid then return false, 'no_player' end
  if not canBuild(citizenid, propertyId) then return false, 'no_perm' end

  local model = safeModelName(data and data.model)
  if not model then return false, 'bad_model' end

  -- per-property object limit
  local limit = (Config and Config.MaxObjectsPerProperty) or 300
  local countRow = MySQL.single.await('SELECT COUNT(*) AS c FROM yg_property_objects WHERE property_id = ?', { propertyId })
  if countRow and tonumber_fn(countRow.c) and tonumber_fn(countRow.c) >= limit then
    return false, 'limit'
  end

  local coords = data and data.coords or nil
  local rotation = data and data.rotation or nil
  if not coords or coords.x == nil or coords.y == nil or coords.z == nil then
    return false, 'bad_coords'
  end
  if not rotation or rotation.x == nil or rotation.y == nil or rotation.z == nil then
    return false, 'bad_rot'
  end

  local id = MySQL.insert.await([[
    INSERT INTO yg_property_objects (property_id, model, coords, rotation, frozen, metadata)
    VALUES (?, ?, ?, ?, ?, ?)
  ]], {
    propertyId,
    model,
    json.encode(coords),
    json.encode(rotation),
    1,
    json.encode(data.metadata or {})
  })

  if not id then return false, 'db_fail' end

  local bucketId = Shared.BucketForProperty(propertyId)
  TriggerClientEventInBucket('yg_properties:client:objectAdded', bucketId, propertyId, {
    id = id,
    model = model,
    coords = json.encode(coords),
    rotation = json.encode(rotation),
    frozen = 1,
    metadata = json.encode(data.metadata or {})
  })

  return true, id
end)

RegisterNetEvent('yg_properties:server:updateObject', function(propertyId, objectId, data)
  local src = source
  propertyId = tonumber_fn(propertyId)
  objectId = tonumber_fn(objectId)
  if not propertyId or not objectId then return end

  local citizenid = cid(src)
  if not citizenid then return end
  if not canBuild(citizenid, propertyId) then return end

  local coords = data and data.coords or nil
  local rotation = data and data.rotation or nil
  if not coords or coords.x == nil or coords.y == nil or coords.z == nil then return end
  if not rotation or rotation.x == nil or rotation.y == nil or rotation.z == nil then return end

  MySQL.update.await([[
    UPDATE yg_property_objects
    SET coords = ?, rotation = ?, frozen = ?, metadata = ?
    WHERE id = ? AND property_id = ?
  ]], {
    json.encode(coords),
    json.encode(rotation),
    1,
    json.encode(data.metadata or {}),
    objectId, propertyId
  })

  local bucketId = Shared.BucketForProperty(propertyId)
  TriggerClientEventInBucket('yg_properties:client:objectUpdated', bucketId, propertyId, objectId, {
    coords = json.encode(coords),
    rotation = json.encode(rotation),
    frozen = 1,
    metadata = json.encode(data.metadata or {})
  })
end)

RegisterNetEvent('yg_properties:server:removeObject', function(propertyId, objectId)
  local src = source
  propertyId = tonumber_fn(propertyId)
  objectId = tonumber_fn(objectId)
  if not propertyId or not objectId then return end

  local citizenid = cid(src)
  if not citizenid then return end
  if not canBuild(citizenid, propertyId) then return end

  MySQL.query.await('DELETE FROM yg_property_objects WHERE id = ? AND property_id = ?', { objectId, propertyId })

  local bucketId = Shared.BucketForProperty(propertyId)
  TriggerClientEventInBucket('yg_properties:client:objectRemoved', bucketId, propertyId, objectId)
end)