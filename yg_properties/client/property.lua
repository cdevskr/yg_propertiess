local QBCore = exports['qb-core']:GetCoreObject()
local AccessPoints = {}
local AccessTargets = {}
local placing = false

local function notify(msg, typ)
  if lib and lib.notify then
    lib.notify({ type = typ or 'inform', description = msg })
  else
    QBCore.Functions.Notify(msg, typ or 'primary')
  end
end

local function pid()
  return LocalPlayer.state.ygPropertyId
end

local function clearTargets()
  for _, handle in pairs(AccessTargets) do
    if Bridge and Bridge.RemoveZone then
      Bridge.RemoveZone(handle)
    end
  end
  AccessTargets = {}
end

local function handleAccessPoint(point)
  local propertyId = pid()
  if not propertyId or not point then return end
  if point.type == 'storage' then
    TriggerServerEvent('yg_properties:server:openStash', propertyId)
  elseif point.type == 'wardrobe' then
    TriggerServerEvent('yg_properties:server:openWardrobe', propertyId)
  elseif point.type == 'safe' then
    TriggerEvent('yg_properties:client:openSafeMenu', propertyId)
  end
end

local function rebuildTargets()
  clearTargets()
  if not pid() or not Bridge or not Bridge.target then return end
  if not Config.Interaction or Config.Interaction.mode ~= 'target' then return end

  for _, point in ipairs(AccessPoints) do
    local marker = Config.AccessPoint and Config.AccessPoint.markers and Config.AccessPoint.markers[point.type] or nil
    local label = marker and marker.label or point.type
    AccessTargets[point.id] = Bridge.AddAccessTarget(pid(), point.id, point.coords, label, function()
      handleAccessPoint(point)
    end)
  end
end

local function refreshAccessPoints()
  local propertyId = pid()
  if not propertyId then
    AccessPoints = {}
    clearTargets()
    return
  end
  AccessPoints = lib.callback.await('yg_properties:server:getAccessPoints', false, propertyId) or {}
  rebuildTargets()
end

RegisterNetEvent('yg_properties:client:targetReady', function()
  rebuildTargets()
end)

RegisterNetEvent('yg_properties:client:accessPointsChanged', function(propertyId)
  if tonumber(propertyId) == pid() then
    refreshAccessPoints()
  end
end)

RegisterNetEvent('yg_properties:client:startPlaceAccessPoint', function(propertyId, kind)
  if placing then return end
  if pid() ~= propertyId then
    notify('Bunu yapmak için önce bu mekana girmen lazım.', 'error')
    return
  end

  local ok = lib.callback.await('yg_properties:server:canManage', false, propertyId)
  if not ok then
    notify('Bu mekanda erişim noktası yerleştirme yetkin yok.', 'error')
    return
  end

  placing = true
  CreateThread(function()
    local marker = Config.AccessPoint and Config.AccessPoint.markers and Config.AccessPoint.markers[kind] or { label = kind, color = { r = 255, g = 159, b = 10 } }
    local color = marker.color or { r = 255, g = 159, b = 10 }

    while placing and pid() == propertyId do
      Wait(0)
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped) + GetEntityForwardVector(ped) * 1.0
      DrawMarker(36, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, color.r, color.g, color.b, 180, false, false, 2, false, nil, nil, false)
      BeginTextCommandDisplayHelp('STRING')
      AddTextComponentSubstringPlayerName(('~INPUT_FRONTEND_ACCEPT~ yerleştir / ~INPUT_FRONTEND_CANCEL~ iptal (%s)'):format(marker.label or kind))
      EndTextCommandDisplayHelp(0, false, true, -1)

      if IsControlJustReleased(0, (Config.Gizmo and Config.Gizmo.keys and Config.Gizmo.keys.confirm) or 191) then
        placing = false
        TriggerServerEvent('yg_properties:server:addAccessPoint', propertyId, kind, { x = pos.x, y = pos.y, z = pos.z })
      elseif IsControlJustReleased(0, (Config.Gizmo and Config.Gizmo.keys and Config.Gizmo.keys.cancel) or 194) then
        placing = false
        notify('İptal edildi.', 'inform')
      end
    end
  end)
end)

AddEventHandler('yg_properties:client:enter', function(propertyId)
  SetTimeout(1200, function()
    if pid() == tonumber(propertyId) then
      refreshAccessPoints()
    end
  end)
end)

AddEventHandler('yg_properties:client:exitComplete', function()
  AccessPoints = {}
  clearTargets()
end)

AddEventHandler('onClientResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  clearTargets()
end)

CreateThread(function()
  while true do
    local propertyId = pid()
    if propertyId and not placing then
      local sleep = 500
      local pc = GetEntityCoords(PlayerPedId())
      for _, point in ipairs(AccessPoints) do
        local coords = point.coords
        if coords then
          local dist = #(pc - vec3(coords.x, coords.y, coords.z))
          if dist < (Config.AccessPoint and Config.AccessPoint.drawDist or 6.0) then
            sleep = 0
            local marker = Config.AccessPoint and Config.AccessPoint.markers and Config.AccessPoint.markers[point.type] or { label = point.type, color = { r = 255, g = 159, b = 10 } }
            local color = marker.color or { r = 255, g = 159, b = 10 }
            DrawMarker(36, coords.x, coords.y, coords.z + 0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.35, color.r, color.g, color.b, 180, false, false, 2, false, nil, nil, false)
            if dist < (Config.AccessPoint and Config.AccessPoint.interactDist or 1.6) then
              BeginTextCommandDisplayHelp('STRING')
              AddTextComponentSubstringPlayerName(('[E] %s  •  [DEL] sil'):format(marker.label or point.type))
              EndTextCommandDisplayHelp(0, false, true, -1)
              if IsControlJustReleased(0, (Config.AccessPoint and Config.AccessPoint.openKey) or 38) then
                handleAccessPoint(point)
              elseif IsControlJustReleased(0, 178) then
                TriggerServerEvent('yg_properties:server:removeAccessPoint', propertyId, point.id)
              end
            end
          end
        end
      end
      Wait(sleep)
    else
      Wait(500)
    end
  end
end)
