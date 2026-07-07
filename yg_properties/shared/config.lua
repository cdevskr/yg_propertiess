Config = {}

Config.Debug = false

-- Bucket formula
Config.BucketBase = 200000

-- Interaction distance
Config.TargetDistance = 2.0

Config.PropertyShells = {
    [1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,
    [9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,[16]=true,[17]=true,[18]=true,[19]=true,[20]=true,[21]=true,[22]=true
}

-- Money
Config.MoneyType = 'cash'

-- Admin perms
Config.AdminGroups = { 'god', 'admin' }

-- Defaults when creating
Config.DefaultLabelHome = 'Ev'
Config.DefaultLabelBusiness = 'İş Yeri'
Config.DefaultLocked = false
Config.DefaultEntryFeeHome = 0

-- Permissions stored per property
Config.DefaultPermissions = {
  employeesCanEnterFree = false,
  employeesCanBuild = true,
  employeesCanControlMusic = true,
}

-- Building props catalog (expand)
-- Bu kategorilerdeki objeler "yapı" (duvar/zemin) sayılır: yerleştirilince
-- ızgaraya oturur (grid-snap) ki yan yana dizilince düzgün hizalı dursunlar.
-- Diğer tüm kategoriler (mobilya, dekor vb.) serbest yerleştirilir.
Config.StructureCategories = {
    ['Ev İnşa (Duvar & Zemin)'] = true, -- Build modu (freecam) SADECE bu kategoriyi kullanıyor
}
Config.StructureGridSize = 0.5    -- X/Y konumu bu metreye yuvarlanır (NOT: otomatik çağrı şu an kapalı, bkz. builder.lua/edit.lua)
Config.StructureHeadingSnap = 15  -- heading bu dereceye yuvarlanır

-- ✅ YENİ: Build modu (freecam+raycast) grid boyutu — SADECE mevcut
-- objeye yapışacak bir yüzey bulunamadığında (boş alanda) kullanılır.
-- Mevcut bir duvar/zemin parçasına bakıyorsan zaten o parçanın GERÇEK
-- boyutuna göre (GetModelDimensions) boşluksuz yapışıyor, bu sayı hiç
-- devreye girmiyor — sadece "ilk parçayı boş bir odaya koyarken" ya da
-- büyük bir alanda hizalı başlangıç noktaları için bir taban çizgisi.
-- 3.0 metre çoğu duvar/panel modelinin genişliğine yakın, makul bir
-- varsayılan — istersen değiştir.
Config.BuildGridSize = 3.0

-- ✅ EKLENDİ: Build modundaki Çoklu Kat özelliği ([Yukarı/Aşağı Ok])
-- bunları kullanıyor — kod içindeki "or" yedekleri sayesinde çökmüyordu
-- ama açıkça config'de yoktu, artık buradan ayarlanabilir.
Config.FloorHeight = 3.0   -- her kat bu kadar metre kayar
Config.MinFloor = -1       -- en alt kat (bodrum)
Config.MaxFloor = 2        -- en üst kat

-- ✅ EKLENDİ: Build modundaki Sims Kamerası ([V] ile döngü) bunları
-- kullanıyor.
Config.OrbitCamDistance = 12.0  -- Döner kamera: mülke başlangıç uzaklığı (metre)
Config.TopDownCamHeight = 20.0  -- Kuşbakışı kamera: başlangıç yüksekliği (metre)

Config.BuildCatalog = {

{
  category = 'Ev İnşa (Duvar & Zemin)',
  items = {
    { label = 'Mouse Kapılı Duvar 01', model = 'doorwall01', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 02', model = 'doorwall02', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 03', model = 'doorwall03', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 04', model = 'doorwall04', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 05', model = 'doorwall05', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 06', model = 'doorwall06', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 07', model = 'doorwall07', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 08', model = 'doorwall08', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 09', model = 'doorwall09', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 10', model = 'doorwall10', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 11', model = 'doorwall11', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 12', model = 'doorwall12', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 13', model = 'doorwall13', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 14', model = 'doorwall14', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 15', model = 'doorwall15', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 16', model = 'doorwall16', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 17', model = 'doorwall17', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 18', model = 'doorwall18', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 19', model = 'doorwall19', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 20', model = 'doorwall20', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 21', model = 'doorwall21', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 22', model = 'doorwall22', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 23', model = 'doorwall23', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 24', model = 'doorwall24', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 25', model = 'doorwall25', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 26', model = 'doorwall26', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 27', model = 'doorwall27', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 28', model = 'doorwall28', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 29', model = 'doorwall29', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 30', model = 'doorwall30', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 31', model = 'doorwall31', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 32', model = 'doorwall32', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 33', model = 'doorwall33', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 34', model = 'doorwall34', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 35', model = 'doorwall35', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 36', model = 'doorwall36', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 37', model = 'doorwall37', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 38', model = 'doorwall38', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 39', model = 'doorwall39', structKind = 'wall' },
    { label = 'Mouse Kapılı Duvar 40', model = 'doorwall40', structKind = 'wall' },
    { label = 'Mouse Duvar 01', model = 'wall01', structKind = 'wall' },
    { label = 'Mouse Duvar 02', model = 'wall02', structKind = 'wall' },
    { label = 'Mouse Duvar 03', model = 'wall03', structKind = 'wall' },
    { label = 'Mouse Duvar 04', model = 'wall04', structKind = 'wall' },
    { label = 'Mouse Duvar 05', model = 'wall05', structKind = 'wall' },
    { label = 'Mouse Duvar 06', model = 'wall06', structKind = 'wall' },
    { label = 'Mouse Duvar 07', model = 'wall07', structKind = 'wall' },
    { label = 'Mouse Duvar 08', model = 'wall08', structKind = 'wall' },
    { label = 'Mouse Duvar 09', model = 'wall09', structKind = 'wall' },
    { label = 'Mouse Duvar 10', model = 'wall10', structKind = 'wall' },
    { label = 'Mouse Duvar 11', model = 'wall11', structKind = 'wall' },
    { label = 'Mouse Duvar 12', model = 'wall12', structKind = 'wall' },
    { label = 'Mouse Duvar 13', model = 'wall13', structKind = 'wall' },
    { label = 'Mouse Duvar 14', model = 'wall14', structKind = 'wall' },
    { label = 'Mouse Duvar 15', model = 'wall15', structKind = 'wall' },
    { label = 'Mouse Duvar 16', model = 'wall16', structKind = 'wall' },
    { label = 'Mouse Duvar 17', model = 'wall17', structKind = 'wall' },
    { label = 'Mouse Duvar 18', model = 'wall18', structKind = 'wall' },
    { label = 'Mouse Duvar 19', model = 'wall19', structKind = 'wall' },
    { label = 'Mouse Duvar 20', model = 'wall20', structKind = 'wall' },
    { label = 'Mouse Duvar 21', model = 'wall21', structKind = 'wall' },
    { label = 'Mouse Duvar 22', model = 'wall22', structKind = 'wall' },
    { label = 'Mouse Duvar 23', model = 'wall23', structKind = 'wall' },
    { label = 'Mouse Duvar 24', model = 'wall24', structKind = 'wall' },
    { label = 'Mouse Duvar 25', model = 'wall25', structKind = 'wall' },
    { label = 'Mouse Duvar 26', model = 'wall26', structKind = 'wall' },
    { label = 'Mouse Duvar 27', model = 'wall27', structKind = 'wall' },
    { label = 'Mouse Duvar 28', model = 'wall28', structKind = 'wall' },
    { label = 'Mouse Duvar 29', model = 'wall29', structKind = 'wall' },
    { label = 'Mouse Duvar 30', model = 'wall30', structKind = 'wall' },
    { label = 'Mouse Duvar 31', model = 'wall31', structKind = 'wall' },
    { label = 'Mouse Duvar 32', model = 'wall32', structKind = 'wall' },
    { label = 'Mouse Duvar 33', model = 'wall33', structKind = 'wall' },
    { label = 'Mouse Duvar 34', model = 'wall34', structKind = 'wall' },
    { label = 'Mouse Duvar 35', model = 'wall35', structKind = 'wall' },
    { label = 'Mouse Duvar 36', model = 'wall36', structKind = 'wall' },
    { label = 'Mouse Duvar 37', model = 'wall37', structKind = 'wall' },
    { label = 'Mouse Duvar 38', model = 'wall38', structKind = 'wall' },
    { label = 'Mouse Duvar 39', model = 'wall39', structKind = 'wall' },
    { label = 'Mouse Duvar 40', model = 'wall40', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 01', model = 'halfwall01', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 02', model = 'halfwall02', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 03', model = 'halfwall03', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 04', model = 'halfwall04', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 05', model = 'halfwall05', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 06', model = 'halfwall06', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 07', model = 'halfwall07', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 08', model = 'halfwall08', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 09', model = 'halfwall09', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 10', model = 'halfwall10', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 11', model = 'halfwall11', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 12', model = 'halfwall12', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 13', model = 'halfwall13', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 14', model = 'halfwall14', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 15', model = 'halfwall15', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 16', model = 'halfwall16', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 17', model = 'halfwall17', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 18', model = 'halfwall18', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 19', model = 'halfwall19', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 20', model = 'halfwall20', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 21', model = 'halfwall21', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 22', model = 'halfwall22', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 23', model = 'halfwall23', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 24', model = 'halfwall24', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 25', model = 'halfwall25', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 26', model = 'halfwall26', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 27', model = 'halfwall27', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 28', model = 'halfwall28', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 29', model = 'halfwall29', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 30', model = 'halfwall30', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 31', model = 'halfwall31', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 32', model = 'halfwall32', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 33', model = 'halfwall33', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 34', model = 'halfwall34', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 35', model = 'halfwall35', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 36', model = 'halfwall36', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 37', model = 'halfwall37', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 38', model = 'halfwall38', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 39', model = 'halfwall39', structKind = 'wall' },
    { label = 'Mouse Yarım Duvar 40', model = 'halfwall40', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 01', model = 'longwall01', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 02', model = 'longwall02', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 03', model = 'longwall03', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 04', model = 'longwall04', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 05', model = 'longwall05', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 06', model = 'longwall06', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 07', model = 'longwall07', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 08', model = 'longwall08', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 09', model = 'longwall09', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 10', model = 'longwall10', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 11', model = 'longwall11', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 12', model = 'longwall12', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 13', model = 'longwall13', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 14', model = 'longwall14', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 15', model = 'longwall15', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 16', model = 'longwall16', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 17', model = 'longwall17', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 18', model = 'longwall18', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 19', model = 'longwall19', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 20', model = 'longwall20', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 21', model = 'longwall21', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 22', model = 'longwall22', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 23', model = 'longwall23', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 24', model = 'longwall24', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 25', model = 'longwall25', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 26', model = 'longwall26', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 27', model = 'longwall27', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 28', model = 'longwall28', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 29', model = 'longwall29', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 30', model = 'longwall30', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 31', model = 'longwall31', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 32', model = 'longwall32', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 33', model = 'longwall33', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 34', model = 'longwall34', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 35', model = 'longwall35', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 36', model = 'longwall36', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 37', model = 'longwall37', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 38', model = 'longwall38', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 39', model = 'longwall39', structKind = 'wall' },
    { label = 'Mouse Uzun Duvar 40', model = 'longwall40', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x1 #1', model = 'small_1x1', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x1 #2', model = 'small_1x1_1', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x1 #3', model = 'small_1x1_2', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x1 #4', model = 'small_1x1_3', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x1 #5', model = 'small_1x1_4', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x1 #6', model = 'small_1x1_5', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x1 #7', model = 'small_1x1_6', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x2 #8', model = 'small_1x2', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x2 #9', model = 'small_1x2_1', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x2 #10', model = 'small_1x2_2', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x2 #11', model = 'small_1x2_3', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x2 #12', model = 'small_1x2_4', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x2 #13', model = 'small_1x2_5', structKind = 'wall' },
    { label = 'VG Modüler Blok 1x2 #14', model = 'small_1x2_6', structKind = 'wall' },
    { label = 'Mouse Zemin 01', model = 'floor01', structKind = 'floor' },
    { label = 'Mouse Zemin 02', model = 'floor02', structKind = 'floor' },
    { label = 'Mouse Zemin 03', model = 'floor03', structKind = 'floor' },
    { label = 'Mouse Zemin 04', model = 'floor04', structKind = 'floor' },
    { label = 'Mouse Zemin 05', model = 'floor05', structKind = 'floor' },
    { label = 'Mouse Zemin 06', model = 'floor06', structKind = 'floor' },
    { label = 'Mouse Zemin 07', model = 'floor07', structKind = 'floor' },
    { label = 'Mouse Zemin 08', model = 'floor08', structKind = 'floor' },
    { label = 'Mouse Zemin 09', model = 'floor09', structKind = 'floor' },
    { label = 'Mouse Zemin 10', model = 'floor10', structKind = 'floor' },
    { label = 'Mouse Zemin 11', model = 'floor11', structKind = 'floor' },
    { label = 'Mouse Zemin 12', model = 'floor12', structKind = 'floor' },
    { label = 'Mouse Zemin 13', model = 'floor13', structKind = 'floor' },
    { label = 'Mouse Zemin 15', model = 'floor15', structKind = 'floor' },
    { label = 'Mouse Zemin 16', model = 'floor16', structKind = 'floor' },
    { label = 'Mouse Zemin 17', model = 'floor17', structKind = 'floor' },
    { label = 'Mouse Zemin 18', model = 'floor18', structKind = 'floor' },
    { label = 'Mouse Zemin 19', model = 'floor19', structKind = 'floor' },
    { label = 'Mouse Zemin 20', model = 'floor20', structKind = 'floor' },
    { label = 'Mouse Zemin 21', model = 'floor21', structKind = 'floor' },
    { label = 'Mouse Zemin 22', model = 'floor22', structKind = 'floor' },
    { label = 'Mouse Zemin 23', model = 'floor23', structKind = 'floor' },
    { label = 'Mouse Zemin 24', model = 'floor24', structKind = 'floor' },
    { label = 'Mouse Zemin 25', model = 'floor25', structKind = 'floor' },
    { label = 'Mouse Zemin 26', model = 'floor26', structKind = 'floor' },
    { label = 'Mouse Zemin 27', model = 'floor27', structKind = 'floor' },
    { label = 'Mouse Zemin 28', model = 'floor28', structKind = 'floor' },
    { label = 'Mouse Zemin 29', model = 'floor29', structKind = 'floor' },
    { label = 'Mouse Zemin 30', model = 'floor30', structKind = 'floor' },
  }
},

{
    category = 'Bar Eşyaları',
    items = {
        {model = 'prop_whiskey_glasses'},
        {model = 'prop_tequila_bottle'},
        {model = 'prop_irish_sign_01'},
        {model = 'prop_bar_pump_06'},
        {model = 'prop_pitcher_02'},
        {model = 'prop_pinacolada'},
        {model = 'prop_cockneon'},
        {model = 'prop_beer_amopen'},
        {model = 'prop_bikerset'},
        {model = 'prop_champ_jer_01b'},
        {model = 'prop_glass_stack_08'},
        {model = 'prop_drink_champ'},
        {model = 'vodkarow'},
        {model = 'prop_bottle_cognac'},
        {model = 'prop_bar_pump_08'},
        {model = 'prop_tall_glass'},
        {model = 'prop_bar_measrjug'},
        {model = 'prop_bar_fridge_02'},
        {model = 'prop_bar_cooler_03'},
        {model = 'prop_bar_drinkstraws'},
        {model = 'prop_bar_stool_01'},
        {model = 'prop_optic_vodka'},
        {model = 'prop_stripmenu'},
        {model = 'prop_ragganeon'},
        {model = 'beerrow_world'},
        {model = 'prop_bar_pump_01'},
        {model = 'prop_barrachneon'},
        {model = 'prop_bar_coasterdisp'},
        {model = 'prop_bar_shots'},
        {model = 'prop_bar_stirrers'},
        {model = 'prop_bar_napkindisp'},
        {model = 'prop_bar_lemons'},
        {model = 'prop_bar_beans'},
        {model = 'prop_bar_cockshaker'},
        {model = 'prop_irish_sign_02'},
        {model = 'prop_bar_caddy'},
        {model = 'prop_bar_limes'},
        {model = 'prop_beerneon'},
        {model = 'prop_champ_cool'},
        {model = 'prop_bar_pump_07'},
        {model = 'beerrow_local'},
        {model = 'prop_bahammenu'},
        {model = 'prop_patriotneon'},
        {model = 'prop_bar_ice_01'},
        {model = 'prop_beer_logopen'},
        {model = 'prop_bar_fruit'},
        {model = 'prop_bar_fridge_01'},
        {model = 'prop_bar_fridge_04'},
        {model = 'prop_bar_sink_01'},
        {model = 'prop_irish_sign_03'},
        {model = 'prop_glass_stack_10'},
        {model = 'prop_bar_beerfridge_01'},
        {model = 'prop_loggneon'},
        {model = 'spiritsrow'},
        {model = 'prop_bar_fridge_03'},
        {model = 'prop_drink_whisky'},
        {model = 'prop_glass_stack_05'},
        {model = 'winerow'},
        {model = 'prop_stripset'},
        {model = 'prop_bar_cooler_01'},
        {model = 'prop_drinkmenu'},
    }
},

{
    category = 'Banyo',
    items = {
        {model = 'prop_towel_01'},
        {model = 'prop_toilet_soap_04'},
        {model = 'v_res_mbtaps'},
        {model = 'prop_toilet_roll_05'},
        {model = 'v_res_r_perfume'},
        {model = 'prop_toilet_soap_03'},
        {model = 'v_serv_bs_looroll'},
        {model = 'v_res_tt_looroll'},
        {model = 'v_res_mbtowelfld'},
        {model = 'prop_towel_rail_01'},
        {model = 'prop_toilet_shamp_01'},
        {model = 'prop_toilet_roll_02'},
        {model = 'prop_toothbrush_01'},
        {model = 'prop_toothpaste_01'},
        {model = 'prop_toilet_soap_02'},
        {model = 'v_res_mbath'},
        {model = 'prop_toilet_brush_01'},
        {model = 'prop_w_fountain_01'},
        {model = 'prop_shower_rack_01'},
        {model = 'prop_toilet_soap_01'},
        {model = 'prop_soap_disp_01'},
        {model = 'v_res_r_cottonbuds'},
        {model = 'prop_sink_04'},
        {model = 'prop_toilet_02'},
        {model = 'prop_sponge_01'},
        {model = 'prop_toilet_roll_01'},
        {model = 'prop_toilet_01'},
        {model = 'prop_sink_06'},
        {model = 'prop_toothb_cup_01'},
        {model = 'prop_toilet_shamp_02'},
        {model = 'v_res_mbathpot'},
        {model = 'prop_towel_rail_02'},
        {model = 'v_res_r_bublbath'},
        {model = 'v_res_r_lotion'},
        {model = 'v_res_mbaccessory'},
        {model = 'prop_sink_05'},
        {model = 'v_res_mbsink'},
        {model = 'prop_sink_02'},
        {model = 'v_res_mbtowel'},
        {model = 'prop_handdry_02'},
        {model = 'prop_handdry_01'},
    }
},

{
    category = 'Çöp Kutuları',
    items = {
        {model = 'prop_bin_07b'},
        {model = 'prop_bin_beach_01d'},
        {model = 'prop_bin_01a'},
        {model = 'prop_bin_beach_01a'},
        {model = 'prop_recyclebin_03_a'},
        {model = 'prop_bin_07c'},
        {model = 'prop_bin_07d'},
        {model = 'prop_bin_08a'},
        {model = 'prop_bin_08open'},
        {model = 'prop_bin_12a'},
        {model = 'prop_bin_05a'},
    }
},

{
    category = 'İnşaat',
    items = {
        {model = 'prop_tool_blowtorch'},
        {model = 'prop_worklight_04b'},
        {model = 'prop_paint_wpaper01'},
        {model = 'prop_worklight_04c_l1'},
        {model = 'prop_paints_can07'},
        {model = 'prop_paints_can03'},
        {model = 'prop_medstation_03'},
        {model = 'prop_worklight_03a'},
        {model = 'prop_worklight_01a'},
        {model = 'prop_paint_brush03'},
        {model = 'prop_tool_cable01'},
        {model = 'prop_tool_screwdvr03'},
        {model = 'prop_tool_fireaxe'},
        {model = 'prop_paint_brush02'},
        {model = 'prop_tool_bluepnt'},
        {model = 'prop_tool_pickaxe'},
        {model = 'prop_tool_jackham'},
        {model = 'prop_oiltub_04'},
        {model = 'prop_oiltub_06'},
        {model = 'prop_crosssaw_01'},
        {model = 'prop_tool_nailgun'},
        {model = 'prop_tool_shovel5'},
        {model = 'prop_paints_can01'},
        {model = 'prop_worklight_04d'},
        {model = 'prop_generator_03a'},
        {model = 'prop_tool_spanner02'},
        {model = 'prop_tool_torch'},
        {model = 'prop_oiltub_02'},
        {model = 'prop_tool_box_05'},
        {model = 'prop_tool_box_02'},
        {model = 'prop_tool_rake'},
        {model = 'prop_paint_brush05'},
        {model = 'prop_paints_pallete01'},
        {model = 'prop_tool_shovel3'},
        {model = 'prop_paint_stepl01'},
        {model = 'prop_etricmotor_01'},
        {model = 'prop_tool_shovel006'},
        {model = 'prop_cons_crate'},
        {model = 'prop_generator_01a'},
        {model = 'prop_worklight_04a'},
        {model = 'prop_tool_shovel'},
        {model = 'prop_wheelbarrow01a'},
        {model = 'prop_tool_drill'},
        {model = 'prop_tool_screwdvr02'},
        {model = 'prop_medstation_01'},
        {model = 'prop_tool_rake_l1'},
        {model = 'prop_paint_brush04'},
        {model = 'prop_bandsaw_01'},
        {model = 'prop_paint_tray'},
        {model = 'prop_tool_box_04'},
        {model = 'prop_tool_cable02'},
        {model = 'prop_vertdrill_01'},
        {model = 'prop_tool_consaw'},
        {model = 'prop_cementbags01'},
        {model = 'prop_tool_spanner01'},
        {model = 'prop_worklight_04b_l1'},
        {model = 'prop_paint_roller'},
        {model = 'prop_tool_hardhat'},
        {model = 'prop_tool_bench02_ld'},
        {model = 'prop_paints_can05'},
        {model = 'prop_paints_bench01'},
        {model = 'prop_tool_broom2'},
        {model = 'prop_paints_can04'},
        {model = 'prop_cementmixer_01a'},
        {model = 'prop_paints_can02'},
        {model = 'prop_tool_broom'},
        {model = 'prop_ducktape_01'},
        {model = 'prop_tool_box_07'},
        {model = 'prop_girder_01a'},
        {model = 'prop_workwall_02'},
        {model = 'prop_generator_02a'},
        {model = 'prop_tool_broom2_l1'},
        {model = 'prop_paint_spray01a'},
        {model = 'prop_tool_shovel2'},
        {model = 'prop_tool_mopbucket'},
        {model = 'prop_tool_hammer'},
        {model = 'prop_tablesaw_01'},
        {model = 'prop_oiltub_01'},
        {model = 'prop_worklight_02a'},
        {model = 'prop_oiltub_05'},
        {model = 'prop_tool_adjspanner'},
        {model = 'prop_tool_sledgeham'},
        {model = 'prop_tool_pliers'},
        {model = 'prop_generator_04'},
        {model = 'prop_tool_shovel4'},
        {model = 'prop_tool_box_01'},
        {model = 'prop_wheelbarrow02a'},
        {model = 'prop_medstation_02'},
        {model = 'prop_tool_box_03'},
        {model = 'prop_worklight_04c'},
        {model = 'prop_tool_bench02'},
        {model = 'prop_tool_spanner03'},
        {model = 'prop_worklight_03b'},
        {model = 'prop_paints_can06'},
        {model = 'prop_paint_brush01'},
        {model = 'prop_tool_wrench'},
        {model = 'prop_spraygun_01'},
        {model = 'prop_worklight_04d_l1'},
        {model = 'prop_oiltub_03'},
        {model = 'prop_paint_spray01b'},
        {model = 'prop_tool_mallet'},
        {model = 'prop_cementmixer_02a'},
        {model = 'prop_tool_screwdvr01'},
        {model = 'hei_prop_cash_crate_empty'},
        {model = 'hei_prop_cash_crate_half_full'},
        {model = 'p_blueprints_01_s'},
    }
},

{
    category = 'Elektrik',
    items = {
        {model = 'prop_tv_flat_03b'},
        {model = 'v_res_monitorsquare'},
        {model = 'v_club_roc_mscreen'},
        {model = 'v_res_harddrive'},
        {model = 'prop_ghettoblast_02'},
        {model = 'prop_speaker_01'},
        {model = 'prop_cctv_cont_06'},
        {model = 'prop_tv_01'},
        {model = 'prop_laptop_01a'},
        {model = 'prop_tv_flat_michael'},
        {model = 'prop_laptop_lester2'},
        {model = 'prop_tv_flat_01'},
        {model = 'prop_monitor_w_large'},
        {model = 'prop_dj_deck_02'},
        {model = 'prop_speaker_07'},
        {model = 'prop_mouse_02'},
        {model = 'prop_cctv_01_sm_02'},
        {model = 'v_res_fa_radioalrm'},
        {model = 'prop_tv_flat_02b'},
        {model = 'v_club_roc_spot_b'},
        {model = 'prop_portable_hifi_01'},
        {model = 'prop_monitor_01d'},
        {model = 'prop_monitor_01c'},
        {model = 'v_res_mousemat'},
        {model = 'prop_el_tapeplayer_01'},
        {model = 'prop_dj_deck_01'},
        {model = 'apa_mp_h_acc_coffeemachine_01'},
        {model = 'des_tvsmash_start'},
        {model = 'prop_tv_03'},
        {model = 'xm_prop_x17_tv_ceiling_01'},
        {model = 'prop_monitor_02'},
        {model = 'prop_tv_cabinet_04'},
        {model = 'v_res_monitor'},
        {model = 'prop_cctv_cont_02'},
        {model = 'v_res_keyboard'},
        {model = 'prop_dyn_pc'},
        {model = 'v_res_monitorwidelarge'},
        {model = 'v_res_pcheadset'},
        {model = 'v_res_pctower'},
        {model = 'prop_speaker_02'},
        {model = 'prop_amp_01'},
        {model = 'prop_laptop_02_closed'},
        {model = 'prop_monitor_li'},
        {model = 'prop_laptop_lester'},
        {model = 'prop_monitor_03b'},
        {model = 'prop_mouse_01b'},
        {model = 'v_res_vhsplayer'},
        {model = 'v_club_vu_deckcase'},
        {model = 'v_club_roc_micstd'},
        {model = 'v_res_ipoddock'},
        {model = 'prop_cctv_unit_04'},
        {model = 'prop_cs_tv_stand'},
        {model = 'prop_till_01_dam'},
        {model = 'prop_till_01'},
        {model = 'prop_cs_keyboard_01'},
        {model = 'prop_keyboard_01a'},
        {model = 'prop_cs_dvd_player'},
        {model = 'v_res_vacuum'},
        {model = 'prop_keyboard_01b'},
        {model = 'v_res_tt_tvremote'},
        {model = 'v_club_roc_spot_w'},
        {model = 'prop_trev_tv_01'},
        {model = 'prop_tv_flat_03'},
        {model = 'v_res_mm_audio'},
    }
},

{
    category = 'Ekipman',
    items = {
        {model = 'hei_p_attache_case_shut'},
        {model = 'p_cs_panties_03_s'},
        {model = 'p_cs_cuffs_02_s'},
        {model = 'p_cs_duffel_01_s'},
        {model = 'p_cs_police_torch_s'},
        {model = 'p_ld_heist_bag_s_1'},
        {model = 'p_ld_heist_bag_s_2'},
        {model = 'p_ld_heist_bag_s_pro'},
        {model = 'p_michael_backpack_s'},
        {model = 'p_s_scuba_tank_s'},
        {model = 'stt_prop_c4_stack'},
    }
},

{
    category = 'Garaj',
    items = {
        {model = 'prop_car_seat'},
        {model = 'prop_bumper_06'},
        {model = 'prop_wheel_rim_03'},
        {model = 'prop_compressor_02'},
        {model = 'prop_wheel_01'},
        {model = 'prop_wheel_hub_01'},
        {model = 'prop_engine_hoist'},
        {model = 'prop_toolchest_02'},
        {model = 'prop_carcreeper'},
        {model = 'prop_spray_jackleg'},
        {model = 'prop_compressor_01'},
        {model = 'prop_bumper_05'},
        {model = 'prop_car_bonnet_02'},
        {model = 'prop_toolchest_03'},
        {model = 'prop_car_bonnet_01'},
        {model = 'prop_toolchest_03_l2'},
        {model = 'prop_car_exhaust_01'},
        {model = 'prop_car_door_04'},
        {model = 'prop_car_battery_01'},
        {model = 'prop_toolchest_01'},
        {model = 'prop_car_door_02'},
        {model = 'prop_carjack_l2'},
        {model = 'prop_bumper_02'},
        {model = 'prop_wheel_06'},
        {model = 'prop_toolchest_05'},
        {model = 'prop_bumper_04'},
        {model = 'prop_wheel_03'},
        {model = 'prop_wheel_rim_05'},
        {model = 'prop_wheel_rim_02'},
        {model = 'prop_car_door_01'},
        {model = 'prop_wheel_rim_04'},
        {model = 'prop_car_door_03'},
        {model = 'prop_wheel_04'},
        {model = 'prop_wheel_02'},
        {model = 'prop_wheel_05'},
        {model = 'prop_carjack'},
        {model = 'prop_bumper_03'},
        {model = 'prop_car_engine_01'},
        {model = 'prop_toolchest_04'},
        {model = 'prop_bumper_01'},
        {model = 'prop_wheel_tyre'},
        {model = 'prop_wheel_rim_01'},
        {model = 'prop_compressor_03'},
        {model = 'prop_wheel_hub_02_lod_02'},
    }
},

{
    category = 'Endüstriyel',
    items = {
        {model = 'prop_luggage_04a'},
        {model = 'prop_byard_lifering'},
        {model = 'prop_oil_guage_01'},
        {model = 'prop_mb_crate_01a'},
        {model = 'prop_rail_sign04'},
        {model = 'prop_ind_mech_03a'},
        {model = 'prop_rail_sigbox01'},
        {model = 'prop_air_trailer_2b'},
        {model = 'prop_mb_cargo_01a'},
        {model = 'prop_luggage_09a'},
        {model = 'prop_byard_chains01'},
        {model = 'prop_byard_phone'},
        {model = 'prop_luggage_03a'},
        {model = 'prop_byard_gastank02'},
        {model = 'prop_luggage_01a'},
        {model = 'prop_ind_mech_04a'},
        {model = 'prop_air_cargo_04a'},
        {model = 'prop_mb_crate_01b'},
        {model = 'prop_air_cargo_04c'},
        {model = 'prop_luggage_07a'},
        {model = 'prop_luggage_05a'},
        {model = 'prop_luggage_08a'},
        {model = 'prop_byard_motor_02'},
        {model = 'prop_mb_cargo_04a'},
        {model = 'prop_luggage_06a'},
        {model = 'prop_air_trailer_2a'},
        {model = 'prop_air_cargo_04b'},
        {model = 'hei_prop_carrier_liferafts'},
        {model = 'hei_prop_carrier_light_01'},
        {model = 'hei_prop_carrier_lightset_1'},
        {model = 'hei_prop_hei_warehousetrolly'},
        {model = 'hei_prop_hei_ammo_pile'},
    }
},

{
    category = 'İç Mekan',
    items = {
        {model = 'apa_mp_h_acc_rugwooll_03'},
        {model = 'apa_mp_h_acc_rugwoolm_01'},
        {model = 'apa_mp_h_acc_rugwoolm_02'},
        {model = 'apa_mp_h_acc_rugwools_03'},
        {model = 'hei_heist_str_avunitl_03'},
        {model = 'hei_heist_stn_benchshort'},
        {model = 'hei_p_m_bag_var18_bus_s'},
        {model = 'hei_prop_bank_alarm_01'},
        {model = 'hei_prop_bank_cctv_01'},
        {model = 'hei_prop_bank_cctv_02'},
        {model = 'hei_prop_cc_metalcover_01'},
        {model = 'hei_prop_drug_statue_01'},
        {model = 'hei_prop_drug_statue_stack'},
        {model = 'hei_prop_hei_bank_mon'},
        {model = 'hei_prop_gold_trolly_half_full'},
        {model = 'hei_prop_hei_bank_phone_01'},
        {model = 'hei_prop_hei_bnk_lamp_01'},
        {model = 'hei_prop_hei_bnk_lamp_02'},
        {model = 'hei_prop_hei_bust_01'},
        {model = 'hei_prop_hei_carrier_disp_01'},
        {model = 'hei_prop_hei_cs_keyboard'},
        {model = 'hei_prop_hei_drug_case'},
        {model = 'hei_prop_hei_lflts_02'},
        {model = 'hei_prop_hei_med_benchset1'},
        {model = 'hei_prop_heist_apecrate'},
        {model = 'hei_prop_heist_drug_tub_01'},
        {model = 'hei_prop_heist_pc_01'},
        {model = 'hei_prop_heist_tub_truck'},
        {model = 'hei_prop_mini_sever_01'},
        {model = 'hei_prop_wall_light_10a_cr'},
        {model = 'ng_proc_coffee_01a'},
        {model = 'ng_proc_food_bag01a'},
        {model = 'ng_proc_oilcan01a'},
        {model = 'ng_proc_litter_plasbot1'},
        {model = 'p_amanda_note_01_s'},
        {model = 'p_cctv_s'},
        {model = 'p_controller_01_s'},
        {model = 'p_champ_flute_s'},
        {model = 'p_cs_newspaper_s'},
        {model = 'p_cs_scissors_s'},
        {model = 'p_cs_trolley_01_s'},
        {model = 'p_defilied_ragdoll_01_s'},
        {model = 'p_kitch_juicer_s'},
        {model = 'p_laptop_02_s'},
        {model = 'p_lestersbed_s'},
        {model = 'p_mbbed_s'},
        {model = 'apa_mp_h_bed_double_08'},
        {model = 'apa_mp_h_bed_double_09'},
        {model = 'gr_prop_bunker_bed_01'},
        {model = 'apa_mp_h_bed_wide_05'},
        {model = 'apa_mp_h_yacht_bed_02'},
        {model = 'p_sec_case_02_s'},
        {model = 'p_syringe_01_s'},
        {model = 'p_till_01_s'},
        {model = 'p_tourist_map_01_s'},
        {model = 'p_tv_cam_02_s'},
        {model = 'p_v_43_safe_s'},
        {model = 'p_v_res_tt_bed_s'},
        {model = 'p_w_grass_gls_s'},
        {model = 'prop_train_ticket_02_tu'},
        {model = 'prop_vend_snak_01_tu'},
        {model = 'prop_xmas_tree_int'},
        {model = 'prop_wheelchair_01_s'},
        {model = 'v_ilev_acet_projector'},
        {model = 'v_ilev_fh_dineeamesa'},
        {model = 'v_ilev_lest_bigscreen'},
        {model = 'v_ilev_liconftable_sml'},
        {model = 'v_ilev_mm_fridgeint'},
        {model = 'v_ilev_mm_screen'},
        {model = 'v_ilev_mr_rasberryclean'},
        {model = 'v_ilev_ra_doorsafe'},
        {model = 'v_ilev_ta_tatgun'},
        {model = 'v_ilev_tort_stool'},
        {model = 'v_ilev_trev_pictureframe'},
        {model = 'v_res_msonbed_s'},
        {model = 'w_am_baseball'},
        {model = 'w_am_case'},
        {model = 'w_am_brfcase'},
        {model = 'w_am_fire_exting'},
        {model = 'w_am_jerrycan'},
    }
},

{
    category = 'Mutfak',
    items = {
        {model = 'v_res_mkniferack'},
        {model = 'prop_pot_03'},
        {model = 'v_res_foodjara'},
        {model = 'v_ret_ta_paproll'},
        {model = 'prop_mug_02'},
        {model = 'prop_kitch_pot_fry'},
        {model = 'v_res_foodjarb'},
        {model = 'v_serv_bs_mug'},
        {model = 'prop_mug_03'},
        {model = 'prop_plate_02'},
        {model = 'prop_plate_01'},
        {model = 'v_ret_fh_plate1'},
        {model = 'v_res_tre_fridge'},
        {model = 'v_res_mknifeblock'},
        {model = 'v_res_mplatelrg'},
        {model = 'v_res_tt_bowlpile02'},
        {model = 'v_ret_fh_ironbrd'},
        {model = 'prop_cleaver'},
        {model = 'prop_kettle'},
        {model = 'prop_mug_04'},
        {model = 'prop_knife_stand'},
        {model = 'v_ret_gc_cup'},
        {model = 'prop_cooker_03'},
        {model = 'prop_kettle_01'},
        {model = 'prop_lime_jar'},
        {model = 'v_res_fa_pottea'},
        {model = 'v_ret_fh_dryer'},
        {model = 'v_res_fa_basket'},
        {model = 'v_res_mmug'},
        {model = 'v_res_mplatesml'},
        {model = 'prop_kitch_pot_lrg2'},
        {model = 'prop_pot_01'},
        {model = 'prop_toaster_02'},
        {model = 'v_res_tt_plate01'},
        {model = 'prop_pot_04'},
        {model = 'v_ret_ta_paproll2'},
        {model = 'v_res_pestle'},
        {model = 'prop_micro_04'},
        {model = 'prop_breadbin_01'},
        {model = 'v_res_cakedome'},
        {model = 'v_res_fa_grater'},
        {model = 'prop_wok'},
        {model = 'prop_pot_rack'},
        {model = 'prop_fridge_03'},
        {model = 'prop_washer_01'},
        {model = 'v_ret_fh_washmach'},
        {model = 'v_ret_fh_plate2'},
        {model = 'prop_foodprocess_01'},
        {model = 'prop_micro_01'},
        {model = 'prop_fridge_01'},
        {model = 'prop_whisk'},
        {model = 'v_res_mutensils'},
        {model = 'prop_kitch_juicer'},
        {model = 'prop_micro_02'},
        {model = 'prop_washer_03'},
        {model = 'v_res_fa_chopbrd'},
        {model = 'v_res_fridgemoda'},
    }
},

{
    category = 'Çeşitli',
    items = {
        {model = 'prop_cs_ilev_blind_01'},
        {model = 'prop_amanda_note_01'},
        {model = 'prop_tennis_rack_01'},
        {model = 'prop_sandwich_01'},
        {model = 'prop_space_pistol'},
        {model = 'prop_cs_film_reel_01'},
        {model = 'prop_cs_duffel_01b'},
        {model = 'prop_cs_server_drive'},
        {model = 'prop_mem_candle_combo'},
        {model = 'prop_police_radio_main'},
        {model = 'prop_cash_case_02'},
        {model = 'prop_pineapple'},
        {model = 'prop_cs_amanda_shoe'},
        {model = 'prop_cliff_paper'},
        {model = 'prop_cs_phone_01'},
        {model = 'prop_broken_cboard_p1'},
        {model = 'prop_cd_folder_pile1'},
        {model = 'prop_controller_01'},
        {model = 'prop_gun_case_01'},
        {model = 'prop_ecg_01'},
        {model = 'p_cs_bottle_01'},
        {model = 'prop_cash_pile_01'},
        {model = 'prop_cs_plate_01'},
        {model = 'prop_ear_defenders_01'},
        {model = 'prop_ld_crocclips01'},
        {model = 'prop_cs_mini_tv'},
        {model = 'prop_nigel_bag_pickup'},
        {model = 'prop_boombox_01'},
        {model = 'prop_drug_package'},
        {model = 'prop_mil_crate_01'},
        {model = 'prop_weld_torch'},
        {model = 'prop_trevor_rope_01'},
        {model = 'prop_cs_gascutter_1'},
        {model = 'prop_cd_paper_pile3'},
        {model = 'prop_energy_drink'},
        {model = 'prop_megaphone_01'},
        {model = 'prop_cs_petrol_can'},
        {model = 'prop_ld_bomb_anim'},
        {model = 'prop_cs_bowl_01b'},
        {model = 'p_ing_microphonel_01'},
        {model = 'prop_devin_box_01'},
        {model = 'prop_hard_hat_01'},
        {model = 'prop_rope_family_3'},
        {model = 'prop_anim_cash_pile_01'},
        {model = 'prop_weed_pallet'},
        {model = 'prop_big_shit_02'},
        {model = 'prop_cs_milk_01'},
        {model = 'prop_cs_duffel_01'},
        {model = 'prop_iron_01'},
        {model = 'prop_gold_cont_01'},
        {model = 'prop_cs_photoframe_01'},
        {model = 'prop_table_mic_01'},
        {model = 'prop_cs_walkie_talkie'},
        {model = 'prop_tv_cam_02'},
        {model = 'prop_blox_spray'},
        {model = 'prop_idol_case_02'},
        {model = 'prop_cs_crisps_01'},
        {model = 'prop_ld_flow_bottle'},
        {model = 'prop_cash_pile_02'},
        {model = 'prop_cs_trowel'},
        {model = 'prop_flight_box_01'},
        {model = 'prop_cs_bs_cup'},
        {model = 'prop_mil_crate_02'},
        {model = 'prop_peanut_bowl_01'},
        {model = 'prop_drug_package_02'},
        {model = 'prop_cs_sink_filler'},
        {model = 'prop_ld_headset_01'},
        {model = 'prop_cs_leg_chain_01'},
        {model = 'prop_cash_depot_billbrd'},
        {model = 'prop_cs_mopbucket_01'},
        {model = 'prop_cs_cctv'},
        {model = 'prop_cs_kettle_01'},
        {model = 'prop_cs_hand_radio'},
        {model = 'prop_peyote_lowland_02'},
        {model = 'prop_cs_cashenvelope'},
        {model = 'p_rc_handset'},
        {model = 'prop_cs_ironing_board'},
        {model = 'prop_cash_case_01'},
        {model = 'prop_mp3_dock'},
        {model = 'prop_cs_beer_box'},
        {model = 'prop_ld_gold_chest'},
        {model = 'prop_cs_wrench'},
        {model = 'prop_cs_burger_01'},
        {model = 'prop_shower_towel'},
        {model = 'prop_cs_rub_box_01'},
        {model = 'prop_cs_hotdog_01'},
        {model = 'prop_cs_toaster'},
        {model = 'prop_ld_wallet_pickup'},
        {model = 'prop_coffin_02'},
        {model = 'prop_cs_dildo_01'},
        {model = 'prop_pliers_01'},
        {model = 'prop_sewing_machine'},
        {model = 'prop_cs_lester_crate'},
        {model = 'prop_headset_01'},
        {model = 'prop_beer_box_01'},
        {model = 'prop_makeup_brush'},
        {model = 'prop_anim_cash_pile_02'},
        {model = 'prop_cs_gascutter_2'},
        {model = 'prop_cash_crate_01'},
        {model = 'prop_rail_controller'},
        {model = 'prop_mp_drug_package'},
        {model = 'prop_ld_fireaxe'},
        {model = 'prop_proxy_hat_01'},
        {model = 'prop_tv_test'},
        {model = 'prop_cs_clothes_box'},
        {model = 'prop_binoc_01'},
        {model = 'prop_ld_shovel'},
        {model = 'prop_premier_fence_02'},
        {model = 'prop_cs_sink_filler_02'},
        {model = 'prop_hockey_bag_01'},
        {model = 'prop_fbi3_coffee_table'},
        {model = 'prop_ld_fags_01'},
        {model = 'prop_coke_block_01'},
        {model = 'prop_devin_rope_01'},
        {model = 'prop_bongos_01'},
        {model = 'prop_glass_suck_holder'},
        {model = 'prop_welding_mask_01'},
        {model = 'prop_cs_steak'},
        {model = 'prop_cs_street_binbag_01'},
        {model = 'prop_tea_trolly'},
        {model = 'prop_cs_trolley_01'},
        {model = 'prop_gold_cont_01b'},
        {model = 'prop_sh_mr_rasp_01'},
    }
},

{
    category = 'Ofis',
    items = {
        {model = 'prop_cleaning_trolly'},
        {model = 'prop_copier_01'},
        {model = 'v_res_printer'},
        {model = 'prop_folder_02'},
        {model = 'prop_water_bottle_dark'},
        {model = 'prop_paper_box_02'},
        {model = 'v_res_paperfolders'},
        {model = 'prop_coathook_01'},
        {model = 'prop_off_chair_01'},
        {model = 'v_ret_gc_chair03'},
        {model = 'prop_paper_box_05'},
        {model = 'v_ret_gc_fax'},
        {model = 'v_res_binder'},
        {model = 'prop_off_chair_04b'},
        {model = 'prop_off_chair_04'},
        {model = 'v_corp_cd_chair'},
        {model = 'v_serv_tc_bin2_'},
        {model = 'v_ret_gc_pen1'},
        {model = 'prop_inout_tray_02'},
        {model = 'v_res_cd'},
        {model = 'v_ret_gc_staple'},
        {model = 'prop_cabinet_01b'},
        {model = 'prop_paper_box_04'},
        {model = 'prop_cabinet_01'},
        {model = 'v_ret_gc_scissors'},
        {model = 'v_serv_tc_bin1_'},
        {model = 'v_corp_offchair'},
        {model = 'prop_fan_01'},
        {model = 'prop_paper_box_01'},
        {model = 'prop_wait_bench_01'},
        {model = 'prop_fax_01'},
        {model = 'v_ret_gc_shred'},
        {model = 'prop_folder_01'},
        {model = 'v_ret_gc_folder2'},
        {model = 'prop_printer_01'},
        {model = 'prop_office_phone_tnt'},
        {model = 'prop_off_chair_05'},
        {model = 'prop_office_desk_01'},
        {model = 'v_ret_gc_phone'},
        {model = 'v_ret_gc_print'},
        {model = 'v_res_officeboxfile01'},
        {model = 'prop_water_bottle'},
        {model = 'prop_off_chair_03'},
        {model = 'prop_fib_coffee'},
        {model = 'prop_watercooler'},
        {model = 'prop_office_alarm_01'},
        {model = 'prop_waiting_seat_01'},
        {model = 'prop_cabinet_02b'},
        {model = 'prop_shredder_01'},
        {model = 'prop_paper_box_03'},
        {model = 'v_club_officechair'},
        {model = 'v_corp_bk_chair3'},
        {model = 'prop_off_phone_01'},
        {model = 'prop_printer_02'},
        {model = 'prop_watercooler_dark'},
        {model = 'prop_inout_tray_01'},
        {model = 'watercooler_bottle001'},
        {model = 'prop_fib_clipboard'},
        {model = 'v_ret_gc_trays'},
        {model = 'v_res_cdstorage'},
        {model = 'prop_fib_ashtray_01'},
        {model = 'prop_sol_chair'},
        {model = 'v_ret_gc_folder1'},
        {model = 'v_res_desktidy'},
        {model = 'prop_tablesmall_01'},
        {model = 'v_ret_gc_pen2'},
    }
},

{
    category = 'Dış Mekan',
    items = {
        {model = 'hei_prop_heist_weed_pallet'},
        {model = 'hei_prop_heist_weed_pallet_02'},
        {model = 'hei_prop_heist_weed_block_01b'},
        {model = 'ind_prop_firework_01'},
        {model = 'ind_prop_firework_03'},
        {model = 'ind_prop_firework_02'},
        {model = 'ind_prop_firework_04'},
        {model = 'ng_proc_binbag_01a'},
        {model = 'ng_proc_box_02a'},
        {model = 'ng_proc_coffee_02a'},
        {model = 'ng_proc_litter_plasbot3'},
        {model = 'ng_proc_sodacan_02a'},
        {model = 'ng_proc_sodacan_02c'},
        {model = 'ng_proc_sodacan_03b'},
        {model = 'ng_proc_tyre_dam1'},
        {model = 'ng_proc_tyre_01'},
    }
},

{
    category = 'Bitkiler',
    items = {
        {model = 'apa_mp_h_acc_vase_flowers_01'},
        {model = 'apa_mp_h_acc_vase_flowers_02'},
        {model = 'hei_heist_acc_flowers_01'},
        {model = 'prop_xmas_tree_int'},
        {model = 'prop_veg_crop_03_pump'},
        {model = 'prop_veg_crop_tr_01'},
        {model = 'prop_veg_crop_02'},
        {model = 'prop_plant_int_01b'},
        {model = 'prop_plant_int_03a'},
        {model = 'prop_pot_plant_01d'},
        {model = 'prop_pot_plant_01e'},
        {model = 'p_int_jewel_plant_01'},
        {model = 'p_int_jewel_plant_02'},
        {model = 'prop_fbibombplant'},
        {model = 'prop_bush_ornament_01'},
        {model = 'prop_bush_ornament_02'},
        {model = 'prop_bush_ornament_03'},
        {model = 'prop_plant_interior_05a'},
        {model = 'prop_pot_plant_05b'},
        {model = 'prop_plant_int_01b'},
        {model = 'prop_pot_plant_02c'},
        {model = 'prop_plant_int_05b'},
        {model = 'prop_pot_plant_05d'},
        {model = 'prop_pot_plant_03b'},
        {model = 'prop_plant_int_04a'},
        {model = 'prop_plant_int_06b'},
        {model = 'prop_plant_int_03a'},
        {model = 'prop_pot_plant_04b'},
        {model = 'prop_pot_plant_05c'},
        {model = 'prop_pot_plant_02b'},
        {model = 'prop_pot_plant_inter_03a'},
        {model = 'prop_pot_plant_04c'},
        {model = 'prop_plant_int_03c'},
        {model = 'prop_plant_int_05a'},
        {model = 'prop_pot_plant_01a'},
        {model = 'prop_plant_int_03b'},
        {model = 'prop_plant_int_02a'},
        {model = 'prop_plant_int_06a'},
        {model = 'prop_pot_plant_04a'},
        {model = 'prop_plant_int_01a'},
        {model = 'prop_pot_plant_02a'},
        {model = 'prop_plant_int_04c'},
        {model = 'prop_pot_plant_05a'},
        {model = 'prop_pot_plant_03c'},
        {model = 'prop_plant_int_02b'},
        {model = 'prop_pot_plant_6a'},
        {model = 'prop_pot_plant_03a'},
        {model = 'prop_plant_int_04b'},
        {model = 'prop_pot_plant_01e'},
        {model = 'prop_pot_plant_05d_l1'},
        {model = 'prop_pot_plant_01d'},
        {model = 'prop_pot_plant_02d'},
        {model = 'prop_pot_plant_01b'},
        {model = 'prop_pot_plant_bh1'},
        {model = 'prop_pot_plant_01c'},
    }
},

{
    category = 'Eğlence',
    items = {
        {model = 'prop_beach_towel_02'},
        {model = 'prop_weight_15k'},
        {model = 'prop_boogieboard_10'},
        {model = 'prop_beach_towel_04'},
        {model = 'prop_porn_mag_02'},
        {model = 'prop_sglasses_stand_02b'},
        {model = 'prop_hat_box_06'},
        {model = 'prop_ftowel_07'},
        {model = 'prop_weight_5k'},
        {model = 'prop_bikini_disp_04'},
        {model = 'prop_venice_board_03'},
        {model = 'prop_barbell_100kg'},
        {model = 'prop_bleachers_04'},
        {model = 'prop_vend_snak_01'},
        {model = 'prop_sglasses_stand_01'},
        {model = 'prop_venice_sign_18'},
        {model = 'prop_buck_spade_06'},
        {model = 'prop_beach_lilo_01'},
        {model = 'prop_bikini_disp_05'},
        {model = 'prop_boxing_glove_01'},
        {model = 'prop_venice_counter_02'},
        {model = 'prop_studio_light_01'},
        {model = 'prop_bleachers_05'},
        {model = 'prop_muscle_bench_04'},
        {model = 'prop_suitcase_02'},
        {model = 'prop_dress_disp_04'},
        {model = 'prop_buck_spade_09'},
        {model = 'prop_drug_erlenmeyer'},
        {model = 'prop_beachflag_02'},
        {model = 'prop_bleachers_03'},
        {model = 'prop_pooltable_3b'},
        {model = 'prop_clothes_rail_01'},
        {model = 'prop_sglasss_1_lod'},
        {model = 'prop_front_seat_01'},
        {model = 'prop_scrim_02'},
        {model = 'prop_ice_box_01_l1'},
        {model = 'prop_hwbowl_seat_03b'},
        {model = 'prop_barbell_01'},
        {model = 'prop_slacks_02'},
        {model = 'prop_game_clock_02'},
        {model = 'prop_bleachers_02'},
        {model = 'prop_display_unit_02'},
        {model = 'prop_arm_wrestle_01'},
        {model = 'prop_beach_bag_01a'},
        {model = 'prop_front_seat_05'},
        {model = 'prop_tshirt_stand_01b'},
        {model = 'prop_coolbox_01'},
        {model = 'prop_tshirt_box_01'},
        {model = 'prop_suitcase_01c'},
        {model = 'prop_hwbowl_pseat_6x1'},
        {model = 'prop_barbell_02'},
        {model = 'prop_barbell_20kg'},
        {model = 'prop_table_tennis'},
        {model = 'prop_suitcase_01b'},
        {model = 'prop_game_clock_01'},
        {model = 'prop_front_seat_02'},
        {model = 'prop_vend_water_01'},
        {model = 'prop_gumball_01'},
        {model = 'prop_dart_1'},
        {model = 'prop_golf_bag_01c'},
        {model = 'prop_front_seat_06'},
        {model = 'prop_front_seat_07'},
        {model = 'prop_bikini_disp_06'},
        {model = 'prop_tshirt_stand_04'},
        {model = 'prop_dress_disp_01'},
        {model = 'prop_beach_lotion_02'},
        {model = 'prop_beachflag_le'},
        {model = 'prop_exer_bike_01'},
        {model = 'prop_ven_market_stool'},
        {model = 'prop_barbell_50kg'},
        {model = 'prop_pier_kiosk_01'},
        {model = 'prop_gumball_02'},
        {model = 'prop_dress_disp_02'},
        {model = 'prop_towel_shelf_01'},
        {model = 'prop_weight_1_5k'},
        {model = 'prop_cap_row_02'},
        {model = 'prop_dolly_02'},
        {model = 'prop_beach_punchbag'},
        {model = 'prop_punch_bag_l'},
        {model = 'prop_beach_dip_bars_02'},
        {model = 'prop_sglasses_stand_1b'},
        {model = 'prop_beach_sandcas_05'},
        {model = 'prop_dart_bd_01'},
        {model = 'prop_ftowel_10'},
        {model = 'prop_barbell_30kg'},
        {model = 'prop_speedball_01'},
        {model = 'prop_ftowel_01'},
        {model = 'prop_film_cam_01'},
        {model = 'prop_weight_2_5k'},
        {model = 'prop_jukebox_01'},
        {model = 'prop_drug_bottle'},
        {model = 'prop_porn_mag_03'},
        {model = 'prop_golf_bag_01'},
        {model = 'prop_weight_squat'},
        {model = 'prop_beachflag_01'},
        {model = 'prop_v_15_cars_clock'},
        {model = 'prop_sports_clock_01'},
        {model = 'prop_bikini_disp_01'},
        {model = 'prop_pris_bench_01'},
        {model = 'prop_sglasss_1b_lod'},
        {model = 'prop_kino_light_03'},
        {model = 'prop_basketball_net'},
        {model = 'prop_muscle_bench_03'},
        {model = 'prop_bleachers_01'},
        {model = 'prop_airhockey_01'},
        {model = 'prop_scrim_01'},
        {model = 'prop_beach_bars_01'},
        {model = 'prop_studio_light_03'},
        {model = 'prop_muscle_bench_05'},
        {model = 'prop_weight_rack_02'},
        {model = 'prop_bleachers_04_cr'},
        {model = 'prop_venice_counter_01'},
        {model = 'prop_barbell_10kg'},
        {model = 'prop_muscle_bench_01'},
        {model = 'prop_muscle_bench_02'},
        {model = 'prop_display_unit_01'},
        {model = 'prop_weight_20k'},
        {model = 'prop_barbell_40kg'},
        {model = 'prop_muscle_bench_06'},
        {model = 'prop_barbell_60kg'},
        {model = 'prop_arcade_02'},
        {model = 'prop_porn_mag_01'},
        {model = 'prop_weight_bench_02'},
        {model = 'prop_exer_bike_mg'},
        {model = 'prop_ven_market_table1'},
        {model = 'prop_beach_sandcas_03'},
        {model = 'prop_venice_counter_03'},
        {model = 'prop_pris_bars_01'},
        {model = 'prop_weight_10k'},
        {model = 'prop_pool_rack_02'},
        {model = 'prop_gumball_03'},
        {model = 'prop_freeweight_01'},
        {model = 'prop_bikini_disp_03'},
        {model = 'prop_dress_disp_03'},
        {model = 'prop_sglasses_stand_02'},
        {model = 'prop_barbell_80kg'},
        {model = 'prop_poolball_11'},
        {model = 'prop_a_base_bars_01'},
    }
},

{
    category = 'Çöp',
    items = {
        {model = 'prop_rub_tyre_01'},
        {model = 'prop_rub_boxpile_02'},
        {model = 'prop_rub_table_02'},
        {model = 'prop_rub_matress_01'},
        {model = 'prop_rub_tyre_03'},
        {model = 'prop_skid_chair_01'},
        {model = 'prop_rub_monitor'},
        {model = 'prop_skid_chair_03'},
        {model = 'prop_rub_trainers_01'},
        {model = 'prop_pizza_box_03'},
        {model = 'prop_rub_pile_04'},
        {model = 'prop_rub_trolley02a'},
        {model = 'prop_rub_binbag_03b'},
        {model = 'prop_rub_cabinet03'},
        {model = 'prop_rub_cage01e'},
        {model = 'prop_rub_boxpile_04'},
        {model = 'prop_homeless_matress_01'},
        {model = 'prop_rub_boxpile_05'},
        {model = 'prop_rub_couch01'},
        {model = 'prop_rub_cabinet'},
        {model = 'prop_skid_chair_02'},
        {model = 'prop_rub_matress_02'},
        {model = 'prop_rub_carpart_05'},
        {model = 'prop_homeless_matress_02'},
        {model = 'prop_rub_pile_03'},
        {model = 'prop_rub_bike_02'},
        {model = 'prop_rub_litter_06'},
        {model = 'prop_rub_matress_04'},
        {model = 'prop_skid_trolley_2'},
        {model = 'prop_rub_cardpile_07'},
        {model = 'prop_rub_binbag_06'},
        {model = 'prop_rub_washer_01'},
        {model = 'prop_rub_cage01c'},
        {model = 'prop_rub_couch04'},
        {model = 'prop_rub_trolley03a'},
        {model = 'prop_rub_generator'},
        {model = 'prop_rub_bike_03'},
        {model = 'prop_rub_couch03'},
    }
},

{
    category = 'Oturma Grubu',
    items = {
        {model = 'apa_mp_h_stn_sofa2seat_02'},
        {model = 'apa_mp_h_stn_sofacorn_01'},
        {model = 'apa_mp_h_stn_sofacorn_09'},
        {model = 'apa_mp_h_stn_sofacorn_10'},
        {model = 'apa_mp_h_yacht_sofa_02'},
        {model = 'v_ilev_m_sofa'},
        {model = 'v_res_tre_sofa'},
        {model = 'prop_couch_lg_08'},
        {model = 'apa_mp_h_stn_sofacorn_06'},
        {model = 'ex_mp_h_off_sofa_02'},
        {model = 'apa_mp_h_din_chair_04'},
        {model = 'apa_mp_h_din_chair_12'},
        {model = 'apa_mp_h_stn_chairarm_02'},
        {model = 'apa_mp_h_stn_chairarm_23'},
        {model = 'apa_mp_h_stn_chairstrip_05'},
        {model = 'bkr_prop_biker_boardchair01'},
        {model = 'hei_heist_din_chair_05'},
        {model = 'p_yacht_chair_01_s'},
        {model = 'v_res_m_l_chair1'},
        {model = 'v_res_tre_stool'},
        {model = 'prop_off_chair_04b'},
        {model = 'prop_table_03_chr'},
        {model = 'apa_mp_h_din_stool_04'},
        {model = 'prop_couch_lg_07'},
        {model = 'prop_yaught_sofa_01'},
        {model = 'prop_couch_sm2_07'},
        {model = 'prop_couch_lg_02'},
        {model = 'prop_couch_sm_05'},
        {model = 'prop_couch_lg_05'},
        {model = 'prop_yaught_chair_01'},
        {model = 'prop_couch_lg_06'},
        {model = 'prop_couch_lg_08'},
        {model = 'prop_couch_sm_06'},
        {model = 'prop_couch_01'},
        {model = 'prop_couch_03'},
        {model = 'prop_couch_04'},
        {model = 'prop_gc_chair02'},
        {model = 'prop_armchair_01'},
        {model = 'prop_couch_sm1_07'},
        {model = 'prop_couch_sm_07'},
        {model = 'prop_couch_sm_02'},
        {model = 'prop_table_07'},
        {model = 'prop_chair_01a'},
        {model = 'prop_bench_06'},
        {model = 'prop_table_04_chr'},
        {model = 'prop_table_08_side'},
        {model = 'prop_clown_chair'},
        {model = 'prop_proxy_chateau_table'},
        {model = 'prop_table_03'},
        {model = 'prop_table_04'},
        {model = 'prop_chair_02'},
        {model = 'prop_chateau_chair_01'},
        {model = 'prop_chair_05'},
        {model = 'prop_table_05'},
        {model = 'prop_table_06_chr'},
        {model = 'prop_chair_07'},
        {model = 'prop_chair_01b'},
        {model = 'prop_patio_lounger_3'},
        {model = 'prop_bench_01a'},
        {model = 'prop_patio_lounger1_table'},
        {model = 'prop_old_deck_chair'},
        {model = 'prop_table_03b_chr'},
        {model = 'prop_stool_01'},
        {model = 'prop_chair_04b'},
        {model = 'prop_bench_11'},
        {model = 'p_lev_sofa_s'},
        {model = 'v_ilev_fh_kitchenstool'},
        {model = 'v_ilev_hd_chair'},
        {model = 'v_ilev_leath_chr'},
        {model = 'p_v_med_p_sofa_s'},
        {model = 'v_ilev_m_dinechair'},
        {model = 'v_ilev_m_sofa'},
        {model = 'v_res_tre_sofa_s'},
        {model = 'hei_prop_hei_skid_chair'},
        {model = 'p_clb_officechair_s'},
        {model = 'p_armchair_01_s'},
        {model = 'p_res_sofa_l_s'},
        {model = 'p_soloffchair_s'},
        {model = 'v_ilev_p_easychair'},
        {model = 'p_dinechair_01_s'},
        {model = 'p_ilev_p_easychair_s'},
        {model = 'v_ilev_chair02_ped'},
        {model = 'prop_direct_chair_01'},
    }
},

{
    category = 'Depolama',
    items = {
        {model = 'prop_crate_11c'},
        {model = 'prop_box_wood05a'},
        {model = 'prop_drop_crate_01'},
        {model = 'prop_sacktruck_02b'},
        {model = 'prop_flattruck_01c'},
        {model = 'v_ret_ta_box'},
        {model = 'v_ind_cf_chckbox2'},
        {model = 'prop_cardbordbox_03a'},
        {model = 'prop_barrel_02b'},
        {model = 'prop_boxpile_03a'},
        {model = 'prop_barrel_03a'},
        {model = 'prop_box_wood02a'},
        {model = 'prop_flattruck_01d'},
        {model = 'prop_crate_10a'},
        {model = 'prop_cardbordbox_04a'},
        {model = 'prop_boxpile_07d'},
        {model = 'prop_jerrycan_01a'},
        {model = 'prop_gascyl_01a'},
        {model = 'prop_box_ammo07b'},
        {model = 'prop_barrel_pile_03'},
        {model = 'prop_pallet_pile_01'},
        {model = 'prop_crate_02a'},
        {model = 'prop_pallet_03a'},
        {model = 'v_ind_cf_boxes'},
        {model = 'prop_barrel_pile_05'},
        {model = 'prop_boxpile_05a'},
        {model = 'prop_bucket_02a'},
        {model = 'v_res_filebox01'},
        {model = 'prop_gascyl_04a'},
        {model = 'prop_box_wood01a'},
        {model = 'prop_crate_09a'},
        {model = 'prop_oilcan_02a'},
        {model = 'v_ret_gc_box1'},
        {model = 'v_ind_cs_box01'},
        {model = 'prop_box_wood07a'},
        {model = 'prop_barrel_exp_01b'},
        {model = 'prop_bucket_01a'},
        {model = 'prop_box_guncase_02a'},
        {model = 'prop_drop_crate_01_set'},
        {model = 'prop_box_wood05b'},
        {model = 'prop_cardbordbox_02a'},
        {model = 'prop_box_tea01a'},
        {model = 'prop_box_guncase_01a'},
        {model = 'v_serv_plas_boxg4'},
        {model = 'prop_warehseshelf01'},
        {model = 'prop_warehseshelf03'},
        {model = 'prop_warehseshelf02'},
        {model = 'v_ind_cf_crate2'},
        {model = 'v_ind_cf_crate'},
        {model = 'prop_pallettruck_02'},
        {model = 'prop_barrel_01a'},
        {model = 'prop_boxpile_10b'},
        {model = 'prop_pallet_01a'},
        {model = 'prop_bucket_01b'},
        {model = 'v_serv_plastic_box'},
        {model = 'v_serv_abox_02'},
        {model = 'v_ind_cfbox'},
        {model = 'prop_boxpile_02c'},
        {model = 'v_serv_plas_boxgt2'},
        {model = 'prop_box_wood04a'},
        {model = 'prop_cratepile_02a'},
        {model = 'prop_boxpile_10a'},
        {model = 'prop_crate_11e'},
        {model = 'prop_barrel_pile_01'},
        {model = 'prop_barrel_pile_02'},
        {model = 'prop_crate_05a'},
        {model = 'prop_boxpile_01a'},
        {model = 'prop_box_wood08a'},
        {model = 'prop_cratepile_03a'},
        {model = 'prop_cratepile_01a'},
        {model = 'prop_pallet_pile_02'},
        {model = 'prop_sacktruck_01'},
        {model = 'prop_cratepile_07a'},
        {model = 'prop_boxpile_02b'},
        {model = 'prop_boxpile_06a'},
        {model = 'prop_shelves_02'},
        {model = 'prop_pallettruck_01'},
        {model = 'prop_boxpile_09a'},
        {model = 'prop_shelves_01'},
        {model = 'prop_flattruck_01a'},
        {model = 'prop_sacktruck_02a'},
        {model = 'v_ind_cf_crate1'},
        {model = 'prop_watercrate_01'},
        {model = 'prop_shelves_03'},
    }
},

{
    category = 'Yardımcı Tesisat',
    items = {
        {model = 'prop_tyre_rack_01'},
        {model = 'prop_fire_exting_3a'},
        {model = 'prop_fire_driser_3b'},
        {model = 'prop_fire_driser_1b'},
        {model = 'prop_fire_driser_4b'},
        {model = 'prop_cctv_cam_06a'},
        {model = 'prop_elecbox_18'},
        {model = 'prop_elecbox_10'},
        {model = 'prop_elecbox_21'},
        {model = 'prop_cctv_cam_04a'},
        {model = 'prop_telegwall_03b'},
        {model = 'prop_fire_exting_2a'},
        {model = 'prop_cctv_cam_05a'},
        {model = 'prop_elecbox_23'},
        {model = 'prop_cctv_cam_02a'},
        {model = 'prop_cctv_cam_01a'},
        {model = 'prop_elecbox_08b'},
        {model = 'prop_cctv_cam_07a'},
        {model = 'prop_fire_exting_1b'},
        {model = 'prop_elecbox_22'},
        {model = 'prop_cctv_cam_01b'},
        {model = 'prop_cctv_cam_04b'},
        {model = 'prop_cctv_cam_03a'},
        {model = 'prop_fire_hosereel'},
        {model = 'prop_fire_hosebox_01'},
        {model = 'prop_bikerack_2'},
        {model = 'prop_elecbox_20'},
        {model = 'prop_gas_rack01'},
        {model = 'prop_telegwall_01a'},
        {model = 'prop_fire_exting_1a'},
        {model = 'prop_fire_hosereel_l1'},
        {model = 'prop_cctv_cam_04c'},
    }
},

{
    category = 'Duvarlar (Genel)',
    items = {
        {model = 'prop_fnclink_02h'},
        {model = 'prop_fnclink_06gatepost'},
        {model = 'prop_fnclink_08post'},
        {model = 'prop_fncply_01b'},
        {model = 'frag_plank_a'},
        {model = 'prop_const_fence02a'},
        {model = 'prop_gatecom_02'},
        {model = 'prop_wallchunk_01'},
        {model = 'prop_gatecom_01'},
        {model = 'prop_const_fence02b'},
        {model = 'prop_const_fence01b'},
        {model = 'prop_const_fence01b_cr'},
        {model = 'prop_fncconstruc_ld'},
        {model = 'prop_fncconstruc_01d'},
        {model = 'prop_const_fence01a'},
        {model = 'hei_prop_carrier_panel_4'},
    }
},

{
    category = 'Masalar',
    items = {
        {model = 'apa_mp_h_tab_coffee_08'},
        {model = 'apa_mp_h_tab_coffee_07'},
        {model = 'ex_mp_h_tab_coffee_05'},
        {model = 'hei_heist_tab_coffee_06'},
        {model = 'apa_mp_h_din_table_06'},
        {model = 'ex_mp_h_din_table_05'},
        {model = 'ex_prop_ex_console_table_01'},
        {model = 'hei_prop_yah_table_03'},
        {model = 'hei_prop_yah_table_01'},
        {model = 'v_ret_fh_kitchtable'},
        {model = 'prop_table_02'},
        {model = 'prop_table_04'},
        {model = 'prop_table_05'},
        {model = 'apa_mp_h_din_table_01'},
        {model = 'apa_mp_h_tab_sidelrg_01'},
        {model = 'hei_heist_din_table_06'},
        {model = 'v_corp_officedesk_5'},
        {model = 'v_ind_dc_desk03'},
        {model = 'v_med_p_desk'},
        {model = 'v_res_d_smallsidetable'},
        {model = 'v_res_tre_bedsidetable'},
    }
},

{
    category = 'Dış Mekan Mobilyası',
    items = {
        {model = 'prop_bbq_5'},
        {model = 'prop_ch2_wdfence_01'},
        {model = 'prop_hottub2'},
        {model = 'prop_fnclink_02a_sdt'},
        {model = 'prop_fnclink_01a'},
        {model = 'prop_fnclog_01b'},
        {model = 'prop_fncres_02c'},
        {model = 'prop_fncres_05b'},
    }
},

{
    category = 'Işıklar',
    items = {
        {model = 'apa_mp_h_floorlamp_a'},
        {model = 'apa_mp_h_floorlamp_c'},
        {model = 'apa_mp_h_lit_floorlamp_05'},
        {model = 'apa_mp_h_lit_floorlamp_10'},
        {model = 'apa_mp_h_lit_floorlamp_13'},
        {model = 'apa_mp_h_lit_lamptable_04'},
        {model = 'apa_mp_h_lit_lamptable_09'},
        {model = 'apa_mp_h_lit_lamptablenight_24'},
    }
},

{
    category = 'Ufak Eşyalar',
    items = {
        {model = 'prop_amb_beer_bottle'},
        {model = 'ng_proc_sodacup_01a'},
        {model = 'v_res_mcofcupdirt'},
        {model = 'ng_proc_pizza01a'},
        {model = 'v_res_tt_pizzaplate'},
        {model = 'v_ret_fh_plate1'},
        {model = 'v_ret_247_bread1'},
        {model = 'v_ret_fh_fry02'},
        {model = 'prop_cs_burger_01'},
        {model = 'prop_drink_whisky'},
        {model = 'p_whiskey_bottle_s'},
        {model = 'prop_knife'},
        {model = 'ng_proc_paper_news_globe'},
        {model = 'prop_champset'},
        {model = 'hei_prop_heist_box'},
        {model = 'apa_mp_h_acc_fruitbowl_02'},
        {model = 'apa_mp_h_acc_fruitbowl_01'},
        {model = 'bkr_prop_bkr_cashpile_01'},
        {model = 'bkr_prop_bkr_cashpile_06'},
        {model = 'bkr_prop_bkr_cash_roll_01'},
        {model = 'ex_mp_h_acc_candles_01'},
        {model = 'ex_mp_h_acc_candles_02'},
        {model = 'ex_prop_tv_settop_remote'},
        {model = 'v_res_fa_cereal01'},
        {model = 'v_res_mp_ashtrayb'},
        {model = 'v_res_tissues'},
    }
},
}

-- Per-property placed-object limit
Config.MaxObjectsPerProperty = 300

-- Depo (stash) ve gardırop (kıyafet deposu) ox_inventory boyutları
Config.StashSize = 50
Config.StashWeight = 100000
Config.WardrobeSize = 40
Config.WardrobeWeight = 80000

-- NOT: shell'ler (shell_id 1-22) artık qb-interior export'u ÇAĞIRMIYOR.
-- client/main.lua'daki NativeShells tablosu model adını + exit offsetini
-- tutuyor, obje doğrudan CreateObject ile spawnlanıyor. Modelin kendisi
-- (shell_michael.ydr vb.) qb-interior'un stream/starter_shells_k4mb1.ytyp
-- dosyasından geliyor — o dosyayı bu resource'un stream/ klasörüne kopyala,
-- qb-interior resource'unun kurulu olmasına gerek kalmaz.

-- Prebuilt IPL apartments/interiors selectable from the realtor menu.
-- These are real map interiors (no shell needed). kind='ipl'.
Config.IPLInteriors = {
    -- ✅ DÖNÜŞTÜRÜLDÜ: pb_haus_shell_001 ve moto_shell01 artık burada
    -- DEĞİL — NativeShells[41]/[42]'ye taşındı (yukarıya bak, "DÖNÜŞTÜRÜLDÜ"
    -- notu). Sebep: ymap ile sabit gerçek-dünya koordinatında birden
    -- fazla mülk aynı shell'i kullanırsa hepsi TAM AYNI 3D noktaya
    -- düşüyordu — NativeShells her mülke izole, benzersiz bir cep veriyor.

    eclipse_1 = { label = 'Eclipse Towers - Tip 1', ipl = { 'apa_v_mp_h_01_a' }, spawn = vector4(-773.07, 341.49, 213.39, 175.0) },
    eclipse_2 = { label = 'Eclipse Towers - Tip 2', ipl = { 'apa_v_mp_h_01_c' }, spawn = vector4(-786.87, 315.75, 217.64, 180.0) },
    eclipse_3 = { label = 'Eclipse Towers - Tip 3', ipl = { 'apa_v_mp_h_02_a' }, spawn = vector4(-781.41, 334.32, 207.63, 270.0) },
    tinsel_1  = { label = 'Tinsel Towers',          ipl = { 'apa_v_mp_h_08_a' }, spawn = vector4(-614.86, 40.65, 97.6, 0.0) },
    stilt_1   = { label = 'Vinewood Villa',         ipl = { 'apa_v_mp_h_04_c' }, spawn = vector4(-174.19, 497.62, 137.66, 115.0) },
    office_1  = { label = 'Yönetici Ofisi',         ipl = { 'ex_dt1_02_office_01a' }, spawn = vector4(-141.23, -620.74, 168.82, 95.0) },
    office_2  = { label = 'Maze Bank Ofisi',        ipl = { 'ex_dt1_11_office_01a' }, spawn = vector4(-75.85, -826.95, 243.39, 0.0) },

    -- Ek interiorlar — IPL adları ve koordinatları dokümantasyonla doğrulandı (se7ensins / cfx / forum.cfx.re "List of all online interiors").
    lowend_1    = { label = 'Ucuz Başlangıç Dairesi',  ipl = {}, spawn = vector4(261.46, -998.82, -99.01, 270.0) },  -- her zaman yüklü MLO (IPL gerekmez) — forum.cfx.re tablosundan doğrulandı
    medium_1    = { label = 'Orta Segment Daire',      ipl = {}, spawn = vector4(-612.16, 47.06, 93.6, 180.0) },     -- ⚠️ bu koordinat ayrıca doğrulanamadı, test edip sorun olursa bildir
    -- penthouse hem kendi IPL'i hem de bağlı olduğu ana kumarhane binasının
    -- (vw_casino_main) yüklü olmasını istiyor — forum.cfx.re/bob74_ipl kaynağı.
    penthouse_1 = { label = 'Diamond Casino Penthouse', ipl = { 'vw_casino_main', 'vw_casino_penthouse' }, spawn = vector4(976.63, 70.29, 115.16, 60.0) },

    -- NOT (DÜZELTME): Bu 4 mekan eskiden KISA IPL adları kullanıyordu
    -- (örn. 'bkr_biker_dlc_int_02') — bunlar RequestIpl ile YÜKLENEMEYEN
    -- "konum etiketleri"ydi, gerçek yüklenebilir IPL grubu değildi. RequestIpl
    -- ✅ KESİN DÜZELTME: bir önceki deneme (uzun "_milo" sonekli IPL adları,
    -- RequestIpl ile) HÂLÂ ÇALIŞMIYORDU çünkü bu 4 lokasyon aslında hiç
    -- RequestIpl ile yüklenen bir IPL DEĞİL — tıpkı gece kulübü gibi,
    -- GetInteriorAtCoordsWithType + LoadInterior + IsInteriorReady
    -- gerektiren bir "interior type" (CInteriorInst). Doğrulanmış kaynak
    -- (forum.cfx.re "Gta 5 online mlo's coordinates" + se7ensins hidden
    -- interiors listesi, ikisi de aynı isimlerde hemfikir):
    clubhouse_1 = { label = 'Motosiklet Kulüp Binası', interiorType = 'bkr_biker_dlc_int_02',      typeCoords = vector3(998.48, -3164.71, -38.9),   spawn = vector4(998.48, -3164.71, -38.9, 180.0) },
    weed_1      = { label = 'Esrar Serası',            interiorType = 'bkr_biker_dlc_int_ware02',  typeCoords = vector3(1051.49, -3196.54, -39.15), spawn = vector4(1051.49, -3196.54, -39.15, 180.0) },
    meth_1      = { label = 'Met Laboratuvarı',        interiorType = 'bkr_biker_dlc_int_ware01',  typeCoords = vector3(1009.50, -3196.60, -39.0),  spawn = vector4(1009.50, -3196.60, -39.0, 180.0) },
    coke_1      = { label = 'Kokain Deposu',           interiorType = 'bkr_biker_dlc_int_ware03',  typeCoords = vector3(1093.60, -3196.60, -39.0),  spawn = vector4(1093.60, -3196.60, -39.0, 180.0) },

    -- NOT: Gece kulübü buradan ÇIKARILDI — "ba_dlc_int_01_ba" RequestIpl ile
    -- yüklenebilen bir IPL DEĞİL, GetInteriorAtCoordsWithType + LoadInterior
    -- + IsInteriorReady gerektiren ayrı bir sistem (CInteriorInst). Onu
    -- interiorType alanıyla ayrıca aşağıda tanımladım, client/main.lua'da
    -- farklı bir yükleme yoluna (EnsureInteriorTypeLoaded) yönlendiriliyor.
    nightclub_1 = { label = 'Gece Kulübü', interiorType = 'ba_dlc_int_01_ba', typeCoords = vector3(-1604.664, -3012.583, -79.9999), spawn = vector4(-1569.5865, -3014.5998, -74.4061, 15.08) },

    -- ✅ DÖNÜŞTÜRÜLDÜ: Lynx Shells (6 tane) artık burada DEĞİL —
    -- NativeShells[35..40]'a taşındı (yukarıya bak). Model adları GitHub
    -- README'sinden (github.com/Lynxist/lynx_shells) doğrulandı.
}

-- Realtor (creation) menu shown in the NUI. Categories -> options.
-- option.kind: 'ipl' (uses IPLInteriors[id]) or 'shell' (uses native NativeShells shellId 1-16)
-- Her option'a OPSİYONEL bir "img" alanı eklenebilir, örnek:
--   { label = 'Eclipse Daire 1', kind = 'ipl', ipl = 'eclipse_1', price = 250000, img = 'eclipse_1.jpg' }
-- Bu durumda html/img/eclipse_1.jpg dosyası emlakçı kartında gösterilir
-- (html/img/README.txt'e bak). "img" alanı hiç verilmezse kart eskisi
-- gibi ikon gösterir — hiçbir mevcut satır bozulmaz. Şu an hiçbir option'a
-- gerçek bir görsel eklemedim çünkü oyunundan ekran görüntüsü çekemiyorum
-- (görsel erişimim yok) — eklemek istediğinde sadece "img = '...'" satırını
-- ilgili option'a ekleyip dosyayı html/img/'e atman yeterli.
Config.RealtorCategories = {
    {
        id = 'homes_ipl', label = 'Evler (Daireler)', ptype = 'home',
        options = {
            { label = 'Eclipse Daire 1', kind = 'ipl', ipl = 'eclipse_1', price = 250000, img = 'eclipse_daire_1.jpg' },
            { label = 'Eclipse Daire 2', kind = 'ipl', ipl = 'eclipse_2', price = 250000, img = 'eclipse_daire_2.jpg' },
            { label = 'Eclipse Daire 3', kind = 'ipl', ipl = 'eclipse_3', price = 300000, img = 'eclipse_daire_3.jpg' },
            { label = 'Tinsel Towers',   kind = 'ipl', ipl = 'tinsel_1',  price = 280000, img = 'tinsel_towers.jpg' },
            { label = 'Vinewood Villa',  kind = 'ipl', ipl = 'stilt_1',   price = 1500000, img = 'vinewood_villa.jpg' },
            { label = 'Ucuz Başlangıç Dairesi', kind = 'ipl', ipl = 'lowend_1',    price = 75000, img = 'ucuz_baslangic_dairesi.jpg' },
            { label = 'Orta Segment Daire',     kind = 'ipl', ipl = 'medium_1',    price = 220000, img = 'orta_segment_daire.jpg' },
            { label = 'Casino Penthouse',       kind = 'ipl', ipl = 'penthouse_1', price = 2500000, img = 'casino_penthouse.jpg' },

            -- ✅ DÖNÜŞTÜRÜLDÜ: Lynx Shells + PB Haus + Moto Shell artık
            -- burada değil — "Evler (Shell)" kategorisine, kind='shell'
            -- olarak taşındı (kalibrasyon bekliyorlar, aşağıya bak).
        },
    },
    {
        id = 'homes_shell', label = 'Evler (Shell)', ptype = 'home',
        options = {
            -- K4MB1 Starter Pack — daha önce eklenmeyen kalanlar (model+exit
            -- zaten Config.NativeShells'te doğrulanmış duruyordu, sadece
            -- emlakçı menüsünde hiç görünmüyordu):
            { label = "Michael'in Evi",       kind = 'shell', shellId = 1,  price = 350000, img = 'michael_in_evi.jpg' },
            { label = 'Franklin Hala Evi',     kind = 'shell', shellId = 2,  price = 140000, img = 'franklin_hala_evi.jpg' },
            { label = 'Çiftlik Evi',           kind = 'shell', shellId = 3,  price = 220000, img = 'ciftlik_evi.jpg' },
            { label = 'Orta Segment Ev 2',     kind = 'shell', shellId = 4,  price = 190000, img = 'orta_segment_ev_2.jpg' },
            { label = "Lester'in Evi",        kind = 'shell', shellId = 6,  price = 130000, img = 'lester_in_evi.jpg' },
            { label = "Trevor'ın Evi",        kind = 'shell', shellId = 7,  price = 120000, img = 'trevor_in_evi.jpg' },
            { label = 'Karavan Evi',           kind = 'shell', shellId = 8,  price = 95000, img = 'karavan_evi.jpg' },
            { label = 'Shell Ev (Modern) 2',   kind = 'shell', shellId = 16, price = 175000, img = 'shell_ev_modern_2.jpg' },

            { label = 'Shell Ev (Modern)', kind = 'shell', shellId = 5,  price = 180000, img = 'shell_ev_modern.jpg' },
            { label = 'Shell Ev (Loft)',   kind = 'shell', shellId = 10, price = 160000, img = 'shell_ev_loft.jpg' },
            -- CreateHouseRobbery (qb-interior export) — CreateFurniMid (shellId 10)
            -- ile AYNI model+exit verisine sahip, aynı NativeShells girdisini
            -- kullanıyor, sadece farklı etiketle emlakçıda ayrı satır:
            { label = 'Soygun Evi (Furnished Mid)', kind = 'shell', shellId = 10, price = 145000, img = 'soygun_evi_furnished_mid.jpg' },

            -- shellId 17-22 — qb-interior'un furnshell1-3/unfurnshell1-3
            -- export'larıyla çalışıyor (1-16/23-28'den FARKLI: bunlar için
            -- qb-interior resource'unun ÇALIŞIYOR olması gerekiyor).
            -- shellId 17-22 (furnshell1-3/unfurnshell1-3) — qb-interior
            -- KALDIRILDI (senin isteğinle), bu yüzden bu 6 ID'nin artık
            -- Config.NativeShells'te HİÇ model+exit verisi yok. Şu an aktif
            -- bırakırsam oyuncu satın alır ama mekana giremez ("oluşturulamadı"
            -- hatası). /shelltest + /shellexit ile gerçek model adı + çıkış
            -- koordinatını doldurup Config.NativeShells[17..22]'ye ekleyince
            -- buradaki yorumu kaldırabiliriz.
            -- { label = 'Döşeli Shell 1',   kind = 'shell', shellId = 17, price = 170000 },
            -- { label = 'Döşeli Shell 2',   kind = 'shell', shellId = 18, price = 175000 },
            -- { label = 'Döşeli Shell 3',   kind = 'shell', shellId = 19, price = 180000 },
            -- { label = 'Boş Shell 1',      kind = 'shell', shellId = 20, price = 110000 },
            -- { label = 'Boş Shell 2',      kind = 'shell', shellId = 21, price = 115000 },
            -- { label = 'Boş Shell 3',      kind = 'shell', shellId = 22, price = 120000 },

            -- Envi-Shells (23-28) — gerçek exit verisi var, aktif:
            { label = 'Envi Shell 1 (Boş)',    kind = 'shell', shellId = 23, price = 140000, img = 'envi_shell_1_bos.jpg' },
            { label = 'Envi Shell 1 (Döşeli)', kind = 'shell', shellId = 24, price = 190000, img = 'envi_shell_1_doseli.jpg' },
            { label = 'Envi Shell 2 (Boş)',    kind = 'shell', shellId = 25, price = 150000, img = 'envi_shell_2_bos.jpg' },
            { label = 'Envi Shell 2 (Döşeli)', kind = 'shell', shellId = 26, price = 200000, img = 'envi_shell_2_doseli.jpg' },
            { label = 'Envi Shell 3 (Boş)',    kind = 'shell', shellId = 27, price = 160000, img = 'envi_shell_3_bos.jpg' },
            { label = 'Envi Shell 3 (Döşeli)', kind = 'shell', shellId = 28, price = 210000, img = 'envi_shell_3_doseli.jpg' },

            -- ⚠️ EKLENDİ (KALİBRASYON BEKLİYOR): /shelltest + /shellexit
            -- ile Config.NativeShells[29..34]'teki exit değerlerini
            -- doldurduktan SONRA aşağıdaki satırların başındaki "--"
            -- işaretini kaldır (yorumdan çıkar), fiyatları istediğin gibi
            -- ayarla:
            -- { label = 'Modern Loft',    kind = 'shell', shellId = 29, price = 260000 },
            -- { label = 'Tihulu Kafe/Motel', kind = 'shell', shellId = 30, price = 150000 },
            -- { label = 'Lüks Daire',     kind = 'shell', shellId = 31, price = 300000 },
            -- { label = 'Boş İşyeri (Coke)', kind = 'shell', shellId = 32, price = 90000 },
            -- { label = 'Ucuz Motel Odası', kind = 'shell', shellId = 33, price = 60000 },
            -- { label = 'Küçük Depo',     kind = 'shell', shellId = 34, price = 110000 },
            -- { label = 'Lynx Ev Tip 1 (Boş)',    kind = 'shell', shellId = 35, price = 90000 },
            -- { label = 'Lynx Ev Tip 1 (Döşeli)', kind = 'shell', shellId = 36, price = 130000 },
            -- { label = 'Lynx Ev Tip 2 (Boş)',    kind = 'shell', shellId = 37, price = 150000 },
            -- { label = 'Lynx Ev Tip 2 (Döşeli)', kind = 'shell', shellId = 38, price = 200000 },
            -- { label = 'Lynx Ev Tip 3 (Boş)',    kind = 'shell', shellId = 39, price = 220000 },
            -- { label = 'Lynx Ev Tip 3 (Döşeli)', kind = 'shell', shellId = 40, price = 280000 },
            -- { label = 'PB Haus',                kind = 'shell', shellId = 41, price = 200000 },
            -- { label = 'Moto Shell',             kind = 'shell', shellId = 42, price = 180000 },
            -- { label = 'Eclipse Rooftop',        kind = 'shell', shellId = 43, price = 400000 },

            -- ✅ EKLENDİ: Genişletilmiş K4MB1 paketi (93 shell, ID 44-136) —
            -- kalibrasyon bekliyor: /shelltest <model_adi> + /shellexit ile
            -- Config.NativeShells[44..136]'daki exit=nil değerlerini
            -- doldurduktan SONRA istediğin satırların başındaki "-- "
            -- işaretini kaldır, fiyatları/etiketleri istediğin gibi düzenle.
            -- { label = 'K4MB1 Apartman 1', kind = 'shell', shellId = 44, price = 150000 },
            -- { label = 'K4MB1 Apartman 2', kind = 'shell', shellId = 45, price = 150000 },
            -- { label = 'K4MB1 Apartman 3', kind = 'shell', shellId = 46, price = 150000 },
            -- { label = 'K4MB1 Ev 1', kind = 'shell', shellId = 47, price = 150000 },
            -- { label = 'K4MB1 Ev 2', kind = 'shell', shellId = 48, price = 150000 },
            -- { label = 'K4MB1 Ev 3', kind = 'shell', shellId = 49, price = 150000 },
            -- { label = 'K4MB1 Ev 4', kind = 'shell', shellId = 50, price = 150000 },
            -- { label = 'K4MB1 Ev 5', kind = 'shell', shellId = 51, price = 150000 },
            -- { label = 'K4MB1 Ev 6', kind = 'shell', shellId = 52, price = 150000 },
            -- { label = 'K4MB1 Ev 7', kind = 'shell', shellId = 53, price = 150000 },
            -- { label = 'K4MB1 Ev 8', kind = 'shell', shellId = 54, price = 150000 },
            -- { label = 'K4MB1 Ev 9', kind = 'shell', shellId = 55, price = 150000 },
            -- { label = 'K4MB1 Ev 10', kind = 'shell', shellId = 56, price = 150000 },
            -- { label = 'K4MB1 Ev 11', kind = 'shell', shellId = 57, price = 150000 },
            -- { label = 'K4MB1 Ev 12', kind = 'shell', shellId = 58, price = 150000 },
            -- { label = 'K4MB1 Ev 13', kind = 'shell', shellId = 59, price = 150000 },
            -- { label = 'K4MB1 Ev 14', kind = 'shell', shellId = 60, price = 150000 },
            -- { label = 'K4MB1 Loft 1', kind = 'shell', shellId = 61, price = 150000 },
            -- { label = 'K4MB1 Loft 2', kind = 'shell', shellId = 62, price = 150000 },
            -- { label = 'K4MB1 Loft 3', kind = 'shell', shellId = 63, price = 150000 },
            -- { label = 'K4MB1 Malikane 1', kind = 'shell', shellId = 64, price = 150000 },
            -- { label = 'K4MB1 Malikane 2', kind = 'shell', shellId = 65, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 1', kind = 'shell', shellId = 66, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 2', kind = 'shell', shellId = 67, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 3', kind = 'shell', shellId = 68, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 4', kind = 'shell', shellId = 69, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 5', kind = 'shell', shellId = 70, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 6', kind = 'shell', shellId = 71, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 7', kind = 'shell', shellId = 72, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 8', kind = 'shell', shellId = 73, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 9', kind = 'shell', shellId = 74, price = 150000 },
            -- { label = 'K4MB1 Modern Ev 10', kind = 'shell', shellId = 75, price = 150000 },
            -- { label = 'K4MB1 Çatı Katı', kind = 'shell', shellId = 76, price = 150000 },
            -- { label = 'K4MB1 Çatı Katı 2', kind = 'shell', shellId = 77, price = 150000 },
            -- { label = 'K4MB1 Vinewood Malikanesi 2', kind = 'shell', shellId = 78, price = 150000 },
            -- { label = 'K4MB1 Vinewood Malikanesi 2', kind = 'shell', shellId = 79, price = 150000 },
            -- { label = 'K4MB1 Vinewood Malikanesi 3', kind = 'shell', shellId = 80, price = 150000 },
            -- { label = 'K4MB1 Bodrum Kat 1', kind = 'shell', shellId = 81, price = 150000 },
            -- { label = 'K4MB1 Bodrum Kat 2', kind = 'shell', shellId = 82, price = 150000 },
            -- { label = 'K4MB1 Bodrum Kat 3', kind = 'shell', shellId = 83, price = 150000 },
            -- { label = 'K4MB1 Bodrum Kat 4', kind = 'shell', shellId = 84, price = 150000 },
            -- { label = 'K4MB1 Bodrum Kat 5', kind = 'shell', shellId = 85, price = 150000 },
            -- { label = 'K4MB1 Motorcu Yeri 1', kind = 'shell', shellId = 86, price = 150000 },
            -- { label = 'K4MB1 Motorcu Yeri 2', kind = 'shell', shellId = 87, price = 150000 },
            -- { label = 'K4MB1 Motorcu Yeri 3', kind = 'shell', shellId = 88, price = 150000 },
            -- { label = 'K4MB1 Konteyner', kind = 'shell', shellId = 89, price = 150000 },
            -- { label = 'K4MB1 Ofis 1', kind = 'shell', shellId = 90, price = 150000 },
            -- { label = 'K4MB1 Ofis 2', kind = 'shell', shellId = 91, price = 150000 },
            -- { label = 'K4MB1 Ofis 3', kind = 'shell', shellId = 92, price = 150000 },
            -- { label = 'K4MB1 Ofis 4', kind = 'shell', shellId = 93, price = 150000 },
            -- { label = 'K4MB1 Ofis 5', kind = 'shell', shellId = 94, price = 150000 },
            -- { label = 'K4MB1 Ofis 6', kind = 'shell', shellId = 95, price = 150000 },
            -- { label = 'K4MB1 Ofis 7', kind = 'shell', shellId = 96, price = 150000 },
            -- { label = 'K4MB1 Ofis 8', kind = 'shell', shellId = 97, price = 150000 },
            -- { label = 'K4MB1 Stok Evi 1', kind = 'shell', shellId = 98, price = 150000 },
            -- { label = 'K4MB1 Stok Evi 2', kind = 'shell', shellId = 99, price = 150000 },
            -- { label = 'K4MB1 Mağaza 1', kind = 'shell', shellId = 100, price = 150000 },
            -- { label = 'K4MB1 Mağaza 2', kind = 'shell', shellId = 101, price = 150000 },
            -- { label = 'K4MB1 Mağaza 3', kind = 'shell', shellId = 102, price = 150000 },
            -- { label = 'K4MB1 Mağaza 4', kind = 'shell', shellId = 103, price = 150000 },
            -- { label = 'K4MB1 Mağaza 5', kind = 'shell', shellId = 104, price = 150000 },
            -- { label = 'K4MB1 Depo 1', kind = 'shell', shellId = 105, price = 150000 },
            -- { label = 'K4MB1 Depo 2', kind = 'shell', shellId = 106, price = 150000 },
            -- { label = 'K4MB1 Depo 3', kind = 'shell', shellId = 107, price = 150000 },
            -- { label = 'K4MB1 Depo 4', kind = 'shell', shellId = 108, price = 150000 },
            -- { label = 'K4MB1 Depo 5', kind = 'shell', shellId = 109, price = 150000 },
            -- { label = 'K4MB1 Klasik Ev 1', kind = 'shell', shellId = 110, price = 150000 },
            -- { label = 'K4MB1 Klasik Ev 2', kind = 'shell', shellId = 111, price = 150000 },
            -- { label = 'K4MB1 Klasik Ev 3', kind = 'shell', shellId = 112, price = 150000 },
            -- { label = 'K4MB1 Klasik Ev 4', kind = 'shell', shellId = 113, price = 150000 },
            -- { label = 'K4MB1 Klasik Ev 5', kind = 'shell', shellId = 114, price = 150000 },
            -- { label = 'K4MB1 Klasik Ev 6', kind = 'shell', shellId = 115, price = 150000 },
            -- { label = 'K4MB1 Otel Odası 1', kind = 'shell', shellId = 116, price = 150000 },
            -- { label = 'K4MB1 Otel Odası 2', kind = 'shell', shellId = 117, price = 150000 },
            -- { label = 'K4MB1 Otel Odası 3', kind = 'shell', shellId = 118, price = 150000 },
            -- { label = 'K4MB1 Motel Odası 1', kind = 'shell', shellId = 119, price = 150000 },
            -- { label = 'K4MB1 Motel Odası 2', kind = 'shell', shellId = 120, price = 150000 },
            -- { label = 'K4MB1 Motel Odası 3', kind = 'shell', shellId = 121, price = 150000 },
            -- { label = 'K4MB1 Zengin Ev 1', kind = 'shell', shellId = 122, price = 150000 },
            -- { label = 'K4MB1 Zengin Ev 2', kind = 'shell', shellId = 123, price = 150000 },
            -- { label = 'K4MB1 Zengin Ev 3', kind = 'shell', shellId = 124, price = 150000 },
            -- { label = 'K4MB1 Vinewood Evi 1', kind = 'shell', shellId = 125, price = 150000 },
            -- { label = 'K4MB1 Vinewood Evi 2', kind = 'shell', shellId = 126, price = 150000 },
            -- { label = 'K4MB1 Vinewood Malikanesi 1', kind = 'shell', shellId = 127, price = 150000 },
            -- { label = 'K4MB1 Garaj 6', kind = 'shell', shellId = 128, price = 150000 },
            -- { label = 'K4MB1 Lester'ın Evi 1', kind = 'shell', shellId = 129, price = 150000 },
            -- { label = 'K4MB1 Michael'ın Evi', kind = 'shell', shellId = 130, price = 150000 },
            -- { label = 'K4MB1 Çiftlik Evi 1', kind = 'shell', shellId = 131, price = 150000 },
            -- { label = 'K4MB1 Shell', kind = 'shell', shellId = 132, price = 150000 },
            -- { label = 'K4MB1 Karavan 1', kind = 'shell', shellId = 133, price = 150000 },
            -- { label = 'K4MB1 Trevor'ın Evi 1', kind = 'shell', shellId = 134, price = 150000 },
            -- { label = 'K4MB1 V 16', kind = 'shell', shellId = 135, price = 150000 },
            -- { label = 'K4MB1 V 16', kind = 'shell', shellId = 136, price = 150000 },
        },
    },
    {
        id = 'businesses_ipl', label = 'İşletmeler (Hazır Mekan)', ptype = 'business',
        options = {
            { label = 'Ofis (Yönetici)', kind = 'ipl', ipl = 'office_1', price = 500000, entryFee = 0, img = 'ofis_yonetici.jpg' },
            { label = 'Ofis (Maze Bank)', kind = 'ipl', ipl = 'office_2', price = 750000, entryFee = 0, img = 'ofis_maze_bank.jpg' },
            { label = 'Gece Kulübü',       kind = 'ipl', ipl = 'nightclub_1', price = 1200000, entryFee = 100, img = 'gece_kulubu.jpg' },
            { label = 'MC Kulüp Binası',   kind = 'ipl', ipl = 'clubhouse_1', price = 600000, entryFee = 0, img = 'mc_kulup_binasi.jpg' },
            { label = 'Esrar Serası',      kind = 'ipl', ipl = 'weed_1', price = 450000, entryFee = 0, img = 'esrar_serasi.jpg' },
            { label = 'Met Laboratuvarı',  kind = 'ipl', ipl = 'meth_1', price = 550000, entryFee = 0, img = 'met_laboratuvari.jpg' },
            { label = 'Kokain Deposu',     kind = 'ipl', ipl = 'coke_1', price = 700000, entryFee = 0, img = 'kokain_deposu.jpg' },
        },
    },
    {
        id = 'businesses_shell', label = 'İşletmeler (Shell)', ptype = 'business',
        options = {
            { label = 'Shell İşletme 1', kind = 'shell', shellId = 13, price = 400000, entryFee = 50, img = 'shell_isletme_1.jpg' },
            { label = 'Shell İşletme 2', kind = 'shell', shellId = 15, price = 350000, entryFee = 25, img = 'shell_isletme_2.jpg' },

            -- K4MB1 Starter Pack — kalanlar (model+exit zaten doğrulanmıştı):
            { label = 'Konteyner Depo',  kind = 'shell', shellId = 9,  price = 180000, entryFee = 0, img = 'konteyner_depo.jpg' },
            { label = 'Motel Odası',     kind = 'shell', shellId = 11, price = 260000, entryFee = 40, img = 'motel_odasi.jpg' },
            { label = 'Garaj / Tamirhane', kind = 'shell', shellId = 12, price = 320000, entryFee = 0, img = 'garaj_tamirhane.jpg' },
            { label = 'Dükkan / Mağaza', kind = 'shell', shellId = 14, price = 300000, entryFee = 20, img = 'dukkan_magaza.jpg' },
        },
    },
    {
        -- ÖZEL İNŞA: hiçbir hazır shell/IPL kullanmaz. "İçeri Gir" dediğinde
        -- oyuncu sadece kapının olduğu (mülk oluşturulurken durduğu)
        -- KOORDİNATA ışınlanır — yani fiziksel olarak hâlâ dış dünyadadır,
        -- ayrı bir interior/IPL/shell hiç spawn edilmez. Oyuncu mekanı
        -- baştan, panel → "Mekanı Döşe" (duvar/zemin/dekor kataloğu +
        -- "Bitişik Ekle") ile sıfırdan inşa eder. kind/shellId/ipl HİÇ
        -- verilmiyor — server bu durumda shell_id ve ipl_id'yi NULL
        -- bırakır, client TeleportIntoInterior'daki genel (shell/ipl
        -- olmayan) dala düşer, ki bu zaten "kapı koordinatına ışınla"
        -- davranışıdır — yani kod tarafında EKSTRA bir şey gerekmedi.
        id = 'homes_custom', label = 'Evler (Özel İnşa)', ptype = 'home',
        options = {
            { label = 'Boş Arsa (Sıfırdan İnşa Et)', price = 60000, img = 'bos_arsa_sifirdan_insa_et.jpg' },
        },
    },
    {
        id = 'businesses_custom', label = 'İşletmeler (Özel İnşa)', ptype = 'business',
        options = {
            { label = 'Boş İşyeri (Sıfırdan İnşa Et)', price = 90000, entryFee = 0, img = 'bos_isyeri_sifirdan_insa_et.jpg' },
        },
    },
}

-- Keys / doorbell
Config.Keys = {
    maxHolders = 10,
    knockKey   = 38,   -- E to knock when locked & no access
    doorbell   = true,
}

-- ============================================================
--  NATIVE SHELL MODELLERİ — qb-interior GEREKMEZ
--  Model adı + exit offset, sadece bu tabloyu düzenleyerek eklenir/değişir.
--  exit = mekanın İÇİNDE, modelin spawn noktasına göre YEREL koordinat farkı
--  (model her zaman heading 0 ile spawnlanıyor, o yüzden world delta = local offset).
--
--  Yeni paket eklemek için:
--   1) Paketin stream/ içeriğini bu resource'un stream/ klasörüne kopyala.
--   2) Model adını öğren: .ytyp dosyasını text editörle aç, <archetypes> içindeki
--      <name>modeladi</name> satırlarına bak (ytyp düz XML'dir, CodeWalker ile de açılır).
--   3) Exit offsetini bul: sunucuda admin olarak /shelltest <model> yaz (modeli önüne
--      spawnlar), içine gir, çıkış noktasına geç, /shellexit yaz — çıkan tabloyu
--      kopyalayıp aşağıya yapıştır. /shelltestclear ile test objesini sil.
-- ============================================================
Config.NativeShells = {
    -- ---- K4MB1 Starter Pack (qb-interior'un resmi kaynağından doğrulandı) ----
    [1]  = { model = 'shell_michael',      exit = { x = -9.49, y = 5.54,   z = 9.91,  h = 270.86 } },
    [2]  = { model = 'shell_frankaunt',    exit = { x = -0.36, y = -5.89,  z = 1.70,  h = 358.21 } },
    [3]  = { model = 'shell_ranch',        exit = { x = -1.257,y = -5.469, z = 2.5,   h = 270.57 } },
    [4]  = { model = 'shell_v16mid',       exit = { x = 1.561, y = -14.305,z = 1.147, h = 2.263  } },
    [5]  = { model = 'shell_v16low',       exit = { x = 4.693, y = -6.015, z = 1.11,  h = 358.634} },
    [6]  = { model = 'shell_lester',       exit = { x = -1.780,y = -0.795, z = 1.1,   h = 270.30 } },
    [7]  = { model = 'shell_trevor',       exit = { x = 0.374, y = -3.789, z = 2.428, h = 358.633} },
    [8]  = { model = 'shell_trailer',      exit = { x = -1.4,  y = -2.1,   z = 3.3,   h = 358.634} },
    [9]  = { model = 'container_shell',    exit = { x = 0.08,  y = -5.73,  z = 1.24,  h = 359.32 } },
    [10] = { model = 'furnitured_midapart',exit = { x = 1.46,  y = -10.33, z = 1.06,  h = 0.39   } },
    [11] = { model = 'modernhotel_shell',  exit = { x = 4.98,  y = 4.35,   z = 1.16,  h = 179.79 } },
    [12] = { model = 'shell_garagemed',    exit = { x = 13.90, y = 1.63,   z = 1.0,   h = 87.05  } },
    [13] = { model = 'shell_office1',      exit = { x = 1.88,  y = 5.06,   z = 2.05,  h = 180.07 } },
    [14] = { model = 'shell_store1',       exit = { x = -2.61, y = -4.73,  z = 1.08,  h = 1.0    } },
    [15] = { model = 'shell_warehouse1',   exit = { x = -8.95, y = 0.51,   z = 1.04,  h = 268.82 } },
    [16] = { model = 'shell_v16low',       exit = { x = 4.693, y = -6.015, z = 1.11,  h = 358.634} }, -- 5 ile aynı

    -- NOT: Lynx Shells artık NativeShells[35..40]'ta (yukarı bak) — bu
    -- dosyada bir süre IPLInteriors'taydı, tekrar NativeShells'e taşındı.

    -- ---- Envi-Shells (github.com/Envi-Scripts/envi-shells, ücretsiz, 6 shell) ----
    -- Model adları + exit (doorOffset/doorHeading) değerleri Envi-Scripts'in
    -- cfx.re forum konusunda bir kullanıcı (JIM_the_one_and_only) tarafından
    -- paylaşıldı, Envi-Scripts'in kendisi "muhtemelen doğru çalışır" diye
    -- yanıtladı. Yani RESMİ DEĞİL ama yazarınca onaylanmış — K4MB1 kadar
    -- %100 garanti değil, gene de en güvenilir veri bu. Yanlış çıkarsa
    -- /shelltest + /shellexit ile düzeltirsin.
    [23] = { model = 'envi_shell_01_empty',      exit = { x = 0.600220, y = 0.597168,   z = -1.127975, h = 2.261546 } },
    [24] = { model = 'envi_shell_01_furnished',  exit = { x = 0.390381, y = 0.518066,   z = -1.128654, h = 2.298164 } },
    [25] = { model = 'envi_shell_02_empty',      exit = { x = 0.072021, y = -10.788818, z = 0.038795,  h = 356.032074 } },
    [26] = { model = 'envi_shell_02_furnished',  exit = { x = 0.123047, y = -11.069580, z = 0.045692,  h = 358.241425 } },
    [27] = { model = 'envi_shell_03_empty',      exit = { x = 5.004517, y = -6.798584,  z = 0.192665,  h = 92.380592 } },
    [28] = { model = 'envi_shell_03_furnished',  exit = { x = 4.955200, y = 1.096436,   z = 0.194565,  h = 87.552078 } },

    -- ✅ EKLENDİ: bunların hiçbirinde .ymap YOK (sadece ham .ydr/.ytyp) —
    -- yani pb_haus/moto_shell01'in AKSİNE, haritada hazır bir yerleri
    -- yok. qb-interior mantığıyla (CreateObject + kalibre edilmiş exit)
    -- kurulmaları gerekiyor — SpawnShellForProperty zaten bunu destekliyor,
    -- sadece exit verisi eksik. Oyunda /shelltest <model_adi> yaz, içine
    -- gir, çıkış noktasına git, /shellexit yaz — konsola bastığı x/y/z/h
    -- değerlerini buraya (exit = {...}) yapıştır.
    [29] = { model = 'finals_modernloftv1', exit = nil }, -- /shelltest finals_modernloftv1
    [30] = { model = 'tihulu_kafi_motel',   exit = nil }, -- /shelltest tihulu_kafi_motel
    [31] = { model = 'apart_luxe_1',        exit = nil }, -- /shelltest apart_luxe_1
    [32] = { model = 'coke_business_empty', exit = nil }, -- /shelltest coke_business_empty
    [33] = { model = 'motel_low',           exit = nil }, -- /shelltest motel_low
    [34] = { model = 'warehouse_small',     exit = nil }, -- /shelltest warehouse_small

    -- ✅ DÖNÜŞTÜRÜLDÜ (kullanıcı isteğiyle): Lynx Shells + pb_haus +
    -- moto_shell01 artık IPLInteriors (ymap ile sabit gerçek-dünya
    -- koordinatı) DEĞİL, NativeShells (qb-interior mantığı — CreateObject
    -- ile özel/izole bir "cep" koordinatına spawn) kullanıyor. Sebep:
    -- ymap'le sabit konumda birden fazla mülk AYNI shell'i kullanırsa
    -- hepsi TAM AYNI 3D noktaya düşüyordu (routing bucket oyuncuları
    -- birbirinden gizliyor ama obje'nin kendisi hâlâ TEK, paylaşılan bir
    -- world-konumundaydı); NativeShells her mülke property.id'ye göre
    -- BENZERSİZ bir cep veriyor. Lynx paketinin kendi README'si de bu
    -- kullanımı destekliyor ("Remove the Ymap folder if you use your
    -- own method of spawning in the shells").
    -- ⚠️ ESKİ ipl={}'deki spawn vector4'leri BURAYA taşınamaz — onlar
    -- GERÇEK DÜNYA koordinatlarıydı, NativeShells'in exit'i ise
    -- CreateObject'in koyduğu ÖZEL cep konumuna GÖRE (relative) bir
    -- offset. Yani hepsi SIFIRDAN /shelltest + /shellexit ile kalibre
    -- edilmeli — model adları Lynx'in resmi GitHub README'sinden
    -- (github.com/Lynxist/lynx_shells) doğrulandı, tahmin değil.
    [35] = { model = 't1_unfurn_shell', exit = nil }, -- /shelltest t1_unfurn_shell
    [36] = { model = 't1_furn_shell',   exit = nil }, -- /shelltest t1_furn_shell
    [37] = { model = 't2_unfurn_shell', exit = nil }, -- /shelltest t2_unfurn_shell
    [38] = { model = 't2_furn_shell',   exit = nil }, -- /shelltest t2_furn_shell
    [39] = { model = 't3_unfurn_shell', exit = nil }, -- /shelltest t3_unfurn_shell
    [40] = { model = 't3_furn_shell',   exit = nil }, -- /shelltest t3_furn_shell
    [41] = { model = 'pb_haus_shell_001', exit = nil }, -- /shelltest pb_haus_shell_001
    [42] = { model = 'moto_shell01_shell', exit = nil }, -- /shelltest moto_shell01_shell (moto_shell01_mlo.ybn kolizyon dosyası, ayrıca stream edilmeli ama Config'e girmiyor)

    -- ✅ EKLENDİ: Kullanıcının getirdiği GENİŞLETİLMİŞ K4MB1 paketi (93
    -- yeni shell) — hepsi tek parça .ydr (senin de dediğin gibi "hepsi
    -- shell"), gerçek dünya koordinatına gerek yok, hepsi CreateObject
    -- ile izole bir cebe spawn oluyor. Furniture-only dosyaları (_furn),
    -- doku/kolizyon/shared dosyalarını, ve k4mb1_modernmansion1'i (50+
    -- ayrı dosyalı, gerçek bir MLO gibi karmaşık, tek satırda GÜVENLE
    -- eklenemeyecek bir paket — ayrıca ele alınmalı) buraya KATMADIM.
    -- Hepsi kalibrasyon bekliyor: /shelltest <model_adi> + /shellexit.

    -- ✅ EKLENDİ: Eclipse Rooftop MLO — Blender'da BİRLEŞTİRMEYE gerek
    -- kalmadan, orijinal ayrı .ydr parçaları "üst üste" spawn ediliyor
    -- (models = liste). Kolizyon (.ybn) dosyaları ayrıca stream edilmeli
    -- ama bu tabloya girmiyor (GTA otomatik eşleştiriyor, model adı aynı
    -- olduğu sürece .ybn'i kendisi buluyor).
    [43] = {
        models = { 'app_exterior_shell', 'app_interior_shell', 'grass_fur' },
        exit = nil, -- /shelltest app_exterior_shell app_interior_shell grass_fur
    },

    [44] = { model = 'k4_apa1_shell', exit = nil }, -- /shelltest k4_apa1_shell
    [45] = { model = 'k4_apa2_shell', exit = nil }, -- /shelltest k4_apa2_shell
    [46] = { model = 'k4_apa3_shell', exit = nil }, -- /shelltest k4_apa3_shell
    [47] = { model = 'k4_house1_shell', exit = nil }, -- /shelltest k4_house1_shell
    [48] = { model = 'k4_house2_shell', exit = nil }, -- /shelltest k4_house2_shell
    [49] = { model = 'k4_house3_shell', exit = nil }, -- /shelltest k4_house3_shell
    [50] = { model = 'k4_house4_shell', exit = nil }, -- /shelltest k4_house4_shell
    [51] = { model = 'k4_house5_shell', exit = nil }, -- /shelltest k4_house5_shell
    [52] = { model = 'k4_house6_shell', exit = nil }, -- /shelltest k4_house6_shell
    [53] = { model = 'k4_house7_shell', exit = nil }, -- /shelltest k4_house7_shell
    [54] = { model = 'k4_house8_shell', exit = nil }, -- /shelltest k4_house8_shell
    [55] = { model = 'k4_house9_shell', exit = nil }, -- /shelltest k4_house9_shell
    [56] = { model = 'k4_house10_shell', exit = nil }, -- /shelltest k4_house10_shell
    [57] = { model = 'k4_house11_shell', exit = nil }, -- /shelltest k4_house11_shell
    [58] = { model = 'k4_house12_shell', exit = nil }, -- /shelltest k4_house12_shell
    [59] = { model = 'k4_house13_shell', exit = nil }, -- /shelltest k4_house13_shell
    [60] = { model = 'k4_house14_shell', exit = nil }, -- /shelltest k4_house14_shell
    [61] = { model = 'k4_loft1_shell', exit = nil }, -- /shelltest k4_loft1_shell
    [62] = { model = 'k4_loft2_shell', exit = nil }, -- /shelltest k4_loft2_shell
    [63] = { model = 'k4_loft3_shell', exit = nil }, -- /shelltest k4_loft3_shell
    [64] = { model = 'k4_manor1_shell', exit = nil }, -- /shelltest k4_manor1_shell
    [65] = { model = 'k4_manor2_shell', exit = nil }, -- /shelltest k4_manor2_shell
    [66] = { model = 'k4_modern1_shell', exit = nil }, -- /shelltest k4_modern1_shell
    [67] = { model = 'k4_modern2_shell', exit = nil }, -- /shelltest k4_modern2_shell
    [68] = { model = 'k4_modern3_shell', exit = nil }, -- /shelltest k4_modern3_shell
    [69] = { model = 'k4_modern4_shell', exit = nil }, -- /shelltest k4_modern4_shell
    [70] = { model = 'k4_modern5_shell', exit = nil }, -- /shelltest k4_modern5_shell
    [71] = { model = 'k4_modern6_shell', exit = nil }, -- /shelltest k4_modern6_shell
    [72] = { model = 'k4_modern7_shell', exit = nil }, -- /shelltest k4_modern7_shell
    [73] = { model = 'k4_modern8_shell', exit = nil }, -- /shelltest k4_modern8_shell
    [74] = { model = 'k4_modern9_shell', exit = nil }, -- /shelltest k4_modern9_shell
    [75] = { model = 'k4_modern10_shell', exit = nil }, -- /shelltest k4_modern10_shell
    [76] = { model = 'k4_penthouse_shell', exit = nil }, -- /shelltest k4_penthouse_shell
    [77] = { model = 'k4_penthouse2_shell', exit = nil }, -- /shelltest k4_penthouse2_shell
    [78] = { model = 'k4_vwmansion2a_shell', exit = nil }, -- /shelltest k4_vwmansion2a_shell
    [79] = { model = 'k4_vwmansion2b_shell', exit = nil }, -- /shelltest k4_vwmansion2b_shell
    [80] = { model = 'k4_vwmansion3_shell', exit = nil }, -- /shelltest k4_vwmansion3_shell
    [81] = { model = 'k4_basement1_shell', exit = nil }, -- /shelltest k4_basement1_shell
    [82] = { model = 'k4_basement2_shell', exit = nil }, -- /shelltest k4_basement2_shell
    [83] = { model = 'k4_basement3_shell', exit = nil }, -- /shelltest k4_basement3_shell
    [84] = { model = 'k4_basement4_shell', exit = nil }, -- /shelltest k4_basement4_shell
    [85] = { model = 'k4_basement5_shell', exit = nil }, -- /shelltest k4_basement5_shell
    [86] = { model = 'k4_biker1_shell', exit = nil }, -- /shelltest k4_biker1_shell
    [87] = { model = 'k4_biker2_shell', exit = nil }, -- /shelltest k4_biker2_shell
    [88] = { model = 'k4_biker3_shell', exit = nil }, -- /shelltest k4_biker3_shell
    [89] = { model = 'k4_container_shell', exit = nil }, -- /shelltest k4_container_shell
    [90] = { model = 'k4_office1_shell', exit = nil }, -- /shelltest k4_office1_shell
    [91] = { model = 'k4_office2_shell', exit = nil }, -- /shelltest k4_office2_shell
    [92] = { model = 'k4_office3_shell', exit = nil }, -- /shelltest k4_office3_shell
    [93] = { model = 'k4_office4_shell', exit = nil }, -- /shelltest k4_office4_shell
    [94] = { model = 'k4_office5_shell', exit = nil }, -- /shelltest k4_office5_shell
    [95] = { model = 'k4_office6_shell', exit = nil }, -- /shelltest k4_office6_shell
    [96] = { model = 'k4_office7_shell', exit = nil }, -- /shelltest k4_office7_shell
    [97] = { model = 'k4_office8_shell', exit = nil }, -- /shelltest k4_office8_shell
    [98] = { model = 'k4_stashhouse1_shell', exit = nil }, -- /shelltest k4_stashhouse1_shell
    [99] = { model = 'k4_stashhouse2_shell', exit = nil }, -- /shelltest k4_stashhouse2_shell
    [100] = { model = 'k4_store1_shell', exit = nil }, -- /shelltest k4_store1_shell
    [101] = { model = 'k4_store2_shell', exit = nil }, -- /shelltest k4_store2_shell
    [102] = { model = 'k4_store3_shell', exit = nil }, -- /shelltest k4_store3_shell
    [103] = { model = 'k4_store4_shell', exit = nil }, -- /shelltest k4_store4_shell
    [104] = { model = 'k4_store5_shell', exit = nil }, -- /shelltest k4_store5_shell
    [105] = { model = 'k4_warehouse1_shell', exit = nil }, -- /shelltest k4_warehouse1_shell
    [106] = { model = 'k4_warehouse2_shell', exit = nil }, -- /shelltest k4_warehouse2_shell
    [107] = { model = 'k4_warehouse3_shell', exit = nil }, -- /shelltest k4_warehouse3_shell
    [108] = { model = 'k4_warehouse4_shell', exit = nil }, -- /shelltest k4_warehouse4_shell
    [109] = { model = 'k4_warehouse5_shell', exit = nil }, -- /shelltest k4_warehouse5_shell
    [110] = { model = 'k4_classic1_shell', exit = nil }, -- /shelltest k4_classic1_shell
    [111] = { model = 'k4_classic2_shell', exit = nil }, -- /shelltest k4_classic2_shell
    [112] = { model = 'k4_classic3_shell', exit = nil }, -- /shelltest k4_classic3_shell
    [113] = { model = 'k4_classic4_shell', exit = nil }, -- /shelltest k4_classic4_shell
    [114] = { model = 'k4_classic5_shell', exit = nil }, -- /shelltest k4_classic5_shell
    [115] = { model = 'k4_classic6_shell', exit = nil }, -- /shelltest k4_classic6_shell
    [116] = { model = 'k4_hotel1_shell', exit = nil }, -- /shelltest k4_hotel1_shell
    [117] = { model = 'k4_hotel2_shell', exit = nil }, -- /shelltest k4_hotel2_shell
    [118] = { model = 'k4_hotel3_shell', exit = nil }, -- /shelltest k4_hotel3_shell
    [119] = { model = 'k4_motel1_shell', exit = nil }, -- /shelltest k4_motel1_shell
    [120] = { model = 'k4_motel2_shell', exit = nil }, -- /shelltest k4_motel2_shell
    [121] = { model = 'k4_motel3_shell', exit = nil }, -- /shelltest k4_motel3_shell
    [122] = { model = 'k4_richman1_shell', exit = nil }, -- /shelltest k4_richman1_shell
    [123] = { model = 'k4_richman2_shell', exit = nil }, -- /shelltest k4_richman2_shell
    [124] = { model = 'k4_richman3_shell', exit = nil }, -- /shelltest k4_richman3_shell
    [125] = { model = 'k4_vwhouse1_shell', exit = nil }, -- /shelltest k4_vwhouse1_shell
    [126] = { model = 'k4_vwhouse2_shell', exit = nil }, -- /shelltest k4_vwhouse2_shell
    [127] = { model = 'k4_vwmansion1_shell', exit = nil }, -- /shelltest k4_vwmansion1_shell
    [128] = { model = 'k4_garage6_shell', exit = nil }, -- /shelltest k4_garage6_shell
    [129] = { model = 'k4_lester1_shell', exit = nil }, -- /shelltest k4_lester1_shell
    [130] = { model = 'k4_michael_shell', exit = nil }, -- /shelltest k4_michael_shell
    [131] = { model = 'k4_ranch1_shell', exit = nil }, -- /shelltest k4_ranch1_shell
    [132] = { model = 'k4_shell_medium1', exit = nil }, -- /shelltest k4_shell_medium1
    [133] = { model = 'k4_trailer1_shell', exit = nil }, -- /shelltest k4_trailer1_shell
    [134] = { model = 'k4_trevor1_shell', exit = nil }, -- /shelltest k4_trevor1_shell
    [135] = { model = 'k4_v16low1_shell', exit = nil }, -- /shelltest k4_v16low1_shell
    [136] = { model = 'k4_v16mid1_shell', exit = nil }, -- /shelltest k4_v16mid1_shell
}

-- shellId 23-28'i de yayına aç (orijinal Config.PropertyShells tablosu sadece
-- 1-22'yi içeriyordu; 17-22 zaten orada vardı, 23-28'i ek olarak açıyoruz).
for i = 23, 28 do
    Config.PropertyShells[i] = true
end
-- ✅ EKLENDİ: yeni 6 shell (29-34) — kalibrasyon TAMAMLANMADAN emlakçıda
-- göstermeyin diye Config.RealtorCategories'e henüz EKLEMEDİM (yorum
-- satırı halinde aşağıda duruyor); PropertyShells'e şimdiden açıyorum ki
-- /shelltest ile test ederken hata vermesin.
for i = 29, 34 do
    Config.PropertyShells[i] = true
end
-- ✅ EKLENDİ: Lynx (35-40) + pb_haus (41) + moto_shell01 (42) dönüştürüldü
for i = 35, 42 do
    Config.PropertyShells[i] = true
end
Config.PropertyShells[43] = true
-- ✅ EKLENDİ: genişletilmiş K4MB1 paketi (44-136)
for i = 44, 136 do
    Config.PropertyShells[i] = true
end
