function api.getAvailableGroups()
  if not __isAuth__ then
    return
  end

  local groups = {}
  local groupsList = Group:GetGroups()

  for _, GROUP in pairs(groupsList) do 
    local teamData = CONFIG_TEAMS.TEAMS[GROUP.team]

    if teamData then 
      local ownerName = Player:GetName(GROUP.ownerId)
  
      table.insert(groups, {
        id = GROUP.id,
        name = GROUP.name,
        logoURL = GROUP.logoURL,
        team = { 
          name = teamData.NAME,
          color = teamData.COLOR,
          bannerURL = teamData.BANNER_URL
        },
        owner = {
          id = GROUP.ownerId,
          name = ownerName
        },
        permissions = GROUP.permissions,
        members = #GROUP.members,
        membersLimit = GROUP.membersLimit
      })
    end
  end

  return groups
end

function api.getTeams(teamId)
  if not __isAuth__ then
    return
  end

  if teamId then 
    local teamData = CONFIG_TEAMS.TEAMS[teamId]

    return { id = teamId, name = teamData.NAME, color = teamData.COLOR, bannerURL = teamData.BANNER_URL }
  end

  local availabeTeams = {}

  for ID, TEAM in pairs(CONFIG_TEAMS.TEAMS) do 
    table.insert(availabeTeams, {
      id = ID,
      name = TEAM.NAME,
      color = TEAM.COLOR,
      bannerURL = TEAM.BANNER_URL,
    })
  end

  return availabeTeams
end

function api.createGroup(teamId, groupName, ownerId, permissions, membersLimit)
  if not __isAuth__ then
    return
  end

  local playerSource = source

  Group:CreateGroup(teamId, groupName, ownerId, permissions, membersLimit)
end

function api.updateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
  if not __isAuth__ then
    return
  end

  local playerSource = source

  local status = Group:UpdateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
  return status
end

function api.deleteGroup(groupId)
  if not __isAuth__ then
    return
  end

  local status = Group:DeleteGroup(groupId)
  
  return status
end

function api.hasAdminPermission()
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  local allowed = vRP.HasPermission(playerId, SHARED_CONFIG.ADMIN_PERMISSION)

  return allowed
end

function api.getPlayerName()
  if not __isAuth__ then
    return
  end

  local playerSource = source
  local playerId = vRP.Passport(playerSource)
  local playerName = Player:GetName(playerId)
  
  return playerName
end

function api.getRankingRewards()
  if not __isAuth__ then
    return
  end

  local ranking = Ranking:GetRanking()

  return ranking
end

function api.updateRanking(position, prizes)
  if not __isAuth__ then
    return
  end

  local status = Ranking:UpdateRankingRewards(position, prizes)

  return status
end

function api.getRescueRewards()
  if not __isAuth__ then
    return
  end

  local timeToRescue, timeToExpired = Ranking:GetRescueTimers()

  return timeToRescue, timeToExpired
end

function api.updateRewardTime(timestamp)
  if not __isAuth__ then
    return
  end

  local status = Ranking:UpdateTimestampToRescue(timestamp)

  return status
end