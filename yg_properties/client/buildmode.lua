--[[
  yg_properties — BUILD MODU (freecam + raycast + grid-snap)
  ============================================================
  Sadece "Ev İnşa (Duvar & Zemin)" kategorisi için (her obje kendi
  structKind='wall'/'floor' etiketiyle ayrışıyor; katalogda olmayan
  ÖZEL modeller için boyut sezgisi: basıksa zemin, değilse duvar)
  için — gizmo'nun YANINDA duran, AYRI bir hızlı-inşa modu. Mantık:

    1) Oyuncu donuyor, kamera serbestleşiyor (freecam) — WASD ile uçar,
       fare ile bakar.
    2) Her karede kameranın baktığı yöne bir RAYCAST atılıyor.
    3) Raycast, DAHA ÖNCE BU SİSTEMLE yerleştirilmiş bir duvar/zemin
       parçasına çarparsa: yeni obje o parçanın GERÇEK boyutuna göre
       (GetModelDimensions — tahmin değil) tam kenarına, boşluksuz
       oturuyor (hangi yüzeye baktığına göre sağ/sol/üst/alt).
       ✅ KÖŞE DÖNÜŞÜ: bir duvarın ORTASINA değil de UCUNA/köşesine
       bakıyorsan, sistem bunu otomatik ALGILAR — o anda [R]'ye basarsan
       yeni duvar TAM O KÖŞE NOKTASINDAN başlayıp döndüğün yöne (90°/
       180°/270°) uzanır, Sims'teki gibi oda köşeleri kusursuz birleşir
       (boşluk da, üst üste binme de olmaz). [R]'ye basmazsan (aynı
       rotasyon) düz devam eder, tıpkı öncesi gibi.
    4) Hiçbir şeye çarpmazsa (boş alan/zemin): objenin konumu, mülkün
       build_origin'ine göre sabit bir GRID'e (Config.BuildGridSize)
       yuvarlanıyor.
    4b) ✅ ZEMİN/TAVAN İÇİN DUVAR-YÜKSEKLİK REFERANSI: bir odada henüz
       hiç zemin/tavan yokken (İLK parçayı koyarken), yakındaki
       DUVARLARIN gerçek yüksekliğini otomatik referans alıyoruz —
       zemin duvarın TABANINA, tavan duvarın TEPESİNE oturuyor (kameranın
       yukarı/aşağı bakmasına göre hangisi istendiği anlaşılıyor). Bu
       sayede zemin/tavan koymaya başlarken doğru yükseklikte başlıyorsun,
       tahmin etmene gerek kalmıyor.
    4c) ✅ SİMETRİĞİ: duvar koyarken de aynı şekilde — hiç duvar komşusu
       yokken (zeminin üstüne İLK duvarı başlatırken), yakındaki bir
       ZEMİN/TAVAN parçasının tepesine/altına otomatik oturuyor.
    5) SOL TIK sürükle: 3 farklı modda çalışır (orta tıkla döngü yapılır):
       - YATAY (varsayılan): parçanın kendi hizasında (sağ vektörü
         boyunca) yan yana dizer — bir duvar hattı çekmek için.
       - DİKEY: aynı XY konumunda yukarı/aşağı istifler — çok katlı ev
         ya da yüksek duvar/pencere aralıkları için.
       - ALAN: bir köşeye koyup köşegen sürükleyince aradaki 2 boyutlu
         TÜM alanı dolduruyor — zemin/tavan döşemek için.
       Kısa bir tık (sürüklemeden) her modda TEK parça koyar.
    6) [Orta Tık]: sürükleme modunu değiştirir (Yatay → Dikey → Alan →
       Yatay...) — ekran ipucu hep hangi modda olduğunu gösterir.
    7) [Fare Tekerleği]: aynı kategori içindeki modeller arasında
       freecam'den ÇIKMADAN geçiş yapar.
    8) [H]: hayaleti YATAY YASLAR (0°→90°→180°→270°, devirerek) — bir
       DUVARI bile yatay yaslayıp zemin/tavan olarak kullanabilirsin,
       tek bir "doğru açı" olmadığı için devirerek gözle buluyorsun.
    9) [R]: elle 90° ekstra döndürme / otomatik köşe tahmini yanlışsa düzeltme.
    10) Backspace/Esc: modu tamamen kapatır, kamerayı/kontrolü geri verir.
    11) ✅ EKLENDİ — OTOMATİK KÖŞE HİZALAMA: köşe/uç algılandığında artık
       [R]'ye BASMADAN da otomatik döner — kameranın bakış yönü, duvarın
       kendi ekseninden 90°/270° farklıysa (yani gerçekten köşeyi dönmek
       istiyorsan) sistem bunu kendisi anlar ve doğru açıyla köşeye
       oturtur (T-bağlantısı/köşe otomatik). [R] hâlâ ince ayar için durur.
    12) ✅ EKLENDİ — SİMS KAMERASI: [V] ile Serbest (freecam) ↔ Kuşbakışı
       (top-down, WASD ile pan + Space/Ctrl ile yaklaş/uzaklaş) ↔ Döner
       (orbit, fare ile mülkün etrafında dönme + WASD ile odak kaydırma)
       arasında döngü yapılır.
    13) ✅ EKLENDİ — ÇOKLU KAT: [Yukarı Ok]/[Aşağı Ok] ile bodrum/zemin/1./2.
       kat arasında geçilir; her kat Config.FloorHeight kadar kayar, yeni
       parçalar aktif kata (metadata.floor) kaydedilir ve build modunda
       SADECE aktif kattaki parçalar görünür kalır (diğerleri gizlenir).
       Kat değiştirirken bir parçaya bakıyorsan, yeni kat o parçanın
       GERÇEK üst/alt yüzeyine TAM hizalanır (genel bir tahmin yerine).

  NOT: Bu, gizmo'nun YERİNE GEÇMİYOR — sadece bu 2 kategori için NUI'de
  ayrı bir "Build" sekmesinden başlatılıyor, diğer her şey (mobilya,
  dekor) hâlâ normal gizmo akışını kullanıyor.
]]

local Build = {
    active = false,
    cam = nil,
    model = nil,
    hash = nil,
    ghost = nil,
    yaw = 0.0,
    pitch = 0.0,
    extraYaw = 0.0, -- [R] ile eklenen manuel döndürme
    flattenStep = 0, -- [H] ile eklenen manuel EĞME (0/90/180/270°) — duvarı yatay yaslayıp zemin/tavan olarak kullanmak için
    deleteMode = false, -- [Sağ Tık] ile açılıp kapanan silme modu
    lookedAtEntity = nil, -- silme modunda: şu an bakılan (silinebilir) obje
    camPos = nil,
    propertyId = nil,
    gridOrigin = nil,
    lastTarget = nil, -- { x,y,z, rx,ry,rz } — en son hesaplanan (geçerli) hedef
    count = 0,        -- mevcut obje sayısı (limit göstergesi için)
    limit = 300,
    -- sürükleme durumu
    dragging = false,
    dragMode = 'line', -- 'line' (yatay) | 'vertical' (dikey) | 'rect' (alan) — orta tık TIKLAMASIYLA döngü yapar
    dragStart = nil,  -- sürüklemenin başladığı andaki lastTarget
    dragGhosts = {},  -- önizleme için ekstra hayalet objeler
    -- fare tekerleği model listesi
    modelList = {},
    modelIndex = 1,

    -- ✅ EKLENDİ: Sims Kamerası — 'free' (serbest/freecam, varsayılan) |
    -- 'topdown' (kuşbakışı) | 'orbit' (mülk etrafında döner). [V] ile
    -- döngü yapılır (aşağıdaki yg_buildCycleCamera keybind'i).
    camMode = 'free',
    orbitTarget = nil,  -- döner kamerada odaklanılan nokta (vector3)
    orbitYaw = 0.0,      -- döner kamera: hedefin etrafındaki açı
    orbitPitch = -35.0,  -- döner kamera: yukarı/aşağı açı
    orbitDist = nil,     -- döner kamera: hedefe uzaklık
    cursorAimMode = false, -- ✅ EKLENDİ: [C] ile açılır — döner kamerada AÇIKKEN, imlecin ekrandaki konumu nişan noktası olur (KuzQuality tarzı "her yere tıkla")
    -- ✅ EKLENDİ: ODA SİHİRBAZI — [G] basılı tut + sürükle: 2 köşe
    -- arasındaki DİKDÖRTGENİN 4 DUVARINI tek seferde, otomatik köşe
    -- birleşimiyle üretir. Tek tek duvar dizmenin en yorucu kısmını
    -- (bir odanın tüm çevresini el yordamıyla kapatmak) tamamen ortadan
    -- kaldırıyor.
    roomWizardActive = false,
    roomWizardStart = nil,   -- {x,y,z} — G'ye basıldığı andaki hedef nokta
    roomWizardGhosts = {},   -- önizleme hayaletleri
    topDownHeight = nil, -- kuşbakışı kamera yüksekliği

    -- ✅ EKLENDİ: Çoklu Kat — aktif kat (0 = zemin, -1 = bodrum, 1/2 = üst
    -- katlar). [Yukarı Ok]/[Aşağı Ok] ile değiştirilir; her kat, objeleri
    -- Config.FloorHeight kadar yukarı/aşağı kaydırır ve diğer kattaki
    -- objeleri (görüşü engellemesin diye) build sırasında gizler.
    floor = 0,
    -- ✅ EKLENDİ: bakılan parçaya göre TAM hizalanan kat geçişi — kat
    -- değiştirilirken o an baktığın bir parça varsa, o katın Z referansı
    -- Config.FloorHeight'ın genel (sabit) tahmini yerine, doğrudan o
    -- parçanın GERÇEK üst/alt yüzeyine göre kaydediliyor (aşağıdaki
    -- floorZOverrides). Böylece "yukarı ok'a basınca tam onun üstüne
    -- çıkması" isteği karşılanıyor.
    floorZOverrides = {},
}

local MOVE_SPEED = 6.0 -- saniyede metre
local LOOK_SENS = 3.5
local RAY_DISTANCE = 40.0
local FILL_MAX_CELLS = 150 -- alan doldurmada güvenlik sınırı

-- ✅ EKLENDİ: Çoklu Kat — grid'e oturtma her zaman Build.gridOrigin'i
-- KULLANMAK yerine, aktif kata göre Z'de kaydırılmış bir origin
-- kullanıyor. Böylece 1. kat inşa ederken boş alana konan ilk parça,
-- zemin kattaki origin'in DEĞİL, o katın kendi tabanının hizasına oturur.
-- ✅ DEĞİŞTİ: Build.floorZOverrides[floor] set edilmişse (bkz. changeFloor
-- — kat değişirken bakılan bir parça varsa) o KESİN Z değeri kullanılıyor;
-- yoksa eskisi gibi Config.FloorHeight'a göre sabit bir tahmine düşülüyor.
local function currentGridOrigin()
    local base = Build.gridOrigin or vector3(0, 0, 0)
    local floorH = Config.FloorHeight or 3.0
    local override = Build.floorZOverrides and Build.floorZOverrides[Build.floor or 0]
    local z = override or (base.z + (Build.floor or 0) * floorH)
    return vector3(base.x, base.y, z)
end

-- ✅ EKLENDİ: iki parça TAM matematiksel kenarda (yarı-genişlik + yarı-
-- genişlik) birleştirildiğinde bile, model kenarlarındaki küçük pah/
-- yuvarlatma yüzünden gözle görülür ince bir çizgi/boşluk kalabiliyordu.
-- Bu payı biraz İÇERİ çekip hafif bindirme yapıyoruz — "bir tık daha
-- yakın" isteği + boşluk hiç görünmesin isteği ikisi de bununla çözülüyor.
local OVERLAP_FUDGE = 0.03 -- metre

-- builder.lua/edit.lua'daki AYNI mantık (Lua local'leri dosyalar arası
-- paylaşılmıyor, o yüzden burada da küçük bir kopyası var).
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

-- Sürükleyerek yerleştirme / fare tekerleği için: BUILD modunda
-- kullanılabilecek tüm yapı kategorisi modellerinin DÜZ listesi.
local function buildModelList()
    local list = {}
    for _, cat in ipairs(Config.BuildCatalog or {}) do
        if Config.StructureCategories and Config.StructureCategories[cat.category] then
            for _, item in ipairs(cat.items or {}) do
                list[#list + 1] = item.model
            end
        end
    end
    return list
end

-- Mevcut mekanda, BU SİSTEMLE (yapı kategorisi) yerleştirilmiş objeler
-- arasından hitEnt'i arıyor — yani raycast'in "bir duvara çarptım"
-- dediği entity gerçekten yapı kategorisinden mi, yoksa bir sandalye/
-- lamba mı, ayırt ediyoruz (sadece yapı parçalarına otomatik yapışsın).
-- ✅ BUG DÜZELTİLDİ: eskiden bu fonksiyon, entity'nin spawned tabloda
-- olup olmadığını kontrol ettikten SONRA modelinin Config.BuildCatalog'da
-- kayıtlı bir yapı kategorisinde olup olmadığını DA kontrol ediyordu —
-- ama "Özel model kodu" ile yerleştirilen modeller (Build.model artık
-- katalog dışı da olabiliyor) katalogda HİÇ yok, o yüzden ikinci
-- kontrolde eleniyorlardı. "Silinecek bir parçaya bakmıyorsun" hatası
-- ve attach (mevcut objeye yapış) özelliğinin özel modellerde çalışmaması
-- buradan geliyordu. Artık SADECE "bu obje bu mülkte GERÇEKTEN
-- yerleştirilmiş mi" kontrolü yapılıyor — model kataloglu olsun olmasın.
local function isTrackedStructureEntity(ent)
    if not ent or ent == 0 then return false end
    local ok, spawned = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    if not ok or not spawned then return false end
    for _, spawnedEnt in pairs(spawned) do
        if spawnedEnt == ent then return true end
    end
    return false
end

-- ✅ EKLENDİ: "daha sert yapışma" isteği için — raycast DİREKT bir
-- objeye çarpmasa bile (örn. hafif yana bakıyorsan, ya da zemine
-- bakıyorsan), hedef noktaya YAKIN (PROXIMITY_SNAP_RADIUS içinde) daha
-- önce yerleştirilmiş bir yapı parçası varsa ONU buluyoruz. Bu, boş
-- alana/grid'e düşmeyi ZORLAŞTIRIP, mevcut parçalara yapışmayı NEREDEYSE
-- ZORUNLU hale getiriyor.
local PROXIMITY_SNAP_RADIUS = 2.5
local function findNearestTrackedEntity(point, maxDist)
    local ok, spawned = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    if not ok or not spawned then return nil end
    local nearest, nearestDist = nil, maxDist or PROXIMITY_SNAP_RADIUS
    for _, ent in pairs(spawned) do
        if DoesEntityExist(ent) then
            local c = GetEntityCoords(ent)
            local d = #(point - c)
            if d < nearestDist then
                nearest, nearestDist = ent, d
            end
        end
    end
    return nearest
end

-- Silme modu için: bir entity'nin DB'deki obje ID'sini bulur (spawned
-- tablosu [id]=entity şeklinde, biz tersine arıyoruz).
local function findObjectIdForEntity(ent)
    if not ent or ent == 0 then return nil end
    local ok, spawned = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    if not ok or not spawned then return nil end
    for id, spawnedEnt in pairs(spawned) do
        if spawnedEnt == ent then return id end
    end
    return nil
end

-- ✅ DEĞİŞTİ (KRİTİK): config artık TEK kategori ('Ev İnşa (Duvar &
-- Zemin)') + her objede structKind='wall'/'floor' etiketi kullanıyor —
-- ama bu dosya hâlâ ESKİ kategori adlarını ('Duvar / Panel / Çit' vb.)
-- arıyordu. Config'te o adlar artık HİÇ olmadığı için categoryMatches
-- her zaman false dönüyor, yapışma/köşe/yükseklik-referansı sistemleri
-- HİÇ devreye girmiyordu — her şey 3.0m grid'e düşüyordu (taşma/boşluk
-- şikayetinin ana kaynağı). Artık structKind'e bakıyoruz.
--
-- ✅ CUSTOM PROP DESTEĞİ: katalogda OLMAYAN modeller (Özel model kodu
-- ile yerleştirilenler) için boyut SEZGİSİ kullanıyoruz — yüksekliği,
-- taban uzunluğunun %35'inden azsa "zemin", değilse "duvar" sayılır.
-- Böylece custom prop'lar da akıllı sisteme tam dahil oluyor.
local function structKindFromDims(dim)
    if dim.z < 0.35 * math.max(dim.x, dim.y) then return 'floor' end
    return 'wall'
end

local function getStructKindForModel(model)
    for _, cat in ipairs(Config.BuildCatalog or {}) do
        for _, item in ipairs(cat.items or {}) do
            if item.model == model then
                if item.structKind then return item.structKind end
                break
            end
        end
    end
    -- katalogda yok ya da etiketi yok -> boyut sezgisi (getRealDimensions
    -- aşağıda tanımlı; Lua'da çağrı ANINDA çözüldüğü için sorun değil)
    local hash = joaat(model)
    local mn, mx = GetModelDimensions(hash)
    if not mn or not mx then return 'wall' end
    return structKindFromDims({ x = mx.x - mn.x, y = mx.y - mn.y, z = mx.z - mn.z })
end

local function structKindOfEntity(ent)
    if not ent or ent == 0 then return nil end
    local model = GetEntityModel(ent)
    for _, cat in ipairs(Config.BuildCatalog or {}) do
        for _, item in ipairs(cat.items or {}) do
            if joaat(item.model) == model then
                if item.structKind then return item.structKind end
                break
            end
        end
    end
    local mn, mx = GetModelDimensions(model)
    if not mn or not mx then return 'wall' end
    return structKindFromDims({ x = mx.x - mn.x, y = mx.y - mn.y, z = mx.z - mn.z })
end

-- Sadece structKind='wall' olan (katalog etiketi YA DA boyut sezgisiyle)
-- yerleştirilmiş objeleri döndürür — yükseklik referansı için.
local function getSpawnedWalls()
    local walls = {}
    local ok, spawned = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    if not ok or not spawned then return walls end
    for _, ent in pairs(spawned) do
        if DoesEntityExist(ent) and structKindOfEntity(ent) == 'wall' then
            walls[#walls + 1] = ent
        end
    end
    return walls
end

-- ✅ EKLENDİ: en yakın DUVARI bulur (yatay/XY mesafeye göre, Z'yi
-- görmezden gelir — duvar hangi yükseklikte olursa olsun yakınsa bulunur)
-- — zemin/tavan koyarken YÜKSEKLİK REFERANSI olarak kullanmak için.
local function findNearestWallEntity(point, maxDist)
    local walls = getSpawnedWalls()
    local nearest, nearestDist = nil, maxDist or 3.5
    for _, ent in ipairs(walls) do
        local c = GetEntityCoords(ent)
        local dx, dy = point.x - c.x, point.y - c.y
        local d = math.sqrt(dx * dx + dy * dy)
        if d < nearestDist then
            nearest, nearestDist = ent, d
        end
    end
    return nearest
end

-- ✅ EKLENDİ: findNearestWallEntity'nin SİMETRİĞİ — duvar koyarken
-- yakında bir ZEMİN/TAVAN parçası varsa onu bulur (yükseklik referansı
-- için). Öncesinde SADECE zemin/tavan, duvarlardan referans alıyordu —
-- tersi (duvarın zeminden referans alması) hiç yoktu, bu da "zeminin
-- üstüne duvar ekleyemiyorum" şikayetinin asıl kaynağıydı.
local function findNearestFloorCeilingEntity(point, maxDist)
    local ok, spawned = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    if not ok or not spawned then return nil end
    local nearest, nearestDist = nil, maxDist or 3.5
    for _, ent in pairs(spawned) do
        -- ✅ DEĞİŞTİ: kategori adı yerine structKind (katalog etiketi ya
        -- da boyut sezgisi) — custom prop'lar da dahil.
        if DoesEntityExist(ent) and structKindOfEntity(ent) == 'floor' then
            local c = GetEntityCoords(ent)
            local dx, dy = point.x - c.x, point.y - c.y
            local d = math.sqrt(dx * dx + dy * dy)
            if d < nearestDist then nearest, nearestDist = ent, d end
        end
    end
    return nearest
end

local function getRealDimensions(hash)
    local mn, mx = GetModelDimensions(hash)
    if not mn or not mx then return vector3(1, 1, 1) end
    local w, d, h = mx.x - mn.x, mx.y - mn.y, mx.z - mn.z
    -- ✅ BUG DÜZELTİLDİ: bazı modellerde GetModelDimensions saçma
    -- (devasa) değerler döndürebiliyor (kolizyon verisi henüz tam
    -- çözülmemiş olabilir, ya da modelin kendi meta verisi bozuk) —
    -- "dev/çarpık duvar" şikayeti buradan geliyordu. İnşa parçaları
    -- için 15m'den büyük ya da 0/negatif hiçbir boyut makul değil,
    -- böyle bir durumda güvenli bir varsayılana düşüyoruz.
    if w <= 0 or w > 15 then w = 3.0 end
    if d <= 0 or d > 15 then d = 3.0 end
    if h <= 0 or h > 15 then h = 3.0 end
    return vector3(w, d, h)
end

-- ============================================================
--  HEDEF HESAPLAMA — mevcut objeye yapış (yüzeye göre) YA DA boş
--  alanda grid'e otur.
-- ============================================================
-- [H] ile yatay yaslanmış (pitch ~90°/270°) bir objenin GERÇEK dünya-
-- uzayı genişlik/derinlik/yükseklik değerlerini döner — ham (yerel,
-- döndürülmemiş) GetModelDimensions çıktısını kullanmak, yaslanmış
-- objelerde YANLIŞ boşluk/taşma hesaplarına sebep oluyordu.
local function effectiveDim(dim, pitchDeg)
    local pitchMod = math.abs(pitchDeg or 0.0) % 180
    local swapped = pitchMod > 45 and pitchMod < 135
    if swapped then
        return { x = dim.x, y = dim.z, z = dim.y }
    end
    return dim
end

-- ✅ BUG DÜZELTİLDİ (ANA ŞİKAYET): "custom proplarda yatay mod çalışmıyor,
-- duvar yana değil ARKAYA doğru büyüyor, iç içe bir sürü duvar oluşuyor".
-- Kök sebep: sistem HER YERDE yerel X eksenini "uzunluk ekseni" olarak
-- VARSAYIYORDU. GTA'nın kendi fence/barrier prop'larında bu doğru, ama
-- üçüncü parti paketler (Mouse duvarları gibi) modeli yerel Y ekseninde
-- uzun yapmış olabilir. O durumda "X kadar aralıkla X yönünde diz"
-- demek = duvarın KALINLIĞI (örn. 20cm) kadar aralıkla, kalınlık
-- yönünde (arkaya) dizmek — tam olarak gözlemlediğin iç içe yığılma.
-- Bu fonksiyon, hangi yerel eksenin (X mi Y mi) GERÇEKTEN uzun olduğuna
-- bakıp o eksenin rz'ye göre döndürülmüş dünya yönünü + gerçek uzunluğu
-- döndürüyor — model hangi konvansiyonla yapılmış olursa olsun doğru.
local function lengthAxisWorld(dim, rz)
    local rad = math.rad(rz or 0.0)
    local cosR, sinR = math.cos(rad), math.sin(rad)
    if (dim.y or 0) > (dim.x or 0) then
        return -sinR, cosR, dim.y -- yerel Y daha uzun -> "ileri" vektörü
    end
    return cosR, sinR, dim.x -- yerel X daha uzun (GTA konvansiyonu) -> "sağ" vektörü
end

-- İki modelin uzun-eksen KONVANSİYONU farklıysa (biri X-uzun, öbürü
-- Y-uzun), aynı rz ile yerleştirilen yeni parça sıraya DİK durur. Bu
-- yardımcı, gerekiyorsa rz'ye 90° ekleyerek yeni parçanın uzun eksenini
-- referans parçanın eksenine HİZALAR.
local function alignRzToAxis(newDim, baseDim, baseRz)
    local newIsYLong = (newDim.y or 0) > (newDim.x or 0)
    local baseIsYLong = (baseDim.y or 0) > (baseDim.x or 0)
    if newIsYLong ~= baseIsYLong then
        return baseRz + 90.0
    end
    return baseRz
end

-- ============================================================
--  İMLEÇ-TABANLI NİŞAN ALMA (Döner kamerada [C] ile açılıp kapanır)
--  ============================================================
--  Videodaki KuzQuality Shell Creator'daki gibi "ekranın herhangi bir
--  yerine tıkla, oraya yerleştir" sistemi. SetNuiFocus+SetNuiFocusKeepInput
--  kombinasyonu FiveM'in KENDİ motorunda bilinen, açık bir hataya sahip
--  (imleç Windows Input'ta ekran merkezine kilitleniyor — citizenfx/fivem
--  Issue #3887). Bu yüzden o native'leri KULLANMIYORUZ — bunun yerine
--  client/gizmo.lua'da ZATEN KANITLANMIŞ olan EnterCursorMode()/
--  LeaveCursorMode() (native oyun imleci, Rockstar Editor'ün kendi
--  sistemi) + GetNuiCursorPosition() ile imlecin ekran konumunu okuyup,
--  kameranın GERÇEK yön vektörlerini (GetCamMatrix — kendi trigonometri
--  hesabımızdan çıkarmak yerine motorun kendisinden okuyoruz, yanlış
--  eksen riski yok) kullanarak bir "ekrandan dünyaya" ışın hesaplıyoruz.
local function getCursorNDC()
    local x, y = GetNuiCursorPosition()
    local resX, resY = GetActiveScreenResolution()
    if not resX or resX <= 0 then resX = 1920 end
    if not resY or resY <= 0 then resY = 1080 end
    local nx = (2.0 * x / resX) - 1.0
    local ny = 1.0 - (2.0 * y / resY) -- Y ekranda aşağı artıyor, dünyada yukarı pozitif olsun diye çeviriyoruz
    return nx, ny
end

local function cursorRayDirection(cam)
    local right, forward, up = GetCamMatrix(cam)
    local fov = GetCamFov(cam)
    local resX, resY = GetActiveScreenResolution()
    if not resX or resX <= 0 then resX = 1920 end
    if not resY or resY <= 0 then resY = 1080 end
    local aspect = resX / resY

    local nx, ny = getCursorNDC()
    local tanFov = math.tan(math.rad(fov * 0.5))

    local dirX = forward.x + (right.x * nx * tanFov * aspect) + (up.x * ny * tanFov)
    local dirY = forward.y + (right.y * nx * tanFov * aspect) + (up.y * ny * tanFov)
    local dirZ = forward.z + (right.z * nx * tanFov * aspect) + (up.z * ny * tanFov)

    local len = math.sqrt(dirX * dirX + dirY * dirY + dirZ * dirZ)
    if len < 0.0001 then return 0.0, 1.0, 0.0 end
    return dirX / len, dirY / len, dirZ / len
end

local function computeTarget(hash, camPos, dirX, dirY, dirZ)
    local endX, endY, endZ = camPos.x + dirX * RAY_DISTANCE, camPos.y + dirY * RAY_DISTANCE, camPos.z + dirZ * RAY_DISTANCE
    local ray = StartExpensiveSynchronousShapeTestLosProbe(camPos.x, camPos.y, camPos.z, endX, endY, endZ, 1 + 16, PlayerPedId(), 4)
    local _, hit, hitCoords, hitNormal, hitEnt = GetShapeTestResult(ray)
    local didHit = hit and hit ~= 0
    local refPoint = didHit and hitCoords or vector3(endX, endY, endZ)

    -- ✅ DEĞİŞTİ: kategori artık tek ("Ev İnşa (Duvar & Zemin)") olduğu
    -- için wall/floor ayrımı structKind'den (katalog etiketi ya da custom
    -- prop'lar için boyut sezgisi) yapılıyor.
    local isFloorCeiling = getStructKindForModel(Build.model) == 'floor'

    -- ✅ Aynı TÜRDEN mi kontrolü — zemin sadece zemine, duvar sadece
    -- duvara "yan yana" yapışır; türler arası ilişki (duvar-zemin)
    -- aşağıdaki yükseklik-referansı bloklarında ele alınıyor.
    local function categoryMatches(ent)
        local kind = structKindOfEntity(ent)
        if isFloorCeiling then return kind == 'floor' end
        return kind == 'wall'
    end

    local trackedEnt = nil
    if didHit and isTrackedStructureEntity(hitEnt) and categoryMatches(hitEnt) then
        trackedEnt = hitEnt
    else
        local candidate = findNearestTrackedEntity(refPoint)
        if candidate and categoryMatches(candidate) then trackedEnt = candidate end
    end

    -- ✅ newDim artık [H] ile eklenecek pitch'i (Build.flattenStep) de
    -- hesaba katıyor — yerleştirilecek obje yaslanmış olacaksa, boyutlar
    -- da ona göre (Y/Z takas edilmiş) hesaplanıyor.
    local newDim = effectiveDim(getRealDimensions(hash), Build.flattenStep * 90.0)

    -- ✅ EKLENDİ: ZEMİN/TAVAN İÇİN DUVAR-YÜKSEKLİK REFERANSI. Aynı
    -- kategoriden bir komşu YOKSA (odadaki İLK zemin/tavan parçasını
    -- koyuyorsun demektir) ve yakında bir DUVAR varsa, o duvarın gerçek
    -- yüksekliğini kullanarak Z'yi otomatik hizalıyoruz — zeminler
    -- duvarın TABANINA, tavanlar duvarın TEPESİNE oturuyor. Kameranın
    -- pitch'ine (yukarı mı aşağı mı bakıyorsun) göre hangisini
    -- istediğini anlıyoruz. XY hâlâ mülkün sabit grid'ine oturuyor.
    if isFloorCeiling and not trackedEnt then
        local wallEnt = findNearestWallEntity(refPoint)
        if wallEnt then
            local wCoords = GetEntityCoords(wallEnt)
            local wRot = GetEntityRotation(wallEnt, 2)
            local wDim = effectiveDim(getRealDimensions(GetEntityModel(wallEnt)), wRot.x)
            local wallBottom = wCoords.z - (wDim.z / 2)
            local wallTop = wCoords.z + (wDim.z / 2)

            -- yukarı bakıyorsan tavan, aşağı/düz bakıyorsan zemin
            local wantsCeiling = dirZ > 0.05
            local snapZ = wantsCeiling and (wallTop + (newDim.z / 2) - OVERLAP_FUDGE)
                or (wallBottom - (newDim.z / 2) + OVERLAP_FUDGE)

            -- ✅ BUG DÜZELTİLDİ ("duvara bakıyorum ama [alan/oda] arkaya
            -- taşıyor"): X/Y eskiden genel bir Config.BuildGridSize (3m)
            -- ızgarasına yuvarlanıyordu — bu, refPoint'in duvarın HANGİ
            -- TARAFINDA olduğuna hiç bakmadığı için, ilk zemin karosu
            -- (ve ondan başlayan TÜM Alan/Oda doldurma) duvarın YANLIŞ
            -- tarafına (kameranın olmadığı tarafa) düşebiliyordu. Artık
            -- duvarın YÜZEYİNE dik yönü bulup, refPoint hangi taraftaysa
            -- (kamera/bakış noktası) zemin karosunu O TARAFA, duvara
            -- değecek şekilde oturtuyoruz — tıpkı wall-on-floor
            -- düzeltmesindeki gibi gerçek geometriye göre.
            local isWallYLong = (wDim.y or 0) > (wDim.x or 0)
            local faceAngle = isWallYLong and wRot.z or (wRot.z + 90.0)
            local faceRad = math.rad(faceAngle)
            local faceX, faceY = math.cos(faceRad), math.sin(faceRad) -- duvar yüzeyine DİK birim vektör

            local toRefX, toRefY = refPoint.x - wCoords.x, refPoint.y - wCoords.y
            local side = (toRefX * faceX + toRefY * faceY) >= 0 and 1 or -1
            local wallThickness = math.min(wDim.x, wDim.y)
            local newHalfAcross = math.max(newDim.x, newDim.y) / 2

            -- duvara DİK yönde: tam yüzüne değecek şekilde
            local touchOffset = (wallThickness / 2) + newHalfAcross - OVERLAP_FUDGE
            local touchX = wCoords.x + faceX * side * touchOffset
            local touchY = wCoords.y + faceY * side * touchOffset

            -- duvar BOYUNCA yönde: refPoint'in izdüşümü (serbest, grid'e
            -- değil duvarın kendi uzunluk eksenine göre yuvarlanıyor)
            local _, _, wLength = lengthAxisWorld(wDim, wRot.z)
            local alongX, alongY = math.cos(math.rad(wRot.z)), math.sin(math.rad(wRot.z))
            if isWallYLong then
                local t = -math.sin(math.rad(wRot.z))
                alongX, alongY = t, math.cos(math.rad(wRot.z))
            end
            local alongProj = (refPoint.x - wCoords.x) * alongX + (refPoint.y - wCoords.y) * alongY
            local alongSpacing = math.max(newHalfAcross * 2 - OVERLAP_FUDGE, 0.1)
            local alongSnapped = math.floor((alongProj / alongSpacing) + 0.5) * alongSpacing

            local snappedX = touchX + alongX * alongSnapped
            local snappedY = touchY + alongY * alongSnapped
            -- ✅ ÖNEMLİ: rz, duvarın UZUNLUK eksenine hizalı (dünya
            -- eksenine hizalı, 0°/90° gibi) olmalı — bu değer daha sonra
            -- Alan/Oda ([G]) doldurma başladığında dikdörtgenin KENDİ
            -- ekseni olarak kullanılıyor; rastgele bir açı olsaydı,
            -- doldurma çarpık (eksenlere hizasız) çıkardı.
            local snappedYaw = math.deg(math.atan(alongY, alongX))

            return { x = snappedX, y = snappedY, z = snapZ, rx = 0.0, ry = 0.0, rz = snappedYaw }
        end
    end

    -- ✅ EKLENDİ: DUVAR İÇİN ZEMİN/TAVAN-YÜKSEKLİK REFERANSI (yukarıdakinin
    -- SİMETRİĞİ). Aynı kategoriden bir komşu YOKSA (odadaki İLK duvarı
    -- koyuyorsun ya da zeminin üstüne yeni bir duvar başlatıyorsun) ve
    -- yakında bir ZEMİN/TAVAN parçası varsa, onun gerçek yüksekliğini
    -- kullanarak Z'yi otomatik hizalıyoruz — duvar, zeminin TEPESİNE
    -- oturuyor (tam üstüne, boşluk/batma olmadan). Bu, "zeminin üstüne
    -- duvar ekleyemiyorum, hep altına zorluyor" şikayetinin asıl
    -- düzeltmesi — öncesinde bu yön HİÇ ele alınmıyordu.
    if not isFloorCeiling and not trackedEnt then
        local floorEnt = findNearestFloorCeilingEntity(refPoint)
        if floorEnt then
            local fCoords = GetEntityCoords(floorEnt)
            local fRot = GetEntityRotation(floorEnt, 2)
            local fDim = effectiveDim(getRealDimensions(GetEntityModel(floorEnt)), fRot.x)
            local floorTop = fCoords.z + (fDim.z / 2)
            local floorBottom = fCoords.z - (fDim.z / 2)

            -- kameranın Z'ye göre konumuna bakarak zeminin ÜSTÜNDE mi
            -- ALTINDA mı (tavan altı gibi) duvar istediğini anlıyoruz
            local wantsBelow = camPos.z < fCoords.z
            local snapZ = wantsBelow and (floorBottom - (newDim.z / 2) + OVERLAP_FUDGE)
                or (floorTop + (newDim.z / 2) - OVERLAP_FUDGE)

            -- ✅ BUG DÜZELTİLDİ ("duvar zeminin ucundan değil ortasından
            -- başlıyor"): X/Y eskiden genel bir Config.BuildGridSize
            -- (3m) ızgarasına yuvarlanıyordu — zeminin GERÇEK kenarı o
            -- ızgaraya denk gelmezse, duvar zeminin İÇİNE düşüyordu.
            -- Artık zeminin KENDİ 4 kenarından (min/max X, min/max Y)
            -- hangisi bakış noktasına en yakınsa, duvarın o eksenini TAM
            -- O KENARA (duvarın yarı kalınlığı kadar dışına) oturtuyoruz
            -- — tıpkı köşeye yapışmadaki gibi gerçek geometriye göre.
            local halfW, halfD = fDim.x / 2, fDim.y / 2
            local distMinX, distMaxX = math.abs(refPoint.x - (fCoords.x - halfW)), math.abs(refPoint.x - (fCoords.x + halfW))
            local distMinY, distMaxY = math.abs(refPoint.y - (fCoords.y - halfD)), math.abs(refPoint.y - (fCoords.y + halfD))
            local minDist = math.min(distMinX, distMaxX, distMinY, distMaxY)

            local newHalfThick = math.min(newDim.x, newDim.y) / 2
            -- ✅ DÜZELTME: Y-uzun (Mouse tarzı) custom modellerde, "X
            -- boyunca uzansın" için gereken rz 0° değil 90°'dir (tersi
            -- de geçerli) — generateRoomWalls'daki AYNI düzeltme.
            local isNewYLong = (newDim.y or 0) > (newDim.x or 0)
            local rzAlongX = isNewYLong and 90.0 or 0.0
            local rzAlongY = isNewYLong and 0.0 or 90.0
            local snappedX, snappedY, snappedYaw

            if minDist == distMinX or minDist == distMaxX then
                -- Batı ya da doğu kenarına en yakın -> duvar bu kenar
                -- BOYUNCA (Y ekseninde) uzanır, X'i kenara sabitleriz.
                snappedX = (minDist == distMinX) and (fCoords.x - halfW - newHalfThick) or (fCoords.x + halfW + newHalfThick)
                local grid = Config.BuildGridSize or 3.0
                snappedY = fCoords.y + math.floor((refPoint.y - fCoords.y) / grid + 0.5) * grid
                snappedYaw = rzAlongY
            else
                -- Güney ya da kuzey kenarına en yakın -> duvar BOYUNCA X
                -- ekseninde uzanır, Y'yi kenara sabitleriz.
                snappedY = (minDist == distMinY) and (fCoords.y - halfD - newHalfThick) or (fCoords.y + halfD + newHalfThick)
                local grid = Config.BuildGridSize or 3.0
                snappedX = fCoords.x + math.floor((refPoint.x - fCoords.x) / grid + 0.5) * grid
                snappedYaw = rzAlongX
            end

            return { x = snappedX, y = snappedY, z = snapZ, rx = 0.0, ry = 0.0, rz = snappedYaw }
        end
    end

    if trackedEnt then
        -- ✅ MEVCUT DUVAR/ZEMİN PARÇASINA YAPIŞ — gerçek boyutlarla,
        -- boşluksuz (aynı "Bitişik Ekle" mantığı, ama tuş yerine
        -- raycast'in hangi yüzeyi gösterdiğine göre otomatik).
        local hEnt = trackedEnt
        local hCoords = GetEntityCoords(hEnt)
        local hRot = GetEntityRotation(hEnt, 2)
        local hDim = effectiveDim(getRealDimensions(GetEntityModel(hEnt)), hRot.x)

        -- ✅ refPoint/effNormal: gerçek raycast BU objeye direkt çarpmadıysa
        -- (yakınlık araması bulduysa), hitCoords/hitNormal ya yok ya da
        -- BAŞKA bir şeye (dünya/başka obje) ait — o yüzden hEnt'e göre
        -- güvenli bir referans noktası/yön hesaplıyoruz.
        local samePoint = didHit and hitEnt == hEnt
        local effPoint = samePoint and hitCoords or refPoint
        local effNormal
        if samePoint then
            effNormal = hitNormal
        else
            local dx, dy, dz = effPoint.x - hCoords.x, effPoint.y - hCoords.y, effPoint.z - hCoords.z
            local len = math.sqrt(dx * dx + dy * dy + dz * dz)
            if len < 0.01 then dx, dy, dz, len = 0.0, 1.0, 0.0, 1.0 end
            effNormal = vector3(dx / len, dy / len, dz / len)
        end

        local absX, absY, absZ = math.abs(effNormal.x), math.abs(effNormal.y), math.abs(effNormal.z)

        if absZ > absX and absZ > absY then
            -- üst/alt yüzeye bakılıyor -> dikey istifle (zemin üstü/altı)
            -- ✅ BUG DÜZELTİLDİ: "zeminin üstüne değil altına zorluyor"
            -- şikayeti — yakınlık araması (samePoint=false) kullanıldığında
            -- effNormal'ın Z işareti GÜVENİLMEZDİ (oyuncu zeminin
            -- ÜSTÜNDE dururken bile, referans noktasının tam konumuna
            -- göre yanlış işaret çıkabiliyordu). Artık DİREKT bakış YOKSA
            -- kameranın gerçek dikey bakış yönünü (dirZ — yukarı mı
            -- aşağı mı bakıyorsun) kullanıyoruz, çok daha güvenilir bir
            -- niyet sinyali.
            local dirZsign
            if samePoint then
                dirZsign = effNormal.z > 0 and 1 or -1
            else
                dirZsign = dirZ >= 0 and 1 or -1
            end
            local offset = (hDim.z / 2) + (newDim.z / 2) - OVERLAP_FUDGE
            return {
                x = hCoords.x, y = hCoords.y, z = hCoords.z + dirZsign * offset,
                rx = hRot.x, ry = hRot.y, rz = hRot.z,
            }
        else
            -- ✅ YENİ: köşe/uç algılama. Hit noktasının, mevcut duvarın
            -- KENDİ sağ ekseni (uzunluğu) boyunca izdüşümünü alıyoruz —
            -- eğer bu izdüşüm duvarın YARI GENİŞLİĞİNE yakınsa (yani
            -- duvarın UCUNA/köşesine bakıyorsun, ortasına değil), KÖŞE
            -- MODU'na geçiyoruz.
            -- ✅ OTOMATİK KÖŞE HİZALAMA: artık dönüşü tetiklemek için [R]'ye
            -- BASMAN GEREKMİYOR — kameranın bakış yönü, duvarın kendi
            -- ekseninden farklı bir 90°/270°'ye en yakınsa (yani gerçekten
            -- köşeyi DÖNMEK istiyorsun demektir), sistem bunu otomatik
            -- algılayıp yeni parçayı doğru açıyla köşeye oturtuyor —
            -- tıpkı Sims'teki otomatik köşe/T-bağlantı parçaları gibi.
            -- Kamerayı duvarla AYNI eksende tutarsan (düz devam), köşe
            -- tetiklenmez, düz uzatma yapılır. [R] hâlâ çalışır — otomatik
            -- tahmin istediğin köşe olmazsa (örn. iç/dış köşe ya da 180°
            -- ekleyip karşı yöne almak için) üstüne ekstra döndürme
            -- uygulayabilirsin.
            -- ✅ BUG DÜZELTİLDİ: eskiden sabit bir metre payı (0.7m)
            -- kullanıyordum — dar bir panelde bu pay neredeyse TÜM
            -- paneli kaplayıp her zaman köşe modunu tetikliyordu, geniş
            -- bir panelde ise neredeyse hiç yer kaplamayıp köşeyi
            -- YAKALAMAK ÇOK ZORLAŞIYORDU ("bazen tam ucundan başlamıyor"
            -- şikayeti buradan geliyordu — modelin genişliğine göre
            -- TUTARSIZDI). Artık ORANSAL: panelin yarı-genişliğinin son
            -- %30'u köşe bölgesi sayılıyor, hangi model olursa olsun
            -- TUTARLI çalışıyor.
            -- ✅ BUG DÜZELTİLDİ (ANA ŞİKAYET — "duvar arkaya doğru
            -- büyüyor, iç içe"): eskiden burada rightX/rightY her zaman
            -- yerel X ekseninden (cos/sin(rz)) türetiliyor ve tüm
            -- uzunluklar hDim.x'ten okunuyordu. Yerel Y'si uzun olan
            -- custom duvarlarda (Mouse paketi gibi) bu, duvarın
            -- KALINLIK yönünü "uzunluk" sanmak demekti. Artık
            -- lengthAxisWorld GERÇEK uzun ekseni buluyor.
            local rightX, rightY, hLength = lengthAxisWorld(hDim, hRot.z)
            local localAlongRight = (effPoint.x - hCoords.x) * rightX + (effPoint.y - hCoords.y) * rightY
            local halfWidth = hLength / 2
            local nearEnd = math.abs(localAlongRight) > halfWidth * 0.7

            -- kameranın baktığı yön, duvarın GERÇEK ekseni referansıyla
            -- en yakın 90°'nin katı olarak ne kadar farklı — 0/180 = düz
            -- devam, 90/270 = köşeyi dön.
            -- ✅ NOT: X-uzun (GTA konvansiyonu) modellerde formül BİRE BİR
            -- eskisi gibi (oyunda test ettiğin davranış korunuyor); Y-uzun
            -- modellerde +90 telafisi ekleniyor ki AYNI göreli davranış
            -- (duvara göre bakış yönü) onlarda da geçerli olsun.
            local axisComp = ((hDim.y or 0) > (hDim.x or 0)) and 90.0 or 0.0
            local camYawDeg = math.deg(math.atan(-dirX, dirY))
            local autoTurn = math.floor(((camYawDeg - hRot.z - axisComp) / 90) + 0.5) * 90 % 360
            local wantsTurn = autoTurn == 90 or autoTurn == 270

            if nearEnd and wantsTurn then
                local endSide = localAlongRight >= 0 and 1 or -1
                local cornerX = hCoords.x + rightX * endSide * halfWidth
                local cornerY = hCoords.y + rightY * endSide * halfWidth

                -- ✅ finalRz: otomatik dönüş + [R] ayarı + KONVANSİYON
                -- HİZALAMA (yeni model X-uzun/Y-uzun farklıysa +90, ki
                -- uzun ekseni dönülen yöne baksın).
                local finalRz = alignRzToAxis(newDim, hDim, hRot.z) + autoTurn + Build.extraYaw
                -- ✅ Yeni parçanın KENDİ uzun ekseni (dünya yönü + uzunluk)
                local newRightX, newRightY, newLength = lengthAxisWorld(newDim, finalRz)

                -- köşeden hangi yöne doğru uzanacağını, kameranın/hit
                -- noktasının köşeye göre newRight ekseni boyunca hangi
                -- tarafta olduğuna bakarak buluyoruz
                local toHitX, toHitY = effPoint.x - cornerX, effPoint.y - cornerY
                local extendDir = (toHitX * newRightX + toHitY * newRightY) >= 0 and 1 or -1
                local newOffset = (newLength / 2) - OVERLAP_FUDGE

                return {
                    x = cornerX + newRightX * extendDir * newOffset,
                    y = cornerY + newRightY * extendDir * newOffset,
                    z = hCoords.z,
                    rx = hRot.x, ry = hRot.y,
                    rz = alignRzToAxis(newDim, hDim, hRot.z) + autoTurn, -- caller +extraYaw ekleyecek
                }
            end

            -- yatay yüzey, ORTASI -> düz devam et (uzun eksenler HİZALI,
            -- her iki parçanın da GERÇEK yarı-uzunluğu kadar offset)
            local dot = effNormal.x * rightX + effNormal.y * rightY
            local side = dot >= 0 and 1 or -1
            local alignedRz = alignRzToAxis(newDim, hDim, hRot.z)
            local _, _, newLength = lengthAxisWorld(newDim, alignedRz)
            local offset = (hLength / 2) + (newLength / 2) - OVERLAP_FUDGE
            return {
                x = hCoords.x + rightX * side * offset,
                y = hCoords.y + rightY * side * offset,
                z = hCoords.z,
                rx = hRot.x, ry = hRot.y, rz = alignedRz,
            }
        end
    end

    -- ✅ BOŞ ALAN — grid'e yuvarla (mülkün build_origin'ine göre sabit,
    -- her zaman aynı noktalardan geçen bir ızgara). Buraya SADECE
    -- yakında (PROXIMITY_SNAP_RADIUS içinde) HİÇBİR yapı parçası yoksa
    -- düşülüyor artık — eskisinden çok daha nadir.
    local targetPos = refPoint
    local origin = currentGridOrigin()
    local grid = Config.BuildGridSize or 3.0

    local snappedX = origin.x + math.floor((targetPos.x - origin.x) / grid + 0.5) * grid
    local snappedY = origin.y + math.floor((targetPos.y - origin.y) / grid + 0.5) * grid
    local snappedZ = origin.z + math.floor((targetPos.z - origin.z) / grid + 0.5) * grid

    -- kameranın baktığı yöne en yakın 90°'lik açı — varsayılan yönlendirme
    local camYawDeg = math.deg(math.atan(-dirX, dirY))
    local snappedYaw = math.floor((camYawDeg / 90) + 0.5) * 90

    return { x = snappedX, y = snappedY, z = snappedZ, rx = 0.0, ry = 0.0, rz = snappedYaw }
end

-- ============================================================
--  KAYIT (mevcut savePlacedObject akışıyla AYNI server round-trip)
-- ============================================================
local function placeOne(t)
    -- ✅ EKLENDİ: metadata.floor — objenin hangi kata ait olduğunu
    -- kaydediyoruz, Çoklu Kat özelliği kat değiştirince bu bilgiye göre
    -- objeleri gösterip/gizliyor.
    local ok, res = lib.callback.await('yg_properties:server:addObjectCb', false, Build.propertyId, {
        model = Build.model,
        coords = { x = t.x, y = t.y, z = t.z },
        rotation = { x = t.rx, y = t.ry, z = t.rz },
        frozen = true,
        metadata = { floor = Build.floor or 0 },
    })
    -- ✅ Build.count ARTIK burada elle artırılmıyor — aşağıdaki
    -- 'yg_properties:client:objectAdded/objectRemoved' dinleyicileri
    -- (her ekleme/silmede, kaynağı ne olursa olsun — Ctrl+Z/Y undo/redo
    -- DAHİL — sunucudan yayınlanır) sayaç güncellemesini tek, tutarlı
    -- bir yerden yapıyor; elle sayaç tutmak undo/redo ile senkron
    -- kalamıyordu.
    return ok, res
end

local function confirmPlacement()
    if not Build.lastTarget then return end
    local t = Build.lastTarget
    local ok, res = placeOne(t)
    if ok then
        -- ✅ EKLENDİ: paylaşılan undo/redo geçmişine (edit.lua) kaydediyoruz
        -- — Ctrl+Z ile bu yerleştirmeyi geri alabilirsin.
        TriggerEvent('yg_properties:client:pushUndo', { type = 'add', propertyId = Build.propertyId, objectId = res, snapshot = {
            model = Build.model, coords = { x = t.x, y = t.y, z = t.z }, rotation = { x = t.rx, y = t.ry, z = t.rz },
        } })
        -- ✅ BUG DÜZELTİLDİ ("R'ye basmadan tamamlanıyor demiştin ama
        -- tamamlanmıyor"): [R] ile eklenen Build.extraYaw parça
        -- yerleştirildikten SONRA da SIFIRLANMIYORDU — bir köşede elle
        -- düzelttiğinde bu ekstra döndürme KALICI hale gelip SONRAKİ
        -- TÜM otomatik köşe tahminlerinin üstüne binmeye devam ediyordu,
        -- bu yüzden bir sonraki köşe otomatik doğru dönse bile üstüne
        -- yanlış bir ekstra açı eklenip hizası bozuluyordu. [R] sadece
        -- O ANKİ parça için tek seferlik bir düzeltme olmalı, o yüzden
        -- her başarılı yerleştirmeden sonra sıfırlıyoruz.
        Build.extraYaw = 0.0
        lib.notify({ type = 'success', description = 'Yerleştirildi. Devam edebilirsin.' })
    else
        lib.notify({ type = 'error', description = 'Yerleştirilemedi: ' .. tostring(res) })
    end
end

-- ============================================================
--  SİLME MODU — [Sağ Tık] açar/kapatır, açıkken [Sol Tık] bakılan
--  parçayı siler. SADECE bu sistemle yerleştirilmiş yapı kategorisi
--  objelerini siler (isTrackedStructureEntity) — dünyadaki başka
--  hiçbir şeye (başka oyuncular, harita objeleri) dokunmuyor.
-- ============================================================
local function findLookedAtStructureEntity()
    local yawRad = math.rad(Build.yaw)
    local pitchRad = math.rad(Build.pitch)
    local dirX = -math.sin(yawRad) * math.cos(pitchRad)
    local dirY = math.cos(yawRad) * math.cos(pitchRad)
    local dirZ = math.sin(pitchRad)
    local endX, endY, endZ = Build.camPos.x + dirX * RAY_DISTANCE, Build.camPos.y + dirY * RAY_DISTANCE, Build.camPos.z + dirZ * RAY_DISTANCE
    local ray = StartExpensiveSynchronousShapeTestLosProbe(Build.camPos.x, Build.camPos.y, Build.camPos.z, endX, endY, endZ, 1 + 16, PlayerPedId(), 4)
    local _, hit, _, _, hitEnt = GetShapeTestResult(ray)
    if hit and hit ~= 0 and isTrackedStructureEntity(hitEnt) then
        return hitEnt
    end
    return nil
end

local function deleteLookedAtEntity()
    local ent = Build.lookedAtEntity
    if not ent or not DoesEntityExist(ent) then
        lib.notify({ type = 'error', description = 'Silinecek bir parçaya bakmıyorsun.' })
        return
    end
    local objId = findObjectIdForEntity(ent)
    if not objId then
        lib.notify({ type = 'error', description = 'Obje bulunamadı.' })
        return
    end

    -- ✅ EKLENDİ: silmeden ÖNCE bir snapshot alıyoruz (model adı/koordinat/
    -- rotasyon) — Ctrl+Z ile bu silmeyi geri alabilmek (objeyi aynı
    -- yerde yeniden yaratabilmek) için gerekli.
    local okModel, modelName = pcall(function() return exports['yg_properties']:yg_getSpawnedObjectModel(objId) end)
    if okModel and modelName then
        local c = GetEntityCoords(ent)
        local rx, ry, rz = table.unpack(GetEntityRotation(ent, 2))
        TriggerEvent('yg_properties:client:pushUndo', { type = 'delete', propertyId = Build.propertyId, snapshot = {
            model = modelName, coords = { x = c.x, y = c.y, z = c.z }, rotation = { x = rx, y = ry, z = rz },
        } })
    end

    TriggerServerEvent('yg_properties:server:removeObject', Build.propertyId, objId)
    lib.notify({ type = 'success', description = 'Parça silindi.' })
end

-- ============================================================
--  SÜRÜKLEYEREK ÇOKLU YERLEŞTİRME
--  Sol tık BASILI TUTULUP sürüklenirse, dragStart'tan mevcut hedefe
--  kadar OBJENİN KENDİ HİZASI boyunca (sağ vektörü) kaç adım attığını
--  hesaplayıp önizleme hayaletleri gösterir. Bırakınca hepsini kaydeder.
-- ============================================================
local function clearDragGhosts()
    for _, g in ipairs(Build.dragGhosts) do
        if DoesEntityExist(g) then DeleteEntity(g) end
    end
    Build.dragGhosts = {}
end

-- dragStart'tan şu anki lastTarget'a kadar, objenin KENDİ hizası
-- boyunca (rz açısına göre sağ vektör) kaç birim + hangi yönde
-- gidildiğini hesaplar; her adımın {x,y,z,rx,ry,rz} listesini döner.
local function computeDragLine()
    if not Build.dragStart or not Build.lastTarget then return {} end
    local s, c = Build.dragStart, Build.lastTarget

    -- ✅ BUG DÜZELTİLDİ (ANA ŞİKAYET): eskiden spacing = dim.x ve yön =
    -- cos/sin(rz) (yerel X) sabitti. Yerel Y'si uzun olan custom
    -- duvarlarda bu, duvarın KALINLIĞI (~20cm) kadar aralıkla, kalınlık
    -- yönünde (arkaya) dizmek demekti — "iç içe bir sürü duvar" tam
    -- olarak buydu. Artık lengthAxisWorld GERÇEK uzun ekseni buluyor;
    -- effectiveDim de [H] ile yaslanmış parçalarda doğru taban
    -- boyutlarını veriyor.
    local dim = effectiveDim(getRealDimensions(Build.hash), s.rx)
    local rightX, rightY, length = lengthAxisWorld(dim, s.rz)
    local spacing = math.max(length - OVERLAP_FUDGE, 0.1)

    local dx, dy = c.x - s.x, c.y - s.y
    local proj = dx * rightX + dy * rightY

    local steps = math.floor((math.abs(proj) / spacing) + 0.5)
    steps = math.min(steps, 40) -- güvenlik sınırı (tek sürüklemede en fazla 40 parça)
    local dir = proj >= 0 and 1 or -1

    local line = {}
    for i = 0, steps do
        local off = spacing * i * dir
        line[#line + 1] = {
            x = s.x + rightX * off, y = s.y + rightY * off, z = s.z,
            rx = s.rx, ry = s.ry, rz = s.rz,
        }
    end
    return line
end

-- ✅ EKLENDİ: DİKEY SÜRÜKLEME — çok katlı ev / yüksek duvar boşlukları
-- için. Objenin GERÇEK yüksekliğine ([H] ile yaslanmışsa ona göre
-- ayarlanmış) göre yukarı/aşağı istifler, XY konumu SABİT kalır.
local function computeDragVertical()
    if not Build.dragStart or not Build.lastTarget then return {} end
    local s, c = Build.dragStart, Build.lastTarget

    local dim = effectiveDim(getRealDimensions(Build.hash), s.rx)
    local spacing = math.max(dim.z - OVERLAP_FUDGE, 0.1)

    local dz = c.z - s.z
    local steps = math.min(math.floor((math.abs(dz) / spacing) + 0.5), 40)
    local dir = dz >= 0 and 1 or -1

    local line = {}
    for i = 0, steps do
        local off = spacing * i * dir
        line[#line + 1] = {
            x = s.x, y = s.y, z = s.z + off,
            rx = s.rx, ry = s.ry, rz = s.rz,
        }
    end
    return line
end

-- ✅ DEĞİŞTİ: artık "ALAN" modu — orta tığa TIKLAYINCA 3 mod arasında
-- döngü yapıyorsun (Yatay/Dikey/Alan), BASILI TUTMAK gerekmiyor. Bir
-- köşeye koyup köşegen sürükleyince aradaki TÜM alanı dolduruyor.
local function computeDragRect()
    if not Build.dragStart or not Build.lastTarget then return {} end
    local s, c = Build.dragStart, Build.lastTarget

    local dim = getRealDimensions(Build.hash)

    -- ✅ BUG DÜZELTİLDİ ("bazı kısımlar taşıyor, tam dikdörtgen olmuyor"):
    -- [H] ile yatay yaslanmış (pitch ~90°/270°) bir objede, YEREL Y ekseni
    -- ARTIK dünya "ileri" yönünü temsil etmiyor — bu rolü YEREL Z (objenin
    -- orijinal, dikeyken sahip olduğu yüksekliği) devralıyor, çünkü pitch
    -- döndürmesi Y/Z eksenlerini birbirine karıştırıyor. Eskiden hep
    -- dim.y kullanıyordum — düz duran objelerde (flattenStep=0) doğruydu
    -- ama yaslanmış (flattenStep=1 veya 3, yani ~90°/270°) objelerde
    -- YANLIŞ boyutu kullanıp aralığı yanlış hesaplıyordum.
    local ed = effectiveDim(dim, s.rx)
    local spacingX = math.max(ed.x - OVERLAP_FUDGE, 0.1)
    local spacingY = math.max(ed.y - OVERLAP_FUDGE, 0.1)

    local rad = math.rad(s.rz)
    local rightX, rightY = math.cos(rad), math.sin(rad)
    local fwdX, fwdY = -math.sin(rad), math.cos(rad) -- sağ vektöre dik (90°)

    local dx, dy = c.x - s.x, c.y - s.y
    local projRight = dx * rightX + dy * rightY
    local projFwd = dx * fwdX + dy * fwdY

    local stepsX = math.min(math.floor((math.abs(projRight) / spacingX) + 0.5), 30)
    local stepsY = math.min(math.floor((math.abs(projFwd) / spacingY) + 0.5), 30)
    local dirX = projRight >= 0 and 1 or -1
    local dirY = projFwd >= 0 and 1 or -1

    local cells = {}
    for ix = 0, stepsX do
        for iy = 0, stepsY do
            if #cells >= FILL_MAX_CELLS then break end
            local offX = spacingX * ix * dirX
            local offY = spacingY * iy * dirY
            cells[#cells + 1] = {
                x = s.x + rightX * offX + fwdX * offY,
                y = s.y + rightY * offX + fwdY * offY,
                z = s.z, rx = s.rx, ry = s.ry, rz = s.rz,
            }
        end
        if #cells >= FILL_MAX_CELLS then break end
    end
    return cells
end

-- Aktif sürükleme moduna göre (yatay/dikey/alan) doğru listeyi döner.
local function computeDragCells()
    if Build.dragMode == 'rect' then return computeDragRect() end
    if Build.dragMode == 'vertical' then return computeDragVertical() end
    return computeDragLine()
end

-- ============================================================
--  ODA SİHİRBAZI — 2 köşe arasındaki dikdörtgenin 4 duvarını otomatik
--  üretir, köşeler kusursuz birleşir. Dünya eksenlerine hizalı (axis-
--  aligned) bir dikdörtgen varsayıyoruz — Config.BuildGridSize'ın zaten
--  kullandığı aynı, basit ve öngörülebilir mantık.
-- ============================================================
-- ✅ EKLENDİ: kaba (gözle işaret edilmiş) 2 köşeyi, GERÇEK yakındaki
-- duvarların konumuna göre otomatik hizalar — kullanıcı tam duvara
-- denk gelmese bile, zemin/tavan doldurma duvarlarla TAM örtüşüyor,
-- fazladan boşluk/taşma kalmıyor. Her duvarın uzunluk ekseni dünya
-- X'e mi Y'ye mi yakınsa, o duvar DİĞER ekseni sınırlıyor demektir
-- (X boyunca uzanan bir duvar = Y sınırı / güney-kuzey duvarı gibi).
local function findBoundaryWalls(point, maxDist)
    local walls = getSpawnedWalls()
    local bestXWall, bestXDist = nil, maxDist or 5.0 -- Y boyunca uzanan (X sınırı veren) duvar
    local bestYWall, bestYDist = nil, maxDist or 5.0 -- X boyunca uzanan (Y sınırı veren) duvar
    for _, ent in ipairs(walls) do
        local c = GetEntityCoords(ent)
        local r = GetEntityRotation(ent, 2)
        local dim = effectiveDim(getRealDimensions(GetEntityModel(ent)), r.x)
        local isYLong = (dim.y or 0) > (dim.x or 0)
        local effRz = isYLong and (r.z + 90.0) or r.z
        local rzMod = effRz % 180
        local runsAlongX = (rzMod < 45 or rzMod > 135) -- ~0°/180° -> dünya X boyunca uzanıyor
        if runsAlongX then
            local d = math.abs(point.y - c.y)
            if d < bestYDist then bestYDist, bestYWall = d, ent end
        else
            local d = math.abs(point.x - c.x)
            if d < bestXDist then bestXDist, bestXWall = d, ent end
        end
    end
    return bestXWall, bestYWall
end

-- p1/p2: kaba köşeler. otherCorner: hizalanan eksenin "içeri" (odanın
-- ortasına doğru) hangi yönde olduğunu bulmak için karşı köşe.
local function snapCornerToWalls(point, otherCorner)
    local xWall, yWall = findBoundaryWalls(point)
    local snapped = { x = point.x, y = point.y, z = point.z, rx = point.rx, ry = point.ry, rz = point.rz }

    if xWall then
        local c = GetEntityCoords(xWall)
        local dim = effectiveDim(getRealDimensions(GetEntityModel(xWall)), GetEntityRotation(xWall, 2).x)
        local halfThick = math.min(dim.x, dim.y) / 2
        local sign = (otherCorner.x >= c.x) and 1 or -1
        snapped.x = c.x + sign * halfThick
    end
    if yWall then
        local c = GetEntityCoords(yWall)
        local dim = effectiveDim(getRealDimensions(GetEntityModel(yWall)), GetEntityRotation(yWall, 2).x)
        local halfThick = math.min(dim.x, dim.y) / 2
        local sign = (otherCorner.y >= c.y) and 1 or -1
        snapped.y = c.y + sign * halfThick
    end
    return snapped
end

local function generateRoomWalls(p1, p2)
    local dim = effectiveDim(getRealDimensions(Build.hash), Build.flattenStep * 90.0)
    -- ✅ lengthAxisWorld ile duvarın GERÇEK uzun eksenini buluyoruz (rz=0
    -- referansıyla) — custom paketlerde X/Y hangisi uzunsa onu kullanır.
    local _, _, wallLength = lengthAxisWorld(dim, 0.0)
    local thickness = math.min(dim.x, dim.y)
    local spacing = math.max(wallLength - OVERLAP_FUDGE, 0.1)

    local minX, maxX = math.min(p1.x, p2.x), math.max(p1.x, p2.x)
    local minY, maxY = math.min(p1.y, p2.y), math.max(p1.y, p2.y)
    local z = p1.z

    -- çok küçük bir alan seçildiyse (yanlışlıkla tek nokta gibi) anlamsız
    if (maxX - minX) < spacing * 0.5 or (maxY - minY) < spacing * 0.5 then
        return {}
    end

    local pieces = {}
    local halfThick = thickness / 2

    -- ✅ DÜZELTME: duvarın uzun ekseni yerel X mi Y mi olduğuna göre,
    -- "dünya X boyunca uzansın" ve "dünya Y boyunca uzansın" için
    -- GEREKEN rz farklı olur — sabit 0°/90° varsaymak Y-uzun (Mouse
    -- tarzı) custom modellerde duvarları YANLIŞ yöne (kalınlık yönünde)
    -- döndürürdü, tıpkı önceki "duvar arkaya büyüyor" hatası gibi.
    local isYLong = (dim.y or 0) > (dim.x or 0)
    local rzAlongX = isYLong and 90.0 or 0.0
    local rzAlongY = isYLong and 0.0 or 90.0

    -- Bir kenar boyunca (start->end, dünya ekseninde) duvar dizer.
    -- rz: o kenarda duvarın YÜZÜ dışa baksın diye kullanılan rotasyon.
    local function fillEdge(startX, startY, endX, endY, rz)
        local dx, dy = endX - startX, endY - startY
        local len = math.sqrt(dx * dx + dy * dy)
        local dirX, dirY = dx / len, dy / len
        local steps = math.max(math.floor((len / spacing) + 0.5), 1)
        local realSpacing = len / steps
        for i = 0, steps - 1 do
            local cx = startX + dirX * realSpacing * (i + 0.5)
            local cy = startY + dirY * realSpacing * (i + 0.5)
            pieces[#pieces + 1] = { x = cx, y = cy, z = z, rx = 0.0, ry = 0.0, rz = rz }
        end
    end

    -- 4 kenar: güney, kuzey, batı, doğu — köşe payı (halfThick) ile
    -- kenarları KISALTIYORUZ ki duvarların köşede üst üste binmesi/kenara
    -- taşması yerine tam köşe noktasında düzgün kesişsinler.
    fillEdge(minX + halfThick, minY, maxX - halfThick, minY, rzAlongX)   -- güney (X boyunca)
    fillEdge(minX + halfThick, maxY, maxX - halfThick, maxY, rzAlongX)   -- kuzey (X boyunca)
    fillEdge(minX, minY + halfThick, minX, maxY - halfThick, rzAlongY)   -- batı (Y boyunca)
    fillEdge(maxX, minY + halfThick, maxX, maxY - halfThick, rzAlongY)   -- doğu (Y boyunca)

    return pieces
end

local function updateDragPreview()
    local line = computeDragCells()
    local r, g_, b = 69, 214, 184 -- teal = yatay (line)
    if Build.dragMode == 'rect' then r, g_, b = 232, 184, 109 -- altın = alan (rect)
    elseif Build.dragMode == 'vertical' then r, g_, b = 255, 105, 180 end -- pembe = dikey
    SetEntityDrawOutlineColor(r, g_, b, 255) -- global ayar, tek çağrı yeterli
    -- gerekirse eksik hayaletleri oluştur / fazlaları sil
    while #Build.dragGhosts < #line do
        local g = CreateObject(Build.hash, 0.0, 0.0, 0.0, false, false, false)
        SetEntityAlpha(g, 120, false)
        SetEntityCollision(g, false, false)
        FreezeEntityPosition(g, true)
        SetEntityDrawOutline(g, true)
        Build.dragGhosts[#Build.dragGhosts + 1] = g
    end
    while #Build.dragGhosts > #line do
        local g = table.remove(Build.dragGhosts)
        if DoesEntityExist(g) then DeleteEntity(g) end
    end
    for i, t in ipairs(line) do
        local g = Build.dragGhosts[i]
        if DoesEntityExist(g) then
            SetEntityCoords(g, t.x, t.y, t.z, false, false, false, false)
            SetEntityRotation(g, t.rx, t.ry, t.rz, 2, true)
        end
    end
end

local function commitDrag()
    local line = computeDragCells()
    clearDragGhosts()

    if #line <= 1 then
        -- sürükleme mesafesi çok kısaydı — normal TEK yerleştirme say
        confirmPlacement()
        return
    end

    local placed, failed = 0, 0
    for _, t in ipairs(line) do
        local ok, res = placeOne(t)
        if ok then
            placed = placed + 1
            -- ✅ EKLENDİ: sürükleyerek dizilen HER parça ayrı bir undo
            -- kaydı olarak eklenir — Ctrl+Z tek tek (son yerleştirilenden
            -- başlayarak) geri alabilir.
            TriggerEvent('yg_properties:client:pushUndo', { type = 'add', propertyId = Build.propertyId, objectId = res, snapshot = {
                model = Build.model, coords = { x = t.x, y = t.y, z = t.z }, rotation = { x = t.rx, y = t.ry, z = t.rz },
            } })
        else
            failed = failed + 1
        end
        if failed > 0 then break end -- limit dolduysa devam etmenin anlamı yok
    end

    if failed == 0 then
        lib.notify({ type = 'success', description = ('%d parça yerleştirildi.'):format(placed) })
    else
        lib.notify({ type = 'error', description = ('%d parça yerleştirildi, sonra durduruldu (limit?).'):format(placed) })
    end

    -- ✅ BUG DÜZELTİLDİ: confirmPlacement'taki AYNI sıfırlama — sürükleyerek
    -- dizerken de [R] kalıcı hale gelmesin.
    Build.extraYaw = 0.0
end

-- ============================================================
--  ✅ EKLENDİ: ÇOKLU KAT — aktif olmayan kattaki objeleri build sırasında
--  gizler (görüşü engellemesin diye), aktif kattakileri geri gösterir.
--  metadata.floor'u decode edilmiş şekilde tutan objects.lua export'unu
--  kullanıyor.
-- ============================================================
local function refreshFloorVisibility()
    local ok, spawnedTbl = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    if not ok or not spawnedTbl then return end
    for id, ent in pairs(spawnedTbl) do
        if DoesEntityExist(ent) then
            local okM, meta = pcall(function() return exports['yg_properties']:yg_getSpawnedObjectMetadata(id) end)
            local objFloor = (okM and meta and tonumber(meta.floor)) or 0
            local visible = objFloor == (Build.floor or 0)
            pcall(function() exports['yg_properties']:yg_setObjectFloorVisible(id, visible) end)
        end
    end
end

-- ✅ EKLENDİ: kat değiştirirken bakılan parçaya göre TAM hizalama —
-- "istediğimiz propun üstüne gidip yukarı ok'a basınca tam onun
-- birebir hizasında üstüne çıksın" isteği. Bakılan bir yapı parçası
-- varsa, yeni katın Z referansı Config.FloorHeight'ın genel (yaklaşık)
-- tahmini yerine DOĞRUDAN o parçanın gerçek üst/alt yüzeyinden alınır.
local function changeFloor(delta)
    local minF, maxF = Config.MinFloor or -1, Config.MaxFloor or 2
    local newFloor = math.max(minF, math.min(maxF, (Build.floor or 0) + delta))
    if newFloor == Build.floor then
        lib.notify({ type = 'error', description = 'Bu kat sınırının dışında.' })
        return
    end

    local aligned = false
    local lookEnt = findLookedAtStructureEntity()
    if lookEnt and DoesEntityExist(lookEnt) then
        local eCoords = GetEntityCoords(lookEnt)
        local eRot = GetEntityRotation(lookEnt, 2)
        local eDim = effectiveDim(getRealDimensions(GetEntityModel(lookEnt)), eRot.x)
        local floorH = Config.FloorHeight or 3.0
        Build.floorZOverrides = Build.floorZOverrides or {}
        if delta > 0 then
            -- yukarı: yeni katın tabanı, baktığın parçanın TAM TEPESİNE oturur.
            Build.floorZOverrides[newFloor] = eCoords.z + (eDim.z / 2)
        else
            -- aşağı: baktığın parçanın TAM ALTI, bir alt katın tavanı sayılır —
            -- o katın tabanı, oradan bir kat yüksekliği kadar aşağıdadır.
            Build.floorZOverrides[newFloor] = eCoords.z - (eDim.z / 2) - floorH
        end
        aligned = true
    end

    Build.floor = newFloor
    refreshFloorVisibility()
    local floorNames = { [-1] = 'Bodrum', [0] = 'Zemin Kat' }
    local floorLabel = floorNames[Build.floor] or (Build.floor .. '. Kat')
    lib.notify({ type = 'inform', description = 'Aktif kat: ' .. floorLabel .. (aligned and ' (bakılan parçaya hizalandı)' or '') })
end

-- ============================================================
--  MODEL DEĞİŞTİRME (fare tekerleği)
-- ============================================================
local function switchModel(delta)
    if #Build.modelList == 0 then return end
    Build.modelIndex = ((Build.modelIndex - 1 + delta) % #Build.modelList) + 1
    local newModel = Build.modelList[Build.modelIndex]

    local newHash = joaat(newModel)
    lib.requestModel(newHash)

    Build.model = newModel
    Build.hash = newHash

    if DoesEntityExist(Build.ghost) then DeleteEntity(Build.ghost) end
    Build.ghost = CreateObject(Build.hash, Build.camPos.x, Build.camPos.y, Build.camPos.z, false, false, false)
    SetEntityAlpha(Build.ghost, 140, false)
    SetEntityCollision(Build.ghost, false, false)
    FreezeEntityPosition(Build.ghost, true)
    SetEntityDrawOutline(Build.ghost, true)
    SetEntityDrawOutlineColor(232, 184, 109, 255)

    lib.notify({ type = 'inform', description = 'Model: ' .. newModel })
end

-- ============================================================
--  TEK-BASIŞLIK AKSİYONLAR — lib.addKeybind (GÜVENİLİR mekanizma,
--  client/gizmo.lua'da H/Esc ile yaşanan "tuş görünürde doğru ama
--  tetiklenmiyor" sorunundan sonra doğrulanmış çözüm). Manuel
--  IsControlJustPressed/Released yerine bunu kullanıyoruz — hepsi
--  Build.active değilken sessizce hiçbir şey yapmıyor.
-- ============================================================
lib.addKeybind({
    name = 'yg_buildConfirmEnter',
    description = 'İnşa: Parçayı Yerleştir (Enter)',
    defaultKey = 'RETURN',
    onReleased = function()
        if not Build.active then return end
        confirmPlacement()
    end,
})

lib.addKeybind({
    name = 'yg_buildConfirmClick',
    description = 'İnşa: Parçayı Yerleştir / Sürükle / Sil',
    defaultMapper = 'MOUSE_BUTTON',
    defaultKey = 'MOUSE_LEFT',
    onPressed = function()
        if not Build.active then return end
        if Build.deleteMode or Build.roomWizardActive then return end -- silme modunda ya da oda sihirbazı aktifken sürükleme yok
        Build.dragging = true
        Build.dragStart = Build.lastTarget
        -- ✅ dragMode ARTIK BURADA belirlenmiyor — orta tık TIKLAMASIYLA
        -- (yg_buildCycleDragMode) kalıcı olarak değişiyor, o an ne ise
        -- (Yatay/Dikey/Alan) bu sürüklemede o kullanılıyor.
    end,
    onReleased = function()
        if not Build.active then return end
        if Build.deleteMode then
            deleteLookedAtEntity()
            return
        end
        if Build.dragging then
            Build.dragging = false
            commitDrag()
        end
    end,
})

-- ✅ EKLENDİ: [Sağ Tık] — YERLEŞTİRME MODU ↔ SİLME MODU arasında geçiş.
-- Silme modundayken sol tık artık koymuyor, BAKILAN parçayı siliyor.
-- Tekrar sağ tıklayınca yerleştirme moduna geri dönüyor.
lib.addKeybind({
    name = 'yg_buildToggleDelete',
    description = 'İnşa: Silme Moduna Geç/Çık (Sağ Tık)',
    defaultMapper = 'MOUSE_BUTTON',
    defaultKey = 'MOUSE_RIGHT',
    onReleased = function()
        if not Build.active then return end
        Build.deleteMode = not Build.deleteMode
        Build.dragging = false
        clearDragGhosts()
        lib.notify({ type = Build.deleteMode and 'error' or 'success', description = Build.deleteMode and 'Silme modu AÇIK — Sol Tık ile sil.' or 'Yerleştirme moduna dönüldü.' })
    end,
})

-- ✅ DEĞİŞTİ: orta tık artık BASILI TUTMA değil, RMB (silme modu) ile
-- AYNI "TIKLA/DÖNGÜ YAP" mekanizması — 3 mod arasında geçiyor:
-- Yatay -> Dikey -> Alan -> Yatay... Ekran ipucu hep hangi modda
-- olduğunu gösteriyor. [LAlt] denendi ama Windows'ta ALT'ın özel
-- "sistem tuşu" davranışı yüzünden güvenilir çalışmadı — bu artık
-- LMB/RMB ile TAMAMEN AYNI kanıtlanmış mekanizmayı (lib.addKeybind'in
-- kendi basılı/bırakıldı takibi) kullanıyor.
lib.addKeybind({
    name = 'yg_buildCycleDragMode',
    description = 'İnşa: Sürükleme Modu (Yatay/Dikey/Alan) — Orta Tık',
    defaultMapper = 'MOUSE_BUTTON',
    defaultKey = 'MOUSE_MIDDLE',
    onReleased = function()
        if not Build.active then return end
        if Build.dragMode == 'line' then Build.dragMode = 'vertical'
        elseif Build.dragMode == 'vertical' then Build.dragMode = 'rect'
        else Build.dragMode = 'line' end
        local names = { line = 'Yatay', vertical = 'Dikey', rect = 'Alan' }
        lib.notify({ type = 'inform', description = 'Sürükleme modu: ' .. names[Build.dragMode] })
    end,
})

lib.addKeybind({
    name = 'yg_buildCancelBack',
    description = 'İnşa: Çık (Backspace)',
    defaultKey = 'BACK',
    onReleased = function()
        if not Build.active then return end
        StopBuildMode()
    end,
})

lib.addKeybind({
    name = 'yg_buildCancelEsc',
    description = 'İnşa: Çık (Esc)',
    defaultKey = 'ESCAPE',
    onReleased = function()
        if not Build.active then return end
        StopBuildMode()
    end,
})

-- ✅ EKLENDİ: Ctrl+Z / Ctrl+Y — Sims'teki gibi geri al / yinele. Aynı
-- paylaşılan undo/redo çekirdeğini (client/edit.lua) kullanıyor, o
-- yüzden gizmo/manage panelinden yapılan işlemlerle de tutarlı çalışır.
-- LCtrl algılaması, buildLoop'ta zaten kullanılan (kamera aşağı inme)
-- AYNI kontrolle (36) ve AYNI okuma fonksiyonuyla (IsDisabledControlPressed
-- — bu kontrol her karede devre dışı bırakıldığı için düz IsControlPressed
-- güvenilir değil) yapılıyor.
lib.addKeybind({
    name = 'yg_buildUndo',
    description = 'İnşa: Geri Al (Ctrl+Z)',
    defaultKey = 'Z',
    onReleased = function()
        if not Build.active then return end
        if not IsDisabledControlPressed(0, 36) then return end
        TriggerEvent('yg_properties:client:requestUndo')
    end,
})

lib.addKeybind({
    name = 'yg_buildRedo',
    description = 'İnşa: Yinele (Ctrl+Y)',
    defaultKey = 'Y',
    onReleased = function()
        if not Build.active then return end
        if not IsDisabledControlPressed(0, 36) then return end
        TriggerEvent('yg_properties:client:requestRedo')
    end,
})

-- ✅ EKLENDİ: ODA SİHİRBAZI — [G] BASILI TUT + sürükle: 2 köşe seçip
-- bırakınca aralarındaki dikdörtgenin 4 duvarını TEK SEFERDE, otomatik
-- köşe birleşimiyle üretir. Bir duvar modeli seçiliyken kullanılır.
lib.addKeybind({
    name = 'yg_buildRoomWizard',
    description = 'İnşa: Oda Sihirbazı (Basılı Tut + Sürükle = Duvarsa 4 Kenar, Zeminse Tüm Alan)',
    defaultKey = 'G',
    onPressed = function()
        if not Build.active or Build.deleteMode or Build.dragging then return end
        Build.roomWizardActive = true
        Build.roomWizardStart = Build.lastTarget and { x = Build.lastTarget.x, y = Build.lastTarget.y, z = Build.lastTarget.z, rx = Build.lastTarget.rx, ry = Build.lastTarget.ry, rz = Build.lastTarget.rz } or nil
        -- ✅ EKLENDİ: zemin/tavan modelinde computeDragRect'i (Alan modunun
        -- kendisi) tekrar kullanabilmek için dragStart'ı da dolduruyoruz —
        -- iki ayrı kod yolu yerine TEK, zaten kanıtlanmış alan-doldurma
        -- mantığı hem "Alan" modunda hem burada kullanılıyor.
        Build.dragStart = Build.roomWizardStart
    end,
    onReleased = function()
        if not Build.roomWizardActive then return end
        Build.roomWizardActive = false
        Build.dragStart = nil
        for _, g in ipairs(Build.roomWizardGhosts) do
            if DoesEntityExist(g) then DeleteEntity(g) end
        end
        Build.roomWizardGhosts = {}

        if not Build.roomWizardStart or not Build.lastTarget then return end

        -- ✅ EKLENDİ: DUVAR ise 4 kenar (perimetre), ZEMİN/TAVAN (ya da
        -- structKind bilinmeyen custom bir prop) ise TÜM alanı dolduran
        -- dikdörtgen — computeDragRect zaten kanıtlanmış "Alan" modunun
        -- kendisi, burada tekrar kullanıyoruz.
        local isWall = getStructKindForModel(Build.model) == 'wall'
        local pieces
        if isWall then
            pieces = generateRoomWalls(Build.roomWizardStart, Build.lastTarget)
        else
            -- ✅ EKLENDİ: kaba köşeleri GERÇEK yakındaki duvarlara hizala —
            -- zemin/tavan, duvarlarla TAM örtüşsün, fazladan boşluk/taşma
            -- kalmasın (kullanıcı tam duvara bakmasa bile).
            local snappedStart = snapCornerToWalls(Build.roomWizardStart, Build.lastTarget)
            local snappedEnd = snapCornerToWalls(Build.lastTarget, Build.roomWizardStart)
            Build.dragStart = snappedStart
            Build.lastTarget = snappedEnd
            pieces = computeDragRect()
        end
        local pieceWord = isWall and 'duvar parçası' or 'zemin/tavan parçası'

        if #pieces == 0 then
            lib.notify({ type = 'error', description = 'Alan çok küçük — daha geniş bir dikdörtgen seç.' })
            return
        end
        if #pieces > 150 then
            lib.notify({ type = 'error', description = ('Çok fazla parça (%d) — daha küçük bir alan seç.'):format(#pieces) })
            return
        end

        CreateThread(function()
            local placed, failed = 0, 0
            for _, t in ipairs(pieces) do
                local ok, res = placeOne(t)
                if ok then
                    placed = placed + 1
                    TriggerEvent('yg_properties:client:pushUndo', { type = 'add', propertyId = Build.propertyId, objectId = res, snapshot = {
                        model = Build.model, coords = { x = t.x, y = t.y, z = t.z }, rotation = { x = t.rx, y = t.ry, z = t.rz },
                    } })
                else
                    failed = failed + 1
                    break
                end
            end
            if failed == 0 then
                lib.notify({ type = 'success', description = ('Oluşturuldu: %d %s.'):format(placed, pieceWord) })
            else
                lib.notify({ type = 'error', description = ('%d parça yerleştirildi, sonra durduruldu (limit?).'):format(placed) })
            end
        end)
    end,
})

lib.addKeybind({
    name = 'yg_buildRotate',
    description = 'İnşa: 90° Döndür',
    defaultKey = 'R',
    onPressed = function()
        if not Build.active or Build.deleteMode then return end
        Build.extraYaw = (Build.extraYaw + 90) % 360
    end,
})

-- ✅ EKLENDİ: [H] — bir duvarı YATAY YASLAYIP zemin/tavan olarak
-- kullanabilmek için. client/gizmo.lua'daki AYNI "4 basışta bir tur"
-- mantığı (0°→90°→180°→270°→0°) — her modelin "düz" açısı farklı
-- olabildiği için tek bir hedef açı yerine devirerek doğru duruşu
-- gözle bulmanı sağlıyor.
lib.addKeybind({
    name = 'yg_buildFlatten',
    description = 'İnşa: Yatay Yasla (Devir)',
    defaultKey = 'H',
    onPressed = function()
        if not Build.active or Build.deleteMode then return end
        Build.flattenStep = (Build.flattenStep + 1) % 4
        lib.notify({ type = 'success', description = ('Devrildi (%d°). Şimdi zemin/tavan olarak yerleştirebilirsin.'):format(Build.flattenStep * 90) })
    end,
})

lib.addKeybind({
    name = 'yg_buildNextModel',
    description = 'İnşa: Sonraki Model (Tekerlek Aşağı)',
    defaultMapper = 'MOUSE_WHEEL',
    defaultKey = 'IOM_WHEEL_DOWN',
    onPressed = function()
        if not Build.active or Build.dragging or Build.deleteMode then return end
        switchModel(1)
    end,
})

lib.addKeybind({
    name = 'yg_buildPrevModel',
    description = 'İnşa: Önceki Model (Tekerlek Yukarı)',
    defaultMapper = 'MOUSE_WHEEL',
    defaultKey = 'IOM_WHEEL_UP',
    onPressed = function()
        if not Build.active or Build.dragging or Build.deleteMode then return end
        switchModel(-1)
    end,
})

-- ✅ EKLENDİ: [V] — Sims Kamerası: Serbest (freecam) ↔ Kuşbakışı
-- (top-down) ↔ Döner (orbit) arasında döngü yapar.
lib.addKeybind({
    name = 'yg_buildCycleCamera',
    description = 'İnşa: Kamera Modu (Serbest/Kuşbakışı/Döner)',
    defaultKey = 'V',
    onReleased = function()
        if not Build.active then return end
        -- ✅ EKLENDİ: kamera modundan çıkarken imleç modu açık kaldıysa kapat
        if Build.cursorAimMode then
            LeaveCursorMode()
            Build.cursorAimMode = false
        end
        if Build.camMode == 'free' then
            Build.camMode = 'topdown'
            Build.topDownHeight = Config.TopDownCamHeight or 20.0
        elseif Build.camMode == 'topdown' then
            Build.camMode = 'orbit'
            Build.orbitTarget = Build.camPos
            Build.orbitYaw = Build.yaw
            Build.orbitPitch = -35.0
            Build.orbitDist = Config.OrbitCamDistance or 12.0
        else
            Build.camMode = 'free'
        end
        local names = { free = 'Serbest', topdown = 'Kuşbakışı', orbit = 'Döner' }
        lib.notify({ type = 'inform', description = 'Kamera modu: ' .. names[Build.camMode] })
    end,
})

-- ✅ EKLENDİ: [C] — SADECE Döner (orbit) modda anlamlı. Açıkken fare artık
-- kamerayı DEĞİL, ekrandaki bir imleci kontrol ediyor — o imlecin
-- gösterdiği noktaya (KuzQuality'deki gibi) yerleştirme yapılıyor.
-- Kamerayı döndürmek için tekrar [C]'ye basıp kapatman gerekiyor (fare
-- aynı anda hem imleç hem kamera-döndürme olamıyor, bu yüzden tuşla
-- geçiş yapıyoruz — SetNuiFocusKeepInput'ın bilinen hatasından tamamen
-- kaçınan güvenli yöntem).
lib.addKeybind({
    name = 'yg_buildToggleCursorAim',
    description = 'İnşa: İmleç ile Nişan Alma (Sadece Döner Kamerada)',
    defaultKey = 'C',
    onReleased = function()
        if not Build.active then return end
        if Build.camMode ~= 'orbit' then
            lib.notify({ type = 'error', description = 'İmleç modu sadece Döner kamerada çalışır ([V] ile geç).' })
            return
        end
        Build.cursorAimMode = not Build.cursorAimMode
        if Build.cursorAimMode then
            EnterCursorMode()
        else
            LeaveCursorMode()
        end
        lib.notify({ type = 'inform', description = Build.cursorAimMode and 'İmleç modu AÇIK — tıkladığın yere yerleştirir.' or 'İmleç modu KAPALI — fare kamerayı döndürür.' })
    end,
})

-- ✅ DEĞİŞTİ: [Yukarı Ok]/[Aşağı Ok] — Çoklu Kat: aktif katı değiştirir
-- (Config.MinFloor..Config.MaxFloor arası — bodrum/zemin/üst katlar).
-- Önceden PageUp/PageDown idi; istenen bakılan propa TAM hizalanan geçiş
-- de artık changeFloor içinde ele alınıyor.
lib.addKeybind({
    name = 'yg_buildFloorUp',
    description = 'İnşa: Bir Üst Kat (Yukarı Ok)',
    defaultKey = 'UP',
    onReleased = function()
        if not Build.active then return end
        changeFloor(1)
    end,
})

lib.addKeybind({
    name = 'yg_buildFloorDown',
    description = 'İnşa: Bir Alt Kat (Aşağı Ok)',
    defaultKey = 'DOWN',
    onReleased = function()
        if not Build.active then return end
        changeFloor(-1)
    end,
})

-- ============================================================
--  FREECAM DÖNGÜSÜ
-- ============================================================
local function buildLoop()
    while Build.active do
        Wait(0)

        local dt = GetFrameTime()
        DisableControlAction(0, 24, true) -- ateş etme
        DisableControlAction(0, 25, true) -- nişan alma
        DisablePlayerFiring(cache.playerId, true)

        -- ✅ EKLENDİ: Sims Kamerası — moda göre yaw/pitch/camPos'u
        -- hesaplıyoruz, sonuç HER MODDA AYNI Build.yaw/Build.pitch/
        -- Build.camPos alanlarına yazılıyor — altındaki raycast/hedef
        -- hesaplama kodu (computeTarget vb.) moddan habersiz, hep aynı
        -- şekilde çalışmaya devam ediyor.
        if Build.camMode == 'topdown' then
            -- KUŞBAKIŞI: fare ile bakış YOK (açı sabit, kuzey yukarı) —
            -- WASD, Sims'teki gibi kamerayı DÜNYA eksenlerinde kaydırır
            -- (kameranın kendi yönüne göre değil). Space/Ctrl yaklaştırır/
            -- uzaklaştırır (yükseklik = zoom).
            local moveY = GetDisabledControlNormal(0, 32) - GetDisabledControlNormal(0, 33)
            local moveX = GetDisabledControlNormal(0, 34) - GetDisabledControlNormal(0, 35)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
            local speedMult = IsDisabledControlPressed(0, 21) and 3.0 or 1.0
            DisableControlAction(0, 21, true)
            local curSpeed = MOVE_SPEED * speedMult

            Build.topDownHeight = Build.topDownHeight or Config.TopDownCamHeight or 20.0
            if IsDisabledControlPressed(0, 22) then Build.topDownHeight = math.max(4.0, Build.topDownHeight - 8.0 * dt) end
            if IsDisabledControlPressed(0, 36) then Build.topDownHeight = math.min(60.0, Build.topDownHeight + 8.0 * dt) end
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 36, true)

            Build.yaw = 0.0
            Build.pitch = -89.0
            local baseZ = (Build.gridOrigin and Build.gridOrigin.z or Build.camPos.z) + (Build.floor or 0) * (Config.FloorHeight or 3.0)
            Build.camPos = vector3(
                Build.camPos.x + moveX * curSpeed * dt,
                Build.camPos.y + moveY * curSpeed * dt,
                baseZ + Build.topDownHeight
            )
        elseif Build.camMode == 'orbit' then
            -- DÖNER: fare, mülkün ETRAFINDA dönmeni sağlar (Sims'teki
            -- "orbit camera" gibi) — WASD odak noktasını (Build.orbitTarget)
            -- kaydırır, Space/Ctrl yaklaştırır/uzaklaştırır.
            -- ✅ EKLENDİ: [C] ile imleç modu AÇIKKEN, fare artık kamerayı
            -- DÖNDÜRMÜYOR (imleci kontrol ediyor) — bu yüzden bu bloğu
            -- atlıyoruz, yön aşağıda cursorRayDirection'dan geliyor.
            if not Build.cursorAimMode then
                local lookX = GetDisabledControlNormal(0, 1)
                local lookY = GetDisabledControlNormal(0, 2)
                Build.orbitYaw = Build.orbitYaw - lookX * LOOK_SENS * 4.0
                Build.orbitPitch = math.max(-80.0, math.min(-5.0, Build.orbitPitch - lookY * LOOK_SENS * 4.0))
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
            end

            local moveY = GetDisabledControlNormal(0, 32) - GetDisabledControlNormal(0, 33)
            local moveX = GetDisabledControlNormal(0, 34) - GetDisabledControlNormal(0, 35)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
            local speedMult = IsDisabledControlPressed(0, 21) and 3.0 or 1.0
            DisableControlAction(0, 21, true)
            local curSpeed = MOVE_SPEED * speedMult

            local orbitYawRad = math.rad(Build.orbitYaw)
            local fwdX, fwdY = -math.sin(orbitYawRad), math.cos(orbitYawRad)
            local rightX, rightY = math.cos(orbitYawRad), math.sin(orbitYawRad)
            Build.orbitTarget = Build.orbitTarget or Build.camPos
            Build.orbitTarget = vector3(
                Build.orbitTarget.x + (fwdX * moveY - rightX * moveX) * curSpeed * dt,
                Build.orbitTarget.y + (fwdY * moveY - rightY * moveX) * curSpeed * dt,
                Build.orbitTarget.z
            )

            Build.orbitDist = Build.orbitDist or Config.OrbitCamDistance or 12.0
            if IsDisabledControlPressed(0, 22) then Build.orbitDist = math.max(3.0, Build.orbitDist - 8.0 * dt) end
            if IsDisabledControlPressed(0, 36) then Build.orbitDist = math.min(40.0, Build.orbitDist + 8.0 * dt) end
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 36, true)

            -- kamera, hedefin (orbitTarget) etrafında ters yönde (hedefe
            -- bakacak şekilde) konumlanıyor.
            Build.yaw = Build.orbitYaw
            Build.pitch = Build.orbitPitch
            local pitchRad2 = math.rad(Build.pitch)
            local lookDirX = -math.sin(orbitYawRad) * math.cos(pitchRad2)
            local lookDirY = math.cos(orbitYawRad) * math.cos(pitchRad2)
            local lookDirZ = math.sin(pitchRad2)
            Build.camPos = vector3(
                Build.orbitTarget.x - lookDirX * Build.orbitDist,
                Build.orbitTarget.y - lookDirY * Build.orbitDist,
                Build.orbitTarget.z - lookDirZ * Build.orbitDist
            )
        else
            -- SERBEST (freecam) — mevcut/orijinal davranış.
            local lookX = GetDisabledControlNormal(0, 1) -- LookLeftRight
            local lookY = GetDisabledControlNormal(0, 2) -- LookUpDown
            Build.yaw = Build.yaw - lookX * LOOK_SENS * 4.0
            Build.pitch = math.max(-89.0, math.min(89.0, Build.pitch - lookY * LOOK_SENS * 4.0))
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)

            local moveY = GetDisabledControlNormal(0, 32) - GetDisabledControlNormal(0, 33) -- W-S
            local moveX = GetDisabledControlNormal(0, 34) - GetDisabledControlNormal(0, 35) -- A-D (ters işaretli, D=sağ)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)

            local yawRad0 = math.rad(Build.yaw)
            local fwdX, fwdY = -math.sin(yawRad0), math.cos(yawRad0)
            local rightX, rightY = math.cos(yawRad0), math.sin(yawRad0)

            -- ✅ EKLENDİ: [Shift] basılı tutulunca freecam hızlanır. WASD ile
            -- AYNI okuma deseni (IsDisabledControlPressed) — kontrol 21
            -- (INPUT_SPRINT) burada devre dışı bırakılıp öyle okunuyor.
            local speedMult = IsDisabledControlPressed(0, 21) and 3.0 or 1.0
            DisableControlAction(0, 21, true)
            local curSpeed = MOVE_SPEED * speedMult

            Build.camPos = vector3(
                Build.camPos.x + (fwdX * moveY - rightX * moveX) * curSpeed * dt,
                Build.camPos.y + (fwdY * moveY - rightY * moveX) * curSpeed * dt,
                Build.camPos.z
            )

            -- ✅ GERÇEK SEBEP BULUNDU (önceki SetPlayerControl "düzeltmesi"
            -- yanlış teşhisti): yukarıdaki WASD kontrolleri DOĞRU şekilde
            -- GetDisabledControlNormal kullanıyor (bu kontroller aşağıda
            -- DisableControlAction ile devre dışı bırakıldığı için) ama
            -- Space/Ctrl SADECE düz IsControlPressed kullanıyordu — devre
            -- dışı bırakılmış bir kontrolü "disabled" farkında olmayan bir
            -- fonksiyonla okumak güvenilir değil (bu konuşma boyunca H/Esc
            -- tuşlarında da aynı hatayı yapıp düzeltmiştik). Doğrusu
            -- IsDisabledControlPressed — WASD ile TUTARLI, kanıtlanmış yöntem.
            if IsDisabledControlPressed(0, 22) then -- Space
                Build.camPos = vector3(Build.camPos.x, Build.camPos.y, Build.camPos.z + curSpeed * dt)
            end
            if IsDisabledControlPressed(0, 36) then -- LCtrl
                Build.camPos = vector3(Build.camPos.x, Build.camPos.y, Build.camPos.z - curSpeed * dt)
            end
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 36, true)
        end

        SetCamCoord(Build.cam, Build.camPos.x, Build.camPos.y, Build.camPos.z)
        SetCamRot(Build.cam, Build.pitch, 0.0, Build.yaw, 2)

        -- bakış yönü vektörü (raycast için) — moddan bağımsız, hep
        -- Build.yaw/Build.pitch'ten hesaplanıyor.
        -- ✅ EKLENDİ: Döner kamerada [C] imleç modu AÇIKSA, yön artık
        -- ekranın ortasından DEĞİL, imlecin GERÇEK ekran konumundan
        -- hesaplanıyor (cursorRayDirection) — "her yere tıkla, oraya
        -- yerleştir" işte tam burada gerçekleşiyor.
        local dirX, dirY, dirZ
        if Build.camMode == 'orbit' and Build.cursorAimMode then
            dirX, dirY, dirZ = cursorRayDirection(Build.cam)
        else
            local yawRad = math.rad(Build.yaw)
            local pitchRad = math.rad(Build.pitch)
            dirX = -math.sin(yawRad) * math.cos(pitchRad)
            dirY = math.cos(yawRad) * math.cos(pitchRad)
            dirZ = math.sin(pitchRad)
        end

        if Build.deleteMode then
            -- ✅ SİLME MODU: normal hayaleti gizle, bakılan yapı objesini
            -- kırmızı çerçeveyle vurgula (silinecek olan bu).
            if DoesEntityExist(Build.ghost) then SetEntityAlpha(Build.ghost, 0, false) end
            local newLook = findLookedAtStructureEntity()
            if newLook ~= Build.lookedAtEntity then
                if Build.lookedAtEntity and DoesEntityExist(Build.lookedAtEntity) then
                    SetEntityDrawOutline(Build.lookedAtEntity, false)
                end
                if newLook and DoesEntityExist(newLook) then
                    SetEntityDrawOutline(newLook, true)
                    SetEntityDrawOutlineColor(255, 60, 60, 255)
                end
                Build.lookedAtEntity = newLook
            end
        elseif Build.roomWizardActive then
            -- ✅ EKLENDİ: [G] basılı — hedefi normal şekilde güncelliyoruz
            -- (ikinci köşe budur), DUVAR ise 4 kenarın, ZEMİN/TAVAN ise
            -- tüm alanın CANLI önizlemesini gösteriyoruz.
            local target = computeTarget(Build.hash, Build.camPos, dirX, dirY, dirZ)
            Build.lastTarget = target
            if DoesEntityExist(Build.ghost) then SetEntityAlpha(Build.ghost, 0, false) end

            local isWall = getStructKindForModel(Build.model) == 'wall'
            local pieces = {}
            if Build.roomWizardStart then
                if isWall then
                    pieces = generateRoomWalls(Build.roomWizardStart, target)
                else
                    -- ✅ EKLENDİ: önizlemede de köşeleri gerçek duvarlara
                    -- hizalıyoruz ki bırakınca "sürpriz" bir sonuç çıkmasın —
                    -- gördüğün önizleme = onayladığında olacak sonuç.
                    Build.dragStart = snapCornerToWalls(Build.roomWizardStart, target)
                    Build.lastTarget = snapCornerToWalls(target, Build.roomWizardStart)
                    pieces = computeDragRect()
                    Build.lastTarget = target -- diğer mantık ham hedefi görsün diye geri koyuyoruz
                end
            end
            SetEntityDrawOutlineColor(isWall and 120 or 255, isWall and 200 or 200, isWall and 255 or 100, 255)
            while #Build.roomWizardGhosts < #pieces do
                local g = CreateObject(Build.hash, 0.0, 0.0, 0.0, false, false, false)
                SetEntityAlpha(g, 120, false)
                SetEntityCollision(g, false, false)
                FreezeEntityPosition(g, true)
                SetEntityDrawOutline(g, true)
                Build.roomWizardGhosts[#Build.roomWizardGhosts + 1] = g
            end
            while #Build.roomWizardGhosts > #pieces do
                local g = table.remove(Build.roomWizardGhosts)
                if DoesEntityExist(g) then DeleteEntity(g) end
            end
            for i, t in ipairs(pieces) do
                local g = Build.roomWizardGhosts[i]
                if DoesEntityExist(g) then
                    SetEntityCoords(g, t.x, t.y, t.z, false, false, false, false)
                    SetEntityRotation(g, t.rx, t.ry, t.rz, 2, true)
                end
            end
        elseif not Build.dragging then
            local target = computeTarget(Build.hash, Build.camPos, dirX, dirY, dirZ)
            target.rz = target.rz + Build.extraYaw
            target.rx = target.rx + Build.flattenStep * 90.0
            Build.lastTarget = target

            if DoesEntityExist(Build.ghost) then
                SetEntityCoords(Build.ghost, target.x, target.y, target.z, false, false, false, false)
                SetEntityRotation(Build.ghost, target.rx, target.ry, target.rz, 2, true)
            end
        else
            -- sürüklerken: hedefi yine güncelliyoruz (dragline bunu kullanıyor)
            -- ama TEK hayalet yerine önizleme dizisini gösteriyoruz.
            -- dragStart'ın rx/ry/rz'si zaten flatten/extraYaw dahil olarak
            -- kaydedilmişti (aşağıdaki onPressed'e bak), o yüzden burada
            -- sadece onu koruyoruz — sürüklenen tüm parçalar AYNI eğimde olur.
            -- ✅ DEĞİŞTİ: dragMode artık BURADA canlı güncellenmiyor —
            -- orta tık TIKLAMASIYLA (yukarıda yg_buildCycleDragMode) kalıcı
            -- olarak değişiyor, sürüklemenin ortasında sabit kalıyor.
            local target = computeTarget(Build.hash, Build.camPos, dirX, dirY, dirZ)
            target.rz = Build.dragStart and Build.dragStart.rz or target.rz
            target.rx = Build.dragStart and Build.dragStart.rx or target.rx
            target.ry = Build.dragStart and Build.dragStart.ry or target.ry
            Build.lastTarget = target
            if DoesEntityExist(Build.ghost) then SetEntityAlpha(Build.ghost, 0, false) end
            updateDragPreview()
        end

        if not Build.deleteMode and not Build.dragging and DoesEntityExist(Build.ghost) then
            SetEntityAlpha(Build.ghost, 140, false)
        end

        -- ✅ Enter/Esc/Backspace/R/Tekerlek/F/Sağ Tık artık BURADA DEĞİL —
        -- yukarıda lib.addKeybind ile bağlı (client/gizmo.lua'da defalarca
        -- doğrulanmış GÜVENİLİR mekanizma; manuel IsControlJustPressed/
        -- Released bu tarz tek-basışlık aksiyonlarda tutarsız çalışıyor).

        -- ekran ipucu
        local dragHint = Build.dragging and (' — SÜRÜKLENİYOR (%d parça)'):format(#Build.dragGhosts) or ''
        local modeHint = Build.deleteMode and ' — 🔴 SİLME MODU' or ''
        local modeNames = { line = 'Yatay', vertical = 'Dikey', rect = 'Alan' }
        local dragModeHint = (' — Sürükleme: %s'):format(modeNames[Build.dragMode] or 'Yatay')
        local camNames = { free = 'Serbest', topdown = 'Kuşbakışı', orbit = 'Döner' }
        local floorNames = { [-1] = 'Bodrum', [0] = 'Zemin Kat' }
        local floorHint = (' — Kat: %s'):format(floorNames[Build.floor] or (Build.floor .. '. Kat'))
        local camHint = (' — Kamera: %s'):format(camNames[Build.camMode] or 'Serbest')
        local hintText = Build.deleteMode
            and ('İNŞA MODU — %s (%d/%d)%s%s%s  \n[Fare] Bak  [WASD/Shift] Uç/Hızlan  [Space/Ctrl] Yukarı/Aşağı  \n[Sol Tık] Bakılanı SİL  [Sağ Tık] Yerleştirme Moduna Dön  [Ctrl+Z/Y] Geri Al/Yinele  [V] Kamera  [Yukarı/Aşağı Ok] Kat  [Esc] Çık')
            or ('İNŞA MODU — %s (%d/%d)%s%s%s%s  \n[Fare] Bak  [WASD/Shift] Uç/Hızlan  [Space/Ctrl] Yukarı/Aşağı  \n[Sol Tık] Yerleştir/Sürükle  [G] Basılı+Sürükle=Alan (Duvarsa 4 Kenar, Zeminse Doldur)  [Orta Tık] Sürükleme Modu  [Sağ Tık] Silme  [Tekerlek] Model  \n[H] Yatay Yasla  [R] Köşe/Döndür  [V] Kamera  [C] İmleç Modu (Döner Kamerada)  [Yukarı/Aşağı Ok] Kat  [Ctrl+Z/Y] Geri Al/Yinele  [Esc] Çık')
        lib.showTextUI(
            Build.deleteMode and hintText:format(Build.model, Build.count, Build.limit, modeHint, camHint, floorHint)
                or hintText:format(Build.model, Build.count, Build.limit, dragModeHint, dragHint, camHint, floorHint),
            { position = 'top-center' }
        )
    end
    lib.hideTextUI()
end

-- ============================================================
--  BAŞLAT / DURDUR
-- ============================================================
function StartBuildMode(model)
    if Build.active then return end
    local propertyId = LocalPlayer.state.ygPropertyId
    if not propertyId then
        lib.notify({ type = 'error', description = 'Önce mekana gir.' })
        return
    end

    -- ✅ DEĞİŞTİ: eskiden SADECE Config.BuildCatalog'daki yapı kategorisi
    -- modelleri kabul ediliyordu (isStructureModel) — artık NUI'de "özel
    -- model kodu" girişi de eklendiğinden, katalogda olmayan bir model
    -- de kabul ediliyor. Tek şart: gerçekten var olan/yüklenebilir bir
    -- model olması (isStructureModel true dönerse zaten geçer; false
    -- dönerse — yani katalogda hiç yoksa — IsModelInCdimage ile ayrıca
    -- doğruluyoruz, sahte/olmayan bir model adına freecam açılmasın diye).
    model = tostring(model or ''):gsub('%s+', '')
    if model == '' then return end
    if not isStructureModel(model) then
        local testHash = joaat(model)
        if not IsModelInCdimage(testHash) then
            lib.notify({ type = 'error', description = 'Model bulunamadı: ' .. model })
            return
        end
    end

    local ok, hash = pcall(function()
        local h = joaat(model)
        lib.requestModel(h)
        return h
    end)
    if not ok then
        lib.notify({ type = 'error', description = 'Model yüklenemedi.' })
        return
    end

    local prop = LocalPlayer.state.ygCurrentProperty
    local origin = nil
    if prop and prop.build_origin and prop.build_origin ~= '' then
        local o = Shared.DecodeVec4(prop.build_origin)
        if o then origin = vector3(o.x, o.y, o.z) end
    end
    if not origin then
        local pc = GetEntityCoords(PlayerPedId())
        origin = vector3(pc.x, pc.y, pc.z)
    end

    Build.active = true
    Build.model = model
    Build.hash = hash
    Build.propertyId = propertyId
    Build.gridOrigin = origin
    Build.extraYaw = 0.0
    Build.flattenStep = 0
    Build.deleteMode = false
    Build.lookedAtEntity = nil
    Build.dragging = false
    Build.dragStart = nil
    Build.dragMode = 'line'
    Build.modelList = buildModelList()
    for i, m in ipairs(Build.modelList) do
        if m == model then Build.modelIndex = i break end
    end

    -- ✅ EKLENDİ: her build modu girişinde Serbest kameradan/zemin kattan
    -- başlanır — önceki oturumdan kalan kamera modu/kat karışıklık
    -- yaratmasın diye.
    Build.camMode = 'free'
    Build.orbitTarget = nil
    Build.orbitYaw = 0.0
    Build.orbitPitch = -35.0
    Build.orbitDist = Config.OrbitCamDistance or 12.0
    Build.topDownHeight = Config.TopDownCamHeight or 20.0
    Build.floor = 0
    Build.floorZOverrides = {}

    -- obje sayacı — mevcut yüklü objelerden (server round-trip yerine
    -- yerel spawned tablosundan tahmini sayım, panelin zaten gösterdiği
    -- decorCount ile aynı fikirde ama build.lua'nın kendi context'i
    -- olmadığı için burada basitçe exports üzerinden okuyoruz).
    local ok2, spawned = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    Build.count = (ok2 and spawned) and (function() local n = 0; for _ in pairs(spawned) do n = n + 1 end; return n end)() or 0
    Build.limit = Config.MaxObjectsPerProperty or 300

    local ped = PlayerPedId()
    local pc = GetEntityCoords(ped)
    local fwd = GetEntityForwardVector(ped)
    Build.camPos = vector3(pc.x + fwd.x * 2.0, pc.y + fwd.y * 2.0, pc.z + 1.0)
    Build.yaw = GetEntityHeading(ped)
    Build.pitch = 0.0

    FreezeEntityPosition(ped, true)
    -- Karakteri input-tepkisiz yap (donmuş karakterin zıplama/eğilme
    -- animasyonuna girmeye çalışmasını önler). NOT: Space/Ctrl'nin
    -- çalışmama sebebi bu DEĞİLMİŞ — asıl sebep buildLoop'taki yanlış
    -- fonksiyon seçimiydi (düzeltildi), bu satır sadece ek bir temizlik/
    -- iyi pratik olarak duruyor.
    SetPlayerControl(PlayerId(), false, 0)

    Build.cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(Build.cam, Build.camPos.x, Build.camPos.y, Build.camPos.z)
    SetCamRot(Build.cam, Build.pitch, 0.0, Build.yaw, 2)
    SetCamFov(Build.cam, 70.0)
    RenderScriptCams(true, false, 0, true, false)

    Build.ghost = CreateObject(hash, Build.camPos.x, Build.camPos.y, Build.camPos.z, false, false, false)
    SetEntityAlpha(Build.ghost, 140, false)
    SetEntityCollision(Build.ghost, false, false)
    FreezeEntityPosition(Build.ghost, true)
    SetEntityDrawOutline(Build.ghost, true)
    SetEntityDrawOutlineColor(232, 184, 109, 255)

    CreateThread(buildLoop)

    -- ✅ güvenlik: mekandan çıkarsa (bucket değişirse) build modunu
    -- ZORLA kapat — donmuş oyuncu dışarıda takılı kalmasın.
    CreateThread(function()
        while Build.active do
            Wait(500)
            if not LocalPlayer.state.ygPropertyId then
                StopBuildMode()
                break
            end
        end
    end)
end

function StopBuildMode()
    if not Build.active then return end
    Build.active = false

    -- ✅ EKLENDİ: imleç modu açık kaldıysa (native oyun imleci) kapat,
    -- yoksa oyuncu build modundan çıkınca imleçte takılı kalır.
    if Build.cursorAimMode then
        LeaveCursorMode()
        Build.cursorAimMode = false
    end

    clearDragGhosts()
    Build.dragging = false
    Build.dragStart = nil

    -- ✅ EKLENDİ: Oda Sihirbazı önizleme hayaletlerini temizle
    for _, g in ipairs(Build.roomWizardGhosts) do
        if DoesEntityExist(g) then DeleteEntity(g) end
    end
    Build.roomWizardGhosts = {}
    Build.roomWizardActive = false
    Build.roomWizardStart = nil

    if Build.lookedAtEntity and DoesEntityExist(Build.lookedAtEntity) then
        SetEntityDrawOutline(Build.lookedAtEntity, false)
    end
    Build.deleteMode = false
    Build.lookedAtEntity = nil

    if DoesEntityExist(Build.ghost) then DeleteEntity(Build.ghost) end
    Build.ghost = nil

    if Build.cam then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(Build.cam, false)
        Build.cam = nil
    end

    -- ✅ EKLENDİ: build modundan çıkarken, Çoklu Kat özelliği ile
    -- gizlenmiş olabilecek diğer kattaki objeleri TEKRAR görünür yap —
    -- yoksa oyuncu build modundan çıktığında bazı objeler kaybolmuş gibi
    -- görünürdü.
    Build.floor = 0
    Build.floorZOverrides = {}
    local ok, spawnedTbl = pcall(function() return exports['yg_properties']:yg_getSpawnedObjects() end)
    if ok and spawnedTbl then
        for id in pairs(spawnedTbl) do
            pcall(function() exports['yg_properties']:yg_setObjectFloorVisible(id, true) end)
        end
    end

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetPlayerControl(PlayerId(), true, 0)
    lib.hideTextUI()
end

RegisterNUICallback('startBuildMode', function(d, cb)
    local model = d and d.model
    cb({ ok = true })
    if not model then return end
    -- ✅ BUG DÜZELTİLDİ: SetNuiFocus(false,false) sadece giriş odağını
    -- (mouse/klavye) oyuna geri veriyor — panelin GÖRSEL içeriğini hiç
    -- temizlemiyor, o yüzden menü ekranda "asılı" kalıyordu. Diğer
    -- akışlarda (setUi/close vb.) kullanılan SendNUIMessage({action=
    -- 'close'}) burada eksikti — bu, NUI tarafında clear()'ı tetikleyip
    -- paneli gerçekten kapatıyor.
    SendNUIMessage({ action = 'close' })
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    StartBuildMode(model)
end)

-- ============================================================
--  ✅ EKLENDİ: Build.count SENKRONİZASYONU — bu iki event, kaynağı ne
--  olursa olsun (normal yerleştirme, sürükleme, Ctrl+Z/Y undo/redo, HATTA
--  aynı mekanda inşa yapan başka bir oyuncu) HER ekleme/silmede sunucudan
--  yayınlanıyor. Sayaç artık SADECE buradan güncelleniyor — elle
--  artırma/azaltma undo/redo ile senkron kalamıyordu.
-- ============================================================
RegisterNetEvent('yg_properties:client:objectAdded', function(propertyId)
    if not Build.active or propertyId ~= Build.propertyId then return end
    Build.count = Build.count + 1
end)

RegisterNetEvent('yg_properties:client:objectRemoved', function(propertyId)
    if not Build.active or propertyId ~= Build.propertyId then return end
    Build.count = math.max(0, Build.count - 1)
end)