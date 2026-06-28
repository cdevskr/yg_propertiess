local QBCore = exports['qb-core']:GetCoreObject()

local function getPlayer(src)
  return QBCore.Functions.GetPlayer(src)
end

local function cid(src)
  local p = getPlayer(src)
  return p and p.PlayerData.citizenid or nil
end

local function hasLegacyBuildPermission(propertyId, citizenid)
  local row = MySQL.single.await('SELECT employees, permissions FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not row then return false end
  local employees = Utils.dec(row.employees, {}) or {}
  local hasEmployee = false
  for k, v in pairs(employees) do
    if (type(k) == 'string' and k == citizenid and (v == true or type(v) == 'table')) or v == citizenid or (type(v) == 'table' and v.citizenid == citizenid) then
      hasEmployee = true
      break
    end
  end
  if not hasEmployee then return false end
  local perms = Utils.dec(row.permissions, {}) or {}
  return perms.employeesCanBuild == true
end

local function canEditAccess(src, propertyId)
  local myCid = cid(src)
  if not myCid then return false end
  local row = MySQL.single.await('SELECT owner_citizenid FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not row then return false end
  if row.owner_citizenid == myCid then return true end
  if hasLegacyBuildPermission(propertyId, myCid) then return true end
  return HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canDecorate') or false
end

lib.callback.register('yg_properties:server:getAccessPoints', function(src, propertyId)
  propertyId = tonumber(propertyId)
  if not propertyId then return {} end
  local rows = MySQL.query.await('SELECT id, type, coords FROM yg_property_access_points WHERE property_id = ? ORDER BY id ASC', { propertyId }) or {}
  local out = {}
  for _, row in ipairs(rows) do
    out[#out + 1] = {
      id = row.id,
      type = row.type,
      coords = Utils.dec(row.coords, nil),
    }
  end
  return out
end)

RegisterNetEvent('yg_properties:server:addAccessPoint', function(propertyId, kind, coords)
  local src = source
  propertyId = tonumber(propertyId)
  if not propertyId or not canEditAccess(src, propertyId) then return end
  if kind ~= 'storage' and kind ~= 'wardrobe' and kind ~= 'safe' then return end
  if type(coords) ~= 'table' or coords.x == nil or coords.y == nil or coords.z == nil then return end

  MySQL.insert.await('INSERT INTO yg_property_access_points (property_id, type, coords) VALUES (?, ?, ?)', {
    propertyId, kind, Utils.enc({ x = coords.x + 0.0, y = coords.y + 0.0, z = coords.z + 0.0 })
  })

  local bucket = Shared.BucketForProperty(propertyId)
  for _, playerId in ipairs(GetPlayers()) do
    local target = tonumber(playerId)
    if target and GetPlayerRoutingBucket(target) == bucket then
      TriggerClientEvent('yg_properties:client:accessPointsChanged', target, propertyId)
    end
  end
end)

RegisterNetEvent('yg_properties:server:removeAccessPoint', function(propertyId, accessId)
  local src = source
  propertyId = tonumber(propertyId)
  accessId = tonumber(accessId)
  if not propertyId or not accessId or not canEditAccess(src, propertyId) then return end

  MySQL.query.await('DELETE FROM yg_property_access_points WHERE id = ? AND property_id = ?', { accessId, propertyId })

  local bucket = Shared.BucketForProperty(propertyId)
  for _, playerId in ipairs(GetPlayers()) do
    local target = tonumber(playerId)
    if target and GetPlayerRoutingBucket(target) == bucket then
      TriggerClientEvent('yg_properties:client:accessPointsChanged', target, propertyId)
    end
  end
end)

RegisterNetEvent('yg_properties:server:openWardrobe', function(propertyId)
  local src = source
  propertyId = tonumber(propertyId)
  if not propertyId then return end
  local myCid = cid(src)
  if not myCid then return end

  local prop = MySQL.single.await('SELECT type, owner_citizenid FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not prop then return end

  local allowed = false
  if prop.owner_citizenid == myCid then
    allowed = true
  elseif prop.type == 'business' then
    allowed = IsBusinessEmployee and IsBusinessEmployee(propertyId, myCid) or false
  else
    allowed = HasPropertyKey and HasPropertyKey(propertyId, myCid) or false
  end

  if not allowed then
    TriggerClientEvent('QBCore:Notify', src, 'Dolaba erişim yetkin yok.', 'error')
    return
  end

  TriggerClientEvent((Config.Wardrobe and Config.Wardrobe.openEvent) or 'yg_properties:client:openWardrobe', src, {
    propertyId = propertyId,
    owner = prop.owner_citizenid == myCid,
    type = prop.type,
  })
end)
