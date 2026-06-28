local spawned = {} -- [id] = entity

local function requestModel(model)
  local hash = joaat(model)
  if not IsModelInCdimage(hash) then return false end
  RequestModel(hash)
  local t = GetGameTimer() + 5000
  while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(0) end
  return HasModelLoaded(hash)
end

local function safeDecode(v)
  if type(v) == 'table' then return v end
  if type(v) ~= 'string' or v == '' then return nil end
  local ok, res = pcall(json.decode, v)
  if not ok then return nil end
  return res
end

local function applyPlacedObjectProps(ent, frozen)
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

  if frozen then
    FreezeEntityPosition(ent, true)
    Wait(0)
    FreezeEntityPosition(ent, true)
  else
    FreezeEntityPosition(ent, false)
  end
end

local function spawnOne(row)
  if not row or not row.id or not row.model then return end

  if spawned[row.id] and DoesEntityExist(spawned[row.id]) then
    DeleteEntity(spawned[row.id])
    spawned[row.id] = nil
  end

  if not requestModel(row.model) then
    print(('[yg_properties] model not loaded: %s'):format(tostring(row.model)))
    return
  end

  local c = safeDecode(row.coords)
  local r = safeDecode(row.rotation)
  if not c or not r then return end

  local ent = CreateObject(joaat(row.model), c.x, c.y, c.z, false, false, false)
  SetEntityRotation(ent, r.x, r.y, r.z, 2, true)

  local frozen = tonumber(row.frozen or 1) == 1
  applyPlacedObjectProps(ent, frozen)

  spawned[row.id] = ent
end

local function clearAll()
  for _, ent in pairs(spawned) do
    if DoesEntityExist(ent) then DeleteEntity(ent) end
  end
  spawned = {}
end

RegisterNetEvent('yg_properties:client:loadObjects', function(propertyId)
  if LocalPlayer.state.ygPropertyId ~= propertyId then return end
  clearAll()

  local rows = lib.callback.await('yg_properties:server:getPropertyObjects', false, propertyId) or {}
  for _, row in ipairs(rows) do
    spawnOne(row)
  end

  TriggerEvent('yg_properties:client:objectsLoaded', propertyId, #rows)
end)

RegisterNetEvent('yg_properties:client:clearObjects', function()
  clearAll()
end)

RegisterNetEvent('yg_properties:client:objectAdded', function(propertyId, row)
  if LocalPlayer.state.ygPropertyId ~= propertyId then return end
  spawnOne(row)
end)

RegisterNetEvent('yg_properties:client:objectUpdated', function(propertyId, objectId, data)
  if LocalPlayer.state.ygPropertyId ~= propertyId then return end

  local ent = spawned[objectId]
  if not ent or not DoesEntityExist(ent) then
    TriggerEvent('yg_properties:client:loadObjects', propertyId)
    return
  end

  local c = safeDecode(data.coords)
  local r = safeDecode(data.rotation)
  if not c or not r then return end

  SetEntityCoordsNoOffset(ent, c.x, c.y, c.z, false, false, false)
  SetEntityRotation(ent, r.x, r.y, r.z, 2, true)

  local frozen = tonumber(data.frozen or 1) == 1
  applyPlacedObjectProps(ent, frozen)
end)

RegisterNetEvent('yg_properties:client:objectRemoved', function(propertyId, objectId)
  if LocalPlayer.state.ygPropertyId ~= propertyId then return end
  local ent = spawned[objectId]
  if ent and DoesEntityExist(ent) then DeleteEntity(ent) end
  spawned[objectId] = nil
end)

exports('yg_getSpawnedObjects', function()
  return spawned
end)