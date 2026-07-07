-- ============================================================
--  yg_properties — ek tablolar (keys + relog)
--  Mevcut yg_properties / yg_property_objects tablolarına DOKUNMAZ.
--  Bunları bir kez çalıştır.
-- ============================================================

-- Anahtar sahipleri (sahip dışındaki erişimi olan oyuncular)
CREATE TABLE IF NOT EXISTS `yg_property_keys` (
    `id`           INT NOT NULL AUTO_INCREMENT,
    `property_id`  INT NOT NULL,
    `citizenid`    VARCHAR(64) NOT NULL,
    `name`         VARCHAR(64) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `prop_cid` (`property_id`, `citizenid`),
    KEY `property_id` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- İçeride kim hangi mülkteydi (relog'da evde doğma)
CREATE TABLE IF NOT EXISTS `yg_property_inside` (
    `citizenid`    VARCHAR(64) NOT NULL,
    `property_id`  INT NOT NULL,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- yg_properties tablosuna interior tipi kolonları (IPL daireler için gerekli).
-- MariaDB'de IF NOT EXISTS çalışır; MySQL kullanıyorsan ve kolon zaten varsa bu satırı atla.
ALTER TABLE `yg_properties` ADD COLUMN IF NOT EXISTS `interior_kind` VARCHAR(16) DEFAULT 'shell';
ALTER TABLE `yg_properties` ADD COLUMN IF NOT EXISTS `ipl_id` VARCHAR(48) DEFAULT NULL;

-- ✅ EKLENDİ: Shell Şablonları — Build Mode'da inşa edilen bir mekanı
-- (duvarlar/zeminler/kapılı duvarlar vb.) TEK bir bütün "shell" olarak
-- kaydedip başka mülklerde de aynı şekilde spawn edebilmek için.
CREATE TABLE IF NOT EXISTS `yg_shell_templates` (
    `id`             INT          NOT NULL AUTO_INCREMENT,
    `label`          VARCHAR(80)  NOT NULL,
    `owner_citizenid` VARCHAR(50) DEFAULT NULL,
    `data`           LONGTEXT     NOT NULL,   -- JSON: { pieces = [{model,dx,dy,dz,rx,ry,rz}, ...] }
    `piece_count`    INT          NOT NULL DEFAULT 0,
    `created_at`     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ✅ EKLENDİ: bir mülk, statik Config.NativeShells yerine DB'deki bir
-- şablonu kullanıyorsa bu sütun doldurulur (shell_id NULL kalır).
ALTER TABLE `yg_properties` ADD COLUMN IF NOT EXISTS `shell_template_id` INT DEFAULT NULL;

-- ✅ EKLENDİ: Emlakçı haritasında shell'lerin (rastgele/izole cepte
-- spawn olan mülklerin) GERÇEK bir konumu olmadığı için, admin'in bu
-- katalog girdilerine "haritada burada gösterilsin" diye elle bir
-- konum atayabilmesi için. IPL mülkleri buna gerek duymuyor (onların
-- konumu zaten Config.IPLInteriors'ta var, otomatik kullanılıyor).
CREATE TABLE IF NOT EXISTS `yg_catalog_locations` (
    `id`         INT          NOT NULL AUTO_INCREMENT,
    `kind`       VARCHAR(10)  NOT NULL,   -- 'shell' ya da 'ipl' (ipl'i override etmek istersen)
    `ref_key`    VARCHAR(50)  NOT NULL,   -- shellId (sayı) ya da ipl anahtarı (string)
    `x`          FLOAT        NOT NULL,
    `y`          FLOAT        NOT NULL,
    `z`          FLOAT        DEFAULT NULL,
    `heading`    FLOAT        DEFAULT NULL,
    `set_by`     VARCHAR(50)  DEFAULT NULL,
    `updated_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `kind_ref` (`kind`, `ref_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
