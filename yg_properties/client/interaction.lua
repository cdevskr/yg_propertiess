local QBCore = exports['qb-core']:GetCoreObject()

local function notify(msg, typ)
  if lib and lib.notify then
    lib.notify({ type = typ or 'inform', description = msg })
  else
    QBCore.Functions.Notify(msg, typ or 'primary')
  end
end

local function nearestDoor(maxDist)
  local props = GetProperties and GetProperties() or {}
  local pc = GetEntityCoords(PlayerPedId())
  local best, bestDist
  for _, prop in ipairs(props) do
    if prop.door_coords and prop.door_coords ~= '' then
      local door = Shared.DecodeVec4(prop.door_coords)
      local dist = #(pc - vec3(door.x, door.y, door.z))
      if dist <= (maxDist or 2.0) and (not bestDist or dist < bestDist) then
        best, bestDist = prop, dist
      end
    end
  end
  return best, bestDist
end

local function showDoorMenu(prop)
  if not prop then return end
  local options = {
    {
      title = 'İçeri Gir',
      icon = 'fa-solid fa-door-open',
      onSelect = function()
        TriggerEvent('yg_properties:client:enter', prop.id)
      end
    },
    {
      title = 'Mekan Bilgisi',
      icon = 'fa-solid fa-circle-info',
      onSelect = function()
        TriggerEvent('yg_properties:client:showInfo', prop.id)
      end
    }
  }

  if (not prop.owner_citizenid or prop.owner_citizenid == '') then
    options[#options + 1] = {
      title = 'Satın Al',
      icon = 'fa-solid fa-cart-shopping',
      onSelect = function()
        TriggerEvent('yg_properties:client:buy', prop.id)
      end
    }

    if Config.Ownership and Config.Ownership.allowRent and (tonumber(prop.rent_price) or 0) > 0 then
      options[#options + 1] = {
        title = ('Kirala ($%s)'):format(Utils.money(prop.rent_price or 0)),
        icon = 'fa-solid fa-key',
        onSelect = function()
          TriggerEvent('yg_properties:client:rent', prop.id)
        end
      }
    end
  end

  if Config.Keys and Config.Keys.doorbell then
    options[#options + 1] = {
      title = 'Kapıyı Çal',
      icon = 'fa-solid fa-bell',
      onSelect = function()
        TriggerServerEvent('yg_properties:server:knock', prop.id)
      end
    }
  end

  lib.registerContext({
    id = ('yg_property_door_%s'):format(prop.id),
    title = prop.label or ('Mekan #%s'):format(prop.id),
    options = options,
  })
  lib.showContext(('yg_property_door_%s'):format(prop.id))
end

RegisterCommand((Config.Interaction and Config.Interaction.command) or 'property', function()
  if LocalPlayer.state.ygPropertyId then
    TriggerEvent('yg_properties:client:openPanelCurrent')
    return
  end

  local prop = nearestDoor((Config.Interaction and Config.Interaction.interactDist or 1.6) + 1.5)
  if not prop then
    notify('Yakında etkileşime girilecek bir mekan yok.', 'error')
    return
  end

  showDoorMenu(prop)
end, false)

RegisterCommand((Config.Interaction and Config.Interaction.menuCommand) or 'propmenu', function()
  if LocalPlayer.state.ygPropertyId then
    TriggerEvent('yg_properties:client:openPanelCurrent')
    return
  end

  local prop = nearestDoor((Config.Interaction and Config.Interaction.interactDist or 1.6) + 1.5)
  if not prop then
    notify('Yakında etkileşime girilecek bir mekan yok.', 'error')
    return
  end

  showDoorMenu(prop)
end, false)

RegisterKeyMapping((Config.Interaction and Config.Interaction.menuCommand) or 'propmenu', 'Mülk menüsünü aç', 'keyboard', (Config.Interaction and Config.Interaction.menuKey) or 'F6')
