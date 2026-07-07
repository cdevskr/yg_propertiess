--[[
  yg_properties — GİZMO (object_gizmo'dan AYNI MEKANİZMAYLA port edildi)
  ============================================================
  Kaynak: github.com/DemiAutomatic/object_gizmo (GPL-3.0)

  ÖNEMLİ DÜZELTME (önceki sürümde EKSİKTİ): native `DrawGizmo` widget'ı
  mod değişimini (Taşı/Döndür/Relative-World) ve mouse ile seçim/sürüklemeyi
  Lua DEĞİŞKENİYLE değil, ÖZEL, REZERVE EDİLMİŞ ham komutlarla (+gizmoSelect,
  +gizmoTranslation, +gizmoRotation, +gizmoLocal) öğreniyor. Bu komutları BİZ
  KAYDETMİYORUZ (RegisterCommand yok) — bunlar CitizenFX runtime'ının
  DrawGizmo native'ine GÖMÜLÜ, dinlenen isimler. Önceki sürümde bunları
  "ölü kod" sanıp atmıştım; o yüzden native hiç mod değiştirmiyor, sürükleme
  hiç başlamıyordu. Şimdi orijinaldeki gibi `lib.addKeybind` + ExecuteCommand
  ile bu komutları press/release olarak tetikliyoruz — native bunları kendi
  içinde yakalayıp gerçek davranışı uyguluyor.

    - EnterCursorMode() / LeaveCursorMode() — native cursor (NUI değil)
    - Citizen.InvokeNative(0xEB2EDCA2, ...) — gerçek `DrawGizmo` native'i
    - client/dataview.lua — entity transform matrisini ham buffer'a paketler

  Credits (object_gizmo README'sinden):
    Andyyy7666: https://github.com/overextended/ox_lib/pull/453
    AvarianKnight: https://forum.cfx.re/t/allow-drawgizmo-to-be-used-outside-of-fxdk/5091845/8

  KASITLI FARKLAR (object_gizmo'nun orijinalinde YOK, ben ekledim):
    1) [Esc] ile İPTAL — orijinalde sadece [Enter] var. Bizim builder.lua/
       edit.lua zaten "iptal edilirse objeyi sil" akışına göre yazılmıştı.
       Esc, native'e ExecuteCommand ile haber VERMİYOR (buna gerek yok,
       sadece bizim Lua döngümüzü sonlandırıp entity'yi eski haline getiriyor).
    2] lib.locale() + locales/*.json kullanmadım, mesajları Türkçe yazdım.
    3] Dışa export değil, global fonksiyon (YgOpenGizmo).
    4) [F] EN YAKIN OBJEYE BİTİŞTİR — orijinalde yok, duvar/zemin dizme
       işini kolaylaştırmak için eklendi. Mantık: mekandaki TÜM yerleştirilmiş
       objeler arasından (kendisi hariç) en yakınını bulur, GERÇEK model
       genişliğini (GetModelDimensions) hesaplar, düzenlenen objenin o
       objeye göre HANGİ TARAFTA olduğunu (sağ vektör + dot product) tespit
       edip TAM O TARAFA, aynı rotasyonla yapıştırır. Hem yeni yerleştirmede
       hem mevcut obje düzenlemede çalışır, hem katalogdan hem custom model
       koduyla gelen objelerde — çünkü artık NUI butonuna değil, doğrudan
       gizmo'nun kendisine bağlı.
]]

local dataview = require 'client.dataview'

local gizmoEnabled = false
local currentMode = 'Translate'
local isRelative = false
local currentEntity = nil
local isCursorActive = false
local GizmoCommitted = false

-- ============================================================
--  EN YAKIN OBJEYE BİTİŞTİR — yardımcı fonksiyonlar
-- ============================================================
local function getModelWidth(hash)
    local min, max = GetModelDimensions(hash)
    if not min or not max then return 1.0 end
    local w = max.x - min.x
    if w <= 0 then return 1.0 end
    return w
end

-- vektörü SADECE Z (yaw) ekseninde döndürür
local function rotateVectorByZ(vx, vy, degrees)
    local rad = math.rad(degrees)
    local c, s = math.cos(rad), math.sin(rad)
    return vx * c - vy * s, vx * s + vy * c
end

-- mekandaki tüm yerleştirilmiş objeler arasından (kendisi hariç) en yakınını bulur
local function findNearestObject(entity, myCoords)
    local ok, spawned = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    if not ok or not spawned then return nil end

    local nearest, nearestDist = nil, nil
    for _, ent in pairs(spawned) do
        if ent ~= entity and DoesEntityExist(ent) then
            local c = GetEntityCoords(ent)
            local d = #(vector3(myCoords.x, myCoords.y, myCoords.z) - c)
            if not nearestDist or d < nearestDist then
                nearest, nearestDist = ent, d
            end
        end
    end
    return nearest, nearestDist
end

-- direction: 'right' | 'left' | 'up' | 'down'
--   right/left  → en yakın objenin sağına/soluna (kendi yaw'ına göre)
--   up          → en yakın objenin tam üstüne (Z ekseni, biri diğerinin üstüne)
--   down        → en yakın objenin tam altına (Z ekseni)
local function snapToNearest(entity, direction)
    local myCoords = GetEntityCoords(entity)
    local nearest = findNearestObject(entity, myCoords)
    if not nearest then
        lib.notify({ type = 'error', description = 'Bitiştirilecek başka obje bulunamadı.' })
        return
    end

    local nCoords = GetEntityCoords(nearest)
    local nRot    = GetEntityRotation(nearest, 2)
    local nModel  = GetEntityModel(nearest)
    local nMin, nMax = GetModelDimensions(nModel)
    local myModel = GetEntityModel(entity)
    local mMin, mMax = GetModelDimensions(myModel)

    local nW = (nMax and mMin) and (nMax.x - nMin.x) or 1.0  -- en yakın objenin genişliği
    local mW = (mMax and mMin) and (mMax.x - mMin.x) or 1.0  -- düzenlenen objenin genişliği
    local nH = (nMax and nMin) and (nMax.z - nMin.z) or 1.0  -- en yakın objenin yüksekliği
    local mH = (mMax and mMin) and (mMax.z - mMin.z) or 1.0  -- düzenlenen objenin yüksekliği

    -- en yakın objenin sağ vektörü (kendi yaw'ına göre)
    local rightX, rightY = rotateVectorByZ(1.0, 0.0, nRot.z)

    local nx, ny, nz, label

    if direction == 'right' then
        -- sağa: en yakın objenin merkezi + (ikisinin genişliğinin ortalaması) * sağ vektör
        local offset = (nW + mW) * 0.5
        nx, ny, nz = nCoords.x + rightX * offset, nCoords.y + rightY * offset, nCoords.z
        label = 'Sağa bitiştirildi.'
    elseif direction == 'left' then
        local offset = (nW + mW) * 0.5
        nx, ny, nz = nCoords.x - rightX * offset, nCoords.y - rightY * offset, nCoords.z
        label = 'Sola bitiştirildi.'
    elseif direction == 'up' then
        -- üste: aynı X/Y, Z = en yakın objenin tabanı + en yakın objenin yüksekliği + düzenlenen objenin yüksekliğinin yarısı
        nx, ny = nCoords.x, nCoords.y
        nz = nCoords.z + (nH * 0.5) + (mH * 0.5)
        label = 'Üste bitiştirildi.'
    elseif direction == 'down' then
        nx, ny = nCoords.x, nCoords.y
        nz = nCoords.z - (nH * 0.5) - (mH * 0.5)
        label = 'Alta bitiştirildi.'
    else -- 'nearest' — eski [F] davranışı: hangi tarafta olduğunu otomatik tespit et
        local toMineX, toMineY = myCoords.x - nCoords.x, myCoords.y - nCoords.y
        local side = (toMineX * rightX + toMineY * rightY) >= 0 and 1.0 or -1.0
        local offset = (nW + mW) * 0.5
        nx, ny, nz = nCoords.x + rightX * offset * side, nCoords.y + rightY * offset * side, nCoords.z
        label = side > 0 and 'Sağa bitiştirildi.' or 'Sola bitiştirildi.'
    end

    SetEntityCoords(entity, nx, ny, nz, false, false, false, false)
    SetEntityRotation(entity, nRot.x, nRot.y, nRot.z, 2, true)
    lib.notify({ type = 'success', description = label })
end

-- ============================================================
--  MATRİS PAKETLEME (object_gizmo'dan birebir — byte offsetlerine
--  DOKUNULMADI, DrawGizmo native'inin beklediği format bu)
-- ============================================================
local function normalize(x, y, z)
    local length = math.sqrt(x * x + y * y + z * z)
    if length == 0 then
        return 0, 0, 0
    end
    return x / length, y / length, z / length
end

local function makeEntityMatrix(entity)
    local f, r, u, a = GetEntityMatrix(entity)
    local view = dataview.ArrayBuffer(60)

    view:SetFloat32(0, r[1])
        :SetFloat32(4, r[2])
        :SetFloat32(8, r[3])
        :SetFloat32(12, 0)
        :SetFloat32(16, f[1])
        :SetFloat32(20, f[2])
        :SetFloat32(24, f[3])
        :SetFloat32(28, 0)
        :SetFloat32(32, u[1])
        :SetFloat32(36, u[2])
        :SetFloat32(40, u[3])
        :SetFloat32(44, 0)
        :SetFloat32(48, a[1])
        :SetFloat32(52, a[2])
        :SetFloat32(56, a[3])
        :SetFloat32(60, 1)

    return view
end

local function applyEntityMatrix(entity, view)
    local x1, y1, z1 = view:GetFloat32(16), view:GetFloat32(20), view:GetFloat32(24)
    local x2, y2, z2 = view:GetFloat32(0), view:GetFloat32(4), view:GetFloat32(8)
    local x3, y3, z3 = view:GetFloat32(32), view:GetFloat32(36), view:GetFloat32(40)
    local tx, ty, tz = view:GetFloat32(48), view:GetFloat32(52), view:GetFloat32(56)

    x1, y1, z1 = normalize(x1, y1, z1)
    x2, y2, z2 = normalize(x2, y2, z2)
    x3, y3, z3 = normalize(x3, y3, z3)

    SetEntityMatrix(entity,
        x1, y1, z1,
        x2, y2, z2,
        x3, y3, z3,
        tx, ty, tz
    )
end

-- ============================================================
--  EKRAN YAZISI
-- ============================================================
local function getVectorText(entity, isCoords)
    local label = isCoords and 'Konum' or 'Rotasyon'
    local vec = isCoords and GetEntityCoords(entity) or GetEntityRotation(entity, 2)
    return ('%s: %.2f, %.2f, %.2f'):format(label, vec.x, vec.y, vec.z)
end

local function textUILoop(entity)
    CreateThread(function()
        while gizmoEnabled do
            Wait(100)
            if not DoesEntityExist(entity) then break end

            local modeLine = ('Mod: %s | %s  \n'):format(currentMode, isRelative and 'Relative' or 'World')

            lib.showTextUI(
                modeLine ..
                getVectorText(entity, true) .. '  \n' ..
                getVectorText(entity, false) .. '  \n' ..
                '[Fare]  - Tut ve Sürükle  \n' ..
                '[W]     - Tasi Modu  \n' ..
                '[R]     - Dondur Modu  \n' ..
                '[Q]     - Relative/World  \n' ..
                '[LALT]  - Yere Yapistir  \n' ..
                '[F]     - En Yakin Objeye Bitistir (otomatik)  \n' ..
                '[→←]    - Sag / Sol bitistir  \n' ..
                '[↑↓]    - Ust / Alt bitistir  \n' ..
                '[H]     - Yatay Yasla  \n' ..
                '[Enter] - Bitir  \n' ..
                '[Esc]   - Iptal'
            )
        end
        lib.hideTextUI()
    end)
end

-- ============================================================
--  GİZMO KONTROLLERİ — orijinalin AYNI mekanizması: lib.addKeybind ile
--  press/release yakalanır, ExecuteCommand('+gizmoX'/'-gizmoX') ile
--  native DrawGizmo'ya iletilir. Bu komutları BİZ kaydetmiyoruz —
--  CitizenFX runtime'ı bunları DrawGizmo context'i için zaten dinliyor.
--  Keybind'lar SADECE BİR KEZ (script başlarken) kaydedilir; içeride
--  `gizmoEnabled` kontrolü ile sadece gizmo açıkken etkili olurlar —
--  orijinaldeki tasarım da bu (modül-seviyesi state).
-- ============================================================
lib.addKeybind({
    name = 'yg_gizmoSelect',
    description = 'Gizmo: Seç/Sürükle',
    defaultMapper = 'MOUSE_BUTTON',
    defaultKey = 'MOUSE_LEFT',
    onPressed = function()
        if not gizmoEnabled then return end
        ExecuteCommand('+gizmoSelect')
    end,
    onReleased = function()
        ExecuteCommand('-gizmoSelect')
    end
})

lib.addKeybind({
    name = 'yg_gizmoTranslation',
    description = 'Gizmo: Taşı Modu',
    defaultKey = 'W',
    onPressed = function()
        if not gizmoEnabled then return end
        currentMode = 'Translate'
        ExecuteCommand('+gizmoTranslation')
    end,
    onReleased = function()
        ExecuteCommand('-gizmoTranslation')
    end
})

lib.addKeybind({
    name = 'yg_gizmoRotation',
    description = 'Gizmo: Döndür Modu',
    defaultKey = 'R',
    onPressed = function()
        if not gizmoEnabled then return end
        currentMode = 'Rotate'
        ExecuteCommand('+gizmoRotation')
    end,
    onReleased = function()
        ExecuteCommand('-gizmoRotation')
    end
})

lib.addKeybind({
    name = 'yg_gizmoLocal',
    description = 'Gizmo: Relative/World',
    defaultKey = 'Q',
    onPressed = function()
        if not gizmoEnabled then return end
        isRelative = not isRelative
        ExecuteCommand('+gizmoLocal')
    end,
    onReleased = function()
        ExecuteCommand('-gizmoLocal')
    end
})

lib.addKeybind({
    name = 'yg_gizmoSnapToGround',
    description = 'Gizmo: Yere Yapıştır',
    defaultKey = 'LMENU',
    onPressed = function()
        if not gizmoEnabled or not currentEntity then return end
        PlaceObjectOnGroundProperly_2(currentEntity)
    end,
})

-- ✅ KESİN DÜZELTME: [H] artık manuel IsControlJustPressed(0,74) yerine
-- lib.addKeybind ile bağlı — TAM OLARAK W/R/Q/Enter/LAlt'ın (hepsi zaten
-- çalışıyor) kullandığı AYNI kanıtlanmış mekanizma (ox_lib'in kendi
-- RegisterKeyMapping tabanlı sistemi). Önceki iki denemem (disabled-check
-- ve sonra plain-check ile kontrol 74'ü manuel okumak) ikisi de kontrol
-- 74'ün (INPUT_VEH_HEADLIGHT, araç-bağlamlı) ayaktayken güvenilir bir
-- input event ÜRETMEDİĞİ ihtimalini hesaba katmamıştı — artık hangi
-- native kontrol ID'sinin arkasında olduğu HİÇ önemli değil, ox_lib
-- kendi bağımsız key-mapping sistemini kullanıyor.
-- ✅ MANTIK DÜZELTİLDİ: Eskiden pitch/roll'u SIFIRLIYORDUM — ama bazı
-- modellerin (örn. bu bariyer tabelası) DOĞAL duruşu rotasyon (0,0,0)
-- iken zaten DİKEY'dir (Rockstar öyle modellemiş). Sıfırlamak o zaman
-- hiçbir şeyi değiştirmiyordu — "çalışmıyor" şikayeti buradan geliyordu,
-- tuş algısı sorunu değildi (nitekim ekran görüntüsünde "Rotasyon:
-- 0.00, 0.00, 0.00" yazıyordu — kod ÇALIŞMIŞTI, sadece o model için
-- 0,0,0 zaten "ayakta" duruş demekmiş).
--
-- Her modelin "düz" açısı farklı olduğu için TEK bir hedef açı (0 gibi)
-- hiçbir zaman HER model için doğru olamaz. Onun yerine artık [H]'ye
-- her basışta objeyi PITCH ekseninde 90° DEVİRİYORUZ — 4 basışta
-- (0°→90°→180°→270°→0°) objenin 4 olası "yan yatış" hâlini sırayla
-- gezip, gözünle doğru duran açıda durabiliyorsun.
local flattenStep = 0
lib.addKeybind({
    name = 'yg_gizmoFlatten',
    description = 'Gizmo: Yatay Yasla (devir)',
    defaultKey = 'H',
    onPressed = function()
        if not gizmoEnabled or not currentEntity then return end
        flattenStep = (flattenStep + 1) % 4
        local r = GetEntityRotation(currentEntity, 2)
        SetEntityRotation(currentEntity, flattenStep * 90.0, 0.0, r.z, 2, true)
        lib.notify({ type = 'success', description = ('Devrildi (%d°).'):format(flattenStep * 90) })
    end,
})

lib.addKeybind({
    name = 'yg_gizmoClose',
    description = 'Gizmo: Bitir',
    defaultKey = 'RETURN',
    onReleased = function()
        if not gizmoEnabled then return end
        gizmoEnabled = false
        GizmoCommitted = true
    end,
})

lib.addKeybind({
    name = 'yg_gizmoCancel',
    description = 'Gizmo: İptal (kasıtlı ekleme)',
    defaultKey = 'BACK',
    onReleased = function()
        if not gizmoEnabled then return end
        gizmoEnabled = false
        GizmoCommitted = false
    end,
})

-- ✅ EKLENDİ: [Esc] de iptal ediyor. Önceden SADECE [Backspace] (BACK)
-- bağlıydı — 'ESC' diye bir anahtar YOK, doğrusu 'ESCAPE' (resmi FiveM
-- input-mapper listesinden doğrulandı). Bu eksikti, o yüzden Esc'e
-- basınca hiçbir şey olmuyordu.
lib.addKeybind({
    name = 'yg_gizmoCancelEsc',
    description = 'Gizmo: İptal (Esc)',
    defaultKey = 'ESCAPE',
    onReleased = function()
        if not gizmoEnabled then return end
        gizmoEnabled = false
        GizmoCommitted = false
    end,
})

-- ============================================================
--  ANA GİZMO DÖNGÜSÜ (object_gizmo'nun gizmoLoop'uyla AYNI çekirdek)
-- ============================================================
local function gizmoLoop(entity, outlineColor)
    EnterCursorMode()
    isCursorActive = true

    if IsEntityAPed(entity) then
        SetEntityAlpha(entity, 200)
    else
        if outlineColor then
            SetEntityDrawOutlineColor(outlineColor[1], outlineColor[2], outlineColor[3], outlineColor[4] or 255)
        end
        SetEntityDrawOutline(entity, true)
    end

    GizmoCommitted = false

    while gizmoEnabled and DoesEntityExist(entity) do
        Wait(0)

        -- G veya SAĞ TIK: cursor/kamera modu arasında geçiş.
        -- ✅ KÖK SEBEP BULUNDU: 25 ve 238 numaralı kontroller aşağıda
        -- DisableControlAction ile KAPATILIYOR — disable edilmiş bir
        -- kontrolü normal IsControlJustPressed ile okumak GÜVENİLİR
        -- DEĞİL (resmi best-practice: disable edilen kontroller için
        -- IsDisabledControlJustPressed kullanılmalı). G (47) hiç disable
        -- edilmediği için normal okuma ile zaten çalışıyordu, sağ tık
        -- (25/238) disable edildiği için hiç tetiklenmiyordu.
        if IsControlJustPressed(0, 47)
            or IsDisabledControlJustPressed(0, 25)
            or IsDisabledControlJustPressed(0, 238) then -- G / sağ tık (her iki mod)
            if isCursorActive then
                LeaveCursorMode()
                isCursorActive = false
            else
                EnterCursorMode()
                isCursorActive = true
            end
        end

        -- [F] EN YAKIN OBJEYE BİTİŞTİR (hangi tarafta olduğunu otomatik tespit et)
        if IsDisabledControlJustPressed(0, 49) then
            snapToNearest(entity, 'nearest')
        end

        -- YÖN TUŞLARI: tam bitişik konumu seç
        if IsDisabledControlJustPressed(0, 175) then snapToNearest(entity, 'right') end  -- → Sağ ok
        if IsDisabledControlJustPressed(0, 174) then snapToNearest(entity, 'left')  end  -- ← Sol ok
        if IsDisabledControlJustPressed(0, 172) then snapToNearest(entity, 'up')    end  -- ↑ Yukarı ok
        if IsDisabledControlJustPressed(0, 173) then snapToNearest(entity, 'down')  end  -- ↓ Aşağı ok

        -- [H] YATAY YASLA artık burada DEĞİL — yukarıda lib.addKeybind
        -- ile bağlı (bkz. yg_gizmoFlatten), W/R/Q/Enter/LAlt ile aynı
        -- kanıtlanmış mekanizma.

        DisableControlAction(0, 24, true)  -- lmb
        DisableControlAction(0, 25, true)  -- rmb (normal kamera modu)
        DisableControlAction(0, 238, true) -- rmb (cursor modu - INPUT_CURSOR_CANCEL)
        DisableControlAction(0, 140, true) -- r
        DisableControlAction(0, 49, true)  -- f (varsayılan tutuklama davranışını bastır)
        DisableControlAction(0, 172, true) -- ↑ ok
        DisableControlAction(0, 173, true) -- ↓ ok
        DisableControlAction(0, 174, true) -- ← ok
        DisableControlAction(0, 175, true) -- → ok
        DisablePlayerFiring(cache.playerId, true)

        local matrixBuffer = makeEntityMatrix(entity)
        local changed = Citizen.InvokeNative(0xEB2EDCA2, matrixBuffer:Buffer(), 'Editor1',
            Citizen.ReturnResultAnyway())

        if changed then
            applyEntityMatrix(entity, matrixBuffer)
        end
    end

    if isCursorActive then
        LeaveCursorMode()
    end
    isCursorActive = false

    if DoesEntityExist(entity) then
        if IsEntityAPed(entity) then SetEntityAlpha(entity, 255) end
        SetEntityDrawOutline(entity, false)
    end
    if outlineColor then
        SetEntityDrawOutlineColor(255, 255, 255, 255) -- varsayılana döndür, sonraki objelere sızmasın
    end

    gizmoEnabled = false
    currentEntity = nil

    return GizmoCommitted == true
end

--- object_gizmo'nun useGizmo'suyla AYNI çekirdek mekanizma, builder.lua/
--- edit.lua'nın beklediği gibi bool döner (true=Enter, false=Esc/Backspace).
-- outlineColor: opsiyonel {r,g,b,a} — verilirse gizmo açıkken entity'nin
-- çevresi o renkte vurgulanır (örn. duvar/zemin yerleştirirken pembe).
-- Verilmezse object_gizmo'nun varsayılan rengiyle (turuncu/sarı) devam eder.
function YgOpenGizmo(entity, outlineColor)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end

    local originalCoords = GetEntityCoords(entity)
    local originalRot = GetEntityRotation(entity, 2)

    gizmoEnabled = true
    currentEntity = entity
    currentMode = 'Translate'
    isRelative = false
    flattenStep = 0

    textUILoop(entity)
    local committed = gizmoLoop(entity, outlineColor)

    if not committed then
        SetEntityCoords(entity, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false, false)
        SetEntityRotation(entity, originalRot.x, originalRot.y, originalRot.z, 2, true)
        return false
    end

    return true
end
