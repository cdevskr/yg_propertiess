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
local GetEntityHeading = GetEntityHeading
local SetEntityHeading = SetEntityHeading
local SetEntityCoords = SetEntityCoords

local function notify(msg, typ)
  if lib and lib.notify then
    lib.notify({ type = typ or 'inform', description = msg })
  else
    QBCore.Functions.Notify(msg, typ or 'primary')
  end
end

-- builder.lua'daki ile aynı mantık: model hangi kategoriden, yapı mı?
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
  -- Düzenleme SIRASINDA (obje "live"/dinamik durumdayken) collision'ı
  -- kapatıyoruz — oyuncu/araç ona çarpıp gizmo ile ayarladığın konumu
  -- bozmasın diye. Düzenleme bitince setEntityLocked tekrar solid yapar.
  SetEntityCollision(ent, false, false)

  if SetActivateObjectPhysicsAsSoonAsItIsUnfrozen then
    SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(ent, true)
  end

  if SetObjectPhysicsParams then
    SetObjectPhysicsParams(ent, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
  end
end

local function setEntityLocked(ent)
  if not ent or ent == 0 or not DoesEntityExist(ent) then return end
  -- ✅ BUG DÜZELTİLDİ ("bir tık yukarı kayma"): collision KAPALIYKEN
  -- düzenlenen objenin son konumunu/rotasyonunu burada, collision'ı
  -- tekrar AÇMADAN ÖNCE yakalıyoruz — sonra bir kare bekleyip TEKRAR
  -- zorluyoruz. Collision geç yüklenince RAGE motoru donmuş objeleri
  -- birkaç cm itebiliyor, bu düzeltme onu geri alıyor.
  local c = GetEntityCoords(ent)
  local r = GetEntityRotation(ent, 2)

  SetEntityAsMissionEntity(ent, true, true)
  SetEntityLoadCollisionFlag(ent, true)
  SetEntityCanBeDamaged(ent, false)
  SetEntityInvincible(ent, true)
  SetEntityDynamic(ent, false)
  -- ✅ DÜZELTME: bu fonksiyon DÜZENLEME BİTTİKTEN sonra (kalıcı hale
  -- gelirken) çağrılıyor — collision burada AÇIK olmalı (solid, üstüne
  -- çıkılabilsin, içinden geçilmesin). Collision'ın KAPALI olduğu an
  -- sadece düzenleme SIRASINDADIR (bkz. setEntityEditable).
  SetEntityCollision(ent, true, true)
  RequestCollisionAtCoord(c.x, c.y, c.z)

  -- ✅ BUG DÜZELTİLDİ: ActivatePhysics(ent) kaldırıldı — objects.lua'daki
  -- aynı düzeltme (oyuncu/araç çarpınca obje haritadan düşüyordu).

  if SetActivateObjectPhysicsAsSoonAsItIsUnfrozen then
    SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(ent, false)
  end

  if SetObjectPhysicsParams then
    SetObjectPhysicsParams(ent, 99999.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  end

  FreezeEntityPosition(ent, true)
  Wait(0)
  SetEntityCoords(ent, c.x, c.y, c.z, false, false, false, false)
  SetEntityRotation(ent, r.x, r.y, r.z, 2, true)
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

-- ✅ object_gizmo benzeri araçlarda standart olan: son N işlemi geri alma.
-- ✅ EKLENDİ: RedoStack — Sims'teki gibi Ctrl+Z/Ctrl+Y ile geri al/ileri al
-- yapabilmek için. Her undo/redo işlemi, GERİ ALINDIĞINDA tekrar
-- uygulanabilmesi için karşı yığına (RedoStack<->UndoStack) bir kayıt
-- iter (snapshot tabanlı — model/coords/rotation), objectId'ler her
-- ekleme/silmede DEĞİŞTİĞİ için sabit tutulmuyor.
local UndoStack = {}
local RedoStack = {}
local MAX_UNDO = 10

local function pushUndo(entry)
  UndoStack[#UndoStack + 1] = entry
  if #UndoStack > MAX_UNDO then table.remove(UndoStack, 1) end
  -- yeni bir işlem yapıldığında eski redo geçmişi geçersiz olur (standart
  -- undo/redo davranışı — çoğu editörde de böyledir).
  RedoStack = {}
end

RegisterNetEvent('yg_properties:client:pushUndo', function(entry)
  pushUndo(entry)
end)

-- ============================================================
--  PAYLAŞILAN UNDO/REDO ÇEKİRDEĞİ — hem NUI "Geri Al" düğmesi hem de
--  buildmode.lua'daki Ctrl+Z/Ctrl+Y kısayolları BU fonksiyonları kullanır,
--  tek bir tutarlı geçmiş (UndoStack/RedoStack) üzerinden çalışırlar.
-- ============================================================
local function performUndo()
  local entry = table.remove(UndoStack)
  if not entry then return false, 'empty' end

  if entry.type == 'add' then
    -- eklemeyi geri almak = objeyi sil. Snapshot'ı (model/coords/rotation)
    -- varsa, bu SİLME işlemi redo yığınına konup ileride tekrar EKLEME
    -- olarak uygulanabilir.
    TriggerServerEvent('yg_properties:server:removeObject', entry.propertyId, entry.objectId)
    if entry.snapshot then
      RedoStack[#RedoStack + 1] = { type = 'add', propertyId = entry.propertyId, snapshot = entry.snapshot }
    end
  elseif entry.type == 'delete' then
    -- silmeyi geri almak = objeyi snapshot'tan yeniden ekle (YENİ id ile).
    local ok, res = lib.callback.await('yg_properties:server:addObjectCb', false, entry.propertyId, {
      model = entry.snapshot.model, coords = entry.snapshot.coords,
      rotation = entry.snapshot.rotation, frozen = true, metadata = {},
    })
    if ok then
      RedoStack[#RedoStack + 1] = { type = 'delete', propertyId = entry.propertyId, objectId = res, snapshot = entry.snapshot }
    end
  elseif entry.type == 'update' then
    -- taşımayı geri almak = önceki konuma dön. NOT: "sonraki" konumu
    -- saklamadığımız için bu tip işlemler redo YIĞININA eklenmiyor.
    TriggerServerEvent('yg_properties:server:updateObject', entry.propertyId, entry.objectId, {
      coords = entry.snapshot.coords, rotation = entry.snapshot.rotation, metadata = {},
    })
  end

  return true
end

local function performRedo()
  local entry = table.remove(RedoStack)
  if not entry then return false, 'empty' end

  if entry.type == 'add' then
    -- geri alınan bir EKLEMEYİ yeniden uygula (yeniden ekle, yeni id ile).
    local ok, res = lib.callback.await('yg_properties:server:addObjectCb', false, entry.propertyId, {
      model = entry.snapshot.model, coords = entry.snapshot.coords,
      rotation = entry.snapshot.rotation, frozen = true, metadata = {},
    })
    if ok then
      UndoStack[#UndoStack + 1] = { type = 'add', propertyId = entry.propertyId, objectId = res, snapshot = entry.snapshot }
    end
  elseif entry.type == 'delete' then
    -- geri alınan bir SİLMEYİ yeniden uygula (undo sırasında yeniden
    -- eklenmiş objeyi tekrar sil).
    TriggerServerEvent('yg_properties:server:removeObject', entry.propertyId, entry.objectId)
    UndoStack[#UndoStack + 1] = { type = 'delete', propertyId = entry.propertyId, snapshot = entry.snapshot }
  end

  return true
end

RegisterNetEvent('yg_properties:client:requestUndo', function()
  local ok = performUndo()
  if ok then notify('Geri alındı.', 'success') else notify('Geri alınacak işlem yok.', 'inform') end
end)

RegisterNetEvent('yg_properties:client:requestRedo', function()
  local ok = performRedo()
  if ok then notify('Yinelendi.', 'success') else notify('Yinelenecek işlem yok.', 'inform') end
end)

RegisterNUICallback('getObjectList', function(_, cb)
  if not canUse() then cb({ ok = false, error = 'no_property' }); return end
  local propertyId = pid()

  local rows = lib.callback.await('yg_properties:server:getPropertyObjects', false, propertyId) or {}
  local p = GetEntityCoords(PlayerPedId())
  local list = {}
  for _, row in ipairs(rows) do
    local c = safeDecode(row.coords)
    local dist = c and #(vector3(p.x, p.y, p.z) - vector3(c.x, c.y, c.z)) or 99999.0
    list[#list+1] = {
      id = row.id,
      model = row.model,
      frozen = row.frozen,
      coords = c,
      rotation = safeDecode(row.rotation),
      distance = dist,
    }
  end

  table.sort(list, function(a, b) return a.distance < b.distance end)

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

  -- undo için silmeden önce snapshot al
  if data.model and data.coords then
    pushUndo({ type = 'delete', propertyId = propertyId, snapshot = {
      model = data.model, coords = data.coords, rotation = data.rotation,
    } })
  end

  TriggerServerEvent('yg_properties:server:removeObject', propertyId, objectId)
  cb({ ok = true })
end)

-- yarıçap içindeki TÜM objeleri tek seferde sil (undo yok, dikkatli kullan)
RegisterNUICallback('deleteNearby', function(data, cb)
  if not canUse() then cb({ ok = false, error = 'no_property' }); return end
  local propertyId = pid()
  local radius = tonumber(data and data.radius) or 3.0
  local list = (data and data.objects) or {}

  local p = GetEntityCoords(PlayerPedId())
  local count = 0
  for _, o in ipairs(list) do
    if o.coords then
      local d = #(vector3(p.x, p.y, p.z) - vector3(o.coords.x, o.coords.y, o.coords.z))
      if d <= radius then
        TriggerServerEvent('yg_properties:server:removeObject', propertyId, o.id)
        count = count + 1
      end
    end
  end

  cb({ ok = true, count = count })
end)

-- son işlemi geri al (ekleme/silme/taşıma)
RegisterNUICallback('undoLast', function(_, cb)
  local ok = performUndo()
  if not ok then
    cb({ ok = false, error = 'empty' })
    return
  end

  notify('Geri alındı.', 'success')
  cb({ ok = true })
end)

-- ✅ EKLENDİ: NUI tarafında da ileri al (redo) için — Ctrl+Y kısayolunun
-- simetriği, aynı çekirdek fonksiyonu (performRedo) kullanır.
RegisterNUICallback('redoLast', function(_, cb)
  local ok = performRedo()
  if not ok then
    cb({ ok = false, error = 'empty' })
    return
  end

  notify('Yinelendi.', 'success')
  cb({ ok = true })
end)

-- mevcut objeyi kopyala, hemen gizmo ile konumlandır
RegisterNUICallback('duplicateObject', function(data, cb)
  if not canUse() then cb({ ok = false, error = 'no_property' }); return end
  local propertyId = pid()
  local model = data and data.model
  local coords = data and data.coords
  local rotation = data and data.rotation
  if not model or not coords then cb({ ok = false, error = 'bad_data' }); return end

  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  cb({ ok = true })

  local hash = joaat(model)
  RequestModel(hash)
  local t = GetGameTimer() + 5000
  while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(0) end
  if not HasModelLoaded(hash) then
    notify('Model yüklenemedi.', 'error')
    SetNuiFocus(true, true); SetNuiFocusKeepInput(false)
    return
  end

  local nc = { x = coords.x + 0.5, y = coords.y + 0.5, z = coords.z }
  local obj = CreateObject(hash, nc.x, nc.y, nc.z, false, false, false)
  SetEntityAsMissionEntity(obj, true, true)
  SetEntityCollision(obj, false, false) -- yerleştirirken geçici kapalı, setEntityLocked sonra solid yapar
  if rotation then SetEntityRotation(obj, rotation.x, rotation.y, rotation.z, 2, true) end

  setEntityEditable(obj)
  -- kontrol ipucu artık gizmonun kendi NUI overlay'inde gösteriliyor
  local result = YgOpenGizmo(obj, isStructureModel(model) and { 255, 20, 147, 255 } or nil)

  if not result then
    if DoesEntityExist(obj) then DeleteEntity(obj) end
    notify('İptal edildi.', 'inform')
    SetNuiFocus(true, true); SetNuiFocusKeepInput(false)
    return
  end

  -- ✅ KALDIRILDI: otomatik ızgara hizalama (bkz. builder.lua'daki açıklama).

  setEntityLocked(obj)
  local c2 = GetEntityCoords(obj)
  local rx, ry, rz = table.unpack(GetEntityRotation(obj, 2))

  local ok, res = lib.callback.await('yg_properties:server:addObjectCb', false, propertyId, {
    model = model, coords = { x = c2.x, y = c2.y, z = c2.z },
    rotation = { x = rx, y = ry, z = rz }, frozen = true, metadata = {},
  })

  if DoesEntityExist(obj) then DeleteEntity(obj) end -- server broadcast'i objects.lua zaten doğru spawnlayacak

  if ok then
    pushUndo({ type = 'add', propertyId = propertyId, objectId = res, snapshot = {
      model = model, coords = { x = c2.x, y = c2.y, z = c2.z }, rotation = { x = rx, y = ry, z = rz },
    } })
    notify('Çoğaltıldı.', 'success')
  else
    notify('Kaydedilemedi.', 'error')
  end

  SetNuiFocus(true, true); SetNuiFocusKeepInput(false)
  SendNUIMessage({ action = 'refreshManage' })
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

  -- undo için taşımadan ÖNCEKİ konumu sakla
  local beforeC = GetEntityCoords(ent)
  local beforeR = GetEntityRotation(ent, 2)
  local beforeSnapshot = {
    coords = { x = beforeC.x, y = beforeC.y, z = beforeC.z },
    rotation = { x = beforeR[1], y = beforeR[2], z = beforeR[3] },
  }

  -- kontrol ipucu artık gizmonun kendi NUI overlay'inde gösteriliyor
  local result = YgOpenGizmo(ent, (data.model and isStructureModel(data.model)) and { 255, 20, 147, 255 } or nil)

  if not result then
    setEntityLocked(ent)
    notify('İptal edildi.', 'inform')
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    return
  end

  -- ✅ KALDIRILDI: otomatik ızgara hizalama (bkz. builder.lua'daki açıklama).

  setEntityLocked(ent)

  local c = GetEntityCoords(ent)
  local rx, ry, rz = table.unpack(GetEntityRotation(ent, 2))

  TriggerServerEvent('yg_properties:server:updateObject', propertyId, objectId, {
    coords = { x = c.x, y = c.y, z = c.z },
    rotation = { x = rx, y = ry, z = rz },
    metadata = {}
  })

  pushUndo({ type = 'update', propertyId = propertyId, objectId = objectId, snapshot = beforeSnapshot })
  notify('Güncellendi.', 'success')

  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ action = 'refreshManage' })
end)
