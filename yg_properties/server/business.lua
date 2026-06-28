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

local function maxGrade()
  local max = 0
  for grade in pairs((Config.Business and Config.Business.grades) or {}) do
    if tonumber(grade) and tonumber(grade) > max then
      max = tonumber(grade)
    end
  end
  return max
end

local function normalizeLegacyEmployees(raw)
  local out = {}
  local data = Utils.dec(raw, {}) or {}
  if type(data) ~= 'table' then return out end
  for k, v in pairs(data) do
    if type(k) == 'string' and v == true then
      out[k] = { citizenid = k }
    elseif type(v) == 'string' and v ~= '' then
      out[v] = { citizenid = v }
    elseif type(v) == 'table' and v.citizenid then
      out[v.citizenid] = v
    end
  end
  return out
end

local function hasLegacyPermission(propertyId, citizenid, permKey)
  local row = MySQL.single.await('SELECT employees, permissions FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not row then return false end
  local employees = normalizeLegacyEmployees(row.employees)
  if not employees[citizenid] then return false end
  local perms = Utils.dec(row.permissions, {}) or {}
  return perms[permKey] == true
end

local function syncLegacyEmployees(propertyId, targetCitizenId, add, employeeName)
  local row = MySQL.single.await('SELECT employees FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not row then return end
  local employees = normalizeLegacyEmployees(row.employees)
  if add then
    employees[targetCitizenId] = employees[targetCitizenId] or { citizenid = targetCitizenId, name = employeeName or targetCitizenId }
  else
    employees[targetCitizenId] = nil
  end
  MySQL.update.await('UPDATE yg_properties SET employees = ? WHERE id = ?', { Utils.enc(employees), propertyId })
end

local function canManageStaff(src, propertyId)
  local myCid = cid(src)
  if not myCid then return false end
  local prop = MySQL.single.await('SELECT owner_citizenid FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  if not prop then return false end
  if prop.owner_citizenid == myCid then return true end
  if hasLegacyPermission(propertyId, myCid, 'employeesCanManageEmployees') then return true end
  return HasBusinessPermission and HasBusinessPermission(propertyId, myCid, 'canManageStaff') or false
end

function GetBusinessEmployee(propertyId, citizenid)
  if not propertyId or not citizenid then return nil end
  return MySQL.single.await('SELECT property_id, citizenid, name, grade, salary FROM yg_property_business_staff WHERE property_id = ? AND citizenid = ? LIMIT 1', {
    propertyId, citizenid
  })
end

function IsBusinessEmployee(propertyId, citizenid)
  return GetBusinessEmployee(propertyId, citizenid) ~= nil
end

function HasBusinessPermission(propertyId, citizenid, right)
  local row = GetBusinessEmployee(propertyId, citizenid)
  if not row then return false end
  return Utils.gradeRight(row.grade, right)
end

lib.callback.register('yg_properties:server:getBusinessEmployees', function(src, propertyId)
  propertyId = tonumber(propertyId)
  if not propertyId or not canManageStaff(src, propertyId) then return {} end
  return MySQL.query.await('SELECT citizenid, name, grade, salary FROM yg_property_business_staff WHERE property_id = ? ORDER BY grade DESC, name ASC', { propertyId }) or {}
end)

RegisterNetEvent('yg_properties:server:hireBusinessEmployee', function(propertyId, targetSrc, grade, salary)
  local src = source
  propertyId = tonumber(propertyId)
  targetSrc = tonumber(targetSrc)
  grade = math.max(0, math.min(tonumber(grade) or 0, maxGrade()))
  salary = math.max(0, math.floor(tonumber(salary) or 0))
  if not propertyId or not targetSrc or not canManageStaff(src, propertyId) then return end

  local prop = MySQL.single.await('SELECT id, type, label FROM yg_properties WHERE id = ? LIMIT 1', { propertyId })
  local targetPlayer = getPlayer(targetSrc)
  if not prop or not targetPlayer or prop.type ~= 'business' then return end

  local countRow = MySQL.single.await('SELECT COUNT(*) AS total FROM yg_property_business_staff WHERE property_id = ?', { propertyId })
  if countRow and tonumber(countRow.total) >= ((Config.Business and Config.Business.maxEmployees) or 15) then
    TriggerClientEvent('QBCore:Notify', src, 'Çalışan limiti dolu.', 'error')
    return
  end

  MySQL.insert.await('INSERT INTO yg_property_business_staff (property_id, citizenid, name, grade, salary) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name), grade = VALUES(grade), salary = VALUES(salary)', {
    propertyId,
    targetPlayer.PlayerData.citizenid,
    getName(targetSrc),
    grade,
    salary,
  })

  syncLegacyEmployees(propertyId, targetPlayer.PlayerData.citizenid, true, getName(targetSrc))
  TriggerClientEvent('QBCore:Notify', src, ('Çalışan eklendi: %s'):format(getName(targetSrc)), 'success')
  TriggerClientEvent('QBCore:Notify', targetSrc, ('%s işletmesinde işe alındın.'):format(prop.label or ('Mekan #' .. propertyId)), 'success')
end)

RegisterNetEvent('yg_properties:server:updateBusinessEmployee', function(propertyId, targetCitizenId, grade, salary)
  local src = source
  propertyId = tonumber(propertyId)
  targetCitizenId = Utils.trim(targetCitizenId)
  grade = math.max(0, math.min(tonumber(grade) or 0, maxGrade()))
  salary = math.max(0, math.floor(tonumber(salary) or 0))
  if not propertyId or targetCitizenId == '' or not canManageStaff(src, propertyId) then return end

  MySQL.update.await('UPDATE yg_property_business_staff SET grade = ?, salary = ? WHERE property_id = ? AND citizenid = ?', {
    grade, salary, propertyId, targetCitizenId
  })

  TriggerClientEvent('QBCore:Notify', src, ('Çalışan güncellendi: %s'):format(targetCitizenId), 'success')
end)

RegisterNetEvent('yg_properties:server:fireBusinessEmployee', function(propertyId, targetCitizenId)
  local src = source
  propertyId = tonumber(propertyId)
  targetCitizenId = Utils.trim(targetCitizenId)
  if not propertyId or targetCitizenId == '' or not canManageStaff(src, propertyId) then return end

  MySQL.query.await('DELETE FROM yg_property_business_staff WHERE property_id = ? AND citizenid = ?', { propertyId, targetCitizenId })
  syncLegacyEmployees(propertyId, targetCitizenId, false)
  TriggerClientEvent('QBCore:Notify', src, ('Çalışan çıkarıldı: %s'):format(targetCitizenId), 'success')
end)

CreateThread(function()
  while true do
    local interval = (((Config.Business and Config.Business.payrollInterval) or 0) * 1000)
    if interval <= 0 then
      Wait(60000)
    else
      Wait(interval)
      local props = MySQL.query.await('SELECT id, label, stash_money FROM yg_properties WHERE type = ? AND owner_citizenid IS NOT NULL AND owner_citizenid != ""', { 'business' }) or {}
      for _, prop in ipairs(props) do
        local employees = MySQL.query.await('SELECT citizenid, salary FROM yg_property_business_staff WHERE property_id = ?', { prop.id }) or {}
        local total = 0
        for _, row in ipairs(employees) do
          total = total + (tonumber(row.salary) or 0)
        end
        if total > 0 then
          local balance = tonumber(prop.stash_money) or 0
          if balance >= total then
            MySQL.update.await('UPDATE yg_properties SET stash_money = stash_money - ? WHERE id = ?', { total, prop.id })
            for _, row in ipairs(employees) do
              local amount = tonumber(row.salary) or 0
              if amount > 0 then
                local target = QBCore.Functions.GetPlayerByCitizenId(row.citizenid)
                if target then
                  target.Functions.AddMoney(Config.MoneyType, amount, 'property-business-payroll')
                  TriggerClientEvent('QBCore:Notify', target.PlayerData.source, ('$%s maaş aldın.'):format(amount), 'success')
                end
              end
            end
          else
            local propRow = MySQL.single.await('SELECT owner_citizenid FROM yg_properties WHERE id = ? LIMIT 1', { prop.id })
            if propRow and propRow.owner_citizenid then
              local owner = QBCore.Functions.GetPlayerByCitizenId(propRow.owner_citizenid)
              if owner then
                TriggerClientEvent('QBCore:Notify', owner.PlayerData.source, ('%s işletmesinin kasasında maaş için yeterli para yok.'):format(prop.label or ('Mekan #' .. prop.id)), 'error')
              end
            end
          end
        end
      end
    end
  end
end)
