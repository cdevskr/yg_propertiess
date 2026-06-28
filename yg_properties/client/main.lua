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

-- ✅ OPTİMİZASYON: Shell mapping table (döngü yerine lookup)
local shellFunctions = {
    [1] = function(base) return exports['qb-interior']:CreateMichael(base) end,
    [2] = function(base) return exports['qb-interior']:CreateFranklinAunt(base) end,
    [3] = function(base) return exports['qb-interior']:CreateRanchShell(base) end,
    [4] = function(base) return exports['qb-interior']:CreateTier1House(base) end,
    [5] = function(base) return exports['qb-interior']:CreateApartmentShell(base) end,
    [6] = function(base) return exports['qb-interior']:CreateLesterShell(base) end,
    [7] = function(base) return exports['qb-interior']:CreateTrevorsShell(base) end,
    [8] = function(base) return exports['qb-interior']:CreateCaravanShell(base) end,
    [9] = function(base) return exports['qb-interior']:CreateContainer(base) end,
    [10] = function(base) return exports['qb-interior']:CreateFurniMid(base) end,
    [11] = function(base) return exports['qb-interior']:CreateFurniMotelModern(base) end,
    [12] = function(base) return exports['qb-interior']:CreateGarageMed(base) end,
    [13] = function(base) return exports['qb-interior']:CreateOffice1(base) end,
    [14] = function(base) return exports['qb-interior']:CreateStore1(base) end,
    [15] = function(base) return exports['qb-interior']:CreateWarehouse1(base) end,
    [16] = function(base) return exports['qb-interior']:CreateApartmentShell(base) end,
    [17] = function(base) return exports['qb-interior']:furnshell1(base) end,
    [18] = function(base) return exports['qb-interior']:furnshell2(base) end,
    [19] = function(base) return exports['qb-interior']:furnshell3(base) end,
    [20] = function(base) return exports['qb-interior']:unfurnshell1(base) end,
    [21] = function(base) return exports['qb-interior']:unfurnshell2(base) end,
    [22] = function(base) return exports['qb-interior']:unfurnshell3(base) end,
}


local function SpawnShellForProperty(prop)
    if not prop or not prop.shell_id then return nil, nil, nil end

    local shellId = tonumber(prop.shell_id)
    local shellBase = Config.ShellBase or vector3(1000.0, -1000.0, 1000.0)
    local base = vector3(
        shellBase.x + (prop.id * 100.0),
        shellBase.y,
        shellBase.z
    )
    
    print('[yg_properties] shell spawn start | propertyId=' .. tostring(prop.id) .. ' | shellId=' .. tostring(shellId))

    local ok, result = pcall(function()
        local shellFunc = shellFunctions[shellId]
        if shellFunc then
            return shellFunc(base)
        end
        return nil
    end)

    if not ok then
        print('[yg_properties] shell spawn pcall failed: ' .. tostring(result))
        return nil, nil, nil
    end

    if type(result) ~= 'table' then
        print('[yg_properties] shell result invalid')
        return nil, nil, nil
    end

    local shellObjects = result[1]
    local offsets = result[2]

    return shellObjects, offsets, base
end

local function DespawnCurrentShell(cb)
    if CurrentShellObjects then
        exports['qb-interior']:DespawnInterior(CurrentShellObjects, function()
            CurrentShellObjects = nil
            CurrentShellOffsets = nil
            CurrentShellBase = nil
            if cb then cb() end
        end)
    else
        CurrentShellOffsets = nil
        CurrentShellBase = nil
        if cb then cb() end
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

local function beginEnterEffects(propertyId)
    pendingEnterPropertyId = tonumber(propertyId)
    unfreezeTimeoutAt = GetGameTimer() + 10000
    fadeOut(250)
    freezePlayer(true)
end

local function endEnterEffects(propertyId)
    propertyId = tonumber(propertyId)
    if pendingEnterPropertyId and propertyId == pendingEnterPropertyId then
        pendingEnterPropertyId = nil
        unfreezeTimeoutAt = 0
        freezePlayer(false)
        fadeIn(250)
    end
end

AddEventHandler('yg_properties:client:objectsLoaded', function(propertyId, count)
    endEnterEffects(propertyId)
end)

CreateThread(function()
    while true do
        if pendingEnterPropertyId and unfreezeTimeoutAt > 0 and GetGameTimer() > unfreezeTimeoutAt then
            pendingEnterPropertyId = nil
            unfreezeTimeoutAt = 0
            freezePlayer(false)
            fadeIn(250)
        end
        Wait(250)
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
-- Door target + marker (DIŞARISI)
-- ======================
local createdTargets = {}
local doorMarkers = {}
local lastDoorRebuild = 0

local function clearDoorTargets()
    for _, t in ipairs(createdTargets) do
        if Bridge and Bridge.RemoveZone then
            Bridge.RemoveZone(t)
        else
            pcall(function() exports.ox_target:removeZone(t) end)
        end
    end
    createdTargets = {}
    doorMarkers = {}
end

local function makeDoorOptions(prop)
    local opts = {
        {
            name = ('yg_prop_enter_%s'):format(prop.id),
            icon = 'fa-solid fa-door-open',
            label = 'İçeri Gir',
            onSelect = function()
                TriggerEvent('yg_properties:client:enter', prop.id)
            end
        },
        {
            name = ('yg_prop_info_%s'):format(prop.id),
            icon = 'fa-solid fa-circle-info',
            label = 'Mekan Bilgisi',
            onSelect = function()
                TriggerEvent('yg_properties:client:showInfo', prop.id)
            end
        }
    }

    if not prop.owner_citizenid or prop.owner_citizenid == '' then
        opts[#opts + 1] = {
            name = ('yg_prop_buy_%s'):format(prop.id),
            icon = 'fa-solid fa-cart-shopping',
            label = 'Satın Al',
            onSelect = function()
                TriggerEvent('yg_properties:client:buy', prop.id)
            end
        }

        if Config.Ownership and Config.Ownership.allowRent and (tonumber(prop.rent_price) or 0) > 0 then
            opts[#opts + 1] = {
                name = ('yg_prop_rent_%s'):format(prop.id),
                icon = 'fa-solid fa-key',
                label = ('Kirala ($%s)'):format(Utils.money(prop.rent_price or 0)),
                onSelect = function()
                    TriggerEvent('yg_properties:client:rent', prop.id)
                end
            }
        end
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
                entry_fee = tonumber(prop.entry_fee) or 0,
                rent_price = tonumber(prop.rent_price) or 0
            }

            if Config.Interaction and Config.Interaction.mode == 'target' and Bridge and Bridge.AddDoorTarget and Bridge.target then
                local zoneId = Bridge.AddDoorTarget(prop.id, door, makeDoorOptions(prop))
                if zoneId then
                    table.insert(createdTargets, zoneId)
                end
            end
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

        if prop.interior_spawn and prop.interior_spawn ~= '' then
            local spawn = Shared.DecodeVec4(prop.interior_spawn)
            createInteriorZone(propertyId, { x = spawn.x, y = spawn.y, z = spawn.z })
        else
            local door = Shared.DecodeVec4(prop.door_coords)
            createInteriorZone(propertyId, { x = door.x, y = door.y, z = door.z })
        end
    end
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    RefreshProperties()
    RebuildDoorTargets()
end)

AddEventHandler('yg_properties:client:targetReady', function()
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
                        if Config.Ownership and Config.Ownership.allowRent and tonumber(m.rent_price or 0) > 0 then
                            lines[#lines + 1] = ('~w~Kira:~s~ ~g~$%s~s~'):format(CashFmt(m.rent_price))
                        end
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

local function teleportRaw(vec4)
    SetEntityCoordsNoOffset(PlayerPedId(), vec4.x, vec4.y, vec4.z, false, false, false)
    SetEntityHeading(PlayerPedId(), vec4.w or 0.0)
end

local function removeInteriorZone()
    if InteriorZoneId then
        pcall(function()
            if Bridge and Bridge.RemoveZone then
                Bridge.RemoveZone(InteriorZoneId)
            else
                exports.ox_target:removeZone(InteriorZoneId)
            end
        end)
        InteriorZoneId = nil
    end
    InteriorMarkerCoords = nil
end

function createInteriorZone(propertyId, coords)
    if type(coords) ~= 'table' or coords.x == nil or coords.y == nil or coords.z == nil then
        return
    end

    removeInteriorZone()

    InteriorMarkerCoords = {
        x = coords.x + 0.0,
        y = coords.y + 0.0,
        z = coords.z + 0.0
    }

    local v3 = vec3(InteriorMarkerCoords.x, InteriorMarkerCoords.y, InteriorMarkerCoords.z)

    local ok, zoneId = pcall(function()
        if Bridge and Bridge.AddSphereZone and Bridge.target then
            return Bridge.AddSphereZone(('yg_prop_exit_%s'):format(propertyId), { x = v3.x, y = v3.y, z = v3.z }, 2.0, {
                {
                    name = ('yg_prop_exit_%s'):format(propertyId),
                    icon = 'fa-solid fa-door-closed',
                    label = 'Dışarı Çık',
                    onSelect = function()
                        TriggerEvent('yg_properties:client:exit')
                    end
                }
            })
        end

        return exports.ox_target:addSphereZone({
            coords = v3,
            radius = 2.0,
            debug = Config.Debug or false,
            options = {
                {
                    name = ('yg_prop_exit_%s'):format(propertyId),
                    icon = 'fa-solid fa-door-closed',
                    label = 'Dışarı Çık',
                    onSelect = function()
                        TriggerEvent('yg_properties:client:exit')
                    end
                }
            }
        })
    end)

    if ok and zoneId then
        InteriorZoneId = zoneId
    end
end

-- ✅ OPTİMİZASYON: Conditional marker drawing
CreateThread(function()
    while true do
        local c = InteriorMarkerCoords
        if LocalPlayer.state.ygPropertyId ~= nil and type(c) == 'table' and c.x ~= nil and c.y ~= nil and c.z ~= nil then
            Wait(0)
            DrawMarker(2, c.x, c.y, c.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 0, 0, 180, false, true, 2, false, nil, nil, false)
        else
            Wait(500)
        end
    end
end)

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
        lib.notify({ type = 'error', description = 'Kilitli.' })
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

    if prop.shell_id then
        local shellObjects, offsets, base = SpawnShellForProperty(prop)
        if not shellObjects or not offsets or not base then
            TriggerServerEvent('yg_properties:server:exitBucket')
            LocalPlayer.state.ygPropertyId = nil
            LocalPlayer.state.ygCurrentProperty = nil
            SetCurrentProperty(nil)
            endEnterEffects(propertyId)
            lib.notify({ type = 'error', description = 'Shell oluşturulamadı.' })
            return
        end

        local exitPos = offsets.exit or offsets.Exit or offsets.exitPos
        if not exitPos then
            print('[yg_properties] shell exit bulunamadı')
            print('[yg_properties] offsets dump: ' .. json.encode(offsets))

            TriggerServerEvent('yg_properties:server:exitBucket')
            LocalPlayer.state.ygPropertyId = nil
            LocalPlayer.state.ygCurrentProperty = nil
            SetCurrentProperty(nil)
            endEnterEffects(propertyId)
            lib.notify({ type = 'error', description = 'Shell exit verisi bulunamadı.' })
            return
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

    LoadObjectsForCurrent()
    TriggerEvent('yg_properties:client:syncMusic', propertyId)
    lib.notify({ type = 'success', description = 'İçeri girdin.' })
end)

RegisterNetEvent('yg_properties:client:exit', function()
    ClearObjectsAndBuilder()

    local prop = GetCurrentProperty()
    if not prop then return end

    removeInteriorZone()

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

    local label = prop.label or ('Mekan #%s'):format(propertyId)
    local desc = prop.description or ''
    if desc == '' then desc = 'Bilgi girilmemiş.' end

    local lines = {}
    lines[#lines + 1] = ('**Tür:** %s'):format(prop.type == 'business' and 'İş Yeri' or 'Ev')
    lines[#lines + 1] = ('**Kilit:** %s'):format(IsLocked(prop.locked) and 'Kilitli' or 'Açık')

    if not prop.owner_citizenid or prop.owner_citizenid == '' then
        lines[#lines + 1] = ('**Durum:** Satılık ($%s)'):format(CashFmt(prop.price or 0))
    else
        lines[#lines + 1] = ('**Durum:** Sahipli')
    end

    if (tonumber(prop.rent_price) or 0) > 0 then
        lines[#lines + 1] = ('**Kira:** $%s'):format(CashFmt(prop.rent_price or 0))
    end

    if prop.type == 'business' then
        lines[#lines + 1] = ('**Giriş Ücreti:** $%s'):format(CashFmt(prop.entry_fee or 0))
    end

    local content = ('%s\n\n%s'):format(table.concat(lines, '\n'), desc)

    lib.alertDialog({
        header = label,
        content = content,
        centered = true,
        cancel = true
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

RegisterNetEvent('yg_properties:client:rent', function(propertyId)
    local ok, reason = lib.callback.await('yg_properties:server:rentProperty', false, propertyId)
    if ok then
        lib.notify({ type = 'success', description = 'Mülk kiralandı.' })
        RefreshProperties()
        RebuildDoorTargets()
    else
        lib.notify({ type = 'error', description = ('Kiralanamadı: %s'):format(reason) })
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

RegisterNetEvent('yg_properties:client:openPanel', function(propertyId)
    local prop = lib.callback.await('yg_properties:server:getProperty', false, propertyId)
    if not prop then return end

    if not prop.owner_citizenid or prop.owner_citizenid == '' then
        lib.notify({ type = 'error', description = 'Bu mekan satın alınmamış. Panel açılamaz.' })
        return
    end

    if LocalPlayer.state.ygPropertyId ~= propertyId then
        lib.notify({ type = 'error', description = 'Panel için mekana girmen lazım.' })
        return
    end

    local canManage = lib.callback.await('yg_properties:server:canManage', false, propertyId)
    if not canManage then
        lib.notify({ type = 'error', description = 'Bu panel için yetkin yok.' })
        return
    end

    local manageData = lib.callback.await('yg_properties:server:getManagementData', false, propertyId)
    if not manageData then
        lib.notify({ type = 'error', description = 'Yönetim verisi alınamadı.' })
        return
    end

    local myCid = MyCitizenId()
    local amOwner = (myCid and manageData.owner_citizenid == myCid)
    local perms = manageData.permissions or {}
    local gradeRights = manageData.business_rights or {}
    local employeeCount = 0

    for _ in pairs(manageData.employees or {}) do
        employeeCount = employeeCount + 1
    end

    local canDoor = amOwner or perms.employeesCanManageDoor or gradeRights.canLock
    local canEntryFee = amOwner or perms.employeesCanSetEntryFee or gradeRights.canManageStaff
    local canDesc = amOwner or perms.employeesCanEditDescription or gradeRights.canManageStaff
    local canDeposit = amOwner or perms.employeesCanDeposit or gradeRights.canManageStash
    local canWithdraw = amOwner or perms.employeesCanWithdraw or gradeRights.canManageStaff
    local canManageEmployees = amOwner or perms.employeesCanManageEmployees or gradeRights.canManageStaff

    local options = {}

    options[#options + 1] = {
        title = ('Kasa Bakiyesi: $%s'):format(CashFmt(manageData.stash_money or 0)),
        description = ('Çalışan sayısı: %s'):format(employeeCount),
        readOnly = true
    }

    options[#options + 1] = {
        title = ('Mekan Adını Değiştir (Şu an: %s)'):format(prop.label or ''),
        onSelect = function()
            local input = lib.inputDialog('Mekan Adı', {
                { type = 'input', label = 'Ad', required = true, default = prop.label or '' }
            })
            if not input then return end
            TriggerServerEvent('yg_properties:server:setLabel', propertyId, input[1])
            lib.notify({ type = 'success', description = 'Mekan adı güncellendi.' })
        end
    }

    options[#options + 1] = {
        title = 'Stash\'ı Aç',
        description = 'Mülk stash inventory\'sini aç',
        onSelect = function()
            TriggerServerEvent('yg_properties:server:openStash', propertyId)
        end
    }

    if canDesc then
        options[#options + 1] = {
            title = 'Mekan Bilgisi / Açıklama Ayarla',
            description = 'Kapıda "Mekan Bilgisi"nden görünür.',
            onSelect = function()
                local input = lib.inputDialog('Mekan Açıklaması', {
                    { type = 'input', label = 'Açıklama', required = false, default = prop.description or '' }
                })
                if not input then return end
                TriggerServerEvent('yg_properties:server:setDescription', propertyId, input[1] or '')
                lib.notify({ type = 'success', description = 'Açıklama güncellendi.' })
            end
        }
    end

    options[#options + 1] = {
        title = 'Çıkış/Spawn Noktasını Buraya Taşı (İç Marker)',
        description = 'İçerideki çıkış target + marker yerini değiştirir.',
        onSelect = function()
            if LocalPlayer.state.ygPropertyId ~= propertyId then
                lib.notify({ type = 'error', description = 'Bunu yapmak için önce bu mekana girmen lazım.' })
                return
            end

            local c = GetEntityCoords(PlayerPedId())
            local h = GetEntityHeading(PlayerPedId())
            local enc = Shared.EncodeVec4(vector4(c.x, c.y, c.z, h))

            local ok = lib.callback.await('yg_properties:server:setInteriorSpawnHere', false, propertyId, enc)
            if not ok then
                lib.notify({ type = 'error', description = 'Sadece sahip çıkış/spawn noktasını taşıyabilir.' })
                return
            end

            createInteriorZone(propertyId, { x = c.x, y = c.y, z = c.z })

            local cur = GetCurrentProperty()
            if cur then
                cur.interior_spawn = enc
            end

            lib.notify({ type = 'success', description = 'Çıkış/spawn noktası taşındı.' })
        end
    }

    if canDoor then
        options[#options + 1] = {
            title = IsLocked(prop.locked) and '🔓 Kilidi AÇ' or '🔒 Kilidi KAPAT',
            description = IsLocked(prop.locked) and 'Şu an kilitli, herkes giremez.' or 'Şu an açık, herkes girebilir.',
            onSelect = function()
                local currentStatus = IsLocked(prop.locked)
                local newStatus = not currentStatus

                TriggerServerEvent('yg_properties:server:setLocked', propertyId, newStatus)

                prop.locked = newStatus and 1 or 0
                TriggerEvent('yg_properties:client:openPanel', propertyId)
            end
        }
    end

    if isBusiness(prop) and canEntryFee then
        options[#options + 1] = {
            title = ('Giriş Ücreti Ayarla (Şu an: $%s)'):format(CashFmt(prop.entry_fee or 0)),
            onSelect = function()
                local input = lib.inputDialog('Giriş Ücreti', {
                    { type = 'number', label = 'Ücret', default = tonumber(prop.entry_fee or 0) }
                })
                if not input then return end
                TriggerServerEvent('yg_properties:server:setEntryFee', propertyId, tonumber(input[1]) or 0)
                lib.notify({ type = 'success', description = 'Giriş ücreti ayarlandı.' })
            end
        }
    end

    if canDeposit then
        options[#options + 1] = {
            title = 'Kasaya Para Koy',
            description = ('Mevcut bakiye: $%s'):format(CashFmt(manageData.stash_money or 0)),
            onSelect = function()
                local input = lib.inputDialog('Kasaya Para Koy', {
                    { type = 'number', label = 'Miktar', required = true, min = 1 }
                })
                if not input then return end
                TriggerServerEvent('yg_properties:server:depositSafeMoney', propertyId, tonumber(input[1]) or 0)
            end
        }
    end

    if canWithdraw then
        options[#options + 1] = {
            title = 'Kasadan Para Çek',
            description = ('Mevcut bakiye: $%s'):format(CashFmt(manageData.stash_money or 0)),
            onSelect = function()
                local input = lib.inputDialog('Kasadan Para Çek', {
                    { type = 'number', label = 'Miktar', required = true, min = 1 }
                })
                if not input then return end
                TriggerServerEvent('yg_properties:server:withdrawSafeMoney', propertyId, tonumber(input[1]) or 0)
            end
        }
    end

    if canManageEmployees then
        options[#options + 1] = {
            title = 'Çalışan Ekle',
            description = 'CitizenID ile çalışan ekle',
            onSelect = function()
                local input = lib.inputDialog('Çalışan Ekle', {
                    { type = 'input', label = 'CitizenID', required = true }
                })
                if not input then return end
                TriggerServerEvent('yg_properties:server:addEmployee', propertyId, input[1])
            end
        }

        options[#options + 1] = {
            title = 'Çalışan Çıkar',
            description = 'Listeden çalışan çıkar',
            onSelect = function()
                local employeeOptions = {}

                for empCid, _ in pairs(manageData.employees or {}) do
                    employeeOptions[#employeeOptions + 1] = {
                        title = empCid,
                        onSelect = function()
                            TriggerServerEvent('yg_properties:server:removeEmployee', propertyId, empCid)
                        end
                    }
                end

                if #employeeOptions == 0 then
                    lib.notify({ type = 'error', description = 'Çalışan yok.' })
                    return
                end

                lib.registerContext({
                    id = 'yg_employee_remove_menu',
                    title = 'Çalışan Çıkar',
                    options = employeeOptions
                })
                lib.showContext('yg_employee_remove_menu')
            end
        }
    end

    if amOwner then
        options[#options + 1] = {
            title = 'Çalışan Yetkileri',
            description = 'Çalışanların genel izinlerini aç/kapat',
            onSelect = function()
                local p = manageData.permissions or {}

                local input = lib.inputDialog('Çalışan Yetkileri', {
                    { type = 'checkbox', label = 'İçeri girebilsin', checked = p.employeesCanEnter == true },
                    { type = 'checkbox', label = 'Panel açabilsin', checked = p.employeesCanManage == true },
                    { type = 'checkbox', label = 'Kilidi yönetebilsin', checked = p.employeesCanManageDoor == true },
                    { type = 'checkbox', label = 'Giriş ücreti ayarlayabilsin', checked = p.employeesCanSetEntryFee == true },
                    { type = 'checkbox', label = 'Açıklama düzenleyebilsin', checked = p.employeesCanEditDescription == true },
                    { type = 'checkbox', label = 'Build/dekor yapabilsin', checked = p.employeesCanBuild == true },
                    { type = 'checkbox', label = 'Kasaya para koyabilsin', checked = p.employeesCanDeposit == true },
                    { type = 'checkbox', label = 'Kasadan para çekebilsin', checked = p.employeesCanWithdraw == true },
                    { type = 'checkbox', label = 'Çalışan yönetebilsin', checked = p.employeesCanManageEmployees == true }
                })

                if not input then return end

                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanEnter', input[1] == true)
                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanManage', input[2] == true)
                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanManageDoor', input[3] == true)
                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanSetEntryFee', input[4] == true)
                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanEditDescription', input[5] == true)
                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanBuild', input[6] == true)
                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanDeposit', input[7] == true)
                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanWithdraw', input[8] == true)
                TriggerServerEvent('yg_properties:server:setPermission', propertyId, 'employeesCanManageEmployees', input[9] == true)

                lib.notify({ type = 'success', description = 'Yetkiler güncellendi.' })
            end
        }
    end

    options[#options + 1] = {
        title = 'Anahtar Yönetimi',
        description = 'Mülk anahtarlarını ver / geri al',
        onSelect = function()
            TriggerEvent('yg_properties:client:openKeysMenu', propertyId)
        end
    }

    if isBusiness(prop) then
        options[#options + 1] = {
            title = 'Çalışan Grade / Maaş Yönetimi',
            description = 'İşe al, çıkar, grade ve maaş düzenle',
            onSelect = function()
                TriggerEvent('yg_properties:client:openBusinessStaffMenu', propertyId)
            end
        }
    end

    options[#options + 1] = {
        title = 'Depo Noktası Yerleştir',
        description = 'Dünya üzerinde erişilebilir depo noktası oluştur',
        onSelect = function()
            TriggerEvent('yg_properties:client:startPlaceAccessPoint', propertyId, 'storage')
        end
    }

    options[#options + 1] = {
        title = 'Dolap Noktası Yerleştir',
        description = 'Kıyafet / dolap erişim noktası oluştur',
        onSelect = function()
            TriggerEvent('yg_properties:client:startPlaceAccessPoint', propertyId, 'wardrobe')
        end
    }

    if isBusiness(prop) then
        options[#options + 1] = {
            title = 'Kasa Noktası Yerleştir',
            description = 'İşletme kasası erişim noktası oluştur',
            onSelect = function()
                TriggerEvent('yg_properties:client:startPlaceAccessPoint', propertyId, 'safe')
            end
        }
    end

    if amOwner then
        options[#options + 1] = {
            title = tostring(prop.tenure or '') == 'rent' and 'Kiralamayı Sonlandır' or 'Mülkü Sat / Bırak',
            description = 'Mülkü tekrar satışa çıkar',
            onSelect = function()
                TriggerServerEvent('yg_properties:server:sellProperty', propertyId)
            end
        }
    end

    options[#options + 1] = {
        title = 'Build Editor (Dekor / Yapı)',
        description = 'Duvar/tavan/masa/sandalye yerleştir',
        onSelect = function()
            TriggerEvent('yg_properties:client:openBuildEditor')
        end
    }

    options[#options + 1] = {
        title = 'Mekandaki Objeler (Düzenle / Sil)',
        description = 'Yerleştirilen objeleri listeden yönet',
        onSelect = function()
            TriggerEvent('yg_properties:client:openObjectManager')
        end
    }

    lib.registerContext({
        id = 'yg_owner_panel',
        title = ('Patron Paneli - #%s'):format(propertyId),
        options = options
    })

    lib.showContext('yg_owner_panel')
end)

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    removeInteriorZone()
    clearDoorTargets()
    ClearObjectsAndBuilder()
    DespawnCurrentShell()
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