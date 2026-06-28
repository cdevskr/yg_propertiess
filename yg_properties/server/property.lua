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

function ProcessPropertyCommission(propertyId, amount)
  if not (Config.Commission and Config.Commission.enabled) then return end
  local prop = MySQL.single.await('SELECT realtor_citizenid, realtor_name FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not prop or not prop.realtor_citizenid then return end
  local commission = math.floor((tonumber(amount) or 0) * ((Config.Commission.percent or 0) / 100.0))
  if commission <= 0 then return end
  local realtor = QBCore.Functions.GetPlayerByCitizenId(prop.realtor_citizenid)
  if realtor then
    realtor.Functions.AddMoney(Config.MoneyType, commission, 'property-realtor-commission')
    TriggerClientEvent('QBCore:Notify', realtor.PlayerData.source, ('$%s komisyon kazandın.'):format(commission), 'success')
  end
end

function ReleaseProperty(propertyId)
  propertyId = tonumber(propertyId)
  if not propertyId then return false end

  MySQL.query.await('DELETE FROM yg_property_keys WHERE property_id = ?', { propertyId })
  MySQL.query.await('DELETE FROM yg_property_business_staff WHERE property_id = ?', { propertyId })

  MySQL.update.await([[
    UPDATE yg_properties
    SET owner_citizenid = NULL,
        tenure = NULL,
        rent_due = NULL,
        tax_due = NULL,
        locked = 1,
        stash_money = 0,
        employees = ?,
        permissions = ?
    WHERE id = ?
  ]], {
    Utils.enc({}),
    Utils.enc(Config.DefaultPermissions or {}),
    propertyId,
  })

  TriggerClientEvent('yg_properties:client:refresh', -1)
  return true
end

lib.callback.register('yg_properties:server:rentProperty', function(src, propertyId)
  propertyId = tonumber(propertyId)
  if not propertyId then return false, 'bad_property' end

  local player = getPlayer(src)
  if not player then return false, 'player_not_found' end
  if not (Config.Ownership and Config.Ownership.allowRent) then return false, 'rent_disabled' end

  local prop = MySQL.single.await('SELECT id, rent_price, owner_citizenid FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not prop then return false, 'property_not_found' end
  if prop.owner_citizenid and prop.owner_citizenid ~= '' then return false, 'already_owned' end

  local rentPrice = math.max(0, tonumber(prop.rent_price) or 0)
  local charge = rentPrice
  if Config.Commission and Config.Commission.enabled and Config.Commission.fromBuyer then
    charge = charge + math.floor(rentPrice * ((Config.Commission.percent or 0) / 100.0))
  end

  if charge > 0 then
    local ok = player.Functions.RemoveMoney(Config.MoneyType, charge, 'rent-property')
    if not ok then return false, 'not_enough_money' end
  end

  local now = Utils.now()
  MySQL.update.await('UPDATE yg_properties SET owner_citizenid = ?, tenure = ?, locked = 1, rent_due = ?, tax_due = ? WHERE id = ?', {
    player.PlayerData.citizenid,
    'rent',
    now + ((Config.Ownership and Config.Ownership.rentInterval) or (7 * 24 * 60 * 60)),
    (Config.Tax and Config.Tax.enabled) and (now + (Config.Tax.interval or (7 * 24 * 60 * 60))) or nil,
    propertyId,
  })

  if charge > 0 and not (Config.Commission and Config.Commission.fromBuyer) then
    ProcessPropertyCommission(propertyId, rentPrice)
  elseif charge > rentPrice then
    ProcessPropertyCommission(propertyId, charge)
  end

  TriggerClientEvent('yg_properties:client:refresh', -1)
  return true, 'ok'
end)

RegisterNetEvent('yg_properties:server:sellProperty', function(propertyId)
  local src = source
  propertyId = tonumber(propertyId)
  if not propertyId then return end

  local player = getPlayer(src)
  local prop = MySQL.single.await('SELECT owner_citizenid, tenure, price, label FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not player or not prop or prop.owner_citizenid ~= player.PlayerData.citizenid then return end

  if tostring(prop.tenure or '') == 'buy' then
    local refund = math.floor((tonumber(prop.price) or 0) * 0.5)
    if refund > 0 then
      player.Functions.AddMoney(Config.MoneyType, refund, 'property-sell-refund')
    end
  end

  ReleaseProperty(propertyId)
  TriggerClientEvent('QBCore:Notify', src, ('%s tekrar satışa çıkarıldı.'):format(prop.label or ('Mekan #' .. propertyId)), 'success')
end)

RegisterNetEvent('yg_properties:server:knock', function(propertyId)
  local src = source
  propertyId = tonumber(propertyId)
  if not propertyId then return end

  local prop = MySQL.single.await('SELECT id, owner_citizenid, label FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not prop then return end

  local recipients = {}
  if prop.owner_citizenid and prop.owner_citizenid ~= '' then
    recipients[prop.owner_citizenid] = true
  end

  local keys = MySQL.query.await('SELECT citizenid FROM yg_property_keys WHERE property_id = ?', { propertyId }) or {}
  for _, row in ipairs(keys) do
    recipients[row.citizenid] = true
  end

  local staff = MySQL.query.await('SELECT citizenid FROM yg_property_business_staff WHERE property_id = ?', { propertyId }) or {}
  for _, row in ipairs(staff) do
    recipients[row.citizenid] = true
  end

  local sent = false
  for citizenid in pairs(recipients) do
    local target = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if target then
      sent = true
      TriggerClientEvent('QBCore:Notify', target.PlayerData.source, ('%s kapısı çalıyor.'):format(prop.label or ('Mekan #' .. propertyId)), 'primary')
      TriggerClientEvent('yg_properties:client:knockReceived', target.PlayerData.source, propertyId)
    end
  end

  if not sent then
    TriggerClientEvent('QBCore:Notify', src, 'Kapıyı duyacak kimse yok gibi görünüyor.', 'primary')
  end
end)
