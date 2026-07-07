-- ============================================================
--  yg_properties — TAM VERİTABANI ŞEMASI
--  (Koddaki tüm SELECT/INSERT/UPDATE'lerden türetildi.)
--  Tek seferde çalıştır. MariaDB / MySQL uyumlu.
-- ============================================================

-- 1) Ana mülk tablosu ----------------------------------------
CREATE TABLE IF NOT EXISTS `yg_properties` (
    `id`              INT             NOT NULL AUTO_INCREMENT,
    `type`            VARCHAR(16)     NOT NULL DEFAULT 'home',      -- 'home' | 'business'
    `label`           VARCHAR(64)     NOT NULL DEFAULT 'Mekan',
    `price`           BIGINT          NOT NULL DEFAULT 0,
    `entry_fee`       INT             NOT NULL DEFAULT 0,
    `owner_citizenid` VARCHAR(64)     DEFAULT NULL,                 -- NULL = sahipsiz (satılık)
    `created_by`      VARCHAR(64)     DEFAULT NULL,
    `door_coords`     TEXT            DEFAULT NULL,                 -- vec4 JSON {x,y,z,w}
    `build_origin`    TEXT            DEFAULT NULL,                 -- vec4 JSON
    `interior_spawn`  TEXT            DEFAULT NULL,                 -- vec4 JSON | NULL
    `locked`          TINYINT(1)      NOT NULL DEFAULT 0,
    `employees`       LONGTEXT        DEFAULT NULL,                 -- JSON map: { "citizenid": true }
    `permissions`     LONGTEXT        DEFAULT NULL,                 -- JSON: izinler
    `shell_id`        INT             DEFAULT NULL,                 -- 1-22 | NULL
    `description`     TEXT            DEFAULT NULL,
    `stash_money`     BIGINT          NOT NULL DEFAULT 0,
    `interior_kind`   VARCHAR(16)     DEFAULT 'shell',              -- 'shell' | 'ipl'
    `ipl_id`          VARCHAR(48)     DEFAULT NULL,                 -- IPLInteriors anahtarı
    `stash_point`     TEXT            DEFAULT NULL,                 -- depo target noktası (vec4 json)
    `wardrobe_point`  TEXT            DEFAULT NULL,                 -- gardırop target noktası (vec4 json)
    PRIMARY KEY (`id`),
    KEY `owner_citizenid` (`owner_citizenid`),
    KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2) Yerleştirilen objeler (döşeme) --------------------------
CREATE TABLE IF NOT EXISTS `yg_property_objects` (
    `id`           INT          NOT NULL AUTO_INCREMENT,
    `property_id`  INT          NOT NULL,
    `model`        VARCHAR(80)  NOT NULL,
    `coords`       TEXT         DEFAULT NULL,                       -- JSON {x,y,z}
    `rotation`     TEXT         DEFAULT NULL,                       -- JSON {x,y,z}
    `frozen`       TINYINT(1)   NOT NULL DEFAULT 1,
    `metadata`     TEXT         DEFAULT NULL,                       -- JSON
    PRIMARY KEY (`id`),
    KEY `property_id` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3) Anahtar sahipleri ---------------------------------------
CREATE TABLE IF NOT EXISTS `yg_property_keys` (
    `id`           INT          NOT NULL AUTO_INCREMENT,
    `property_id`  INT          NOT NULL,
    `citizenid`    VARCHAR(64)  NOT NULL,
    `name`         VARCHAR(64)  DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `prop_cid` (`property_id`, `citizenid`),
    KEY `property_id` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4) İçeride olanlar (relog'da evde doğma) --------------------
CREATE TABLE IF NOT EXISTS `yg_property_inside` (
    `citizenid`    VARCHAR(64)  NOT NULL,
    `property_id`  INT          NOT NULL,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
