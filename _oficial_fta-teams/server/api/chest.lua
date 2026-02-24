local apiModule = Tunnel.getInterface('fta-module')

function api.tryCreateChest()
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  if playerId then
    local playerTeamObject = Group:GetPlayerGroupById(playerId)

    if playerTeamObject and playerTeamObject.ownerId == playerId then
      local chestObject = exports['fta-inventory']:getChestByName(playerTeamObject.name)

      if chestObject then
        TriggerClientEvent('Notify', playerSource, 'denied', 'O seu time já possui um baú criado.', 10000)
        return
      end

      local applied, model, coords, heading = apiModule.getObjectPositionByCamera(playerSource, { 'prop_ld_int_safe_01' })

      if not applied then
          return
      end

      local chestName = playerTeamObject.name
      local permissions = {}
      local chestWeight = 500
      local formattedCoordinates = {{ x = coords.x, y = coords.y, z = coords.z, h = heading, m = model }}
      local payload = {
        labelIndex = 'Team'
      }

      local chestCreated = exports['fta-inventory']:createChest('TEAM', chestName, chestWeight, permissions, formattedCoordinates, payload)

      if chestCreated then
        TriggerClientEvent('Notify', playerSource, 'success', 'Baú criado com sucesso.', 10000)
      else
        TriggerClientEvent('Notify', playerSource, 'denied', 'Ocorreu um erro ao criar o baú.', 10000)
      end
    end
  end
end

function api.tryEditChestLocation()
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  if playerId then
    local playerTeamObject = Group:GetPlayerGroupById(playerId)

    if playerTeamObject and playerTeamObject.ownerId == playerId then
        local chestObject = exports['fta-inventory']:getChestByName(playerTeamObject.name)
        
        if chestObject then
          local applied, model, coords, heading = apiModule.getObjectPositionByCamera(playerSource, { 'prop_ld_int_safe_01' })

          if not applied then
            return
          end

          local chestCoordinates = { x = coords.x, y = coords.y, z = coords.z, h = heading, m = model }

          local canCreate = true
          local availableChests = exports['fta-inventory']:getAvailableChests()
      
          for chestId, chestObject in pairs(availableChests) do
            for index, coordinates in ipairs(chestObject.coordinates) do
              local distance = #(vector3(chestCoordinates.x, chestCoordinates.y, chestCoordinates.z) - vector3(coordinates.x , coordinates.y, coordinates.z))
          
              if distance <= 5.0 then
                canCreate = false

                break
              end
            end
          end
      
          if not canCreate then
            TriggerClientEvent('Notify', playerSource, 'Você não pode colocar um baú aqui.', 10000)
    
            return false
          end

        local status = exports['fta-inventory']:updateChestCoordinates(chestObject.id, { chestCoordinates })

        if status then
          TriggerClientEvent('Notify', playerSource, 'sucess', 'Coordenadas atualizadas com sucesso!')
        else
          TriggerClientEvent('Notify', playerSource, 'denied', 'Ocorreu um erro ao atualizar as coordenadas.')
        end
      end
    end
  end
end

function api.tryBuyMoreChestWeight()
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  if playerId then
    local playerTeamObject = Group:GetPlayerGroupById(playerId)

    if playerTeamObject and playerTeamObject.ownerId == playerId then
      local chestObject = exports['fta-inventory']:getChestByName(playerTeamObject.name)
      
      if chestObject then
        local request = vRP.Request(playerSource, 'Baú de equipe', 'Deseja pagar 50 coins para aumentar 500Kg do baú?')

        if not request then
          return
        end

        if vRP.PaymentGems(playerId, 50) then
          local status = exports['fta-inventory']:upgradeChestWeight(chestObject.id, 500)

          if status then
            TriggerClientEvent('Notify', playerSource, 'sucess', 'Você aumentou 500Kgs do baú.')
          else
            vRP.UpgradeGemstone(playerId, 50)
            TriggerClientEvent('Notify', playerSource, 'denied', 'Ocorreu um erro ao aumentar os kilos do baú.')
          end
        end
      end
    end
  end
end

function api.canCreateChest()
  local playerSource = source
  local playerId = vRP.Passport(playerSource)

  if playerId then
    local playerTeamObject = Group:GetPlayerGroupById(playerId)

    if playerTeamObject and playerTeamObject.ownerId == playerId then
      local chestObject = exports['fta-inventory']:getChestByName(playerTeamObject.name)

      if chestObject then
        return false
      end

      return true
    end
  end

  return false
end