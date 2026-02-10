_G.Items = {
  vehicles = {},
  items = {},
  permissions = {}
}

function Items:SetupVehicles(vehicles)
  print(json.encode(vehicles))
  
  if #self.vehicles <= 0 then 
    self.vehicles = vehicles
  end
end

function Items:SetupItems(items)
  if #self.items <= 0 then 
    self.items = items
  end
end

function Items:SetupPermissions(permissions)
  if #self.permissions <= 0 then 
    self.permissions = permissions
  end
end

function Items:GetVehicles()
  return self.vehicles
end

function Items:GetItems()
  return self.items
end

function Items:GetPermissions()
  return self.permissions
end

RegisterNetEvent('fta-teams:setup:vehicles', function(payload)
  Items:SetupVehicles(payload)
end)

RegisterNetEvent('fta-teams:setup:items', function(payload)
  Items:SetupItems(payload)
end)

RegisterNetEvent('fta-teams:setup:permissions', function(payload)
  Items:SetupPermissions(payload)
end)