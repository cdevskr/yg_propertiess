local function run(query, params)
  local ok, err = pcall(function()
    MySQL.query.await(query, params or {})
  end)
  if not ok then
    print(('[yg_properties] schema query failed: %s | %s'):format(query, tostring(err)))
  end
end

local function hasColumn(tbl, column)
  local row = MySQL.single.await(('SHOW COLUMNS FROM `%s` LIKE ?'):format(tbl), { column })
  return row ~= nil
end

local function addColumn(tbl, column, definition)
  if hasColumn(tbl, column) then return end
  run(('ALTER TABLE `%s` ADD COLUMN `%s` %s'):format(tbl, column, definition))
end

MySQL.ready(function()
  run([[CREATE TABLE IF NOT EXISTS `yg_property_keys` (
    `property_id` INT NOT NULL,
    `citizenid` VARCHAR(64) NOT NULL,
    `holder_name` VARCHAR(128) NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`property_id`, `citizenid`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])

  run([[CREATE TABLE IF NOT EXISTS `yg_property_business_staff` (
    `property_id` INT NOT NULL,
    `citizenid` VARCHAR(64) NOT NULL,
    `name` VARCHAR(128) NULL,
    `grade` INT NOT NULL DEFAULT 0,
    `salary` INT NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`property_id`, `citizenid`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])

  run([[CREATE TABLE IF NOT EXISTS `yg_property_realtors` (
    `citizenid` VARCHAR(64) NOT NULL,
    `name` VARCHAR(128) NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`citizenid`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])

  run([[CREATE TABLE IF NOT EXISTS `yg_property_access_points` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `property_id` INT NOT NULL,
    `type` VARCHAR(32) NOT NULL,
    `coords` LONGTEXT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_property_id` (`property_id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])

  addColumn('yg_properties', 'rent_price', 'INT NOT NULL DEFAULT 0')
  addColumn('yg_properties', 'tenure', 'VARCHAR(16) NULL DEFAULT NULL')
  addColumn('yg_properties', 'rent_due', 'BIGINT NULL DEFAULT NULL')
  addColumn('yg_properties', 'tax_due', 'BIGINT NULL DEFAULT NULL')
  addColumn('yg_properties', 'realtor_citizenid', 'VARCHAR(64) NULL DEFAULT NULL')
  addColumn('yg_properties', 'realtor_name', 'VARCHAR(128) NULL DEFAULT NULL')
  addColumn('yg_properties', 'interior_id', 'VARCHAR(64) NULL DEFAULT NULL')
end)
