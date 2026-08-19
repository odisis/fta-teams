vRP = Proxy.getInterface('vRP')

api = {}
Tunnel.bindInterface(GetCurrentResourceName(), api)

apiClient = Tunnel.getInterface(GetCurrentResourceName())

_G.SHARED_CONFIG = require('config/shared/general')
_G.CONFIG_TEAMS = require('config/shared/teams')
_G.FTA_TEAMS_DB_READY = false

if not LPH_OBFUSCATED then
  __isAuth__ = true

  LPH_NO_VIRTUALIZE = function(...) 
    return ... 
  end
end

CreateThread(function ()
  Wait(250)

  while not __isAuth__ do
    Citizen.Wait(1000)
  end

  exports['oxmysql']:executeSync([[
    CREATE TABLE IF NOT EXISTS `fta_groups_schema_migrations` (
      `version` INT UNSIGNED NOT NULL,
      `name` VARCHAR(120) NOT NULL,
      `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (`version`)
    ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
  ]])

  local appliedMigration = exports['oxmysql']:executeSync(
    'SELECT `version` FROM `fta_groups_schema_migrations` WHERE `version` = 1 LIMIT 1'
  )
  if appliedMigration and appliedMigration[1] then
    _G.FTA_TEAMS_DB_READY = true
    return
  end

  exports['oxmysql']:executeSync([[
    CREATE TABLE IF NOT EXISTS `fta_groups` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `team` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
      `name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
      `owner_id` INT(11) NOT NULL DEFAULT '0',
      `members_limit` INT(11) NULL DEFAULT '25',
      `balance` INT(11) NULL DEFAULT '0',
      `permissions` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
      `roles_hierarchy` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
      `logo_url` VARCHAR(255) NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
      PRIMARY KEY (`id`) USING BTREE,
      INDEX `name` (`name`) USING BTREE
    ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB AUTO_INCREMENT=0;
  ]])
  
  exports['oxmysql']:executeSync([[
    CREATE TABLE IF NOT EXISTS `fta_groups_members` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `group` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
      `player_id` INT(11) NULL DEFAULT NULL,
      `role_id` INT(11) NULL DEFAULT NULL,
      `joined_at` INT(11) NULL DEFAULT '0',
      `last_login` INT(11) NULL DEFAULT '0',
      `rescue_wave` INT(11) NOT NULL DEFAULT '0',
      `rescue_rewards` TINYINT(1) NULL DEFAULT '0',
      PRIMARY KEY (`id`) USING BTREE,
      INDEX `FK_fta_groups_members_fta_groups` (`group`) USING BTREE,
      CONSTRAINT `FK_fta_groups_members_fta_groups` FOREIGN KEY (`group`) REFERENCES `fta_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
    ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB AUTO_INCREMENT=0;
  ]])
  
  exports['oxmysql']:executeSync([[
    CREATE TABLE IF NOT EXISTS `fta_groups_ranking` (
      `id` INT(11) NOT NULL,
      `rewards` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
      PRIMARY KEY (`id`) USING BTREE
    ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
  ]])
  
  exports['oxmysql']:executeSync([[
    CREATE TABLE IF NOT EXISTS `fta_groups_roles` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `group` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
      `name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
      `permissions` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
      `icon` VARCHAR(50) NULL DEFAULT 'LEADER' COLLATE 'utf8mb4_general_ci',
      `can_delete` TINYINT(1) NULL DEFAULT '1',
      PRIMARY KEY (`id`) USING BTREE,
      INDEX `FK_fta_groups_roles_fta_groups` (`group`) USING BTREE,
      CONSTRAINT `FK_fta_groups_roles_fta_groups` FOREIGN KEY (`group`) REFERENCES `fta_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
    ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB AUTO_INCREMENT=0;
  ]])
  
  exports['oxmysql']:executeSync([[
    CREATE TABLE IF NOT EXISTS `fta_groups_transactions` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `group` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
      `player_id` INT(11) NOT NULL DEFAULT '0',
      `player_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
      `amount` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8mb4_general_ci',
      `role_id` INT(11) NOT NULL DEFAULT '0',
      `action` ENUM('DEPOSIT','WITHDRAW') NOT NULL DEFAULT 'DEPOSIT' COLLATE 'utf8mb4_general_ci',
      `timestamp` INT(11) NOT NULL DEFAULT '0',
      PRIMARY KEY (`id`) USING BTREE,
      INDEX `FK_fta_groups_transactions_fta_groups` (`group`) USING BTREE,
      CONSTRAINT `FK_fta_groups_transactions_fta_groups` FOREIGN KEY (`group`) REFERENCES `fta_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
    ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB AUTO_INCREMENT=0;
  ]])
  
  exports['oxmysql']:executeSync([[
    CREATE TABLE IF NOT EXISTS `fta_groups_chests` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `group` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
      `player_id` INT(11) NULL DEFAULT NULL,
      `role_id` INT(11) NULL DEFAULT NULL,
      `action` ENUM('STORE','TAKE') NULL DEFAULT 'STORE' COLLATE 'latin1_swedish_ci',
      `payload` LONGTEXT NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
      `timestamp` INT(11) NULL DEFAULT '0',
      PRIMARY KEY (`id`) USING BTREE, -- Added missing comma here
      INDEX `FK_fta_groups_chests_fta_groups` (`group`) USING BTREE,
      CONSTRAINT `FK_fta_groups_chests_fta_groups` FOREIGN KEY (`group`) REFERENCES `fta_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
    ) COLLATE='latin1_swedish_ci' ENGINE=InnoDB;
  ]])

  local playerIdIndex = exports['oxmysql']:executeSync([[
    SELECT 1
    FROM `INFORMATION_SCHEMA`.`STATISTICS`
    WHERE `TABLE_SCHEMA` = DATABASE()
      AND `TABLE_NAME` = 'fta_groups_members'
      AND `INDEX_NAME` = 'idx_fta_groups_members_player'
    LIMIT 1
  ]])
  if not playerIdIndex or not playerIdIndex[1] then
    exports['oxmysql']:executeSync([[
      ALTER TABLE `fta_groups_members`
      ADD INDEX `idx_fta_groups_members_player` (`player_id`)
    ]])
  end

  exports['oxmysql']:executeSync([[
    INSERT INTO `fta_groups_schema_migrations` (`version`, `name`)
    VALUES (1, 'initial_schema_and_player_lookup_index')
  ]])
  _G.FTA_TEAMS_DB_READY = true
end)
