function NUI:OpenGroup(groupId)
  local playerPermissions = apiServer.getPlayerRolePermissions(groupId)
  local groupData = apiServer.getGroups(groupId)
  local teamData = CONFIG_TEAMS.TEAMS[groupData.team]
  local rolesList = {}

  self.groupId = groupId

  for _, ROLE in pairs(groupData.roles) do 
    table.insert(rolesList, {
      id = ROLE.id,
      name = ROLE.name,
      permissions = ROLE.permissions,
      canDelete = ROLE.canDelete
    })
  end

  SetNuiFocus(true, true)
  SendNUIMessage({
    action = 'openGroup',
    data = {
      name = groupId,
      permissions = playerPermissions,
      faction = {
        name = teamData.NAME,
        color = teamData.COLOR
      },
      bannerURL = teamData.BANNER_URL,
      logoURL = groupData.logoURL,
      rolesList = rolesList,
    }
  })
end

function NUI:HideGroup()
  self:HidePainel()

  SendNUIMessage({
    action = 'closeGroup'
  })
end

RegisterNUICallback('getGroupMembers', function(data, cb)
  local members = apiServer.getGroupMembers(NUI.groupId)
  
  cb({
    members = members
  })
end)

RegisterNUICallback('updateMemberRole', function(data, cb)
  local memberId, roleId = data.memberId, data.roleId
  local status = apiServer.updateMemberRole(NUI.groupId, memberId, roleId)

  cb({ status = status })
end)

RegisterNUICallback('kickMember', function(data, cb)
  local memberId = data.memberId
  local status = apiServer.kickMember(NUI.groupId, memberId)

  cb({ status = status })
end)

RegisterNUICallback('tryInviteMember', function(data, cb)
  local memberId = data.memberId
  local status = apiServer.tryInviteMember(NUI.groupId, memberId)

  cb({ status = status })
end)


RegisterNUICallback('getGroupBank', function(data, cb)
  local balance, transactions = apiServer.getGroupBank(NUI.groupId)

  cb({
    balance = balance,
    transactions = transactions
  })
end)

RegisterNUICallback('withdrawFromBank', function(data, cb)
  local amount = data.amount
  local status = apiServer.withdrawFromBank(NUI.groupId, amount)

  cb({ status = status })
end)

RegisterNUICallback('depositToBank', function(data, cb)
  local amount = data.amount
  local status = apiServer.depositToBank(NUI.groupId, amount)

  cb({ status = status })
end)

RegisterNUICallback('getRoles', function(data, cb)
  local roles = apiServer.getRoles(NUI.groupId)
  
  print(json.encode(roles))

  table.sort(roles, function(a, b)
      return a.id < b.id
  end)

  cb({
    roles = roles
  })
end)

RegisterNUICallback('createRole', function(data, cb)
  local name, icon, permissions = data.name, data.icon, data.permissions
  local status = apiServer.createRole(NUI.groupId, name, icon, permissions)

  cb({ status = status })
end)

RegisterNUICallback('deleteRole', function(data, cb)
  local roleId = data.id
  local status = apiServer.deleteRole(NUI.groupId, roleId)

  cb({ status = status })
end)

RegisterNUICallback('editRole', function(data, cb)
  local id, name, icon, permissions = data.id, data.name, data.icon, data.permissions
  local status = apiServer.editRole(NUI.groupId, id, name, icon, permissions)

  cb({ status = status })
end)

RegisterNUICallback('updateGroupLogo', function(data, cb)
  apiServer.editGroupLogo(NUI.groupId, data.logoURL)
  
  cb({ status = true })
end)

RegisterNUICallback('tryRescueRewards', function(data, cb)
  local status = apiServer.rankingTryRescue(NUI.groupId)
  cb({ success = status })
end)