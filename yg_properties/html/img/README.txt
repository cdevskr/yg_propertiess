GÖRSEL KLASÖRÜ — kendi ekran görüntülerini buraya at
======================================================

Ben (Claude) senin oyunundaki gerçek mülklerin ekran görüntüsünü
çekemiyorum — görsel erişimim yok. Bu yüzden kodu, dosya VARSA
otomatik gösterecek, YOKSA mevcut ikona zarifçe düşecek şekilde
kurdum. Sen istediğin zaman buraya .jpg/.png atınca devreye girer.

DOSYA ADLANDIRMA KURALI:

1) Emlakçı kartları (shared/config.lua -> Config.RealtorCategories
   içindeki her option'ın "img" alanı) — ŞÖYLE EKLE:
     { label = 'Eclipse Daire 1', kind = 'ipl', ipl = 'eclipse_1',
       price = 250000, img = 'eclipse_1.jpg' }
   Sonra bu dosyayı tam olarak şu isimle buraya koy:
     html/img/eclipse_1.jpg
   "img" alanını HİÇ eklemezsen kart eskisi gibi ikon gösterir,
   hiçbir şey bozulmaz.

2) Mülk Detayları paneli (yönetim panelinde sağ taraf) — bir mülkün
   açıklamasına resim eklemek istersen aynı mantık, ama bu daha
   sonra server tarafına "img" alanı eklenmesini gerektirir (şu an
   DB'de böyle bir alan yok, bunu yorum satırında işaretledim, istersen
   bir sonraki adımda DB migration'ı ekleriz).

GENİŞLİK/YÜKSEKLİK: kartlar 16:10 oranında kırpılıyor (CSS object-fit:
cover), yaklaşık 400x250px ve üzeri bir kaynak yeterli, daha büyüğü de
sorun değil.

TELİF UYARISI: buraya koyduğun her görsel SENİN sorumluluğun —
internetten bulduğun gerçek mülk fotoğrafları, başka bir oyunun
ekran görüntüleri vb. telifli olabilir. Kendi GTA ekran görüntülerini
kullanmanı öneririm.

======================================================
HARİTA GÖRSELİ (emlakçı ekranındaki sağ panel)
======================================================

Ben (Claude) gerçek GTA V harita görselini kullanamıyorum (telif —
Rockstar'ın kendi haritası, kaç scriptin kullandığından bağımsız
olarak). Onun yerine kod, SEN kendi harita görselini eklersen onu
gösterecek, eklemezsen kendi özgün soyut haritamıza dönecek şekilde
kuruldu.

NASIL EKLENİR:
  Dosyayı TAM OLARAK şu isimle buraya koy:
    html/img/map.jpg
  (jpg olması şart, farklı bir uzantı istersen app.js'te
  "src=\"img/map.jpg\"" satırını değiştirmen yeterli.)

Dosyayı attığın an emlakçı ekranındaki harita paneli otomatik olarak
senin görselini gösterir, mavi pin'ler (mülklerin gerçek konumu)
üzerine biner.

KALİBRASYON NOTU (dürüst olmam lazım): Pin'lerin haritanın DOĞRU
noktasına denk gelmesi, senin attığın görselin GTA'nın tüm oyun
haritasını (Cayo Perico HARİÇ, sadece ana ada) standart bir kadrajla
kapsadığını varsayıyor. Kullandığım oyun-koordinatı sınırları
(shared'da değil, html/app.js içinde RL_WORLD sabiti):
  X: -4000 ile 4500 arası, Y: -4500 ile 8000 arası
Senin haritan bu kadraja tam oturmuyorsa (kırpılmış, farklı oranlı,
sadece şehir merkezini gösteren bir görsel vb.) pin'ler biraz kaymış
görünebilir. Böyle bir durumda html/app.js içinde RL_WORLD sabitindeki
4 sayıyı (minX/maxX/minY/maxY) görselinin gerçek kadrajına göre ince
ayar yapmamız gerekir — atınca bana söyle, birlikte ayarlarız.
