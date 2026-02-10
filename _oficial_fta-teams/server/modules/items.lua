_G.Items = {
  vehicles = {},
  items = {},
  permissions = {}
}

function Items:SetupVehicles()
  CreateThread(function()
    local vehicleList = exports['nation-garages']:getVehList()
  
    local availableVehicles = {}
    for INDEX, VEHICLE in pairs(vehicleList) do 
      table.insert(availableVehicles, {
        id = VEHICLE.model,
        name = VEHICLE.name,
        imageURL = 'http://189.127.164.6/vehicles/'..VEHICLE.model..'.png',
      })
    end
  
    self.vehicles = availableVehicles
  
    Wait(500)

    TriggerClientEvent('fta-teams:setup:vehicles', -1, availableVehicles)
  end)
end

function Items:SetupItems()
  CreateThread(function()
    local itemList = ItemGlobal()
  
    local availableItems = {}
    for INDEX, ITEM in pairs(itemList) do 
      table.insert(availableItems, {
        id = INDEX,
        name = ITEM.Name,
        imageURL = 'http://189.127.164.6/inv/'..INDEX..'.png',
      })
    end
  
    self.items = availableItems
    
    Wait(500)

    TriggerClientEvent('fta-teams:setup:items', -1, availableItems)
  end)
end

function Items:SetupPermissions()
  CreateThread(function()
    local permissionsList = getPermissionList()

    local availablePermissions = {}

    for PERMISSION, GROUP in pairs(permissionsList) do 
      for INDEX, HIERARCHY in ipairs(GROUP.Hierarchy) do
        table.insert(availablePermissions, {
          id = PERMISSION..'-'..HIERARCHY..'-'..INDEX,
          name = PERMISSION..'-'..HIERARCHY,
          imageURL = ''
        })
      end
    end

    self.permissions = availablePermissions

    Wait(500)

    TriggerClientEvent('fta-teams:setup:permissions', -1, availablePermissions)
  end)
end

function Items:GetItems()
  return self.items
end

function Items:GetVehicles()
  return self.vehicles
end

function Items:GetPermissions()
  return self.permissions
end

CreateThread(function()
  Wait(1000)

  Items:SetupVehicles()
  Wait(500)
  Items:SetupItems()
  Wait(500)
  Items:SetupPermissions()
end)

RegisterNetEvent('fta-teams:setupItems', function()
  local playerSource = source
  
  CreateThread(function()
    TriggerClientEvent('fta-teams:setup:vehicles', playerSource, Items.vehicles)
    TriggerClientEvent('fta-teams:setup:items', playerSource, Items.items)
    TriggerClientEvent('fta-teams:setup:permissions', playerSource, Items.permissions)
  end)
end)