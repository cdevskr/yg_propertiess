# yg_properties — Güncelleme Notları

qb-interior bağımlılığı kaldırıldı, NUI emlakçı + büyük yönetim paneli + anahtar sistemi +
zil + IPL daireler + obje limiti + relog'da evde doğma eklendi. Obje yerleştirme (object_gizmo)
aynen korundu.

## Kurulum
1. **SQL:** `sql/additions.sql` dosyasını bir kez çalıştır (keys + relog tabloları + interior kolonları).
2. **Stream:** qb-interior'un `stream/` klasöründeki shell asset'lerini **bu resource'un içine** bir
   `stream/` klasörü açıp kopyala. (Artık qb-interior'u başlatmana gerek yok, sadece asset'leri lazım.)
3. **Shell modelleri:** `shared/config.lua` içinde `Config.ShellModels[1..22]` şu an hepsi fallback
   modeline ayarlı. qb-interior'daki gerçek shell prop adlarını oraya yaz (örn. `[1] = { model = 'shell_xxx', spawn = vector4(...) }`).
   Bilmiyorsan: qb-interior'un shell dosyasını bana yükle, hepsini tek tek bakıp doldurayım.
4. **Bağımlılıklar:** qb-core, ox_lib, oxmysql, object_gizmo (+ stash için ox_inventory).

## Kullanım
- Kapıya yaklaş → **[E]**: sahipliyse gir, değilse satın al menüsü.
- **F7** veya `/emlakci`: emlakçı menüsü (Evler / İşletmeler → seç, bulunduğun yere mülk kurulur).
- İçerideyken `/mekanpanel`: büyük yönetim paneli (detaylar, döşeme, anahtarlar, çalışanlar, giriş ücreti, spawn taşıma, satış).
- `/anahtarlarim`: anahtarın olan mülkler.
- **BACKSPACE** veya `/cikis`: mekandan çık.
- Kilitli kapıda [E] → zil çalar, içerideki sahip/anahtarlılar bildirim alır.

## Notlar
- **client/main.lua sıfırdan yazıldı** — yüklediğin zip'te düz klasöre tek `main.lua` (server) gelmişti,
  client tarafı server'ın altında kalıp kaybolmuştu. Yeni client; mevcut DB kolonların
  (door_coords / build_origin / interior_spawn / shell_id) ve server callback'lerinle birebir uyumlu.
- Shell'ler artık native `CreateObject` ile bucket içinde oluşturuluyor (qb-interior'un yaptığı işin aynısı).
