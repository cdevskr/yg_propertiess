local QBCore = exports['qb-core']:GetCoreObject()

local function notify(msg, typ)
  if lib and lib.notify then
    lib.notify({ type = typ or 'inform', description = msg })
  else
    QBCore.Functions.Notify(msg, typ or 'primary')
  end
end

local function canOpen(propertyId)
  if LocalPlayer.state.ygPropertyId ~= propertyId then
    notify('Bunu yapmak için önce bu mekana girmen lazım.', 'error')
    return false
  end
  return true
end

RegisterNetEvent('yg_properties:client:openSafeMenu', function(propertyId)
  if not canOpen(propertyId) then return end

  local balance = lib.callback.await('yg_properties:server:getPropertySafeMoney', false, propertyId) or 0
  lib.registerContext({
    id = ('yg_property_safe_%s'):format(propertyId),
    title = ('Mülk Kasası - $%s'):format(Utils.money(balance)),
    options = {
      {
        title = 'Kasaya Para Koy',
        onSelect = function()
          local input = lib.inputDialog('Kasaya Para Koy', {
            { type = 'number', label = 'Miktar', required = true, min = 1 }
          })
          if input then
            TriggerServerEvent('yg_properties:server:depositSafeMoney', propertyId, tonumber(input[1]) or 0)
          end
        end
      },
      {
        title = 'Kasadan Para Çek',
        onSelect = function()
          local input = lib.inputDialog('Kasadan Para Çek', {
            { type = 'number', label = 'Miktar', required = true, min = 1 }
          })
          if input then
            TriggerServerEvent('yg_properties:server:withdrawSafeMoney', propertyId, tonumber(input[1]) or 0)
          end
        end
      }
    }
  })
  lib.showContext(('yg_property_safe_%s'):format(propertyId))
end)

RegisterNetEvent('yg_properties:client:openKeysMenu', function(propertyId)
  if not canOpen(propertyId) then return end

  local rows = lib.callback.await('yg_properties:server:getPropertyKeys', false, propertyId) or {}
  local options = {}

  for _, row in ipairs(rows) do
    options[#options + 1] = {
      title = row.holder_name or row.citizenid,
      description = row.citizenid,
      icon = 'fa-solid fa-key',
      onSelect = function()
        TriggerServerEvent('yg_properties:server:removeKey', propertyId, row.citizenid)
      end
    }
  end

  options[#options + 1] = {
    title = 'Yakındaki Oyuncuya Anahtar Ver',
    icon = 'fa-solid fa-user-plus',
    onSelect = function()
      local nearby = lib.callback.await('yg_properties:server:getNearbyPlayers', false, 6.0) or {}
      if #nearby == 0 then
        notify('Yakında oyuncu yok.', 'error')
        return
      end

      local playerOptions = {}
      for _, player in ipairs(nearby) do
        playerOptions[#playerOptions + 1] = {
          title = ('%s [%s]'):format(player.name, player.src),
          description = player.citizenid,
          onSelect = function()
            TriggerServerEvent('yg_properties:server:giveKey', propertyId, player.src)
          end
        }
      end

      lib.registerContext({
        id = ('yg_property_keys_give_%s'):format(propertyId),
        title = 'Anahtar Ver',
        options = playerOptions,
      })
      lib.showContext(('yg_property_keys_give_%s'):format(propertyId))
    end
  }

  lib.registerContext({
    id = ('yg_property_keys_%s'):format(propertyId),
    title = 'Anahtar Yönetimi',
    options = options,
  })
  lib.showContext(('yg_property_keys_%s'):format(propertyId))
end)

RegisterNetEvent('yg_properties:client:openBusinessStaffMenu', function(propertyId)
  if not canOpen(propertyId) then return end

  local rows = lib.callback.await('yg_properties:server:getBusinessEmployees', false, propertyId) or {}
  local options = {}

  for _, row in ipairs(rows) do
    local gradeCfg = Config.Business and Config.Business.grades and Config.Business.grades[tonumber(row.grade) or 0] or nil
    options[#options + 1] = {
      title = row.name or row.citizenid,
      description = ('CitizenID: %s | Grade: %s | Maaş: $%s'):format(row.citizenid, gradeCfg and gradeCfg.label or tostring(row.grade), Utils.money(row.salary or 0)),
      icon = 'fa-solid fa-user-tie',
      onSelect = function()
        local input = lib.inputDialog('Çalışanı Düzenle', {
          { type = 'number', label = 'Grade', required = true, default = tonumber(row.grade) or 0, min = 0 },
          { type = 'number', label = 'Maaş', required = true, default = tonumber(row.salary) or 0, min = 0 }
        })
        if not input then return end
        TriggerServerEvent('yg_properties:server:updateBusinessEmployee', propertyId, row.citizenid, tonumber(input[1]) or 0, tonumber(input[2]) or 0)
      end,
      menu = ('yg_property_staff_actions_%s_%s'):format(propertyId, row.citizenid)
    }
    lib.registerContext({
      id = ('yg_property_staff_actions_%s_%s'):format(propertyId, row.citizenid),
      title = row.name or row.citizenid,
      menu = ('yg_property_staff_%s'):format(propertyId),
      options = {
        {
          title = 'Grade / Maaş Güncelle',
          icon = 'fa-solid fa-pen',
          onSelect = function()
            local input = lib.inputDialog('Çalışanı Düzenle', {
              { type = 'number', label = 'Grade', required = true, default = tonumber(row.grade) or 0, min = 0 },
              { type = 'number', label = 'Maaş', required = true, default = tonumber(row.salary) or 0, min = 0 }
            })
            if input then
              TriggerServerEvent('yg_properties:server:updateBusinessEmployee', propertyId, row.citizenid, tonumber(input[1]) or 0, tonumber(input[2]) or 0)
            end
          end
        },
        {
          title = 'Çalışanı Çıkar',
          icon = 'fa-solid fa-user-xmark',
          onSelect = function()
            TriggerServerEvent('yg_properties:server:fireBusinessEmployee', propertyId, row.citizenid)
          end
        }
      }
    })
  end

  options[#options + 1] = {
    title = 'Yakındaki Oyuncuyu İşe Al',
    icon = 'fa-solid fa-user-plus',
    onSelect = function()
      local nearby = lib.callback.await('yg_properties:server:getNearbyPlayers', false, 6.0) or {}
      if #nearby == 0 then
        notify('Yakında oyuncu yok.', 'error')
        return
      end

      local playerOptions = {}
      for _, player in ipairs(nearby) do
        playerOptions[#playerOptions + 1] = {
          title = ('%s [%s]'):format(player.name, player.src),
          description = player.citizenid,
          onSelect = function()
            local input = lib.inputDialog('Çalışan Ekle', {
              { type = 'number', label = 'Grade', required = true, default = 0, min = 0 },
              { type = 'number', label = 'Maaş', required = true, default = 0, min = 0 }
            })
            if input then
              TriggerServerEvent('yg_properties:server:hireBusinessEmployee', propertyId, player.src, tonumber(input[1]) or 0, tonumber(input[2]) or 0)
            end
          end
        }
      end

      lib.registerContext({
        id = ('yg_property_staff_hire_%s'):format(propertyId),
        title = 'Çalışan Seç',
        menu = ('yg_property_staff_%s'):format(propertyId),
        options = playerOptions,
      })
      lib.showContext(('yg_property_staff_hire_%s'):format(propertyId))
    end
  }

  lib.registerContext({
    id = ('yg_property_staff_%s'):format(propertyId),
    title = 'Çalışan / Grade Yönetimi',
    options = options,
  })
  lib.showContext(('yg_property_staff_%s'):format(propertyId))
end)
