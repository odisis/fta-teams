function api.getGroupMembers(groupId)
  local playerSource = source 
  local playerId = vRP.Passport(playerSource)

  local groupData = Group:GetGroups(groupId)
  local groupMembers = Group:GetGroupMembers(groupId)
  local groupRoles = Group:GetGroupRoles(groupId)
  local members = {}

  for _, MEMBER in ipairs(groupMembers) do 
    local formatMember = Player:MemberFormat(groupId, MEMBER.playerId, MEMBER.roleId)

    formatMember.role = groupRoles[MEMBER.roleId]
    formatMember.isLeader = MEMBER.playerId == groupData.ownerId
    formatMember.isMe = playerId == MEMBER.playerId

    table.insert(members, formatMember)
  end
  
  return members
end

function api.getPlayerRolePermissions(groupId)
  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)

  return playerRole.permissions, roleId
end

function api.getGroups(groupId)
  if groupId then
    return Group.groups[groupId]
  end

  return Group.groups
end

function api.isPlayerInGroup()
  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  local groupId = Group:IsPlayerInGroup(playerId)

  if groupId then
    return groupId
  end

  return false
end

function api.updateMemberRole(groupId, memberId, roleId)
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  local status = Group:UpdateMemberRole(playerId, groupId, memberId, roleId)

  return status
end

function api.kickMember(groupId, memberId)
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  Group:KickMember(playerId, groupId, memberId)

  return true
end

function api.tryInviteMember(groupId, memberId)
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  local status = Group:TryInviteMember(playerId, groupId, memberId)

  return status
end

function api.getGroupBank(groupId)
  local transactions = Group:GetLatestTransactions(groupId)
  local balance = Group.groups[groupId].balance or 0
  
  return balance, transactions
end

function api.withdrawFromBank(groupId, amount)
  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  
  local status = Group:BankWithdraw(playerId, groupId, amount)

  return status
end

function api.depositToBank(groupId, amount)
  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  
  local status = Group:BankDeposit(playerId, groupId, amount)

  return status
end

function api.getRoles(groupId)
  local groupData = Group:GetGroups(groupId)
  local groupRoles = {}

  for _, ROLE in pairs(groupData.roles) do
    local members = Group:GetMembersFromRole(groupId, ROLE.id)

    table.insert(groupRoles, {
      id = ROLE.id,
      name = ROLE.name,
      permissions = ROLE.permissions,
      icon = ROLE.icon,
      canDelete = ROLE.canDelete,
      members = members
    })
  end

  return groupRoles
end

function api.createRole(groupId, name, icon, permissions)
  local status = Group:CreateRole(groupId, name, icon, permissions)

  return status
end

function api.deleteRole(groupId, id)
  local status = Group:DeleteRole(groupId, id)

  return status
end

function api.editRole(groupId, id, name, icon, permissions)
  local status = Group:EditRole(groupId, id, name, icon, permissions)

  return status
end

function api.editGroupLogo(groupId, logoURL)
  Group:UpdateLogo(groupId, logoURL)
end

function api.rankingTryRescue(groupId)
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  local status = Ranking:TryRescue(groupId, playerId)

  return status
end