_G.Group = {
  groups = {},
  groupsReady = false
}

local function getFactionPermission(teamId)
  local team = CONFIG_TEAMS.TEAMS[teamId]
  return team and (team.PERMISSION or teamId) or teamId
end

function Group:GetGroups(groupName)
  if groupName then
    return self.groups[groupName]
  end

  return self.groups
end

function Group:IsGroupsReady()
  return self.groupsReady == true
end

function Group:GetGroupById(groupId)
  for _, GROUP in pairs(self.groups) do
    if GROUP.id == groupId then 
      return GROUP
    end
  end
end

function Group:GetGroupRoles(groupId)
  local group = self.groups[groupId]

  if not group then
    return nil
  end

  return group.roles
end

function Group:GetGroupMembers(groupId)
  local group = self.groups[groupId]

  if not group then
    return nil
  end

  return group.members
end

function Group:UpdateMemberRescue(groupId, playerId, rescueWave) 
  local group = self.groups[groupId]

  if not group then
    return
  end
  
  for INDEX, MEMBER in ipairs(group.members) do 
    if MEMBER.playerId == playerId then
      group.members[INDEX].rescueReward = 1
      group.members[INDEX].rescueWave = rescueWave
      exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `rescue_rewards` = ? WHERE `group` = ? AND `player_id` = ?', { 1, groupId, playerId })
      return
    end
  end
end

function Group:Setup(groups, membersByGroup, rolesByGroup)
  self.groupsReady = false
  local availableGroups = {}

  for _, OBJECT in ipairs(groups) do
    local consultMembers = membersByGroup and (membersByGroup[OBJECT.name] or {})
    if not membersByGroup then
      consultMembers = exports['oxmysql']:executeSync('SELECT `player_id` AS `playerId`, `role_id` AS `roleId`, `joined_at` AS `joinedAt`, `last_login` AS `lastLogin`, `rescue_wave` AS `rescueWave`, `rescue_rewards` AS `rescueReward` FROM `fta_groups_members` WHERE `group` = ?', { OBJECT.name })
    end

    local consultRoles = rolesByGroup and (rolesByGroup[OBJECT.name] or {})
    if not rolesByGroup then
      consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ?', { OBJECT.name })
    end

    availableGroups[OBJECT.name] = {
      id = OBJECT.id,
      team = OBJECT.team,
      factionPermission = getFactionPermission(OBJECT.team),
      name = OBJECT.name,
      ownerId = OBJECT.owner_id,
      balance = OBJECT.balance,
      membersLimit = OBJECT.members_limit,
      logoURL = OBJECT.logo_url or '',
      permissions = json.decode(OBJECT.permissions),
      members = consultMembers or {},
      roles = {}
    }

    for _, ROLE in ipairs(consultRoles) do
      if ROLE then
        availableGroups[OBJECT.name].roles[ROLE.id] = {
          id = ROLE.id,
          name = ROLE.name,
          permissions = json.decode(ROLE.permissions),
          icon = ROLE.icon,
          canDelete = ROLE.can_delete
        }
      end
    end
  end

  self.groups = availableGroups
  self.groupsReady = true
end

function Group:CreateGroup(teamId, groupName, ownerId, permissions, membersLimit)
  local groupInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups` (`team`, `name`, `owner_id`, `members_limit`, `permissions`, `logo_url`) VALUES (?, ?, ?, ?, ?, ?)', {
    teamId,
    groupName,
    ownerId,
    membersLimit,
    json.encode(permissions),
    CONFIG_TEAMS.TEAMS[teamId].DEFAULT_LOGO_URL
  })

  local groupId = groupInsert and groupInsert.insertId or 1

  local roleInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`, `can_delete`) VALUES (?, ?, ?, ?, ?)', {
    groupName,
    'Líder',
    json.encode({ INVITE = true, KICK = true, PROMOTE = true, WITHDRAW_BANK = true, CHEST = true, MATUTO = true, SETTINGS = true }),
    'LEADER',
    false
  })

  local roleId = roleInsert and roleInsert.insertId or 1

  local roleMemberInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`, `can_delete`) VALUES (?, ?, ?, ?, ?)', {
    groupName,
    'Membro',
    json.encode({ INVITE = false, KICK = false, PROMOTE = false, WITHDRAW_BANK = false, CHEST = false, MATUTO = false, SETTINGS = false }),
    'MEMBER',
    false
  })

  local roleMemberId = roleMemberInsert and roleMemberInsert.insertId or 1

  local timestamp = os.time()
  
  exports['oxmysql']:executeSync('INSERT INTO `fta_groups_members` (`group`, `player_id`, `role_id`, `joined_at`, `last_login`) VALUES (?, ?, ?, ?, ?)', {
    groupName,
    ownerId,
    roleId,
    timestamp,
    timestamp
  })

  self.groups[groupName] = {
    id = groupId,
    team = teamId,
    factionPermission = getFactionPermission(teamId),
    name = groupName,
    ownerId = ownerId,
    balance = 0,
    membersLimit = membersLimit,
    logoURL = CONFIG_TEAMS.TEAMS[teamId].DEFAULT_LOGO_URL,
    permissions = permissions,
    members = {
      { playerId = ownerId, roleId = roleId, joinedAt = os.time(), lastTime = timestamp }
    },
    roles = {
      [roleId] = { id = roleId, name = 'Líder', icon = 'LEADER', permissions = { INVITE = true, KICK = true, PROMOTE = true, WITHDRAW_BANK = true, CHEST = true, MATUTO = true, SETTINGS = true }, canDelete = false },
      [roleMemberId] = { id = roleMemberId, name = 'Membro', icon = 'MEMBER', permissions = { INVITE = false, KICK = false, PROMOTE = false, WITHDRAW_BANK = false, CHEST = false, MATUTO = false, SETTINGS = false }, canDelete = false },
    }
  }

  Roles:Refresh(groupId, groupName)
  Player:SetPermissions(ownerId, permissions)
end

function Group:UpdateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
  local teamData = CONFIG_TEAMS.TEAMS[teamId]

  if not teamData then
    return false
  end

  local group = self.groups[groupId]

  if not group then
    return false
  end

  local newGroup = {
    id = group.id,
    team = teamId,
    factionPermission = getFactionPermission(teamId),
    name = groupName,
    ownerId = ownerId,
    balance = group.balance,
    membersLimit = membersLimit,
    logoURL = teamData.DEFAULT_LOGO_URL,
    permissions = permissions,
    members = group.members,
    roles = group.roles
  }

  exports['oxmysql']:executeSync([[
    UPDATE `fta_groups`
    SET `team` = ?, `name` = ?, `owner_id` = ?, `members_limit` = ?, `logo_url` = ?, `permissions` = ?
    WHERE `id` = ?
  ]], { teamId, groupName, ownerId, membersLimit, teamData.DEFAULT_LOGO_URL, json.encode(permissions), group.id })

  if group.ownerId ~= ownerId then
    for INDEX, MEMBER in ipairs(newGroup.members) do
      if MEMBER.playerId == ownerId then
        exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `player_id` = ?', { group.ownerId })
        exports['oxmysql']:executeSync('INSERT INTO `fta_groups_members` (`group`, `player_id`, `joined_at`, `last_login`) VALUES (?, ?, ?, ?)', { groupName, ownerId, os.time(), os.time() })

        table.insert(newGroup.members, { playerId = ownerId, roleId = MEMBER.roleId, joinedAt = os.time(), lastLogin = os.time() })
        table.remove(newGroup.members, INDEX)
        break
      end
    end
  end

  local oldPermissions = group.permissions

  CreateThread(function()
    for _, MEMBER in ipairs(newGroup.members) do
      Player:RemovePermissions(MEMBER.playerId, oldPermissions)
      Player:SetPermissions(MEMBER.playerId, permissions)
    end
  end)

  self.groups[groupId] = newGroup

  return true
end

function Group:DeleteGroup(groupId)
  if FtaBaquesTeamsContract then
    local canDelete, reason = FtaBaquesTeamsContract:CanDeleteOrganization(groupId)
    if not canDelete then
      return false, reason
    end
  end

  for _, GROUP in pairs(self.groups) do
    if GROUP.id == groupId then
      local consultMembers = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_members` WHERE `group` = ?', { GROUP.name })

      if consultMembers then 
        for _, MEMBER in ipairs(consultMembers) do
          local memberId = MEMBER.player_id
          Player:RemovePermissions(memberId, GROUP.permissions)
        end

        exports['oxmysql']:executeSync('DELETE FROM `fta_groups` WHERE `id` = ?', { GROUP.id })

        self.groups[GROUP.name] = nil

        if FtaBaquesTeamsContract
          and type(FtaBaquesTeamsContract.NotifyOrganizationDeleted) == 'function'
        then
          local notified, notifyReason = FtaBaquesTeamsContract:NotifyOrganizationDeleted(
            GROUP.id,
            GROUP.ownerId
          )
          if not notified then
            print(('[fta-teams] Organizacao %s excluida; reconciliacao territorial pendente: %s'):format(
              tostring(GROUP.id),
              tostring(notifyReason)
            ))
          end
        end

        return true
      end

      break
    end
  end
end

function Group:CreateRole(groupId, name, icon, permissions)
  local group = self.groups[groupId]

  if not group then
    return false
  end

  local roleInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`) VALUES (?, ?, ?, ?)', {
    group.name,
    name,
    json.encode(permissions),
    icon
  })

  local roleId = roleInsert and roleInsert.insertId or 1

  group.roles[roleId] = {
    id = roleId,
    name = name,
    permissions = permissions,
    icon = icon,
    canDelete = true
  }

  Roles:Refresh(group.id, group.name)

  return true
end

function Group:DeleteRole(groupId, roleId)
  local group = self.groups[groupId]

  if not group then
    return false
  end

  local roleData = group.roles[roleId]

  if not roleData or not roleData.canDelete then
    return false
  end

  local consultRole = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ? AND `icon` = "MEMBER"', { groupId })[1]
  
  if not consultRole then
    return false
  end

  exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `role_id` = ? WHERE `role_id` = ? AND `group` = ?', { consultRole.id, roleId, groupId })
  exports['oxmysql']:executeSync('DELETE FROM `fta_groups_roles` WHERE `id` = ?', { roleId })

  group.roles[roleId] = nil

  Roles:Refresh(group.id, group.name)

  return true
end

function Group:EditRole(groupId, roleId, name, icon, permissions)
  local group = self.groups[groupId]

  if not group then
    return false
  end

  local roleData = group.roles[roleId]

  if not roleData or not roleData.canDelete then
    return false
  end

  exports['oxmysql']:executeSync('UPDATE `fta_groups_roles` SET `name` = ?, `permissions` = ?, `icon` = ? WHERE `id` = ? AND `group` = ?', {
    name,
    json.encode(permissions),
    icon,
    roleId,
    groupId
  })

  group.roles[roleId] = {
    id = roleId,
    name = name,
    icon = icon,
    permissions = permissions,
    canDelete = true
  }

  return true
end

function Group:UpdateMemberRole(playerId, groupId, memberId, roleId)
  local group = self.groups[groupId]

  if not group then
    return false
  end

  local playerRole = Player:GetPlayerRole(groupId, playerId)

  memberId = tonumber(memberId)
  roleId = tonumber(roleId)

  if playerId == memberId then 
    return false
  end

  if not playerRole or not playerRole.permissions.PROMOTE then
    return false
  end

  for INDEX, MEMBER in ipairs(group.members) do 
    if MEMBER.playerId == memberId then 
      group.members[INDEX] = {
        playerId = MEMBER.playerId,
        roleId = roleId,
        joinedAt = MEMBER.joinedAt
      }

      exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `role_id` = ? WHERE `group` = ? AND `player_id` = ?', {
        roleId,
        groupId,
        memberId
      })

      return true
    end
  end

  return false
end

function Group:KickMember(playerId, groupId, memberId)
  local group = self.groups[groupId]

  if not group then
    return
  end

  local playerRole = Player:GetPlayerRole(groupId, playerId)

  memberId = tonumber(memberId)

  if group.ownerId == memberId then 
    return
  end

  if not playerRole or not playerRole.permissions.KICK then
    return
  end

  for INDEX, MEMBER in ipairs(group.members) do 
    if MEMBER.playerId == memberId then 
      table.remove(group.members, INDEX)
      Player:RemovePermissions(memberId, group.permissions)
      exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `group` = ? AND `player_id` = ?', { group.name, memberId })
      break
    end
  end
end

function Group:LeaveMember(groupId, memberId)
  local group = self.groups[groupId]

  if not group then
    return
  end

  memberId = tonumber(memberId)

  if group.ownerId == memberId then 
    return
  end

  for INDEX, MEMBER in ipairs(group.members) do 
    if MEMBER.playerId == memberId then 
      table.remove(group.members, INDEX)
      Player:RemovePermissions(memberId, group.permissions)
      exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `group` = ? AND `player_id` = ?', { group.name, memberId })
      break
    end
  end
end

function Group:ForceKickMember(groupId, memberId)
  local group = self.groups[groupId]

  if not group then
    return
  end

  memberId = tonumber(memberId)

  for INDEX, MEMBER in ipairs(group.members) do 
    if MEMBER.playerId == memberId then
      table.remove(group.members, INDEX)
      Player:RemovePermissions(memberId, group.permissions)
      exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `group` = ? AND `player_id` = ?', { group.name, memberId })
      break
    end
  end
end

function Group:UpdateLastTime(playerId)
  local consultMember = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_members` WHERE `player_id` = ?', { playerId })[1]

  if not consultMember then
    return
  end

  local timestamp = os.time()
  local lastTime = consultMember.last_login + 604800

  if lastTime < timestamp then
    local group = self.groups[consultMember.group]
    
    if group and #group.members > 1 then
      Group:ForceKickMember(consultMember.group, playerId)
    end
  else
    exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `last_login` = ? WHERE `player_id` = ?', { os.time(), playerId })
  end
end

function Group:TryInviteMember(playerId, groupId, memberId)  
  local group = self.groups[groupId]

  if not group then
    return false
  end

  if group.membersLimit then
    if #group.members >= group.membersLimit then 
      return false
    end
  end

  local playerRole = Player:GetPlayerRole(groupId, playerId)

  memberId = tonumber(memberId)
  
  if playerId == memberId then
    return false
  end

  local playerData = Group:GetPlayerGroupById(memberId)

  if playerData then 
    return false
  end

  if not playerRole or not playerRole.permissions.INVITE then
    return false
  end

  local memberSource = vRP.Source(memberId)
  
  if not memberSource then
    return false
  end

  local message = '%s está te convidando para participar do grupo'
  
  local request = vRP.Request(memberSource, message:format(group.name))

  if not request then
    return false
  end

  local consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ? AND `icon` = "MEMBER" AND `can_delete` = 0 ORDER BY `id` DESC LIMIT 1', { groupId })[1]

  if not consultRoles then
    return false
  end

  local roleId = consultRoles.id
  local timestamp = os.time()

  table.insert(group.members, {
    playerId = memberId,
    roleId = roleId,
    joinedAt = timestamp,
    lastLogin = timestamp
  })

  exports['oxmysql']:executeSync('INSERT INTO `fta_groups_members` (`group`, `player_id`, `role_id`, `joined_at`, `last_login`) VALUES (?, ?, ?, ?, ?)', {
    group.name,
    memberId,
    roleId,
    timestamp,
    timestamp
  })

  Player:SetPermissions(memberId, group.permissions)
  
  return true
end

function Group:GetLatestTransactions(groupId)
  local group = self.groups[groupId]

  if not group then
    return {}
  end

  local availableTransactions = {}
  local consultTransactions = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_transactions` WHERE `group` = ? ORDER BY `id` DESC LIMIT 10', { groupId })

  for _, TRANSACTION in ipairs(consultTransactions) do 
    table.insert(availableTransactions, {
      id = TRANSACTION.player_id,
      name = TRANSACTION.player_name,
      amount = TRANSACTION.amount,
      role = group.roles[TRANSACTION.role_id],
      action = TRANSACTION.action,
      date = TRANSACTION.timestamp
    })
  end

  return availableTransactions
end

function Group:BankWithdraw(playerId, groupId, amount)
  local group = self.groups[groupId]

  if not group then
    return false
  end

  if group.balance < amount then 
    return false
  end

  local playerName = Player:GetName(playerId)
  local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)
  
  if not playerRole or not playerRole.permissions.WITHDRAW_BANK then
    return false
  end

  vRP.GiveBank(playerId, amount)
  group.balance = group.balance - amount

  exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `balance` = `balance` - ? WHERE `name` = ?', { amount, groupId })
  exports['oxmysql']:executeSync('INSERT INTO `fta_groups_transactions` (`group`, `player_id`, `player_name`, `amount`, `role_id`, `action`, `timestamp`) VALUES (?, ?, ?, ?, ?, ?, ?)', {
    groupId,
    playerId,
    playerName,
    amount,
    roleId,
    'WITHDRAW',
    os.time()
  })

  return true
end

function Group:BankDeposit(playerId, groupId, amount)
  local group = self.groups[groupId]

  if not group then
    return false
  end

  local playerName = Player:GetName(playerId)
  local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)

  if not vRP.PaymentBank(playerId, amount) then
    return false
  end

  group.balance = group.balance + amount

  exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `balance` = `balance` + ? WHERE `name` = ?', { amount, groupId })
  exports['oxmysql']:executeSync('INSERT INTO `fta_groups_transactions` (`group`, `player_id`, `player_name`, `amount`, `role_id`, `action`, `timestamp`) VALUES (?, ?, ?, ?, ?, ?, ?)', {
    groupId,
    playerId,
    playerName,
    amount,
    roleId,
    'DEPOSIT',
    os.time()
  })

  return true
end

function Group:IsPlayerInGroup(playerId)
  local consultPlayer = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_members` WHERE `player_id` = ?', { playerId })[1]

  if not consultPlayer then
    return false
  end

  local group = self.groups[consultPlayer.group]

  if not group then
    return false
  end

  return consultPlayer.group, group.ownerId == playerId
end

function Group:UpdateLogo(groupId, logoURL)
  local group = self.groups[groupId]

  if not group then
    return
  end

  group.logoURL = logoURL
  exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `logo_url` = ? WHERE `name` = ?', { logoURL, groupId })
end

function Group:GetMembersFromRole(groupId, roleId)
  local group = self.groups[groupId]

  if not group then
    return 0
  end

  local members = {}

  for _, MEMBER in ipairs(group.members) do 
    if MEMBER.roleId == roleId then 
      table.insert(members, MEMBER)
    end
  end

  return #members
end

function Group:GetPlayerGroupById(playerId)
  for _, GROUP in pairs(self.groups) do
    for _, MEMBER in ipairs(GROUP.members) do 
      if MEMBER.playerId == playerId then 
        return GROUP
      end
    end
  end

  return false
end

local READY_SCHEMA = 'fta.session-ready/v2'
local AUTH_WAIT_LIMIT = 30
local updatedSessions = {}

local function isPositiveInteger(value)
  return type(value) == 'number' and value > 0 and value % 1 == 0
end

local function isCurrentSession(Passport, playerSource)
  if not isPositiveInteger(Passport) or not isPositiveInteger(playerSource) then
    return false
  end

  return vRP.Passport(playerSource) == Passport
    and vRP.Source(Passport) == playerSource
end

local function updateSessionLastLogin(Passport, playerSource, finalizationId)
  local waited = 0
  while not __isAuth__ and waited < AUTH_WAIT_LIMIT do
    Citizen.Wait(1000)
    waited = waited + 1
  end

  if not __isAuth__ or not isCurrentSession(Passport, playerSource) then
    return
  end

  if finalizationId and updatedSessions[playerSource] == finalizationId then
    return
  end

  Group:UpdateLastTime(Passport)
  if finalizationId then
    updatedSessions[playerSource] = finalizationId
  end
end

-- Current bootstrap compatibility. Connect is intentionally server-local.
AddEventHandler('Connect', function(Passport, playerSource)
  updateSessionLastLogin(Passport, playerSource)
end)

-- Canonical post-finalization signal emitted locally by fta-appearence.
AddEventHandler('fta:sessionReady:v2', function(context)
  if type(context) ~= 'table'
    or context.schema ~= READY_SCHEMA
    or type(context.finalizationId) ~= 'string'
    or not context.finalizationId:match('^sfn%-%x+$')
    or not isPositiveInteger(context.effectsVersion)
  then
    return
  end

  updateSessionLastLogin(context.passport, context.source, context.finalizationId)
end)

AddEventHandler('playerDropped', function()
  updatedSessions[source] = nil
end)

CreateThread(function()
  Wait(1500)

  while not __isAuth__ do
    Citizen.Wait(1000)
  end

  while not _G.FTA_TEAMS_DB_READY do
    Citizen.Wait(100)
  end

  local consultGroups = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups`')
  local consultMembers = exports['oxmysql']:executeSync('SELECT `group`, `player_id` AS `playerId`, `role_id` AS `roleId`, `joined_at` AS `joinedAt`, `last_login` AS `lastLogin`, `rescue_wave` AS `rescueWave`, `rescue_rewards` AS `rescueReward` FROM `fta_groups_members`') or {}
  local consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` ORDER BY `group`, `id` ASC') or {}
  local consultChests = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_chests` ORDER BY `group`, `id` ASC') or {}

  local function groupRows(rows)
    local grouped = {}
    for _, row in ipairs(rows) do
      local groupName = row.group
      if groupName then
        grouped[groupName] = grouped[groupName] or {}
        table.insert(grouped[groupName], row)
      end
    end
    return grouped
  end

  local membersByGroup = groupRows(consultMembers)
  local rolesByGroup = groupRows(consultRoles)
  local chestsByGroup = groupRows(consultChests)

  Roles:Setup(consultGroups, rolesByGroup)
  Chests:Setup(consultGroups, chestsByGroup)

  Wait(500)
  
  Group:Setup(consultGroups, membersByGroup, rolesByGroup)
end)
