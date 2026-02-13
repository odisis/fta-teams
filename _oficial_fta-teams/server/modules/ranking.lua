_G.Ranking = {
  cache = {},
  ranking = {},
  rescue = {}
}

function Ranking:GetRescueTimers()
  return self.rescue.rescueTimestamp, self.rescue.timeToRescue
end

function Ranking:Setup()
  self:ReadingFile()

  local consultRanking = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_ranking`')

  for _, RANKING in ipairs(consultRanking) do 
    self.cache[RANKING.id] = {
      position = RANKING.id,
      rewards = json.decode(RANKING.rewards)
    }
  end

  Ranking:UpdateRankingPositions()
end

function Ranking:UpdateRankingPositions()
  local sleepTime = (60 * 5) * 1000

  CreateThread(LPH_NO_VIRTUALIZE(function()
    while true do 
      local availableGroups = Group:GetGroups()
      local groups = {}

      for _, GROUP in pairs(availableGroups) do 
        table.insert(groups, {
          name = GROUP.name,
          contracts = #GROUP.members,
          members = GROUP.members
        })
      end

      table.sort(groups, function(a, b)
        return a.contracts > b.contracts
      end)

      self.ranking = groups

      Wait(sleepTime)
    end
  end))
end

function Ranking:GetRanking(position)
  if position then 
    return self.cache[position]
  end
  
  return self.cache
end

function Ranking:UpdateRankingRewards(position, prizes)
  local consultRanking = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_ranking` WHERE `id` = ?', { position })[1]
  
  self.cache[position] = {
    position = position,
    rewards = prizes
  }

  if consultRanking then 
    exports['oxmysql']:executeSync('UPDATE `fta_groups_ranking` SET `rewards` = ? WHERE `id` = ?', { json.encode(prizes), position })
  else
    exports['oxmysql']:executeSync('INSERT INTO `fta_groups_ranking` (`id`, `rewards`) VALUES (?, ?)', { position, json.encode(prizes) })
  end

  return true
end

function Ranking:GiveItem(playerId, item, quantity)
  vRP.GenerateItem(playerId, item, quantity, true)
end

function Ranking:SetPermission(playerId, permission, duration, durationType)
  local splits = splitString(permission, '-')
  local timestamp = os.time()
  
  if durationType == 'PERMANENT' then 
    vRP.SetPermission(playerId, splits[1], tonumber(splits[3]))
    return true
  end
  
  if durationType == 'DAYS' then 
    local days = duration * 86400
    timestamp = timestamp + days
  end

  if durationType == 'WEEKS' then 
    local weeks = duration * 604800
    timestamp = timestamp + weeks
  end

  if durationType == 'MONTH' then 
    local months = duration * 2629743
    timestamp = timestamp + months
  end
  
  vRP.SetPermission(playerId, splits[1], tonumber(splits[3]))
  exports['oxmysql']:executeSync('INSERT INTO `hydrus_scheduler` (`player_id`, `command`, `args`, `execute_at`) VALUES (?, ?, ?, ?)', { tostring(playerId), 'delpermission', json.encode({ user_id = playerId, permission = splits[1] }), timestamp })
end

function Ranking:GiveVehicle(playerId, vehicle, duration, durationType)
  local timestamp = os.time()
  
  if durationType == 'PERMANENT' then 
    exports['nation-garages']:addUserVehicle(vehicle, playerId, { type = 'vip' })
    return true
  end
  
  if durationType == 'DAYS' then 
    local days = duration * 86400
    timestamp = timestamp + days
  end

  if durationType == 'WEEKS' then 
    local weeks = duration * 604800
    timestamp = timestamp + weeks
  end

  if durationType == 'MONTH' then 
    local months = duration * 2629743
    timestamp = timestamp + months
  end

  exports['nation-garages']:addUserVehicle(vehicle, playerId, { type = 'vip' })
  exports['oxmysql']:executeSync('INSERT INTO `hydrus_scheduler` (`player_id`, `command`, `args`, `execute_at`) VALUES (?, ?, ?, ?)', { tostring(playerId), 'delvehicle', json.encode({ user_id = playerId, vehicle = vehicle }), timestamp })
end

function Ranking:GetRewards(playerId, position) 
  local rewardsData = self.cache[position]

  if rewardsData then 
    local rewards = rewardsData.rewards

    for _, REWARD in pairs(rewards) do
      if REWARD.type == 'VEHICLE' then
        self:GiveVehicle(playerId, REWARD.item, REWARD.value, REWARD.durationType)
      end
  
      if REWARD.type == 'PERMISSION' then
        self:SetPermission(playerId, REWARD.item, REWARD.value, REWARD.durationType)
      end
      
      if REWARD.type == 'ITEM' then
        self:GiveItem(playerId, REWARD.item, REWARD.value)
      end
    end
  end
end

function Ranking:TryRescue(groupId, playerId)
  local timestamp = os.time()

  if self.rescue.rescueTimestamp > timestamp and self.rescue.timeToRescue < timestamp then 
    return false
  end
  
  local groups = self.ranking

  for POSITION, GROUP in ipairs(groups) do
    if GROUP.name == groupId then 
      for _, MEMBER in ipairs(GROUP.members) do 
        if MEMBER.playerId == playerId then
          local allowed = self:AllowedToRescue(MEMBER)

          if allowed then 
            Group:UpdateMemberRescue(groupId, playerId, self.rescue.waveId) 
            self:GetRewards(playerId, POSITION)

            return true
          end

          return false
        end
      end
    end
  end

  return false
end

function Ranking:AllowedToRescue(member)
  local changedWave = false
  local timestamp = os.time()
  local joinedAt = member.joinedAt + 604800

  if member.rescueWave ~= self.rescue.waveId then 
    changedWave = true
  end

  if joinedAt > timestamp then 
    return false
  end
  
  if not member.rescueReward then 
    return true
  else
    if changedWave then 
      return true
    end
  end

  return false
end

function Ranking:ReadingFile()
  local data = LoadResourceFile(GetCurrentResourceName(), 'rescue.json')
  local rescueData = json.decode(data)
  
  self.rescue = {
    waveId = rescueData.wave_id,
    rescueTimestamp = rescueData.rescue_timestamp,
    timeToRescue = rescueData.time_to_rescue
  }
end

function Ranking:UpdateTimestampToRescue(timestamp)
  timestamp = timestamp - 2629743
  
  local timeToRescue = timestamp + 86400
  local waveId = self:GetWaveId()

  local payload = {
    wave_id = waveId,
    rescue_timestamp = timestamp,
    time_to_rescue = timeToRescue
  }

  local encoded = json.encode(payload)

  local saved = SaveResourceFile(GetCurrentResourceName(), 'rescue.json', encoded, -1)

  self:ReadingFile()

  return saved and payload or false
end

function Ranking:Get()
  return self.ranking
end

function Ranking:GetWaveId()
  local random = math.random(1, 99999999)

  return random
end

CreateThread(function()
  Wait(1000)

  while not __isAuth__ do
    Citizen.Wait(1000)
  end

  Ranking:Setup()
end)