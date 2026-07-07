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
local GetEntityHeading = GetEntityHeading
local SetEntityHeading = SetEntityHeading
local SetEntityCoords = SetEntityCoords
local SetEntityRotation = SetEntityRotation
local Builder = { uiOpen = false, placing = false }

-- ✅ EKLENDİ: Dekor menüsünde bir objenin üzerine (Yerleştir'e) gelince,
-- o objenin GERÇEK 3D modelini oyuncunun sağında, havada gösteren
-- önizleme sistemi — sadece bizde (client-side) görünüyor, hiçbir
-- şekilde kaydedilmiyor/yerleştirilmiyor, sadece "bu obje neye
-- benziyor" diye bakabilesin diye.
local PreviewObj = nil
local PreviewHash = nil

local function clearPreview()
    if PreviewObj and DoesEntityExist(PreviewObj) then DeleteEntity(PreviewObj) end
    PreviewObj = nil
    if PreviewHash then SetModelAsNoLongerNeeded(PreviewHash) end
    PreviewHash = nil
end

RegisterNUICallback('previewProp', function(data, cb)
    cb({ ok = true })
    local model = data and data.model
    if not model or model == '' then return end

    clearPreview()

    local hash = joaat(model)
    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    local t = GetGameTimer() + 2000
    while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(0) end
    if not HasModelLoaded(hash) then return end

    -- ✅ BUG DÜZELTİLDİ: karakterin baktığı yön (GetEntityForwardVector)
    -- yerine KAMERANIN gerçek yönünü kullanıyoruz — üçüncü şahıs
    -- kamerasında bu ikisi FARKLI olabiliyor (menü açıkken kamera sabit
    -- kalırken karakter başka yöne bakıyor olabilir), obje bu yüzden
    -- ekranda hiç görünmeyen bir yere (kameranın arkasına/dışına)
    -- düşüyordu.
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local rad = math.rad(camRot.z)
    local fwdX, fwdY = -math.sin(rad), math.cos(rad)
    local rightX, rightY = math.cos(rad), math.sin(rad)

    local px = camCoords.x + fwdX * 1.8 + rightX * 0.7
    local py = camCoords.y + fwdY * 1.8 + rightY * 0.7
    local pz = camCoords.z - 0.3

    PreviewObj = CreateObject(hash, px, py, pz, false, false, false)
    PreviewHash = hash
    if PreviewObj and PreviewObj ~= 0 then
        SetEntityAlpha(PreviewObj, 235, false)
        SetEntityCollision(PreviewObj, false, false)
        FreezeEntityPosition(PreviewObj, true)
        SetEntityRotation(PreviewObj, 0.0, 0.0, camRot.z + 180.0, 2, true) -- kameraya dönük dursun
    end
end)

RegisterNUICallback('previewPropClear', function(data, cb)
    cb({ ok = true })
    clearPreview()
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    clearPreview()
end)

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

-- ✅ EKLENDİ: "Dekor Menüsü hep açık kalsın" isteği için — focusReset'in
-- simetriği, ama DOM'u YENİDEN KURMUYOR (setUi(true) gibi 'open' mesajı
-- göndermiyor). Menü zaten ekranda duruyor, sadece fare/klavye kontrolünü
-- geri alıyoruz.
local function focusRestore()
  SetNuiFocus(true, true)
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

-- Bu model hangi kategoriden? (Config.BuildCatalog'ta arar)
local function findCategoryForModel(model)
  for _, cat in ipairs(Config.BuildCatalog or {}) do
    for _, item in ipairs(cat.items or {}) do
      if item.model == model then return cat.category end
    end
  end
  return nil
end

local function isStructureModel(model)
  local cat = findCategoryForModel(model)
  return cat ~= nil and Config.StructureCategories and Config.StructureCategories[cat] == true
end

-- "En Yakın Objeye Bitiştir" mantığı artık client/gizmo.lua içinde ([F] tuşu)
-- — burada tekrar tanımlamaya gerek yok.

-- Yapı (duvar/zemin) objelerini ızgaraya oturtur — yan yana dizilince
-- düzgün hizalı dursunlar diye. Sadece "yapı" kategorisindeki modellere
-- uygulanır, mobilya/dekor serbest kalır.
-- ✅ BUG DÜZELTİLDİ: önceden SetEntityHeading kullanıyordum — bu native
-- objelerde pitch/roll'u GARANTİ KORUMUYOR (sadece yaw'a odaklı), bu
-- yüzden gizmo ile eğip/çevirdiğin duvar burada "rotate öncesi" haline
-- sıfırlanıyordu. Şimdi GetEntityRotation'dan mevcut pitch/roll'u alıp
-- SetEntityRotation ile SADECE yaw'ı (z) snap'liyorum, x/y aynen kalıyor.
local function snapToGrid(entity)
  local grid = Config.StructureGridSize or 0.5
  local headSnap = Config.StructureHeadingSnap or 15

  local c = GetEntityCoords(entity)
  local r = GetEntityRotation(entity, 2)

  local nx = math.floor((c.x / grid) + 0.5) * grid
  local ny = math.floor((c.y / grid) + 0.5) * grid
  local nz = math.floor((r.z / headSnap) + 0.5) * headSnap

  SetEntityCoords(entity, nx, ny, c.z, false, false, false, false)
  SetEntityRotation(entity, r.x, r.y, nz, 2, true)
end

local function spawnNearPlayer(hash)
  local ped = PlayerPedId()
  local p = GetEntityCoords(ped)
  local fwd = GetEntityForwardVector(ped)
  local pos = vector3(p.x + fwd.x * 2.0, p.y + fwd.y * 2.0, p.z + 0.2)

  local obj = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false)
  SetEntityAsMissionEntity(obj, true, true)
  -- Yerleştirme SIRASINDA (gizmo açıkken) collision kapalı — oyuncu/araç
  -- ona çarpıp düşürmesin diye. savePlacedObject çağrılıp obje kalıcı hale
  -- gelince (objects.lua üzerinden yeniden spawnlanınca) solid olur.
  SetEntityCollision(obj, false, false)
  return obj
end

-- ✅ OPTİMİZASYON: Batch save with error handling
local function savePlacedObject(model, entity)
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
    if res == 'limit' then
      notify(('Obje limiti dolu (%s).'):format(Config.MaxObjectsPerProperty or 300), 'error')
    else
      notify(('Kaydedilemedi: %s'):format(tostring(res)), 'error')
    end
    return false
  end

  notify('Kaydedildi.', 'success')
  TriggerEvent('yg_properties:client:pushUndo', { type = 'add', propertyId = pid(), objectId = res, snapshot = {
    model = model, coords = { x = c.x, y = c.y, z = c.z }, rotation = { x = rx, y = ry, z = rz },
  } })
  return true
end

local function placeModel(model)
  if Builder.placing then return end
  if not canUse() then notify('Önce mekana gir.', 'error'); return end

  model = tostring(model or ''):gsub('%s+', '')
  if model == '' then return end

  Builder.placing = true
  -- ✅ DEĞİŞTİ: eskiden setUi(false) menüyü TAMAMEN YOK EDİYORDU (DOM'u
  -- silip, işlem bitince yeniden kuruyordu — "Yükleniyor" anı, menünün
  -- kapanıp açılma hissi). Artık menü EKRANDA KALIYOR, sadece fare/
  -- klavye kontrolünü oyuna bırakıyoruz (focusReset) — sen objeyi
  -- gizmo ile konumlandırırken (yürüyerek/döndürerek) menü arka planda
  -- görünür duruyor, Enter'a basıp onaylayınca (gizmo zaten bekleyen/
  -- bloklayan bir çağrı olduğu için) otomatik olarak menüye tekrar
  -- odaklanıyoruz (focusRestore) — EKSTRA bir tuşa hiç gerek yok.
  focusReset()

  local hash, err = loadModel(model)
  if not hash then
    notify(('Model yüklenemedi: %s (%s)'):format(tostring(model), tostring(err)), 'error')
    Builder.placing = false
    focusRestore()
    return
  end

  local isStructure = isStructureModel(model)
  local obj = spawnNearPlayer(hash)

  -- kontrol ipucu artık gizmonun kendi NUI overlay'inde gösteriliyor —
  -- "En Yakın Objeye Bitiştir" artık orada [F] tuşu (bkz. gizmo.lua),
  -- NUI butonu değil, hem katalogdan hem custom model girişinden gelen
  -- objelerde aynı şekilde çalışır.
  -- Yapı (duvar/zemin) objeleri PEMBE outline ile vurgulanır (görünüm/ayrım
  -- için) — mobilya/dekor object_gizmo'nun varsayılan rengiyle kalır.
  local result = YgOpenGizmo(obj, isStructure and { 255, 20, 147, 255 } or nil)

  if not result then
    if DoesEntityExist(obj) then DeleteEntity(obj) end
    notify('İptal edildi.', 'inform')
    Builder.placing = false
    focusRestore()
    return
  end

  -- ✅ KALDIRILDI: otomatik ızgara hizalama. Önceden burada snapToGrid()
  -- çağrılıp X/Y/açı otomatik yuvarlanıyordu — bu, gizmo ile TAM olarak
  -- ayarladığın konumu Enter'dan SONRA değiştiriyordu ("bazen üstüne
  -- bazen yanına kayıyor" şikayetinin sebebi buydu). Artık obje Enter'a
  -- bastığında gizmo'da bıraktığın HALİYLE birebir kaydediliyor.

  local saved = savePlacedObject(model, obj)

  if DoesEntityExist(obj) then DeleteEntity(obj) end

  Builder.placing = false
  focusRestore()

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
