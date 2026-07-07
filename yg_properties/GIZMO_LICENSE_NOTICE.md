# Gizmo Lisans Notu

`client/gizmo.lua` ve `client/dataview.lua`, **object_gizmo**
(github.com/DemiAutomatic/object_gizmo) projesinden **aynı çekirdek
mekanizma** (DrawGizmo native + EnterCursorMode + dataview matrix
marshalling) kullanılarak port edildi.

- object_gizmo lisansı: **GPL-3.0**
- `client/dataview.lua`: object_gizmo'dan birebir kopyalandı (kendisi de
  CitizenFX'in resmi örnek scriptlerinden alınmış, dosyanın başındaki
  credit yorumu korunmuştur).
- `client/gizmo.lua`: aynı native çağrı mekanizması korunarak yeniden
  yazıldı (Türkçe arayüz metinleri, farklı fonksiyon ismi/dönüş tipi,
  ve dosya başında belirtilen birkaç kasıtlı davranış farkı ile).

GPL-3.0, türetilmiş çalışmaların da GPL-3.0 ile dağıtılmasını ve kaynak
kodun erişilebilir olmasını şart koşar. Bu script'i (yg_properties)
**dışarıya dağıtırsan/satarsan** bu gerekliliklere uymanı öneririm —
sadece kendi sunucunda kullanıyorsan pratik bir sorun yok, ama bilmen
gerektiğini düşündüğüm bir husus.

Orijinal proje ve teşekkürler:
- DemiAutomatic (Austin Dunn) — github.com/DemiAutomatic/object_gizmo
- Andyyy7666 — github.com/overextended/ox_lib/pull/453
- AvarianKnight — forum.cfx.re/t/allow-drawgizmo-to-be-used-outside-of-fxdk/5091845
