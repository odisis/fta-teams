local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')
vRP = Proxy.getInterface('vRP')

api = {}
Tunnel.bindInterface(GetCurrentResourceName(), api)

apiClient = Tunnel.getInterface(GetCurrentResourceName())

CreateThread(function ()
  Wait(250)

  exports['oxmysql']:executeSync([[
    CREATE TABLE IF NOT EXISTS `fta_groups` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `team` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
      `name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
      `owner_id` INT(11) NOT NULL DEFAULT '0',
      `members_limit` INT(11) NULL DEFAULT '25',
      `balance` INT(11) NULL DEFAULT '0',
      `permissions` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
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
end)