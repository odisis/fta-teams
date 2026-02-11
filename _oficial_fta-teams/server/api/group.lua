function api.getGroupMembers(groupId)
  if not __isAuth__ then
    return
  end

  local playerSource = source 
  local playerId = vRP.Passport(playerSource)

  local group = Group:GetGroups(groupId)

  if not group then
    return {}
  end

  local groupMembers = group.members
  local groupRoles = group.roles
  local members = {}

  for _, MEMBER in ipairs(groupMembers) do 
    local formatMember = Player:MemberFormat(groupId, MEMBER.playerId, MEMBER.roleId)

    formatMember.role = groupRoles[MEMBER.roleId]
    formatMember.isLeader = MEMBER.playerId == group.ownerId
    formatMember.isMe = playerId == MEMBER.playerId

    table.insert(members, formatMember)
  end
  
  return members
end

function api.getPlayerRolePermissions(groupId)
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)

  if not playerRole then
    return nil, nil
  end

  return playerRole.permissions, roleId
end

function api.getGroups(groupId)
  if not __isAuth__ then
    return
  end

  return Group:GetGroups(groupId)
end

function api.isPlayerInGroup()
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  local groupId = Group:IsPlayerInGroup(playerId)

  if groupId then
    return groupId
  end

  return false
end

function api.updateMemberRole(groupId, memberId, roleId)
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  local status = Group:UpdateMemberRole(playerId, groupId, memberId, roleId)

  return status
end

function api.kickMember(groupId, memberId)
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  Group:KickMember(playerId, groupId, memberId)

  return true
end

function api.tryInviteMember(groupId, memberId)
  if not __isAuth__ then
    return
  end
  
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  local status = Group:TryInviteMember(playerId, groupId, memberId)

  return status
end

function api.getGroupBank(groupId)
  if not __isAuth__ then
    return
  end

  local group = Group:GetGroups(groupId)

  if not group then
    return 0, {}
  end

  local transactions = Group:GetLatestTransactions(groupId)
  local balance = group.balance or 0
  
  return balance, transactions
end

function api.withdrawFromBank(groupId, amount)
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  
  local status = Group:BankWithdraw(playerId, groupId, amount)

  return status
end

function api.depositToBank(groupId, amount)
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  
  local status = Group:BankDeposit(playerId, groupId, amount)

  return status
end

function api.getRoles(groupId)
  if not __isAuth__ then
    return
  end

  local group = Group:GetGroups(groupId)

  if not group then
    return {}
  end

  local groupRoles = {}

  for _, ROLE in pairs(group.roles) do
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
  if not __isAuth__ then
    return
  end

  local status = Group:CreateRole(groupId, name, icon, permissions)

  return status
end

function api.deleteRole(groupId, id)
  if not __isAuth__ then
    return
  end

  local status = Group:DeleteRole(groupId, id)

  return status
end

function api.editRole(groupId, id, name, icon, permissions)
  if not __isAuth__ then
    return
  end

  local status = Group:EditRole(groupId, id, name, icon, permissions)

  return status
end

function api.editGroupLogo(groupId, logoURL)
  if not __isAuth__ then
    return
  end

  Group:UpdateLogo(groupId, logoURL)
end

function api.rankingTryRescue(groupId)
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  local status = Ranking:TryRescue(groupId, playerId)

  return status
end