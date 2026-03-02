_G.Chests = {
  cache = {},
  playersCache = {},
  rolesCache = {}
}

function Chests:GetPlayerName(playerId)
  if not self.playersCache[playerId] then 
    self.playersCache[playerId] = vRP.UserName(playerId)
  end

  return self.playersCache[playerId]
end

function Chests:Setup(availableGroups)
  local availableChests = {}
  local players = {}
  local roles = {}

  for _, GROUP in ipairs(availableGroups) do 
    local consultChests = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_chests` WHERE `group` = ?', { GROUP.name })

    if consultChests then 
      availableChests[GROUP.name] = {}
      
      for _, CHEST in ipairs(consultChests) do
        local playerName = Chests:GetPlayerName(CHEST.player_id)
        local payload = json.decode(CHEST.payload)
        local itemData = Items:GetEasyItems(payload.item)

        table.insert(availableChests[GROUP.name], {
          id = CHEST.player_id,
          name = playerName,
          roleId = CHEST.role_id,
          action = CHEST.action,
          payload = {
            name = itemData.name,
            amount = payload.amount
          },
          timestamp = CHEST.timestamp
        })
      end
    end
  end

  self.cache = availableChests
end

function Chests:InsertLogInGroup(groupId, playerId, action, item, amount)
  local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)

  if not playerRole then 
    if SHARED_CONFIG.DEV_MODE then 
      print('[DEBUG] - Não foi encontrado playerRole no jogador id: ', playerId, groupId)
    end

    return
  end

  local playerName = Chests:GetPlayerName(playerId)
  local itemData = Items:GetEasyItems(item)

  if not self.cache[groupId] then
    self.cache[groupId] = {}
  end

  local timestamp = os.time()

  table.insert(self.cache[groupId], {
    id = playerId,
    name = playerName,
    roleId = roleId,
    action = action,
    payload = {
      name = itemData.name,
      amount = amount
    },
    timestamp = timestamp
  })

  exports['oxmysql']:executeSync('INSERT INTO `fta_groups_chests` (`group`, `player_id`, `role_id`, `action`, `payload`, `timestamp`) VALUES (?, ?, ?, ?, ?, ?)', {
    groupId,
    playerId,
    roleId,
    action,
    json.encode({ item = item, amount = amount }),
    timestamp
  })
end 

function Chests:GetLogsByGroupId(groupId)
  local groupData = Group:GetGroupById(groupId)

  if groupData then 
    if self.cache[groupData.name] then 
      return self.cache[groupData.name]
    end 
  end
end

function Chests:GetLogsByGroupName(groupName)
  if self.cache[groupName] then 
    return self.cache[groupName]
  end 
end

exports('insertLogInGroup', function(...)
  Chests:InsertLogInGroup(...)
end)