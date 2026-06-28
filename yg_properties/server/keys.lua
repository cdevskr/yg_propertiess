local QBCore = exports['qb-core']:GetCoreObject()

local function getPlayer(src)
  return QBCore.Functions.GetPlayer(src)
end

local function cid(src)
  local p = getPlayer(src)
  return p and p.PlayerData.citizenid or nil
end

local function getName(src)
  local p = getPlayer(src)
  if p and p.PlayerData and p.PlayerData.charinfo then
    return ('%s %s'):format(p.PlayerData.charinfo.firstname or '', p.PlayerData.charinfo.lastname or '')
  end
  return GetPlayerName(src) or ('Player %s'):format(src)
end

function HasPropertyKey(propertyId, citizenid)
  if not propertyId or not citizenid then return false end
  local row = MySQL.single.await('SELECT citizenid FROM yg_property_keys WHERE property_id = ? AND citizenid = ? LIMIT 1', { propertyId, citizenid })
  return row ~= nil
end

local function canManageKeys(src, propertyId)
  local myCid = cid(src)
  if not myCid then return false end
  local prop = MySQL.single.await('SELECT owner_citizenid FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not prop then return false end
  if prop.owner_citizenid == myCid then return true end
  if HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canManageStaff') then return true end
  return false
end

lib.callback.register('yg_properties:server:getPropertyKeys', function(src, propertyId)
  propertyId = tonumber(propertyId)
  if not propertyId or not canManageKeys(src, propertyId) then return {} end
  return MySQL.query.await('SELECT citizenid, holder_name FROM yg_property_keys WHERE property_id = ? ORDER BY holder_name ASC', { propertyId }) or {}
end)

lib.callback.register('yg_properties:server:getNearbyPlayers', function(src, maxDist)
  local ped = GetPlayerPed(src)
  local pc = GetEntityCoords(ped)
  local distLimit = tonumber(maxDist) or 6.0
  local list = {}

  for _, playerId in ipairs(GetPlayers()) do
    local target = tonumber(playerId)
    if target and target ~= src then
      local tp = getPlayer(target)
      if tp then
        local tc = GetEntityCoords(GetPlayerPed(target))
        if #(pc - tc) <= distLimit then
          list[#list + 1] = {
            src = target,
            citizenid = tp.PlayerData.citizenid,
            name = getName(target)
          }
        end
      end
    end
  end

  return list
end)

RegisterNetEvent('yg_properties:server:giveKey', function(propertyId, targetSrc)
  local src = source
  propertyId = tonumber(propertyId)
  targetSrc = tonumber(targetSrc)
  if not propertyId or not targetSrc or not canManageKeys(src, propertyId) then return end

  local targetPlayer = getPlayer(targetSrc)
  if not targetPlayer then return end

  local prop = MySQL.single.await('SELECT owner_citizenid, label FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not prop then return end
  if prop.owner_citizenid == targetPlayer.PlayerData.citizenid then return end

  local countRow = MySQL.single.await('SELECT COUNT(*) AS total FROM yg_property_keys WHERE property_id = ?', { propertyId })
  if countRow and tonumber(countRow.total) >= ((Config.Keys and Config.Keys.maxHolders) or 20) then
    TriggerClientEvent('QBCore:Notify', src, 'Anahtar limiti dolu.', 'error')
    return
  end

  MySQL.insert.await('INSERT INTO yg_property_keys (property_id, citizenid, holder_name) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE holder_name = VALUES(holder_name)', {
    propertyId,
    targetPlayer.PlayerData.citizenid,
    getName(targetSrc),
  })

  TriggerClientEvent('QBCore:Notify', src, ('Anahtar verildi: %s'):format(getName(targetSrc)), 'success')
  TriggerClientEvent('QBCore:Notify', targetSrc, ('%s için anahtar aldın.'):format(prop.label or ('Mekan #' .. propertyId)), 'success')
end)

RegisterNetEvent('yg_properties:server:removeKey', function(propertyId, targetCitizenId)
  local src = source
  propertyId = tonumber(propertyId)
  targetCitizenId = Utils.trim(targetCitizenId)
  if not propertyId or targetCitizenId == '' or not canManageKeys(src, propertyId) then return end

  MySQL.query.await('DELETE FROM yg_property_keys WHERE property_id = ? AND citizenid = ?', { propertyId, targetCitizenId })
  TriggerClientEvent('QBCore:Notify', src, ('Anahtar kaldırıldı: %s'):format(targetCitizenId), 'success')
end)
