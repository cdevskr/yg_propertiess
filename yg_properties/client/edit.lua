local QBCore = exports['qb-core']:GetCoreObject()

-- ✅ OPTİMİZASYON: Localized functions
local SetNuiFocus = SetNuiFocus
local SetNuiFocusKeepInput = SetNuiFocusKeepInput
local SendNUIMessage = SendNUIMessage
local GetEntityCoords = GetEntityCoords
local GetEntityRotation = GetEntityRotation
local DoesEntityExist = DoesEntityExist
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local FreezeEntityPosition = FreezeEntityPosition
local SetEntityDynamic = SetEntityDynamic
local SetEntityLoadCollisionFlag = SetEntityLoadCollisionFlag
local SetEntityCanBeDamaged = SetEntityCanBeDamaged
local SetEntityInvincible = SetEntityInvincible
local ActivatePhysics = ActivatePhysics
local SetActivateObjectPhysicsAsSoonAsItIsUnfrozen = SetActivateObjectPhysicsAsSoonAsItIsUnfrozen
local SetObjectPhysicsParams = SetObjectPhysicsParams
local Wait = Wait
local TriggerServerEvent = TriggerServerEvent

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

local function canUse()
  return pid() ~= nil
end

local function safeDecode(v)
  if type(v) == 'table' then return v end
  if type(v) ~= 'string' or v == '' then return nil end
  local ok, res = pcall(json.decode, v)
  if not ok then return nil end
  return res
end

local function getSpawnedEntityById(objectId)
  local spawned = exports['yg_properties']:yg_getSpawnedObjects()
  return spawned and spawned[objectId] or nil
end

local function setEntityEditable(ent)
  if not ent or ent == 0 or not DoesEntityExist(ent) then return end
  SetEntityAsMissionEntity(ent, true, true)

  FreezeEntityPosition(ent, false)
  SetEntityDynamic(ent, true)
  ActivatePhysics(ent)

  if SetActivateObjectPhysicsAsSoonAsItIsUnfrozen then
    SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(ent, true)
  end

  if SetObjectPhysicsParams then
    SetObjectPhysicsParams(ent, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
  end
end

local function setEntityLocked(ent)
  if not ent or ent == 0 or not DoesEntityExist(ent) then return end
  SetEntityAsMissionEntity(ent, true, true)
  SetEntityLoadCollisionFlag(ent, true)
  SetEntityCanBeDamaged(ent, false)
  SetEntityInvincible(ent, true)

  ActivatePhysics(ent)
  SetEntityDynamic(ent, false)

  if SetActivateObjectPhysicsAsSoonAsItIsUnfrozen then
    SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(ent, false)
  end

  if SetObjectPhysicsParams then
    SetObjectPhysicsParams(ent, 99999.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  end

  FreezeEntityPosition(ent, true)
  Wait(0)
  FreezeEntityPosition(ent, true)
end

RegisterNetEvent('yg_properties:client:openObjectManager', function()
  if not canUse() then
    notify('Önce mekana gir.', 'error')
    return
  end

  local ok = lib.callback.await('yg_properties:server:canManage', false, pid())
  if not ok then
    notify('Bu mekanda obje yönetme yetkin yok (satın alınmamış olabilir).', 'error')
    return
  end

  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ action = 'openManage' })
end)

RegisterNUICallback('getObjectList', function(_, cb)
  if not canUse() then cb({ ok = false, error = 'no_property' }); return end
  local propertyId = pid()

  local rows = lib.callback.await('yg_properties:server:getPropertyObjects', false, propertyId) or {}
  local list = {}
  for _, row in ipairs(rows) do
    list[#list+1] = {
      id = row.id,
      model = row.model,
      frozen = row.frozen,
      coords = safeDecode(row.coords),
      rotation = safeDecode(row.rotation),
    }
  end

  cb({ ok = true, propertyId = propertyId, objects = list })
end)

RegisterNUICallback('closeManage', function(_, cb)
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  cb({ ok = true })
end)

RegisterNUICallback('deleteObject', function(data, cb)
  if not canUse() then cb({ ok = false, error = 'no_property' }); return end
  local propertyId = pid()
  local objectId = tonumber(data and data.id)
  if not objectId then cb({ ok = false, error = 'bad_id' }); return end

  TriggerServerEvent('yg_properties:server:removeObject', propertyId, objectId)
  cb({ ok = true })
end)

RegisterNetEvent('yg_properties:client:loadMLO', function(propertyId, ipl, coords)
  RequestIpl(ipl)
  SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
end)

RegisterNUICallback('editObject', function(data, cb)
  if not canUse() then cb({ ok = false, error = 'no_property' }); return end
  local propertyId = pid()
  local objectId = tonumber(data and data.id)
  if not objectId then cb({ ok = false, error = 'bad_id' }); return end

  local ent = getSpawnedEntityById(objectId)
  if not ent or not DoesEntityExist(ent) then
    cb({ ok = false, error = 'not_spawned' })
    notify('Obje bulunamadı. Refresh yapıp tekrar dene.', 'error')
    return
  end

  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  cb({ ok = true })

  setEntityEditable(ent)

  local result = exports['object_gizmo']:useGizmo(ent)

  if not result then
    setEntityLocked(ent)
    notify('İptal edildi.', 'inform')
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    return
  end

  setEntityLocked(ent)

  local c = GetEntityCoords(ent)
  local rx, ry, rz = table.unpack(GetEntityRotation(ent, 2))

  TriggerServerEvent('yg_properties:server:updateObject', propertyId, objectId, {
    coords = { x = c.x, y = c.y, z = c.z },
    rotation = { x = rx, y = ry, z = rz },
    metadata = {}
  })

  notify('Güncellendi.', 'success')

  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ action = 'refreshManage' })
end)
