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
  if HasBusinessPermission and HasBusinessPermission(propertyId, citizenid, 'canDecorate') then return true end

  local perms = json.decode(prop.permissions or '{}') or {}
  if not perms.employeesCanBuild then return false end

  local employees = json.decode(prop.employees or '[]') or {}
  for _, v in ipairs_fn(employees) do
    if v == citizenid or (type(v) == 'table' and v.citizenid == citizenid) then return true end
  end
  for k, v in pairs(employees) do
    if k == citizenid and (v == true or type(v) == 'table') then return true end
  end
  return false
end

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