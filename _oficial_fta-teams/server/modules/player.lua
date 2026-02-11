_G.Player = {}

function Player:GetPlayerRole(groupId, playerId)
  local group = Group:GetGroups(groupId)

  if not group then
    return false
  end

  for _, MEMBER in ipairs(group.members) do 
    if MEMBER.playerId == playerId then
      return group.roles[MEMBER.roleId], MEMBER.roleId
    end
  end

  return false
end

function Player:Get(groupId, playerId)
  local groupMembers = Group:GetGroupMembers(groupId)

  if not groupMembers then
    return nil
  end
  
  for _, MEMBER in ipairs(groupMembers) do 
    if MEMBER.playerId == playerId then 
      return MEMBER
    end
  end
end

function Player:GetName(playerId)
  return vRP.UserName(tonumber(playerId))
end

function Player:MemberFormat(groupId, playerId, roleId)
  local player = self:Get(groupId, playerId)
  local playerName = self:GetName(playerId)
  local isOnline = vRP.Source(playerId)

  return {
    id = playerId,
    name = playerName,
    online = isOnline,
    joinedAt = player.joinedAt
  }
end

function Player:SetPermissions(playerId, permissions)
  for _, PERMISSION in ipairs(permissions) do
    local splits = splitString(PERMISSION.id, '-')
    vRP.SetPermission(playerId, splits[1], tonumber(splits[3]))
  end
end

function Player:RemovePermissions(playerId, permissions)
  for _, PERMISSION in ipairs(permissions) do
    local splits = splitString(PERMISSION.id, '-')
    vRP.RemovePermission(playerId, splits[1])
  end
end