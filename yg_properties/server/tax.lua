local QBCore = exports['qb-core']:GetCoreObject()
local rentMisses = {}
local taxMisses = {}

local function chargeOwner(citizenid, amount, reason)
  local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
  if not player then return false, nil end
  local ok = player.Functions.RemoveMoney(Config.Currency, amount, reason or 'property-charge')
  return ok, player
end

local function processRent(row)
  if tostring(row.tenure or '') ~= 'rent' or not row.rent_due then return end
  if Utils.now() < tonumber(row.rent_due) then return end

  local rentPrice = math.max(0, tonumber(row.rent_price) or 0)
  local ok, player = chargeOwner(row.owner_citizenid, rentPrice, 'property-rent-cycle')
  if ok then
    rentMisses[row.id] = 0
    MySQL.update.await('UPDATE yg_properties SET rent_due = ? WHERE id = ?', {
      Utils.now() + ((Config.Ownership and Config.Ownership.rentInterval) or (7 * 24 * 60 * 60)),
      row.id,
    })
    if player then
      TriggerClientEvent('QBCore:Notify', player.PlayerData.source, ('%s kira bedeli ödendi.'):format(row.label or ('Mekan #' .. row.id)), 'primary')
    end
  else
    rentMisses[row.id] = (rentMisses[row.id] or 0) + 1
    MySQL.update.await('UPDATE yg_properties SET rent_due = ? WHERE id = ?', { Utils.now() + 3600, row.id })
    if player then
      TriggerClientEvent('QBCore:Notify', player.PlayerData.source, ('%s için kira alınamadı.'):format(row.label or ('Mekan #' .. row.id)), 'error')
    end
    if rentMisses[row.id] > ((Config.Ownership and Config.Ownership.rentGraceMisses) or 1) then
      ReleaseProperty(row.id)
      rentMisses[row.id] = nil
    end
  end
end

local function processTax(row)
  if not (Config.Tax and Config.Tax.enabled) or not row.tax_due then return end
  if Utils.now() < tonumber(row.tax_due) then return end

  local rate = row.type == 'business' and ((Config.Tax and Config.Tax.businessRate) or 0.02) or ((Config.Tax and Config.Tax.houseRate) or 0.01)
  local amount = math.max((Config.Tax and Config.Tax.minTax) or 100, math.floor((tonumber(row.price) or 0) * rate))
  local ok, player = chargeOwner(row.owner_citizenid, amount, 'property-tax-cycle')
  if ok then
    taxMisses[row.id] = 0
    MySQL.update.await('UPDATE yg_properties SET tax_due = ? WHERE id = ?', {
      Utils.now() + ((Config.Tax and Config.Tax.interval) or (7 * 24 * 60 * 60)),
      row.id,
    })
    if player then
      TriggerClientEvent('QBCore:Notify', player.PlayerData.source, ('%s vergi bedeli ödendi.'):format(row.label or ('Mekan #' .. row.id)), 'primary')
    end
  else
    taxMisses[row.id] = (taxMisses[row.id] or 0) + 1
    MySQL.update.await('UPDATE yg_properties SET tax_due = ? WHERE id = ?', { Utils.now() + 3600, row.id })
    if player then
      TriggerClientEvent('QBCore:Notify', player.PlayerData.source, ('%s için vergi alınamadı.'):format(row.label or ('Mekan #' .. row.id)), 'error')
    end
    if taxMisses[row.id] > ((Config.Tax and Config.Tax.graceMisses) or 2) then
      ReleaseProperty(row.id)
      taxMisses[row.id] = nil
    end
  end
end

CreateThread(function()
  while true do
    Wait(5 * 60 * 1000)
    local rows = MySQL.query.await('SELECT id, type, price, label, owner_citizenid, tenure, rent_price, rent_due, tax_due FROM yg_properties WHERE owner_citizenid IS NOT NULL AND owner_citizenid != ""') or {}
    for _, row in ipairs(rows) do
      processRent(row)
      processTax(row)
    end
  end
end)
