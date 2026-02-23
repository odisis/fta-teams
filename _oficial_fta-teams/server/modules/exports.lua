--[[ PEGAR O GRUPO QUE O JOGADOR ESTÁ ]]

exports('getPlayerGroup', function(playerId)
  local playerGroup = Group:GetPlayerGroupById(playerId)

  return playerGroup
end)

--[[ PEGAR GRUPOS ]]
exports('getGroups', function()
  local groupData = Group:GetGroups()

  return groupData
end)

--[[ PEGAR GRUPO PELO ID ]]
exports('getGroup', function(groupId)
  local groupData = Group:GetGroups(groupId)

  return groupData
end)

--[[ PEGAR CARGOS DO GRUPO ]]
exports('getGroupRoles', function(groupId)
  local groupData = Group:GetGroups(groupId)

  if groupData then 
    return groupData.roles or {}
  end

  return nil
end)

--[[ PEGAR PERMISSOES DO CARGO DO GRUPO ]]
exports('getGroupRolePermissions', function(groupId, roleId)
  local groupData = Group:GetGroups(groupId)

  if groupData then 
    return groupData.roles[roleId] or {}
  end

  return nil
end)

--[[ PEGAR PERMISSOES DO MEMBRO PELO GROUP ID ]]
exports('getPlayerRoleByGroupId', function(groupId, playerId)
  local groupData = Group:GetGroups(groupId)

  if groupData then 
    for _, MEMBER in ipairs(groupData.members) do 
      if MEMBER.playerId == playerId then 
        return groupData.roles[MEMBER.roleId].permissions
      end
    end
  end
end)

--[[ PEGAR PERMISSOES DO MEMBRO ]]
exports('getPlayerRole', function(playerId)
  local playerGroup = Group:GetPlayerGroupById(playerId)

  if playerGroup then 
    for _, MEMBER in ipairs(playerGroup.members) do 
      if MEMBER.playerId == playerId then 
        return playerGroup.roles[MEMBER.roleId].permissions
      end
    end
  end
end)

--[[ PEGAR MEMBROS DO GRUPO ]]
exports('getGroupMembers', function(groupId)
  local groupData = Group:GetGroups(groupId)

  if groupData then 
    return groupData.members or {}
  end

  return nil
end)