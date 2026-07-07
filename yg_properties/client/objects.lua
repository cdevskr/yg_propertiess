local spawned = {} -- [id] = entity
local spawnedFrozen = {} -- [id] = bool — watchdog hangi objelerin donmuş kalması gerektiğini bilsin diye
local spawnedModel = {} -- [id] = model adı (string) — undo/redo snapshot'ları için (buildmode.lua'nın silme akışı)
-- ✅ EKLENDİ: [id] = metadata tablosu (decode edilmiş) — çoklu kat
-- (metadata.floor) ve duvar/oda boyama (metadata.color) özellikleri
-- için gerekli; öncesinde metadata hiç saklanmıyordu.
local spawnedMetadata = {}

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
  SetEntityDynamic(ent, false)

  -- ✅ DÜZELTME: collision burada KAPATILMIYOR — kalıcı (yerleştirilmiş)
  -- objeler SOLID kalmalı (üstüne çıkılabilsin, içinden geçilmesin).
  -- "Çarpınca düşme" sorunu sadece YERLEŞTİRME SIRASINDA (gizmo açıkken,
  -- henüz kaydedilmemiş geçici obje) oluyordu — onun çözümü builder.lua/
  -- edit.lua'da (geçici obje için collision kapatma), burada DEĞİL.
  SetEntityCollision(ent, true, true)

  -- ✅ BUG DÜZELTİLDİ: ActivatePhysics(ent) BURADA ÇAĞRILMIYOR artık.
  -- Bu çağrı objeyi fizik motoruna "uyandırıyordu" — oyuncu/araç çarpınca
  -- frozen flag'i göz ardı edilip obje haritadan aşağı düşüyordu. Bizim
  -- yerleştirilen objeler hep sabit/donmuş kalacağı için fiziği hiç aktive
  -- etmeye gerek yok.

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

-- ✅ EKLENDİ: metadata.color varsa (Duvar/Oda Boyama özelliği ile
-- kaydedilmiş bir doku varyasyon indexi), objeye uyguluyoruz. Modelin bu
-- native'i desteklemediği durumlarda (çoğu yapı parçası) sessizce hiçbir
-- görsel etkisi olmaz — ama metadata yine de kalıcı, ileride destekleyen
-- modeller eklenirse otomatik çalışır.
local function applyPaint(ent, meta)
  if not ent or ent == 0 or not DoesEntityExist(ent) then return end
  local variation = meta and tonumber(meta.color)
  if variation and SetObjectTextureVariation then
    pcall(SetObjectTextureVariation, ent, variation)
  end
end

-- ✅ EKLENDİ: metadata.floor varsa (Çoklu Kat özelliği) — build modu bu
-- exportu kullanarak, aktif olmayan kattaki objeleri build sırasında
-- gizleyip görünürlüğü geri getirebiliyor.
exports('yg_setObjectFloorVisible', function(id, visible)
  local ent = spawned[id]
  if not ent or not DoesEntityExist(ent) then return end
  SetEntityVisible(ent, visible, false)
  SetEntityCollision(ent, visible, visible)
end)

exports('yg_getSpawnedObjectMetadata', function(id)
  return spawnedMetadata[id]
end)

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

  -- ✅ BUG DÜZELTİLDİ: "bir tık yukarı kayma" — collision geç yüklenince
  -- RAGE motoru donmuş objeleri birkaç cm itebiliyor. Collision'ı zorla
  -- isteyip bir kare bekliyoruz, SONRA koordinatı/rotasyonu TEKRAR
  -- zorluyoruz — böylece obje kesin olarak kaydedilen konumda kalıyor.
  RequestCollisionAtCoord(c.x, c.y, c.z)
  Wait(0)
  SetEntityCoords(ent, c.x, c.y, c.z, false, false, false, false)
  SetEntityRotation(ent, r.x, r.y, r.z, 2, true)

  local frozen = tonumber(row.frozen or 1) == 1
  applyPlacedObjectProps(ent, frozen)

  local meta = safeDecode(row.metadata) or {}
  applyPaint(ent, meta)

  spawned[row.id] = ent
  spawnedFrozen[row.id] = frozen
  spawnedModel[row.id] = row.model
  spawnedMetadata[row.id] = meta
end

local function clearAll()
  for _, ent in pairs(spawned) do
    if DoesEntityExist(ent) then DeleteEntity(ent) end
  end
  spawned = {}
  spawnedFrozen = {}
  spawnedModel = {}
  spawnedMetadata = {}
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
  spawnedFrozen[objectId] = frozen

  local meta = safeDecode(data.metadata) or {}
  applyPaint(ent, meta)
  spawnedMetadata[objectId] = meta
end)

RegisterNetEvent('yg_properties:client:objectRemoved', function(propertyId, objectId)
  if LocalPlayer.state.ygPropertyId ~= propertyId then return end
  local ent = spawned[objectId]
  if ent and DoesEntityExist(ent) then DeleteEntity(ent) end
  spawned[objectId] = nil
  spawnedFrozen[objectId] = nil
  spawnedModel[objectId] = nil
  spawnedMetadata[objectId] = nil
end)

exports('yg_getSpawnedObjects', function()
  return spawned
end)

-- ✅ EKLENDİ: buildmode.lua'nın silme/undo akışında bir entity'nin GERÇEK
-- model adını (hash değil) bulabilmesi için — undo/redo snapshot'ı bu
-- olmadan modeli yeniden yaratamıyordu (GetEntityModel sadece hash döner,
-- hash'ten model adına geri dönüş mümkün değil).
exports('yg_getSpawnedObjectModel', function(id)
  return spawnedModel[id]
end)

-- ============================================================
--  DONMA NÖBETÇİSİ (freeze watchdog) — GTA'nın bilinen bir fizik motoru
--  tuhaflığına karşı: FreezeEntityPosition ile dondurulmuş bir obje,
--  oyuncu/araç çarpışması (collision/itme) alınca bazen "uyanıp" donmayı
--  kaybedip yer çekimine maruz kalıyor (haritadan aşağı düşüyor). Düşük
--  frekansta (1 saniyede bir) "frozen kalması gereken" objeleri kontrol
--  edip, eğer biri donmaktan çıkmışsa sessizce yeniden dondurur VE
--  collision'ı tekrar kapatır — oyuncu hiç fark etmeden, obje hep
--  yerinde duruyormuş gibi görünür.
-- ============================================================
CreateThread(function()
    while true do
        Wait(1000)
        if LocalPlayer.state.ygPropertyId ~= nil then
            for id, ent in pairs(spawned) do
                if spawnedFrozen[id] and DoesEntityExist(ent) then
                    local stillFrozen = true
                    if IsEntityPositionFrozen then
                        stillFrozen = IsEntityPositionFrozen(ent) == true or IsEntityPositionFrozen(ent) == 1
                    end
                    if not stillFrozen then
                        FreezeEntityPosition(ent, true)
                        SetEntityCollision(ent, true, true)
                    end
                end
            end
        end
    end
end)