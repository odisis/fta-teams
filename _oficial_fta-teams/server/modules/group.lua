_G.Group = {
  groups = {}
}

function Group:GetGroups(groupId)
  if groupId then
    return self.groups[groupId]
  end

  return self.groups
end

function Group:GetGroupRoles(groupId)
  return self.groups[groupId].roles
end

function Group:GetGroupMembers(groupId)
  return self.groups[groupId].members
end

function Group:UpdateMemberRescue(groupId, playerId, rescueWave) 
  local groupData = self.groups[groupId]
  
  for INDEX, MEMBER in ipairs(groupData.members) do 
    if MEMBER.playerId == playerId then
      self.groups[groupId].members[INDEX].rescueReward = 1
      self.groups[groupId].members[INDEX].rescueWave = rescueWave
      exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `rescue_rewards` = ? WHERE `group` = ? AND `player_id` = ?', { 1, groupId, playerId })
      return
    end
  end
end

function Group:Setup(groups)
  local availableGroups = {}

  for _, OBJECT in ipairs(groups) do
    local consultMembers = exports['oxmysql']:executeSync('SELECT `player_id` AS `playerId`, `role_id` AS `roleId`, `joined_at` AS `joinedAt`, `last_login` AS `lastLogin`, `rescue_wave` AS `rescueWave`, `rescue_rewards` AS `rescueReward` FROM `fta_groups_members` WHERE `group` = ?', { OBJECT.name })
    local consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ?', { OBJECT.name })

    availableGroups[OBJECT.name] = {
      id = OBJECT.id,
      team = OBJECT.team,
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
    json.encode({ INVITE = true, KICK = true, PROMOTE = true, WITHDRAW_BANK = true }),
    'LEADER',
    false
  })

  local roleId = roleInsert and roleInsert.insertId or 1

  local roleMemberInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`, `can_delete`) VALUES (?, ?, ?, ?, ?)', {
    groupName,
    'Membro',
    json.encode({ INVITE = false, KICK = false, PROMOTE = false, WITHDRAW_BANK = false }),
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
      [roleId] = { id = roleId, name = 'Líder', icon = 'LEADER', permissions = { INVITE = true, KICK = true, PROMOTE = true, WITHDRAW_BANK = true }, canDelete = false },
      [roleMemberId] = { id = roleId, name = 'Membro', icon = 'MEMBER', permissions = { INVITE = false, KICK = false, PROMOTE = false, WITHDRAW_BANK = false }, canDelete = false },
    }
  }

  Player:SetPermissions(ownerId, permissions)
end

function Group:UpdateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
  local teamData = CONFIG_TEAMS.TEAMS[teamId]

  if teamData then 
    local groupData = self.groups[groupId]
  
    local newGroup = {
      id = groupData.id,
      team = teamId,
      name = groupName,
      ownerId = ownerId,
      balance = groupData.balance,
      membersLimit = membersLimit,
      logoURL = teamData.DEFAULT_LOGO_URL,
      permissions = permissions,
      members = groupData.members,
      roles = groupData.roles
    }
  
    exports['oxmysql']:executeSync([[
      UPDATE `fta_groups`
      SET `team` = ?, `name` = ?, `owner_id` = ?, `members_limit` = ?, `logo_url` = ?, `permissions` = ?
      WHERE `id` = ?
    ]], { teamId, groupName, ownerId, membersLimit, teamData.DEFAULT_LOGO_URL, json.encode(permissions), groupData.id })
  
    if groupData.ownerId ~= ownerId then
      for INDEX, MEMBER in ipairs(newGroup.members) do
        if MEMBER.playerId == ownerId then
          exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `player_id` = ?', { groupData.ownerId })
          exports['oxmysql']:executeSync('INSERT INTO `fta_groups_members` (`group`, `player_id`, `joined_at`, `last_login`) VALUES (?, ?, ?, ?)', { groupName, ownerId, os.time(), os.time() })
  
          table.insert(newGroup.members, { playerId = ownerId, roleId = MEMBER.roleId, joinedAt = os.time(), lastLogin = os.time() })
          table.remove(newGroup.members, INDEX)
          break
        end
      end
    end

    CreateThread(function()
      for INDEX, MEMBER in ipairs(groupData.members) do
        Player:RemovePermissions(MEMBER.playerId, groupData.permissions)
        Player:SetPermissions(MEMBER.playerId, permissions)
      end
    end)
  
    self.groups[groupId] = newGroup
  
    return true
  end

  return false
end

function Group:DeleteGroup(groupId)
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

        return true
      end

      break
    end
  end
end

function Group:CreateRole(groupId, name, icon, permissions)
  local groupData = self.groups[groupId]

  local roleInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`) VALUES (?, ?, ?, ?)', {
    groupData.name,
    name,
    json.encode(permissions),
    icon
  })

  local roleId = roleInsert and roleInsert.insertId or 1

  self.groups[groupData.name].roles[roleId] = {
    id = roleId,
    name = name,
    permissions = permissions,
    icon = icon,
    canDelete = true
  }

  return true
end

function Group:DeleteRole(groupId, roleId)
  local groupData = self.groups[groupId]
  local roleData = groupData.roles[roleId]

  if roleData.canDelete then
    local consultRole = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ? AND `icon` = "MEMBER"', { groupId })[1]
    
    if consultRole then 
      local consultRole = exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `role_id` = ? WHERE `role_id` = ? AND `group` = ?', { consultRole.id, roleId, groupId })
      exports['oxmysql']:executeSync('DELETE FROM `fta_groups_roles` WHERE `id` = ?', { roleId })

      self.groups[groupId].roles[roleId] = nil

      return true
    end
  end

  return false
end

function Group:EditRole(groupId, roleId, name, icon, permissions)
  local groupData = self.groups[groupId]
  local roleData = groupData.roles[roleId]
  
  if roleData.canDelete then
    exports['oxmysql']:executeSync('UPDATE `fta_groups_roles` SET `name` = ?, `permissions` = ?, `icon` = ? WHERE `id` = ? AND `group` = ?', {
      name,
      json.encode(permissions),
      icon,
      roleId,
      groupId
    })

    self.groups[groupId].roles[roleId] = {
      id = roleId,
      name = name,
      icon = icon,
      permissions = permissions,
      canDelete = true
    }

    return true
  end

  return false
end

function Group:UpdateMemberRole(playerId, groupId, memberId, roleId)
  local groupData = self.groups[groupId]
  local playerRole = Player:GetPlayerRole(groupId, playerId)

  memberId = tonumber(memberId)
  roleId = tonumber(roleId)

  if playerId == memberId then 
    return false
  end

  if playerRole then
    if playerRole.permissions.PROMOTE then
      for INDEX, MEMBER in ipairs(groupData.members) do 
        if MEMBER.playerId == memberId then 
          self.groups[groupId].members[INDEX] = {
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
    end
  end

  return false
end

function Group:KickMember(playerId, groupId, memberId)
  local groupData = self.groups[groupId]
  local playerRole = Player:GetPlayerRole(groupId, playerId)

  memberId = tonumber(memberId)

  if playerRole then
    if playerRole.permissions.KICK then 
      for INDEX, MEMBER in ipairs(groupData.members) do 
        if MEMBER.playerId == memberId then 
          table.remove(self.groups[groupId].members, INDEX)
          Player:RemovePermissions(memberId, groupData.permissions)
          exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `group` = ? AND `player_id` = ?', { groupData.name, memberId })
          break
        end
      end
    end
  end
end

function Group:ForceKickMember(groupId, memberId)
  local groupData = self.groups[groupId]

  memberId = tonumber(memberId)

  for INDEX, MEMBER in ipairs(groupData.members) do 
    if MEMBER.playerId == memberId then
      table.remove(self.groups[groupId].members, INDEX)
      Player:RemovePermissions(memberId, groupData.permissions)
      exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `group` = ? AND `player_id` = ?', { groupData.name, memberId })
      break
    end
  end
end

function Group:UpdateLastTime(playerId)
  local consultMember = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_members` WHERE `player_id` = ?', { playerId })[1]

  if consultMember then 
    local timestamp = os.time()
    local lastTime = consultMember.last_login + 604800

    if lastTime < timestamp then
      local groupData = self.groups[consultMember.group]
      
      if #groupData.members > 1 then
        Group:ForceKickMember(consultMember.group, playerId)
      end
    else
      exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `last_login` = ? WHERE `player_id` = ?', { os.time(), playerId })
    end
  end
end

function Group:TryInviteMember(playerId, groupId, memberId)  
  local groupData = self.groups[groupId]

  if #groupData.members >= groupData.membersLimit then 
    return false
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

  if playerRole then
    if playerRole.permissions.INVITE then
      local memberSource = vRP.Source(memberId)
      local message = '%s está te convidando para participar do grupo'
      
      local request = vRP.Request(memberSource, message:format(groupData.name))

      if request then
        local consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ? AND `icon` = "MEMBER" AND `can_delete` = 0 ORDER BY `id` DESC LIMIT 1', { groupId })[1]

        if consultRoles then
          local roleId = consultRoles.id
          local timestamp = os.time()

          table.insert(self.groups[groupId].members, {
            playerId = memberId,
            roleId = roleId,
            joinedAt = timestamp,
            lastLogin = timestamp
          })

          exports['oxmysql']:executeSync('INSERT INTO `fta_groups_members` (`group`, `player_id`, `role_id`, `joined_at`, `last_login`) VALUES (?, ?, ?, ?, ?)', {
            groupData.name,
            memberId,
            roleId,
            timestamp,
            timestamp
          })

          Player:SetPermissions(memberId, groupData.permissions)
          
          return true
        end
      end
    end
  end

  return false
end

function Group:GetLatestTransactions(groupId)
  local availableTransactions = {}
  local consultTransactions = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_transactions` WHERE `group` = ? ORDER BY `id` DESC LIMIT 10', { groupId })

  local groupData = self.groups[groupId]

  for _, TRANSACTION in ipairs(consultTransactions) do 
    table.insert(availableTransactions, {
      id = TRANSACTION.player_id,
      name = TRANSACTION.player_name,
      amount = TRANSACTION.amount,
      role = groupData.roles[TRANSACTION.role_id],
      action = TRANSACTION.action,
      date = TRANSACTION.timestamp
    })
  end

  return availableTransactions
end

function Group:BankWithdraw(playerId, groupId, amount)
  local groupData = self.groups[groupId]

  if groupData.balance < amount then 
    return false
  end

  local playerName = Player:GetName(playerId)

  local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)
  
  if playerRole then
    local rolePermissions = playerRole.permissions
  
    if rolePermissions.WITHDRAW_BANK then
      vRP.GiveBank(playerId, amount)
      self.groups[groupId].balance = self.groups[groupId].balance - amount
  
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
  end

  return false
end

function Group:BankDeposit(playerId, groupId, amount)
  local groupData = self.groups[groupId]

  local playerName = Player:GetName(playerId)
  local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)

  if vRP.PaymentBank(playerId, amount) then 
    self.groups[groupId].balance = self.groups[groupId].balance + amount
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

  return false
end

function Group:IsPlayerInGroup(playerId)
  local consultPlayer = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_members` WHERE `player_id` = ?', { playerId })[1]

  if consultPlayer then 
    local groupData = self.groups[consultPlayer.group]

    return consultPlayer.group, groupData.ownerId == playerId
  end

  return false
end

function Group:UpdateLogo(groupId, logoURL)
  self.groups[groupId].logoURL = logoURL
  exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `logo_url` = ? WHERE `name` = ?', { logoURL, groupId })
end

function Group:GetMembersFromRole(groupId, roleId)
  local groupData = self.groups[groupId]
  local members = {}

  for _, MEMBER in ipairs(groupData.members) do 
    if MEMBER.roleId == roleId then 
      table.insert(members, MEMBER)
    end
  end

  return #members
end

function Group:GetPlayerGroupById(playerId)
  for _, GROUP in ipairs(self.groups) do
    for _, MEMBER in ipairs(GROUP.members) do 
      if MEMBER.playerId == playerId then 
        return GROUP
      end
    end
  end

  return false
end

AddEventHandler('Connect', function(Passport, source, bool)
  Group:UpdateLastTime(Passport)
end)

CreateThread(function()
  Wait(1000)

  local consultGroups = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups`')

  Group:Setup(consultGroups)
end)