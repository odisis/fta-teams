function NUI:OpenAdmin(playerName)
  local playerImage = apiServer.getProfileImage()

  self.profileImage = playerImage

  SetNuiFocus(true, true)

  SendNUIMessage({
    action = 'openAdmin',
    data = {
      name = playerName,
      profile = self.profileImage
    }
  })
end

function NUI:HideAdmin()
  self:HidePainel()

  SendNUIMessage({
    action = 'closeAdmin',
    data = {}
  })  
end

function NUI:HideAdmin()
  self:HidePainel()

  SendNUIMessage({
    action = 'closeAdmin'
  })  
end

RegisterNUICallback('getTeams', function(data, cb)
  local teams = apiServer.getTeams()

  cb({
    teams = teams
  })
end)

RegisterNUICallback('createGroup', function(data, cb)
  local teamId, groupName, ownerId, permissions, membersLimit = data.teamId, data.groupName, data.ownerId, data.permissions, data.membersLimit
  local status = apiServer.createGroup(teamId, groupName, ownerId, permissions, membersLimit)

  cb({ status = true })
end)


RegisterNUICallback('editGroup', function(data, cb)
  local teamId, groupId, groupName, ownerId, permissions, membersLimit = data.teamId, data.id, data.groupName, data.ownerId, data.permissions, data.membersLimit
  local status = apiServer.updateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
  
  cb({ status = status })
end)

RegisterNUICallback('getGroups', function(data, cb)
  local groups = apiServer.getAvailableGroups()
  
  cb({
    groups = groups
  })
end)

RegisterNUICallback('deleteGroup', function(data, cb)
  local groupId = data.groupId
  local status = apiServer.deleteGroup(groupId)

  cb({ status = status })
end)

RegisterNUICallback('editGroup', function(data, cb)
  local groupId = data.groupId
  local status = apiServer.editGroup(groupId)

  cb({ status = status })
end)

RegisterNUICallback('getAdminItems', function(data, cb)
  local items = Items:GetItems()
  
  cb({
    items = items
  })
end)

RegisterNUICallback('getAdminVehicles', function(data, cb)
  local vehicles = Items:GetVehicles()
  
  cb({
    items = vehicles
  })
end)

RegisterNUICallback('getAdminPermissions', function(data, cb)
  local permissions = Items:GetPermissions()

  cb({
    items = permissions
  })
end)

RegisterNUICallback('assignRankingPrize', function(data, cb)
  local position = data.position
  local prizes = data.prizes
  
  local status = apiServer.updateRanking(position, prizes)

  cb({ status = status })
end)

RegisterNUICallback('getRescueRewards', function(data, cb)
  local timeToRescue, timeToExpired = apiServer.getRescueRewards()

  cb({ timeToRescue = timeToRescue, timeToExpired = timeToExpired })
end)

RegisterNUICallback('getGroupRanking', function(data, cb)
  local availableGroups = apiServer.getAvailableGroups()
  local rankings = {}

  for _, GROUP in ipairs(availableGroups) do 
    table.insert(rankings, {
      name = GROUP.name,
      contracts = GROUP.members,
      bannerURL = GROUP.team.bannerURL or 'https://media.discordapp.net/attachments/968335309731414106/1459340441269829683/image.png?ex=6962ec32&is=69619ab2&hm=a96d2b1122707c893fdafe3a18d1437186ea557ef7d3df0082bb61a2a9419571&=&format=webp&quality=lossless'
    })
  end
  
  cb({
    rankings = rankings
  })
end)

RegisterNUICallback('getRankingRewards', function(data, cb)
  local availableRewards = apiServer.getRankingRewards()
  local rewards = {}
  
  for _, REWARD in pairs(availableRewards) do 
    if REWARD then 
      table.insert(rewards, {
        position = REWARD.position,
        rewards = REWARD.rewards
      })
    end
  end

  cb({
    rewards = rewards
  })
end)

RegisterNUICallback('updateRewardTime', function(data, cb)
  local timestamp = data.timestamp

  local status = apiServer.updateRewardTime(tonumber(timestamp))

  cb({ status = status })
end)

RegisterCommand('adminpainel', function()
  local allowed = apiServer.hasAdminPermission()

  if allowed then 
    local playerName = apiServer.getPlayerName()
    NUI:OpenAdmin(playerName)
  end
end)