local QBCore = exports['qb-core']:GetCoreObject()

local function getPlayer(src)
  return QBCore.Functions.GetPlayer(src)
end

local function cid(src)
  local p = getPlayer(src)
  return p and p.PlayerData.citizenid or nil
end

local function name(src)
  local p = getPlayer(src)
  if p and p.PlayerData and p.PlayerData.charinfo then
    return ('%s %s'):format(p.PlayerData.charinfo.firstname or '', p.PlayerData.charinfo.lastname or '')
  end
  return GetPlayerName(src) or ('Player %s'):format(src)
end

QBCore.Commands.Add('grantrealtor', 'Oyuncuya emlakçı yetkisi verir', {
  { name = 'id', help = 'Server ID' }
}, true, function(source, args)
  if source ~= 0 and QBCore.Functions.HasPermission and not QBCore.Functions.HasPermission(source, 'admin') then
    TriggerClientEvent('QBCore:Notify', source, 'Yetkin yok.', 'error')
    return
  end

  local target = tonumber(args[1])
  local player = target and getPlayer(target) or nil
  if not player then
    if source ~= 0 then TriggerClientEvent('QBCore:Notify', source, 'Oyuncu bulunamadı.', 'error') end
    return
  end

  MySQL.insert.await('INSERT INTO yg_property_realtors (citizenid, name) VALUES (?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)', {
    player.PlayerData.citizenid,
    name(target)
  })

  TriggerClientEvent('QBCore:Notify', target, 'Emlakçı yetkisi verildi.', 'success')
  if source ~= 0 then TriggerClientEvent('QBCore:Notify', source, 'Emlakçı yetkisi verildi.', 'success') end
end)

QBCore.Commands.Add('revokerealtor', 'Oyuncudan emlakçı yetkisini alır', {
  { name = 'id', help = 'Server ID' }
}, true, function(source, args)
  if source ~= 0 and QBCore.Functions.HasPermission and not QBCore.Functions.HasPermission(source, 'admin') then
    TriggerClientEvent('QBCore:Notify', source, 'Yetkin yok.', 'error')
    return
  end

  local target = tonumber(args[1])
  local player = target and getPlayer(target) or nil
  if not player then
    if source ~= 0 then TriggerClientEvent('QBCore:Notify', source, 'Oyuncu bulunamadı.', 'error') end
    return
  end

  MySQL.query.await('DELETE FROM yg_property_realtors WHERE citizenid = ?', { player.PlayerData.citizenid })
  TriggerClientEvent('QBCore:Notify', target, 'Emlakçı yetkisi kaldırıldı.', 'primary')
  if source ~= 0 then TriggerClientEvent('QBCore:Notify', source, 'Emlakçı yetkisi kaldırıldı.', 'success') end
end)
