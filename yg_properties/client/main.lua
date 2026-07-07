local QBCore = exports['qb-core']:GetCoreObject()

-- ✅ OPTİMİZASYON: Localized functions
local GetGameTimer = GetGameTimer
local GetEntityCoords = GetEntityCoords
local PlayerPedId = PlayerPedId
local SetEntityCoordsNoOffset = SetEntityCoordsNoOffset
local SetEntityHeading = SetEntityHeading
local IsScreenFadedOut = IsScreenFadedOut
local IsScreenFadingOut = IsScreenFadingOut
local DoScreenFadeOut = DoScreenFadeOut
local IsScreenFadedIn = IsScreenFadedIn
local IsScreenFadingIn = IsScreenFadingIn
local DoScreenFadeIn = DoScreenFadeIn
local FreezeEntityPosition = FreezeEntityPosition
local SetPlayerControl = SetPlayerControl
local ClearPedTasksImmediately = ClearPedTasksImmediately
local DrawMarker = DrawMarker
local World3dToScreen2d = World3dToScreen2d
local SetTextScale = SetTextScale
local SetTextFont = SetTextFont
local SetTextProportional = SetTextProportional
local SetTextCentre = SetTextCentre
local SetTextColour = SetTextColour
local SetTextOutline = SetTextOutline
local BeginTextCommandDisplayText = BeginTextCommandDisplayText
local AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
local EndTextCommandDisplayText = EndTextCommandDisplayText
local Wait = Wait
local ipairs = ipairs
local pairs = pairs
local tonumber = tonumber

-- ======================
-- State + cache
-- ======================
LocalPlayer.state.ygPropertyId = nil
LocalPlayer.state.ygCurrentProperty = nil
local CurrentShellObjects = nil
local CurrentShellOffsets = nil
local CurrentShellBase = nil
local CurrentIpls = {} -- şu an yüklü olan IPL'ler (MLO interiorlar için)

-- ✅ OPTİMİZASYON: Cache system
local propertyListCache = nil
local propertyCacheExpire = 0
local cacheTimeout = 30000 -- 30 saniye

local function IsLocked(v)
    return v == true or v == 1 or v == '1'
end

local function GetShellConfig(shellId)
    shellId = tonumber(shellId)
    if not shellId then return nil end
    return Config.PropertyShells and Config.PropertyShells[shellId] or nil
end

local function GetShellData(shellId)
    return Config.NativeShells and Config.NativeShells[tonumber(shellId)]
end


local function SpawnShellForProperty(prop)
    -- ✅ EKLENDİ: ÖNCE DB şablonuna bak (Build Mode'da "shell olarak
    -- kaydet" ile üretilenler) — varsa HER PARÇA kendi göreli konumuna
    -- (dx,dy,dz + kendi rx,ry,rz'siyle) spawn olur, Config.NativeShells'in
    -- "hepsi aynı noktaya üst üste" mantığından FARKLI olarak gerçek bir
    -- ev gibi (duvar burada, kapı orada) doğru dizilir.
    if prop and prop.shell_template_id then
        local tpl = lib.callback.await('yg_properties:server:getShellTemplate', false, prop.shell_template_id)
        if not tpl or not tpl.pieces or #tpl.pieces == 0 then
            print('[yg_properties] shell şablonu bulunamadı/boş: shell_template_id=' .. tostring(prop.shell_template_id))
            return nil, nil, nil
        end

        local base = vector3(1000.0 + (prop.id * 100.0), -1000.0, 1000.0)
        local shellObjects = {}
        for _, piece in ipairs(tpl.pieces) do
            local hash = joaat(piece.model)
            if not IsModelInCdimage(hash) then
                print('[yg_properties] şablon modeli stream edilmemiş: ' .. tostring(piece.model))
            else
                RequestModel(hash)
                local t = GetGameTimer() + 8000
                while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(10) end
                if HasModelLoaded(hash) then
                    local px, py, pz = base.x + (piece.dx or 0.0), base.y + (piece.dy or 0.0), base.z + (piece.dz or 0.0)
                    local ent = CreateObject(hash, px, py, pz, false, false, false)
                    if ent and ent ~= 0 then
                        SetEntityRotation(ent, piece.rx or 0.0, piece.ry or 0.0, piece.rz or 0.0, 2, true)
                        SetEntityAsMissionEntity(ent, true, true)
                        FreezeEntityPosition(ent, true)
                        shellObjects[#shellObjects + 1] = ent
                    end
                end
            end
        end

        if #shellObjects == 0 then
            print('[yg_properties] şablonun hiçbir parçası spawn edilemedi: shell_template_id=' .. tostring(prop.shell_template_id))
            return nil, nil, nil
        end

        -- ⚠️ Şablonlar OTOMATİK üretildiği için kalibre edilmiş bir "exit"
        -- (çıkış) noktası yok — varsayılan olarak oyuncunun build_origin'te
        -- (yani inşaата BAŞLADIĞI noktada) NE zaman yerleştirmeye
        -- başladıysa oraya (base'in tam üstüne, hafif yukarı) ışınlıyoruz.
        local offsets = { exit = { x = 0.0, y = 0.0, z = 1.0, h = 0.0 } }
        return shellObjects, offsets, base
    end

    if not prop or not prop.shell_id then return nil, nil, nil end

    local shellId = tonumber(prop.shell_id)
    local base = vector3(
        1000.0 + (prop.id * 100.0),
        -1000.0,
        1000.0
    )

    local data = GetShellData(shellId)
    if not data then
        print('[yg_properties] shell verisi yok: shellId=' .. tostring(shellId))
        return nil, nil, nil
    end

    if not data.exit or data.exit.x == nil then
        print('[yg_properties] shell HENÜZ KALİBRE EDİLMEMİŞ (exit=nil): shellId=' .. tostring(shellId) ..
              ' model=' .. tostring(data.model) .. ' — /shelltest + /shellexit ile doldur.')
        return nil, nil, nil
    end

    print('[yg_properties] shell spawn start | propertyId=' .. tostring(prop.id) .. ' | shellId=' .. tostring(shellId) .. ' | model=' .. tostring(data.model or (data.models and table.concat(data.models, '+'))))

    -- ✅ EKLENDİ: BİRDEN FAZLA model aynı noktaya birlikte spawn edilebilir
    -- (data.models = {'a','b','c'}) — Blender'da birleştirmeye HİÇ gerek
    -- kalmadan, orijinal ayrı .ydr dosyalarını (dış kabuk + iç kabuk + çim
    -- gibi) "üst üste" koyup TEK bir görsel bütün gibi kullanmak için.
    -- Hepsi aynı base koordinatına spawn oluyor — orijinal MLO paketinde
    -- zaten birbirine göre aynı yerel orijine hizalı şekilde modellenmiş
    -- oldukları için (aynı ymap'te aynı konumda duruyorlardı), üst üste
    -- gelince doğru şekilde hizalanıyorlar.
    local modelList = data.models or { data.model }

    local shellObjects = {}
    for _, modelName in ipairs(modelList) do
        local hash = joaat(modelName)
        if not IsModelInCdimage(hash) then
            print('[yg_properties] shell modeli stream edilmemiş: ' .. modelName)
        else
            RequestModel(hash)
            local t = GetGameTimer() + 8000
            while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(10) end

            if not HasModelLoaded(hash) then
                print('[yg_properties] shell modeli yüklenemedi (timeout): ' .. modelName)
            else
                local ent = CreateObject(hash, base.x, base.y, base.z, false, false, false)
                if ent and ent ~= 0 then
                    SetEntityAsMissionEntity(ent, true, true)
                    FreezeEntityPosition(ent, true)
                    shellObjects[#shellObjects + 1] = ent
                else
                    print('[yg_properties] shell objesi oluşturulamadı: ' .. modelName)
                end
            end
        end
    end

    if #shellObjects == 0 then
        print('[yg_properties] shell hiçbir parçası spawn edilemedi')
        return nil, nil, nil
    end

    local offsets = { exit = data.exit }

    return shellObjects, offsets, base
end

local function DespawnCurrentShell(cb)
    if CurrentShellObjects then
        for _, ent in ipairs(CurrentShellObjects) do
            if DoesEntityExist(ent) then DeleteEntity(ent) end
        end
        CurrentShellObjects = nil
        CurrentShellOffsets = nil
        CurrentShellBase = nil
        if cb then cb() end
    else
        CurrentShellOffsets = nil
        CurrentShellBase = nil
        if cb then cb() end
    end
end

-- ============================================================
--  IPL / MLO INTERIORLAR (GTA'nın kendi mekanları — eclipse, ofis, vb.)
--  Bunlar qb-interior shell değil; native RequestIpl ile yüklenir.
--  Siyah ekran/void sorunu IPL hiç istenmediği için oluyordu — burada
--  IPL'i isteyip aktif olana kadar bekliyoruz, sonra da ışınladığımız
--  noktanın etrafında collision yüklenene kadar bekliyoruz.
-- ============================================================
local function EnsureIplLoaded(iplList, timeoutMs)
    if not iplList or #iplList == 0 then return true end -- her zaman yüklü MLO (IPL gerekmiyor)
    local t = GetGameTimer() + (timeoutMs or 8000)
    for _, ipl in ipairs(iplList) do
        if not IsIplActive(ipl) then RequestIpl(ipl) end
    end
    for _, ipl in ipairs(iplList) do
        while not IsIplActive(ipl) and GetGameTimer() < t do Wait(20) end
        if not IsIplActive(ipl) then
            print('[yg_properties] IPL aktif olmadı: ' .. tostring(ipl))
            return false
        end
    end
    return true
end

local function DespawnCurrentIpls()
    for _, ipl in ipairs(CurrentIpls) do
        if IsIplActive(ipl) then RemoveIpl(ipl) end
    end
    CurrentIpls = {}
end

-- Bazı interiorlar (gece kulübü gibi) RequestIpl ile değil, harita üzerinde
-- KALICI duran bir "interior instance" (CInteriorInst) olarak bulunuyor.
-- Bunlar GetInteriorAtCoordsWithType + LoadInterior + IsInteriorReady ile
-- açılır — RequestIpl'in hiç işe yaramadığı durum budur.
local CurrentInteriorId = nil

local function EnsureInteriorTypeLoaded(typeName, coords, timeoutMs)
    local interiorId = GetInteriorAtCoordsWithType(coords.x, coords.y, coords.z, typeName)
    if not interiorId or interiorId == 0 or not IsValidInterior(interiorId) then
        print('[yg_properties] interior type bulunamadı: ' .. tostring(typeName) .. ' @ ' .. tostring(coords))
        return false
    end

    LoadInterior(interiorId)

    local t = GetGameTimer() + (timeoutMs or 8000)
    while not IsInteriorReady(interiorId) and GetGameTimer() < t do Wait(20) end

    if not IsInteriorReady(interiorId) then
        print('[yg_properties] interior hazır olmadı (timeout): ' .. tostring(typeName))
        return false
    end

    CurrentInteriorId = interiorId
    return true
end

local function DespawnCurrentInteriorType()
    if CurrentInteriorId and IsValidInterior(CurrentInteriorId) then
        RefreshInterior(CurrentInteriorId)
        UnpinInterior(CurrentInteriorId)
    end
    CurrentInteriorId = nil
end

-- ışınlandıktan sonra zemin/koleksiyon (collision) yüklenene kadar bekle.
-- Bu olmadan oyuncu boşlukta (void) kalıp ekran siyah görünüyordu.
local function WaitForCollisionAt(coords, timeoutMs)
    local ped = PlayerPedId()
    local t = GetGameTimer() + (timeoutMs or 6000)
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < t do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(25)
    end
end

local Properties = {}
local CurrentProperty = nil

function GetProperties()
    return Properties
end

function SetCurrentProperty(p)
    CurrentProperty = p
end

function GetCurrentProperty()
    return CurrentProperty
end

-- ✅ OPTİMİZASYON: Cache with expiration
local function GetCachedProperties()
    if propertyListCache and GetGameTimer() < propertyCacheExpire then
        return propertyListCache
    end
    return nil
end

local function SetPropertyCache(data)
    propertyListCache = data
    propertyCacheExpire = GetGameTimer() + cacheTimeout
end

local function RefreshProperties()
    local cached = GetCachedProperties()
    if cached then
        Properties = cached
        return
    end

    local data = lib.callback.await('yg_properties:server:getProperties', false)
    if data then
        Properties = data
        SetPropertyCache(data)
        print('[yg_properties] Mekan verileri serverdan taze olarak çekildi.')
    end
end

print('[yg_properties] client/main.lua LOADED: ' .. GetCurrentResourceName())

-- ======================
-- Helpers
-- ======================
local function MyCitizenId()
    local p = QBCore.Functions.GetPlayerData()
    return p and p.citizenid or nil
end

local function CashFmt(n)
    n = tonumber(n) or 0
    local s = tostring(math.floor(n))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    out = out:gsub("^,", "")
    return out
end

-- ✅ OPTİMİZASYON: Text3D rendering optimize
local function DrawText3DModern(x, y, z, lines, opts)
    opts = opts or {}
    local maxDist = opts.maxDist or 14.0
    local baseScale = opts.scale or 0.40
    local font = opts.font or 0
    local lineGap = opts.lineGap or 0.022

    local cam = GetGameplayCamCoord()
    local dist = #(vec3(cam.x, cam.y, cam.z) - vec3(x, y, z))
    if dist > maxDist then return end

    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    if type(lines) == 'string' then
        lines = { lines }
    end

    local scale = baseScale
    if dist > 2.0 then
        scale = baseScale * (1.0 / (dist * 0.55))
        if scale < 0.24 then scale = 0.24 end
        if scale > baseScale then scale = baseScale end
    end

    for i, line in ipairs(lines) do
        SetTextScale(scale, scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextColour(255, 255, 255, 245)
        SetTextOutline()

        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(line)
        EndTextCommandDisplayText(sx, sy - 0.010 + (i * lineGap))
    end
end

-- ======================
-- Entry FX (fade + freeze while loading objects)
-- ======================
local function freezePlayer(state)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, state)
    SetPlayerControl(PlayerId(), not state, 0)
    if state then
        ClearPedTasksImmediately(ped)
    end
end

local function fadeOut(ms)
    if not IsScreenFadedOut() and not IsScreenFadingOut() then
        DoScreenFadeOut(ms or 250)
    end
end

local function fadeIn(ms)
    if not IsScreenFadedIn() and not IsScreenFadingIn() then
        DoScreenFadeIn(ms or 250)
    end
end

local pendingEnterPropertyId = nil
local unfreezeTimeoutAt = 0
local minUnfreezeAt = 0     -- en az bu ana kadar bekle (5 saniyelik taban)
local objectsReadyFlag = false

-- ✅ YENİ: mekana her girişte EN AZ 5 saniye siyah ekranda (fade-out +
-- donmuş oyuncu) kalıyoruz — objeler daha hızlı yüklense bile taban süre
-- bu. 5 saniye dolduktan sonra objeler HÂLÂ yüklenmediyse, ekranın TAM
-- ORTASINDA "Yükleniyor..." yazısı belirip objeler bitene kadar bekliyor
-- (10 saniyelik genel timeout hâlâ var, sonsuza kadar takılı kalınmıyor).
local function beginEnterEffects(propertyId)
    pendingEnterPropertyId = tonumber(propertyId)
    objectsReadyFlag = false
    minUnfreezeAt = GetGameTimer() + 5000
    unfreezeTimeoutAt = GetGameTimer() + 15000 -- genel güvenlik timeout'u (5sn taban + 10sn ekstra pay)
    fadeOut(250)
    freezePlayer(true)
    -- ✅ BUG DÜZELTİLDİ: "Yükleniyor..." artık NATIVE 2D metin yerine NUI
    -- katmanında gösteriliyor. Sebep: DoScreenFadeOut'un siyah ekranı,
    -- native metin çizimlerinin ÜSTÜNE render olabiliyor (bu yüzden yazı
    -- hiç görünmüyordu) — NUI (CEF tarayıcı katmanı) ise her zaman
    -- fade'in ÜSTÜNDE duruyor, garantili görünür.
    SendNUIMessage({ action = 'showLoading' })
end

-- Objeler yüklendi sinyali — HEMEN serbest bırakmıyor, sadece "hazır"
-- işaretliyor. Gerçek serbest bırakma aşağıdaki watcher thread'de,
-- 5 saniyelik taban süre dolunca oluyor.
local function endEnterEffects(propertyId)
    propertyId = tonumber(propertyId)
    if pendingEnterPropertyId and propertyId == pendingEnterPropertyId then
        objectsReadyFlag = true
    end
end

-- Teleport/shell/IPL BAŞARISIZ olduğunda kullanılır — hiçbir şey
-- yüklenmiyor demektir, 5 saniyelik bekleme mantıksız olurdu, o yüzden
-- ANINDA serbest bırakıyor.
local function abortEnterEffects(propertyId)
    propertyId = tonumber(propertyId)
    if pendingEnterPropertyId and propertyId == pendingEnterPropertyId then
        pendingEnterPropertyId = nil
        unfreezeTimeoutAt = 0
        minUnfreezeAt = 0
        objectsReadyFlag = false
        freezePlayer(false)
        fadeIn(250)
        SendNUIMessage({ action = 'hideLoading' })
    end
end

AddEventHandler('yg_properties:client:objectsLoaded', function(propertyId, count)
    endEnterEffects(propertyId)
end)

-- ======================
-- Hava Durumu (SADECE bu mekana giren client'ı etkiler)
-- ======================
-- SetOverrideWeather/ClearOverrideWeather TAMAMEN client-taraflı native'ler
-- — biz bunu sadece "şu an bu mekana girmiş olan" oyuncunun kendi
-- client'ında çağırıyoruz, başka hiç kimseye TriggerClientEvent atmıyoruz.
-- Bu yüzden "sadece o bucket'ın hava durumu" isteği zaten doğal olarak
-- sağlanıyor — diğer oyuncular (başka bucket'larda, dışarıda) bundan
-- hiç etkilenmiyor.
local weatherWatchActive = false

local function ApplyPropertyWeather(prop)
    if not prop or not prop.weather or prop.weather == '' then return end
    SetOverrideWeather(prop.weather)
    if weatherWatchActive then return end
    weatherWatchActive = true
    CreateThread(function()
        while LocalPlayer.state.ygPropertyId ~= nil do
            local cur = GetCurrentProperty()
            if cur and cur.weather and cur.weather ~= '' then
                SetOverrideWeather(cur.weather) -- ✅ periyodik tekrar: dış bir hava senkron script'i üzerine yazsa bile geri kazanır
            end
            Wait(1000)
        end
        weatherWatchActive = false
    end)
end

local function ClearPropertyWeather()
    ClearOverrideWeather()
end

-- ======================
-- Karartma / Blackout (SADECE bu mekana giren client'ı etkiler)
-- ======================
-- SetArtificialLightsState — qb-weathersync'in kendi "/blackout"
-- komutunun kullandığı AYNI native, tamamen client-taraflı. Dürüst
-- olmak gerekirse: tek tek lamba objelerini "kapatmıyoruz" (statik
-- modeller, açık/kapalı model çifti eşleştirmemiz yok) — bunun yerine
-- TÜM sahneyi "sanki gece/güç kesintisi" gibi karartan, topluluğun
-- blackout için standart kullandığı native'i uyguluyoruz.
local blackoutActive = false
local blackoutWatchActive = false
local function ApplyPropertyBlackout(prop)
    local wants = prop and prop.blackout == true
    blackoutActive = wants
    SetArtificialLightsState(wants)
    if blackoutWatchActive then return end
    blackoutWatchActive = true
    CreateThread(function()
        while LocalPlayer.state.ygPropertyId ~= nil do
            local cur = GetCurrentProperty()
            local curWants = cur and cur.blackout == true
            -- ✅ EKLENDİ: hava durumu ile AYNI desen — sürekli yeniden
            -- uyguluyoruz, tek seferlik çağrı bazen "geri dönme" gibi
            -- görünen davranışa sebep olabiliyordu.
            SetArtificialLightsState(curWants)
            blackoutActive = curWants
            Wait(1000)
        end
        blackoutWatchActive = false
    end)
end

local function ClearPropertyBlackout()
    blackoutActive = false
    SetArtificialLightsState(false)
end

-- ======================
-- Saat (SADECE bu mekana giren client'ı etkiler)
-- ======================
-- NetworkOverrideClockTime — client-taraflı, hava durumu/karartma ile
-- AYNI mantık. PauseClock(true) ile saati o noktada DONDURUYORUZ, yoksa
-- oyunun kendi 48-dakikalık gün döngüsü normal akıp seçtiğin saatten
-- hemen uzaklaşırdı.
local timeActive = false
local timeWatchActive = false
local function ApplyPropertyTime(prop)
    local t = prop and prop.time_of_day
    if not t or t == '' then return end
    local h, m = t:match('^(%d%d?):(%d%d)$')
    h, m = tonumber(h), tonumber(m)
    if not h or not m then return end
    NetworkOverrideClockTime(h, m, 0)
    PauseClock(true)
    timeActive = true

    if timeWatchActive then return end
    timeWatchActive = true
    CreateThread(function()
        while LocalPlayer.state.ygPropertyId ~= nil do
            local cur = GetCurrentProperty()
            local ct = cur and cur.time_of_day
            if ct and ct ~= '' then
                local ch, cm = ct:match('^(%d%d?):(%d%d)$')
                ch, cm = tonumber(ch), tonumber(cm)
                if ch and cm then
                    -- ✅ EKLENDİ: hava durumu ile AYNI desen — sürekli
                    -- yeniden uyguluyoruz (PauseClock tek başına yeterli
                    -- olmayabiliyor, saat "geri dönme" şikayeti buradan
                    -- geliyordu).
                    NetworkOverrideClockTime(ch, cm, 0)
                    PauseClock(true)
                end
            end
            Wait(1000)
        end
        timeWatchActive = false
    end)
end

local function ClearPropertyTime()
    timeActive = false
    PauseClock(false)
end

CreateThread(function()
    while true do
        if pendingEnterPropertyId then
            local now = GetGameTimer()
            local minReached = now >= minUnfreezeAt
            local timedOut = unfreezeTimeoutAt > 0 and now > unfreezeTimeoutAt
            if (minReached and objectsReadyFlag) or timedOut then
                pendingEnterPropertyId = nil
                unfreezeTimeoutAt = 0
                minUnfreezeAt = 0
                objectsReadyFlag = false
                freezePlayer(false)
                fadeIn(250)
                SendNUIMessage({ action = 'hideLoading' })
            end
        end
        Wait(200)
    end
end)

-- ======================
-- Objects glue (builder)
-- ======================
local function LoadObjectsForCurrent()
    local propertyId = LocalPlayer.state.ygPropertyId
    if not propertyId then return end
    TriggerEvent('yg_properties:client:loadObjects', propertyId)
end

local function ClearObjectsAndBuilder()
    TriggerEvent('yg_properties:client:clearObjects')
    TriggerEvent('yg_properties:client:closeBuildEditor')
end

-- ======================
-- TARGET BRIDGE (ox_target / qb-target) — hangisi açıksa onu kullanır
-- ======================
local Bridge = { target = nil }

CreateThread(function()
    local tries = 0
    while Bridge.target == nil and tries < 75 do
        if GetResourceState('ox_target') == 'started' then
            Bridge.target = 'ox'
        elseif GetResourceState('qb-target') == 'started' then
            Bridge.target = 'qb'
        end
        if Bridge.target then
            print('[yg_properties] target sistemi: ' .. Bridge.target)
            break
        end
        tries = tries + 1
        Wait(200)
    end
    if not Bridge.target then
        print('[yg_properties] UYARI: ox_target/qb-target bulunamadi, target zonelar calismaz!')
    end
end)

-- options: { {label, icon, distance, onSelect = function() end}, ... }
-- name: qb-target'ta zone adı olarak kullanılır (silmek için gerekli)
local function BridgeAddSphereZone(name, coords, radius, options)
    if Bridge.target == 'ox' then
        local oxOptions = {}
        for _, o in ipairs(options) do
            oxOptions[#oxOptions + 1] = {
                label = o.label, icon = o.icon, distance = o.distance or 2.0,
                onSelect = o.onSelect,
            }
        end
        return exports.ox_target:addSphereZone({ coords = coords, radius = radius, options = oxOptions })
    elseif Bridge.target == 'qb' then
        local qbOptions = {}
        for _, o in ipairs(options) do
            qbOptions[#qbOptions + 1] = {
                icon = o.icon or 'fas fa-hand-pointer', label = o.label,
                action = function() o.onSelect() end,
            }
        end
        exports['qb-target']:AddCircleZone(name, coords, radius, { name = name, useZ = true, debugPoly = false }, {
            options = qbOptions, distance = (options[1] and options[1].distance) or 2.0,
        })
        return name
    end
    return nil
end

local function BridgeRemoveZone(handle)
    if not handle then return end
    if Bridge.target == 'ox' then
        pcall(function() exports.ox_target:removeZone(handle) end)
    elseif Bridge.target == 'qb' then
        pcall(function() exports['qb-target']:RemoveZone(handle) end)
    end
end

-- ======================
-- Door target + marker (DIŞARISI)
-- ======================
local createdTargets = {}
local doorMarkers = {}
local lastDoorRebuild = 0

local function clearDoorTargets()
    for _, t in ipairs(createdTargets) do
        BridgeRemoveZone(t)
    end
    createdTargets = {}
    doorMarkers = {}
end

local function makeDoorOptions(prop)
    local opts = {
        {
            icon = 'fa-solid fa-door-open',
            label = 'İçeri Gir',
            onSelect = function()
                TriggerEvent('yg_properties:client:enter', prop.id)
            end
        },
        {
            icon = 'fa-solid fa-circle-info',
            label = 'Mekan Bilgisi',
            onSelect = function()
                TriggerEvent('yg_properties:client:showInfo', prop.id)
            end
        }
    }

    if not prop.owner_citizenid or prop.owner_citizenid == '' then
        opts[#opts + 1] = {
            icon = 'fa-solid fa-cart-shopping',
            label = 'Satın Al',
            onSelect = function()
                TriggerEvent('yg_properties:client:buy', prop.id)
            end
        }
    end

    return opts
end

-- ✅ OPTİMİZASYON: Debounced rebuild
local function RebuildDoorTargets()
    clearDoorTargets()

    if not Properties or #Properties == 0 then return end

    for _, prop in ipairs(Properties) do
        if prop.door_coords and prop.door_coords ~= '' then
            local door = Shared.DecodeVec4(prop.door_coords)

            doorMarkers[prop.id] = {
                id = prop.id,
                x = door.x,
                y = door.y,
                z = door.z,
                type = prop.type,
                locked = IsLocked(prop.locked),
                owner = prop.owner_citizenid,
                label = prop.label or 'Mekan',
                price = tonumber(prop.price) or 0,
                entry_fee = tonumber(prop.entry_fee) or 0
            }

            local zoneId = BridgeAddSphereZone(
                ('yg_door_%s'):format(prop.id),
                vec3(door.x, door.y, door.z),
                1.6,
                makeDoorOptions(prop)
            )

            table.insert(createdTargets, zoneId)
        end
    end
    lastDoorRebuild = GetGameTimer()
end

RegisterNetEvent('yg_properties:client:refresh', function()
    local data = lib.callback.await('yg_properties:server:getProperties', false)
    if data then
        Properties = data
        SetPropertyCache(data)
        RebuildDoorTargets()
        print('[yg_properties] Tüm mülkler ve kilitler senkronize edildi.')
    end
end)

RegisterNetEvent('yg_properties:client:propertyUpdated', function(propertyId)
    RefreshProperties()
    RebuildDoorTargets()

    if LocalPlayer.state.ygPropertyId == propertyId then
        local prop = lib.callback.await('yg_properties:server:getProperty', false, propertyId)
        if not prop then return end

        LocalPlayer.state.ygCurrentProperty = prop
        SetCurrentProperty(prop)
        ApplyPropertyWeather(prop)
        ApplyPropertyBlackout(prop)
        ApplyPropertyTime(prop)

        if prop.interior_spawn and prop.interior_spawn ~= '' then
            local spawn = Shared.DecodeVec4(prop.interior_spawn)
            createInteriorZone(propertyId, { x = spawn.x, y = spawn.y, z = spawn.z })
        else
            local door = Shared.DecodeVec4(prop.door_coords)
            createInteriorZone(propertyId, { x = door.x, y = door.y, z = door.z })
        end

        syncAmenityZones(propertyId, prop)
    end
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    RefreshProperties()
    RebuildDoorTargets()
end)

-- ✅ OPTİMİZASYON: Distance-based marker rendering
CreateThread(function()
    local lastRefreshTime = 0
    local refreshInterval = 5000 -- 5 saniye arası check

    while true do
        if LocalPlayer.state.ygPropertyId == nil and next(doorMarkers) ~= nil then
            local sleep = 500
            local pCoords = GetEntityCoords(PlayerPedId())
            local now = GetGameTimer()

            -- Periodik cache refresh
            if now - lastRefreshTime > refreshInterval then
                RefreshProperties()
                lastRefreshTime = now
            end

            for _, m in pairs(doorMarkers) do
                local dist = #(pCoords - vec3(m.x, m.y, m.z))

                if dist < 15.0 then
                    sleep = 0

                    DrawMarker(2, m.x, m.y, m.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 0, 255, 0, 180, false, true, 2, false, nil, nil, false)

                    local isLocked = (m.locked == true)
                    local lockTxt = (isLocked and '~r~Kilitli~s~' or '~g~Açık~s~')

                    local title = ""
                    if not m.owner or m.owner == "" then
                        title = ('~w~#%s~s~'):format(m.id or '?')
                    else
                        local lbl = (m.label and m.label ~= '') and m.label or 'Mekan'
                        title = ('~w~#%s~s~ - ~w~%s~s~'):format(m.id or '?', lbl)
                    end

                    local lines = { title, lockTxt }
                    lines[#lines + 1] = (m.type == 'business') and '~c~İş Yeri~s~' or '~c~Ev~s~'

                    if not m.owner or m.owner == "" then
                        lines[#lines + 1] = ('~y~Satılık~s~  ~g~$%s'):format(CashFmt(m.price))
                    else
                        if m.type == 'business' and tonumber(m.entry_fee or 0) > 0 then
                            lines[#lines + 1] = ('~w~Giriş Ücreti:~s~ ~g~$%s~s~'):format(CashFmt(m.entry_fee))
                        end
                    end

                    DrawText3DModern(m.x, m.y, m.z + 0.70, lines, { maxDist = 14.0, scale = 0.40 })
                end
            end

            Wait(sleep)
        else
            Wait(1000)
        end
    end
end)

-- ✅ OPTİMİZASYON: Reduced rebuild frequency
CreateThread(function()
    while true do
        if LocalPlayer.state.ygPropertyId == nil then
            if not Properties or #Properties == 0 then
                RefreshProperties()
                Wait(1000)
            else
                Wait(5000)
            end
        else
            clearDoorTargets()
            Wait(1500)
        end
    end
end)

-- ======================
-- Interior enter/exit + target + marker (İÇERİSİ)
-- ======================
local InteriorZoneId = nil
local InteriorMarkerCoords = nil
local StashZoneId = nil
local StashMarkerCoords = nil
local WardrobeZoneId = nil
local WardrobeMarkerCoords = nil

local function teleportRaw(vec4)
    SetEntityCoordsNoOffset(PlayerPedId(), vec4.x, vec4.y, vec4.z, false, false, false)
    SetEntityHeading(PlayerPedId(), vec4.w or 0.0)
end

local function removeInteriorZone()
    BridgeRemoveZone(InteriorZoneId)
    InteriorZoneId = nil
    InteriorMarkerCoords = nil
end

local function removeStashZone()
    BridgeRemoveZone(StashZoneId)
    StashZoneId = nil
    StashMarkerCoords = nil
end

local function removeWardrobeZone()
    BridgeRemoveZone(WardrobeZoneId)
    WardrobeZoneId = nil
    WardrobeMarkerCoords = nil
end

function createInteriorZone(propertyId, coords)
    if type(coords) ~= 'table' or coords.x == nil or coords.y == nil or coords.z == nil then
        return
    end

    removeInteriorZone()

    InteriorMarkerCoords = { x = coords.x + 0.0, y = coords.y + 0.0, z = coords.z + 0.0 }

    InteriorZoneId = BridgeAddSphereZone(
        ('yg_exit_%s'):format(propertyId),
        vec3(InteriorMarkerCoords.x, InteriorMarkerCoords.y, InteriorMarkerCoords.z),
        2.0,
        {
            {
                icon = 'fa-solid fa-door-closed',
                label = 'Dışarı Çık',
                onSelect = function()
                    TriggerEvent('yg_properties:client:exit')
                end
            }
        }
    )
end

-- Depo (stash) noktası — panelden "Stash Noktası Koy" ile koyulur, buradan target ile açılır.
function createStashZone(propertyId, coords)
    if type(coords) ~= 'table' or coords.x == nil or coords.y == nil or coords.z == nil then return end
    removeStashZone()
    StashMarkerCoords = { x = coords.x + 0.0, y = coords.y + 0.0, z = coords.z + 0.0 }
    StashZoneId = BridgeAddSphereZone(
        ('yg_stash_%s'):format(propertyId),
        vec3(StashMarkerCoords.x, StashMarkerCoords.y, StashMarkerCoords.z),
        1.4,
        {
            {
                icon = 'fa-solid fa-box-archive',
                label = 'Depoyu Aç',
                onSelect = function()
                    TriggerServerEvent('yg_properties:server:openStash', propertyId)
                end
            }
        }
    )
end

-- Gardırop noktası — aynı mantık, kıyafet deposu için ayrı stash.
function createWardrobeZone(propertyId, coords)
    if type(coords) ~= 'table' or coords.x == nil or coords.y == nil or coords.z == nil then return end
    removeWardrobeZone()
    WardrobeMarkerCoords = { x = coords.x + 0.0, y = coords.y + 0.0, z = coords.z + 0.0 }
    WardrobeZoneId = BridgeAddSphereZone(
        ('yg_wardrobe_%s'):format(propertyId),
        vec3(WardrobeMarkerCoords.x, WardrobeMarkerCoords.y, WardrobeMarkerCoords.z),
        1.4,
        {
            {
                icon = 'fa-solid fa-shirt',
                label = 'Gardırobu Aç',
                onSelect = function()
                    TriggerServerEvent('yg_properties:server:openWardrobe', propertyId)
                end
            }
        }
    )
end

-- prop.stash_point / prop.wardrobe_point varsa zone'ları kurar (yoksa o nokta
-- hiç yok demektir). BİLEREK GLOBAL (`local` değil) — bu fonksiyonu kendisinden
-- ÖNCE (sözdizimsel olarak yukarıda) çağıran event handler'lar var (örn.
-- propertyUpdated); local olsaydı "nil value" hatası verirdi çünkü local'ler
-- ileri referans desteklemez. Global fonksiyonlar runtime'da çağrıldığı anda
-- aranır, dosyadaki sıra önemli değildir.
function syncAmenityZones(propertyId, prop)
    if prop.stash_point and prop.stash_point ~= '' then
        local p = Shared.DecodeVec4(prop.stash_point)
        createStashZone(propertyId, { x = p.x, y = p.y, z = p.z })
    else
        removeStashZone()
    end

    if prop.wardrobe_point and prop.wardrobe_point ~= '' then
        local p = Shared.DecodeVec4(prop.wardrobe_point)
        createWardrobeZone(propertyId, { x = p.x, y = p.y, z = p.z })
    else
        removeWardrobeZone()
    end
end

-- ✅ OPTİMİZASYON: Conditional marker drawing
CreateThread(function()
    while true do
        local c = InteriorMarkerCoords
        if LocalPlayer.state.ygPropertyId ~= nil and type(c) == 'table' and c.x ~= nil and c.y ~= nil and c.z ~= nil then
            Wait(0)
            DrawMarker(2, c.x, c.y, c.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 0, 0, 180, false, true, 2, false, nil, nil, false)

            local sc = StashMarkerCoords
            if type(sc) == 'table' then
                DrawMarker(2, sc.x, sc.y, sc.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 153, 0, 180, false, true, 2, false, nil, nil, false)
            end

            local wc = WardrobeMarkerCoords
            if type(wc) == 'table' then
                DrawMarker(2, wc.x, wc.y, wc.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 0, 120, 255, 180, false, true, 2, false, nil, nil, false)
            end
        else
            Wait(500)
        end
    end
end)

-- shell/ipl/generic ışınlama mantığı — hem normal girişte hem relog'da
-- (oyuna yeniden bağlanınca) kullanılır. Başarısızlıkta state'i temizler
-- ve false döner; caller sadece return etmeli.
local function TeleportIntoInterior(propertyId, prop)
    if prop.shell_id then
        local shellObjects, offsets, base = SpawnShellForProperty(prop)
        if not shellObjects or not offsets or not base then
            TriggerServerEvent('yg_properties:server:exitBucket')
            LocalPlayer.state.ygPropertyId = nil
            LocalPlayer.state.ygCurrentProperty = nil
            SetCurrentProperty(nil)
            abortEnterEffects(propertyId)
            lib.notify({ type = 'error', description = 'Shell oluşturulamadı.' })
            return false
        end

        local exitPos = offsets.exit or offsets.Exit or offsets.exitPos
        if not exitPos then
            print('[yg_properties] shell exit bulunamadı')
            print('[yg_properties] offsets dump: ' .. json.encode(offsets))

            TriggerServerEvent('yg_properties:server:exitBucket')
            LocalPlayer.state.ygPropertyId = nil
            LocalPlayer.state.ygCurrentProperty = nil
            SetCurrentProperty(nil)
            abortEnterEffects(propertyId)
            lib.notify({ type = 'error', description = 'Shell exit verisi bulunamadı.' })
            return false
        end

        CurrentShellObjects = shellObjects
        CurrentShellOffsets = offsets
        CurrentShellBase = base

        local worldExit = vector4(
            base.x + (tonumber(exitPos.x) or 0.0),
            base.y + (tonumber(exitPos.y) or 0.0),
            base.z + (tonumber(exitPos.z) or 0.0),
            exitPos.h or exitPos.w or 0.0
        )

        teleportRaw(worldExit)

        createInteriorZone(propertyId, {
            x = worldExit.x,
            y = worldExit.y,
            z = worldExit.z
        })
    elseif prop.interior_kind == 'ipl' and prop.ipl_id and Config.IPLInteriors and Config.IPLInteriors[prop.ipl_id] then
        local def = Config.IPLInteriors[prop.ipl_id]

        if def.interiorType then
            -- nightclub gibi: RequestIpl DEĞİL, GetInteriorAtCoordsWithType
            -- + LoadInterior + IsInteriorReady ile yüklenen kalıcı interior.
            local loaded = EnsureInteriorTypeLoaded(def.interiorType, def.typeCoords, 8000)
            if not loaded then
                TriggerServerEvent('yg_properties:server:exitBucket')
                LocalPlayer.state.ygPropertyId = nil
                LocalPlayer.state.ygCurrentProperty = nil
                SetCurrentProperty(nil)
                abortEnterEffects(propertyId)
                lib.notify({ type = 'error', description = 'Interior yüklenemedi.' })
                return false
            end

            local spawn
            if prop.interior_spawn and prop.interior_spawn ~= '' then
                spawn = Shared.DecodeVec4(prop.interior_spawn)
            else
                spawn = def.spawn
            end

            teleportRaw(spawn)
            WaitForCollisionAt(spawn)

            createInteriorZone(propertyId, { x = spawn.x, y = spawn.y, z = spawn.z })
            return true
        end

        local loaded = EnsureIplLoaded(def.ipl)
        if not loaded then
            TriggerServerEvent('yg_properties:server:exitBucket')
            LocalPlayer.state.ygPropertyId = nil
            LocalPlayer.state.ygCurrentProperty = nil
            SetCurrentProperty(nil)
            abortEnterEffects(propertyId)
            lib.notify({ type = 'error', description = 'Interior yüklenemedi (IPL bulunamadı).' })
            return false
        end
        CurrentIpls = def.ipl or {}

        local spawn
        if prop.interior_spawn and prop.interior_spawn ~= '' then
            spawn = Shared.DecodeVec4(prop.interior_spawn)
        else
            spawn = def.spawn -- mekan ilk kez giriliyor: config'teki varsayılan iç nokta
        end

        teleportRaw(spawn)
        WaitForCollisionAt(spawn) -- siyah ekran/void'i önler

        createInteriorZone(propertyId, { x = spawn.x, y = spawn.y, z = spawn.z })
    else
        if prop.interior_spawn and prop.interior_spawn ~= '' then
            local spawn = Shared.DecodeVec4(prop.interior_spawn)
            teleportRaw(spawn)
            createInteriorZone(propertyId, { x = spawn.x, y = spawn.y, z = spawn.z })
        else
            local door = Shared.DecodeVec4(prop.door_coords)
            createInteriorZone(propertyId, { x = door.x, y = door.y, z = door.z })
        end
    end

    syncAmenityZones(propertyId, prop)

    return true
end

RegisterNetEvent('yg_properties:client:enter', function(propertyId)
    if LocalPlayer.state.ygPropertyId ~= nil then
        lib.notify({ type = 'error', description = 'Zaten içeridesin.' })
        return
    end

    local prop = lib.callback.await('yg_properties:server:getProperty', false, propertyId)
    if not prop then
        lib.notify({ type = 'error', description = 'Property bulunamadı (getProperty nil).' })
        return
    end

    local canEnter = lib.callback.await('yg_properties:server:canEnter', false, propertyId)
    if not canEnter then
        if Config.Keys and Config.Keys.doorbell then
            TriggerServerEvent('yg_properties:server:knock', propertyId)
        end
        lib.notify({ type = 'error', description = 'Kilitli. (Kapı çalındı.)' })
        return
    end

    local myCid = MyCitizenId()

    if prop.type == 'business' then
        local ownerCid = prop.owner_citizenid
        local amOwner = (myCid and ownerCid and ownerCid == myCid)
        if not amOwner then
            local ok = select(1, lib.callback.await('yg_properties:server:payEntryFee', false, propertyId))
            if not ok then
                lib.notify({ type = 'error', description = 'Giriş ücreti ödenemedi.' })
                return
            end
        end
    end

    beginEnterEffects(propertyId)

    TriggerServerEvent('yg_properties:server:enterBucket', propertyId)

    LocalPlayer.state.ygPropertyId = propertyId
    LocalPlayer.state.ygCurrentProperty = prop
    SetCurrentProperty(prop)

    -- ✅ YENİ: Enter sırasında door targets'ı hemen temizle
    clearDoorTargets()

    if not TeleportIntoInterior(propertyId, prop) then return end

    ApplyPropertyWeather(prop)
    ApplyPropertyBlackout(prop)
    ApplyPropertyTime(prop)
    LoadObjectsForCurrent()
    TriggerEvent('yg_properties:client:syncMusic', propertyId)
    lib.notify({ type = 'success', description = 'İçeri girdin.' })
end)

-- Relog: oyuncu disconnect olduğunda evdeyse, tekrar bağlandığında
-- server bunu tetikler ve otomatik aynı mekanın içine ışınlar.
RegisterNetEvent('yg_properties:client:respawnInside', function(propertyId)
    if LocalPlayer.state.ygPropertyId ~= nil then return end

    local prop = lib.callback.await('yg_properties:server:getProperty', false, propertyId)
    if not prop then return end

    beginEnterEffects(propertyId)
    TriggerServerEvent('yg_properties:server:enterBucket', propertyId)

    LocalPlayer.state.ygPropertyId = propertyId
    LocalPlayer.state.ygCurrentProperty = prop
    SetCurrentProperty(prop)
    clearDoorTargets()

    if not TeleportIntoInterior(propertyId, prop) then return end

    ApplyPropertyWeather(prop)
    ApplyPropertyBlackout(prop)
    ApplyPropertyTime(prop)
    LoadObjectsForCurrent()
    TriggerEvent('yg_properties:client:syncMusic', propertyId)
    lib.notify({ type = 'success', description = ('%s — bağlantın kesilmeden önce buradaydın.'):format(prop.label or 'Mekan') })
end)

RegisterNetEvent('yg_properties:client:exit', function()
    ClearObjectsAndBuilder()
    ClearPropertyWeather()
    ClearPropertyBlackout()
    ClearPropertyTime()

    local prop = GetCurrentProperty()
    if not prop then return end

    removeInteriorZone()
    removeStashZone()
    removeWardrobeZone()
    DespawnCurrentIpls()
    DespawnCurrentInteriorType()

    local door = Shared.DecodeVec4(prop.door_coords)

    fadeOut(250)
    while not IsScreenFadedOut() do Wait(0) end

    DespawnCurrentShell(function()
        TriggerServerEvent('yg_properties:server:exitBucket')

        LocalPlayer.state.ygPropertyId = nil
        LocalPlayer.state.ygCurrentProperty = nil
        SetCurrentProperty(nil)

        teleportRaw(door)
        Wait(150)
        fadeIn(250)

        -- ✅ YENİ: Refresh'i trigger et
        TriggerEvent('yg_properties:client:exitComplete')

        lib.notify({ type = 'success', description = 'Dışarı çıktın.' })
    end)
end)

RegisterNetEvent('yg_properties:client:exitComplete', function()
    Wait(500) -- Exit animasyonu bitsinsin
    RefreshProperties()
    RebuildDoorTargets()
    print('[yg_properties] Door targets/markers reloaded after exit')
end)

-- ======================
-- Info / Buy / Panel
-- ======================
RegisterNetEvent('yg_properties:client:showInfo', function(propertyId)
    local prop = lib.callback.await('yg_properties:server:getProperty', false, propertyId)
    if not prop then return end

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        action = 'openInfo',
        data = {
            label = prop.label or ('Mekan #%s'):format(propertyId),
            type = prop.type,
            description = prop.description or '',
            owned = (prop.owner_citizenid ~= nil and prop.owner_citizenid ~= ''),
            price = tonumber(prop.price) or 0,
            entry_fee = tonumber(prop.entry_fee) or 0,
            locked = IsLocked(prop.locked),
        }
    })
end)

RegisterNetEvent('yg_properties:client:buy', function(propertyId)
    local ok, reason = lib.callback.await('yg_properties:server:buyProperty', false, propertyId)
    if ok then
        lib.notify({ type = 'success', description = 'Satın alındı.' })
        RefreshProperties()
        RebuildDoorTargets()
    else
        lib.notify({ type = 'error', description = ('Satın alınamadı: %s'):format(reason) })
    end
end)

local function isBusiness(prop)
    return prop and prop.type == 'business'
end

RegisterNetEvent('yg_properties:client:openPanelCurrent', function()
    local propertyId = LocalPlayer.state.ygPropertyId
    if not propertyId then
        lib.notify({ type = 'error', description = 'Panel için önce bir mekana girmen lazım.' })
        return
    end
    TriggerEvent('yg_properties:client:openPanel', propertyId)
end)

-- ✅ OPTİMİZASYON: Panel callback caching
local panelDataCache = {}
local panelCacheExpire = {}

-- 9 global çalışan yetkisi (orijinal "Çalışan Yetkileri" dialogundaki aynı liste)
local PERM_KEYS = {
    'employeesCanEnter', 'employeesCanManage', 'employeesCanManageDoor',
    'employeesCanSetEntryFee', 'employeesCanEditDescription', 'employeesCanBuild',
    'employeesCanDeposit', 'employeesCanWithdraw', 'employeesCanManageEmployees',
}

local function MyOwnedProperties()
    local myCid = MyCitizenId()
    local list = {}
    for _, p in ipairs(Properties or {}) do
        if myCid and p.owner_citizenid == myCid then
            list[#list + 1] = { id = p.id, label = p.label, type = p.type }
        end
    end
    return list
end

-- propertyId için panel verisini (mgmt+keys) toplar; yetkisizse nil döner.
local function BuildPanelData(propertyId)
    local prop = lib.callback.await('yg_properties:server:getProperty', false, propertyId)
    if not prop or not prop.owner_citizenid or prop.owner_citizenid == '' then return nil end

    local canManage = lib.callback.await('yg_properties:server:canManage', false, propertyId)
    if not canManage then return nil end

    local manageData = lib.callback.await('yg_properties:server:getManagementData', false, propertyId)
    if not manageData then return nil end

    local keys = lib.callback.await('yg_properties:server:getKeys', false, propertyId) or {}

    local permKeys = {}
    for _, k in ipairs(PERM_KEYS) do permKeys[k] = true end

    local myCid = MyCitizenId()

    return {
        propertyId = propertyId,
        mgmt = manageData,
        myProperties = MyOwnedProperties(),
        keys = keys,
        permKeys = permKeys,
        amOwner = (myCid ~= nil and manageData.owner_citizenid == myCid),
    }
end

RegisterNetEvent('yg_properties:client:openPanel', function(propertyId)
    if LocalPlayer.state.ygPropertyId ~= propertyId then
        lib.notify({ type = 'error', description = 'Panel için mekana girmen lazım.' })
        return
    end

    local data = BuildPanelData(propertyId)
    if not data then
        lib.notify({ type = 'error', description = 'Bu panel için yetkin yok ya da mekan satın alınmamış.' })
        return
    end

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'openManagement', data = data })
end)

RegisterNUICallback('yg_close', function(_, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    cb({ ok = true })
end)

-- panel açıkken başka sahipli/yetkili mülke geçmek (panelden çıkmadan)
RegisterNUICallback('yg_mgmtSelect', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    local data = BuildPanelData(pid)
    if not data then cb({ ok = false }); return end
    cb({ ok = true, propertyId = data.propertyId, mgmt = data.mgmt, keys = data.keys, amOwner = data.amOwner })
end)

RegisterNUICallback('yg_setLabel', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:setLabel', pid, tostring(d.label or ''))
    lib.notify({ type = 'success', description = 'Mekan adı güncellendi.' })
    cb({ ok = true })
end)

RegisterNUICallback('yg_setDescription', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:setDescription', pid, tostring(d.description or ''))
    lib.notify({ type = 'success', description = 'Açıklama güncellendi.' })
    cb({ ok = true })
end)

RegisterNUICallback('yg_setLocked', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:setLocked', pid, d.locked == true)
    cb({ ok = true })
end)

RegisterNUICallback('yg_setEntryFee', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:setEntryFee', pid, tonumber(d.fee) or 0)
    lib.notify({ type = 'success', description = 'Giriş ücreti ayarlandı.' })
    cb({ ok = true })
end)

RegisterNUICallback('yg_setWeather', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:setWeather', pid, d.weather or '')
    lib.notify({ type = 'success', description = 'Hava durumu ayarlandı.' })
    cb({ ok = true })
end)

RegisterNUICallback('yg_setBlackout', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:setBlackout', pid, d.state == true)
    lib.notify({ type = 'success', description = d.state and 'Karartma açıldı.' or 'Karartma kapatıldı.' })
    cb({ ok = true })
end)

RegisterNUICallback('yg_setTime', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:setTime', pid, d.time or '')
    lib.notify({ type = 'success', description = 'Saat ayarlandı.' })
    cb({ ok = true })
end)

RegisterNUICallback('yg_deposit', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:depositSafeMoney', pid, tonumber(d.amount) or 0)
    cb({ ok = true })
end)

RegisterNUICallback('yg_withdraw', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:withdrawSafeMoney', pid, tonumber(d.amount) or 0)
    cb({ ok = true })
end)

-- ✅ orijinaldeki gibi CitizenID ile eklenir (server id DEĞİL)
RegisterNUICallback('yg_addEmployee', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:addEmployee', pid, tostring(d.target or ''))
    cb({ ok = true })
end)

RegisterNUICallback('yg_removeEmployee', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:removeEmployee', pid, tostring(d.citizenid or ''))
    cb({ ok = true })
end)

RegisterNUICallback('yg_setPermission', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid or not d.key then cb({ ok = false }); return end
    TriggerServerEvent('yg_properties:server:setPermission', pid, tostring(d.key), d.value == true)
    cb({ ok = true })
end)

RegisterNUICallback('yg_sell', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    local ok, refund = lib.callback.await('yg_properties:server:sellProperty', false, pid)
    if ok then
        lib.notify({ type = 'success', description = ('Mülk satıldı. Geri ödeme: $%s'):format(CashFmt(refund or 0)) })
        RefreshProperties()
        RebuildDoorTargets()
    else
        lib.notify({ type = 'error', description = 'Satılamadı.' })
    end
    cb({ ok = ok == true })
end)

-- aynı orijinal mantık: sadece içerideyken, sahibi taşıyabilir
RegisterNUICallback('yg_relocateSpawn', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end

    if LocalPlayer.state.ygPropertyId ~= pid then
        lib.notify({ type = 'error', description = 'Bunu yapmak için önce bu mekana girmen lazım.' })
        cb({ ok = false })
        return
    end

    local c = GetEntityCoords(PlayerPedId())
    local h = GetEntityHeading(PlayerPedId())
    local enc = Shared.EncodeVec4(vector4(c.x, c.y, c.z, h))

    local ok = lib.callback.await('yg_properties:server:setInteriorSpawnHere', false, pid, enc)
    if not ok then
        lib.notify({ type = 'error', description = 'Sadece sahip çıkış/spawn noktasını taşıyabilir.' })
        cb({ ok = false })
        return
    end

    createInteriorZone(pid, { x = c.x, y = c.y, z = c.z })

    local cur = GetCurrentProperty()
    if cur then cur.interior_spawn = enc end

    lib.notify({ type = 'success', description = 'Çıkış/spawn noktası taşındı.' })
    cb({ ok = true })
end)

-- Depo noktasını buraya koy (sahip, içerideyken) — koyduğun yerde target zone açılır.
RegisterNUICallback('yg_setStashPoint', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end

    if LocalPlayer.state.ygPropertyId ~= pid then
        lib.notify({ type = 'error', description = 'Bunu yapmak için önce bu mekana girmen lazım.' })
        cb({ ok = false })
        return
    end

    local c = GetEntityCoords(PlayerPedId())
    local h = GetEntityHeading(PlayerPedId())
    local enc = Shared.EncodeVec4(vector4(c.x, c.y, c.z, h))

    local ok = lib.callback.await('yg_properties:server:setStashPointHere', false, pid, enc)
    if not ok then
        lib.notify({ type = 'error', description = 'Sadece sahip depo noktası koyabilir.' })
        cb({ ok = false })
        return
    end

    createStashZone(pid, { x = c.x, y = c.y, z = c.z })
    local cur = GetCurrentProperty()
    if cur then cur.stash_point = enc end

    lib.notify({ type = 'success', description = 'Depo noktası kondu. Yanına gidip target ile aç.' })
    cb({ ok = true })
end)

-- Gardırop noktasını buraya koy — aynı mantık.
RegisterNUICallback('yg_setWardrobePoint', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end

    if LocalPlayer.state.ygPropertyId ~= pid then
        lib.notify({ type = 'error', description = 'Bunu yapmak için önce bu mekana girmen lazım.' })
        cb({ ok = false })
        return
    end

    local c = GetEntityCoords(PlayerPedId())
    local h = GetEntityHeading(PlayerPedId())
    local enc = Shared.EncodeVec4(vector4(c.x, c.y, c.z, h))

    local ok = lib.callback.await('yg_properties:server:setWardrobePointHere', false, pid, enc)
    if not ok then
        lib.notify({ type = 'error', description = 'Sadece sahip gardırop noktası koyabilir.' })
        cb({ ok = false })
        return
    end

    createWardrobeZone(pid, { x = c.x, y = c.y, z = c.z })
    local cur = GetCurrentProperty()
    if cur then cur.wardrobe_point = enc end

    lib.notify({ type = 'success', description = 'Gardırop noktası kondu. Yanına gidip target ile aç.' })
    cb({ ok = true })
end)

RegisterNUICallback('yg_furnish', function(_, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    cb({ ok = true })
    TriggerEvent('yg_properties:client:openBuildEditor')
end)

RegisterNUICallback('yg_manageObjects', function(_, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    cb({ ok = true })
    TriggerEvent('yg_properties:client:openObjectManager')
end)

-- ============================================================
--  MARKET / ANAHTARLARIM (panel-içi sekmeler + bağımsız ekranlar)
-- ============================================================
RegisterNUICallback('yg_getMarket', function(_, cb)
    local list = {}
    for _, p in ipairs(Properties or {}) do
        if not p.owner_citizenid or p.owner_citizenid == '' then
            list[#list + 1] = { id = p.id, label = p.label, type = p.type, price = p.price }
        end
    end
    cb({ ok = true, list = list })
end)

RegisterNUICallback('yg_getMyKeysList', function(_, cb)
    local list = lib.callback.await('yg_properties:server:getMyKeys', false) or {}
    cb({ ok = true, list = list })
end)

RegisterNUICallback('yg_gotoMyKey', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    cb({ ok = true })
    if not pid then return end
    local prop = lib.callback.await('yg_properties:server:getProperty', false, pid)
    if not prop or not prop.door_coords then return end
    local door = Shared.DecodeVec4(prop.door_coords)
    SetNewWaypoint(door.x, door.y)
    lib.notify({ type = 'success', description = 'Rota ayarlandı.' })
end)

RegisterNUICallback('yg_buy', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    local ok, reason = lib.callback.await('yg_properties:server:buyProperty', false, pid)
    if ok then
        lib.notify({ type = 'success', description = 'Satın alındı.' })
        RefreshProperties()
        RebuildDoorTargets()
    else
        lib.notify({ type = 'error', description = ('Satın alınamadı: %s'):format(tostring(reason)) })
    end
    cb({ ok = ok == true })
end)

RegisterNUICallback('yg_giveKey', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    local ok, keysOrErr = lib.callback.await('yg_properties:server:giveKey', false, pid, d.target)
    if ok then
        lib.notify({ type = 'success', description = 'Anahtar verildi.' })
        cb({ ok = true, keys = keysOrErr })
    else
        lib.notify({ type = 'error', description = ('Anahtar verilemedi: %s'):format(tostring(keysOrErr)) })
        cb({ ok = false })
    end
end)

RegisterNUICallback('yg_removeKey', function(d, cb)
    local pid = tonumber(d and d.propertyId)
    if not pid then cb({ ok = false }); return end
    local ok, keysOrErr = lib.callback.await('yg_properties:server:removeKey', false, pid, d.citizenid)
    cb({ ok = ok == true, keys = (ok and keysOrErr) or nil })
end)

-- ============================================================
--  EMLAKÇI (mülk oluşturma) — NUI
-- ============================================================
RegisterNUICallback('yg_realtorCreate', function(d, cb)
    local ok, idOrErr = lib.callback.await('yg_properties:server:realtorCreate', false, d.catId, d.optIndex)
    if ok then
        lib.notify({ type = 'success', description = ('Mekan oluşturuldu (#%s).'):format(tostring(idOrErr)) })
        RefreshProperties()
        RebuildDoorTargets()
    else
        lib.notify({ type = 'error', description = ('Oluşturulamadı: %s'):format(tostring(idOrErr)) })
    end
    cb({ ok = ok == true })
end)

local function OpenRealtorNui()
    local cats = lib.callback.await('yg_properties:server:getRealtorCategories', false) or Config.RealtorCategories or {}
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'openRealtor', data = { categories = cats } })
end

RegisterCommand('emlakci', OpenRealtorNui, false)
RegisterKeyMapping('emlakci', 'Emlakçı Menüsü', 'keyboard', 'F7')

RegisterCommand('anahtarlarim', function()
    local list = lib.callback.await('yg_properties:server:getMyKeys', false) or {}
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'openMyKeys', data = { list = list } })
end, false)

-- ============================================================
--  SHELL EXIT-OFFSET BULMA ARAÇLARI (admin) — yeni shell paketi
--  eklerken Config.NativeShells'e yazılacak exit={x,y,z,h} değerini
--  oyun içinde 10 saniyede bulmana yarar.
-- ============================================================
local ShellTestObj = nil
local ShellTestBase = nil

RegisterCommand('shelltest', function(_, args)
    local playerData = QBCore.Functions.GetPlayerData()
    if not Shared.IsAdmin(playerData) then return end

    if not args[1] or args[1] == '' then
        lib.notify({ type = 'error', description = 'Kullanım: /shelltest <model1> [model2] [model3] ...' })
        return
    end

    -- ✅ DEĞİŞTİ: artık BİRDEN FAZLA model adı (boşlukla ayrılmış) kabul
    -- ediyor, hepsini AYNI noktaya spawn ediyor — dış kabuk + iç kabuk +
    -- çim gibi ayrı parçaları Blender'da birleştirmeden, "üst üste
    -- koyarak" birlikte test edebilmen için.
    if ShellTestObjs then
        for _, e in ipairs(ShellTestObjs) do
            if DoesEntityExist(e) then DeleteEntity(e) end
        end
    end
    ShellTestObjs = {}

    local coords = GetEntityCoords(PlayerPedId())
    ShellTestBase = { x = coords.x, y = coords.y, z = coords.z }

    local spawned, failed = 0, {}
    for _, model in ipairs(args) do
        local hash = joaat(model)
        if not IsModelInCdimage(hash) then
            failed[#failed + 1] = model
        else
            RequestModel(hash)
            local t = GetGameTimer() + 5000
            while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(10) end
            if not HasModelLoaded(hash) then
                failed[#failed + 1] = model
            else
                local ent = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
                SetEntityAsMissionEntity(ent, true, true)
                FreezeEntityPosition(ent, true)
                ShellTestObjs[#ShellTestObjs + 1] = ent
                spawned = spawned + 1
            end
        end
    end

    ShellTestObj = ShellTestObjs[1]

    if spawned == 0 then
        lib.notify({ type = 'error', description = 'Hiçbir model spawn edilemedi (stream edilmemiş/isim yanlış olabilir).' })
        return
    end

    local msg = ('%d parça önüne spawnlandı.'):format(spawned)
    if #failed > 0 then msg = msg .. (' (BAŞARISIZ: %s)'):format(table.concat(failed, ', ')) end
    msg = msg .. ' İçine gir, çıkış noktasına geç, /shellexit yaz.'
    lib.notify({ type = 'success', description = msg })
end, false)

RegisterCommand('shellexit', function()
    local playerData = QBCore.Functions.GetPlayerData()
    if not Shared.IsAdmin(playerData) then return end

    if not ShellTestObj or not DoesEntityExist(ShellTestObj) or not ShellTestBase then
        lib.notify({ type = 'error', description = 'Önce /shelltest <model> ile bir test objesi spawnla.' })
        return
    end

    local p = GetEntityCoords(PlayerPedId())
    local h = GetEntityHeading(PlayerPedId())
    local dx = p.x - ShellTestBase.x
    local dy = p.y - ShellTestBase.y
    local dz = p.z - ShellTestBase.z

    local line = ('{ model = \'?\', exit = { x = %.3f, y = %.3f, z = %.3f, h = %.2f } },'):format(dx, dy, dz, h)
    print('[yg_properties] SHELL EXIT >>> ' .. line)
    lib.notify({ type = 'success', description = 'Değerler F8 konsoluna yazıldı, kopyala-yapıştır yap.' })
end, false)

RegisterCommand('shelltestclear', function()
    local playerData = QBCore.Functions.GetPlayerData()
    if not Shared.IsAdmin(playerData) then return end

    if ShellTestObjs then
        for _, e in ipairs(ShellTestObjs) do
            if DoesEntityExist(e) then DeleteEntity(e) end
        end
    end
    if ShellTestObj and DoesEntityExist(ShellTestObj) then DeleteEntity(ShellTestObj) end
    ShellTestObjs = nil
    ShellTestObj = nil
    ShellTestBase = nil
    lib.notify({ type = 'inform', description = 'Test objeleri silindi.' })
end, false)

-- ✅ EKLENDİ: Build Mode'da inşa ettiğin bir mekanı (duvar/zemin/kapılı
-- duvar — ne varsa) TEK bir bütün "shell" olarak kaydet, başka
-- mülklerde de bu bütün halde spawn edilebilsin. Yetki kontrolü SUNUCU
-- tarafında (canBuild — sahip ya da inşa yetkili çalışan).
RegisterCommand('saveshell', function(_, args)
    if not LocalPlayer.state.ygPropertyId then
        lib.notify({ type = 'error', description = 'Önce mekana gir.' })
        return
    end
    local label = table.concat(args, ' ')
    if label == '' then label = nil end
    TriggerServerEvent('yg_properties:server:saveAsShellTemplate', LocalPlayer.state.ygPropertyId, label)
end, false)

RegisterCommand('mekanpanel', function()
    TriggerEvent('yg_properties:client:openPanelCurrent')
end, false)
RegisterKeyMapping('mekanpanel', 'Mekan Paneli', 'keyboard', 'F6')

RegisterCommand('cikis', function()
    if LocalPlayer.state.ygPropertyId ~= nil then
        TriggerEvent('yg_properties:client:exit')
    end
end, false)
RegisterKeyMapping('cikis', 'Mekandan Çık', 'keyboard', 'BACK')

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    removeInteriorZone()
    removeStashZone()
    removeWardrobeZone()
    clearDoorTargets()
    ClearObjectsAndBuilder()
    DespawnCurrentShell()
    DespawnCurrentIpls()
    DespawnCurrentInteriorType()
end)

-- Kapı çalma (kilitliyken E'ye basan biri olunca, içerideki herkese bildirim)
RegisterNetEvent('yg_properties:client:doorbell', function(who)
    if LocalPlayer.state.ygPropertyId == nil then return end
    lib.notify({ type = 'inform', description = ('🔔 %s kapıyı çalıyor.'):format(who or 'Biri') })
end)

RegisterNetEvent('yg_properties:client:openOxStash', function(stashId, label)
    print('[DEBUG] openOxStash called - stashId: ' .. tostring(stashId))
    
    if not stashId then 
        lib.notify({ type = 'error', description = 'Stash ID boş!' })
        return 
    end

    -- ✅ OX_INVENTORY DOĞRU AÇMA
    local success = exports.ox_inventory:openInventory('stash', stashId)
    
    if success then
        lib.notify({ type = 'success', description = 'Stash açıldı: ' .. label })
    else
        print('[yg_properties] Stash açma başarısız: ' .. stashId)
        lib.notify({ type = 'error', description = 'Stash açılamadı, tekrar deneyin.' })
    end
end)