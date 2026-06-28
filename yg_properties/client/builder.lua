local QBCore = exports['qb-core']:GetCoreObject()

-- ✅ OPTİMİZASYON: Localized functions
local SetNuiFocus = SetNuiFocus
local SetNuiFocusKeepInput = SetNuiFocusKeepInput
local SendNUIMessage = SendNUIMessage
local joaat = joaat
local IsModelInCdimage = IsModelInCdimage
local RequestModel = RequestModel
local GetGameTimer = GetGameTimer
local HasModelLoaded = HasModelLoaded
local Wait = Wait
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local GetEntityForwardVector = GetEntityForwardVector
local CreateObject = CreateObject
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local ActivatePhysics = ActivatePhysics
local FreezeEntityPosition = FreezeEntityPosition
local SetEntityDynamic = SetEntityDynamic
local GetEntityRotation = GetEntityRotation
local DeleteEntity = DeleteEntity
local DoesEntityExist = DoesEntityExist

local Builder = { uiOpen = false, placing = false }

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

local function focusReset()
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
end

local function setUi(open)
  focusReset()
  Builder.uiOpen = open and true or false

  if Builder.uiOpen then
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'open', catalog = Config.BuildCatalog or {} })
  else
    SendNUIMessage({ action = 'close' })
    focusReset()
  end
end

local function loadModel(model)
  model = tostring(model or ''):gsub('%s+', '')
  if model == '' then return nil, 'empty' end
  local hash = joaat(model)
  if not IsModelInCdimage(hash) then return nil, 'not_found' end
  RequestModel(hash)
  local t = GetGameTimer() + 5000
  while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(0) end
  if not HasModelLoaded(hash) then return nil, 'timeout' end
  return hash, nil
end

local function spawnNearPlayer(hash)
  local ped = PlayerPedId()
  local p = GetEntityCoords(ped)
  local fwd = GetEntityForwardVector(ped)
  local pos = vector3(p.x + fwd.x * 2.0, p.y + fwd.y * 2.0, p.z + 0.2)

  local obj = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false)
  SetEntityAsMissionEntity(obj, true, true)
  return obj
end

-- ✅ OPTİMİZASYON: Batch save with error handling
local function savePlacedObject(model, entity)
  ActivatePhysics(entity)
  FreezeEntityPosition(entity, true)
  SetEntityDynamic(entity, false)
  Wait(0)
  FreezeEntityPosition(entity, true)

  local c = GetEntityCoords(entity)
  local rx, ry, rz = table.unpack(GetEntityRotation(entity, 2))

  local ok, res = lib.callback.await('yg_properties:server:addObjectCb', false, pid(), {
    model = model,
    coords = { x = c.x, y = c.y, z = c.z },
    rotation = { x = rx, y = ry, z = rz },
    frozen = true,
    metadata = {}
  })

  if not ok then
    notify(('Kaydedilemedi: %s'):format(tostring(res)), 'error')
    return false
  end

  notify('Kaydedildi.', 'success')
  return true
end

local function placeModel(model)
  if Builder.placing then return end
  if not canUse() then notify('Önce mekana gir.', 'error'); return end

  model = tostring(model or ''):gsub('%s+', '')
  if model == '' then return end

  Builder.placing = true
  setUi(false)

  local hash, err = loadModel(model)
  if not hash then
    notify(('Model yüklenemedi: %s (%s)'):format(tostring(model), tostring(err)), 'error')
    Builder.placing = false
    setUi(true)
    return
  end

  local obj = spawnNearPlayer(hash)
  local result = exports['object_gizmo']:useGizmo(obj)

  if not result then
    if DoesEntityExist(obj) then DeleteEntity(obj) end
    notify('İptal edildi.', 'inform')
    Builder.placing = false
    setUi(true)
    return
  end

  local saved = savePlacedObject(model, obj)
  if DoesEntityExist(obj) then DeleteEntity(obj) end

  Builder.placing = false
  setUi(true)

  if not saved then return end
end

RegisterNetEvent('yg_properties:client:openBuildEditor', function()
  if not canUse() then
    notify('Önce mekana gir.', 'error')
    return
  end

  local ok = lib.callback.await('yg_properties:server:canManage', false, pid())
  if not ok then
    notify('Bu mekanda build yetkin yok (satın alınmamış olabilir).', 'error')
    return
  end

  setUi(true)
end)

RegisterNetEvent('yg_properties:client:closeBuildEditor', function()
  if Builder.uiOpen then setUi(false) end
end)

RegisterNUICallback('close', function(_, cb)
  setUi(false)
  cb({})
end)

RegisterNUICallback('spawn', function(data, cb)
  local model = data and data.model
  if not model then cb({ ok = false, error = 'no_model' }); return end
  cb({ ok = true })
  placeModel(model)
end)

RegisterNUICallback('spawnByModel', function(data, cb)
  local model = data and data.model
  if not model then cb({ ok = false, error = 'no_model' }); return end
  cb({ ok = true })
  placeModel(model)
end)
