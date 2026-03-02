_G.Roles = {
  cache = {}
}

function Roles:Setup(availableGroups)
  local cached = {}

  for _, OBJECT in ipairs(availableGroups) do
    local hierarchy = json.decode(OBJECT.roles_hierarchy)
    local rolesHierarchy = {}

    if #hierarchy == 0 then
      local consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ? ORDER BY id ASC', { OBJECT.name })
  
      for INDEX, ROLE in ipairs(consultRoles) do
        table.insert(rolesHierarchy, {
          role_id = ROLE.id,
          name = ROLE.name,
          hierarchy = INDEX
        })
      end
  
      exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `roles_hierarchy` = ? WHERE `id` = ?', { json.encode(rolesHierarchy), OBJECT.id })
    else
      rolesHierarchy = hierarchy
    end

    cached[OBJECT.id] = rolesHierarchy
  end

  self.cache = cached
end

function Roles:UpdateRoles(groupId, groupName)
  local cached = {}
  local rolesHierarchy = {}

  local consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ? ORDER BY id ASC', { groupName })

  for INDEX, ROLE in ipairs(consultRoles) do
    table.insert(rolesHierarchy, {
      role_id = ROLE.id,
      name = ROLE.name,
      hierarchy = INDEX
    })
  end

  exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `roles_hierarchy` = ? WHERE `id` = ?', { json.encode(rolesHierarchy), groupId })

  self.cache[groupId] = rolesHierarchy
end

function Roles:GetByGroupId(groupId)
  if self.cache[groupId] then 
    return self.cache[groupId]
  end
end

function Roles:GetRoleByGroupId(groupId, roleId)
  if self.cache[groupId] then 
    for _, ROLE in ipairs(self.cache[groupId]) do 
      if ROLE.role_id == roleId then 
        return ROLE
      end
    end
  end
end

local function persistGroupHierarchy(groupId, hierarchyData)
  exports['oxmysql']:executeSync(
    'UPDATE `fta_groups` SET `roles_hierarchy` = ? WHERE `id` = ?',
    { json.encode(hierarchyData), groupId }
  )
end

local function findRoleIndex(rolesHierarchy, roleId)
  for index, role in ipairs(rolesHierarchy) do
    if tonumber(role.role_id) == tonumber(roleId) then
      return index
    end
  end
  return nil
end

local function normalizeHierarchy(rolesHierarchy)
  for index, role in ipairs(rolesHierarchy) do
    role.hierarchy = index
  end
end

function Roles:UpRoleHierarchy(groupId, roleId)
  local rolesHierarchy = self.cache[groupId]
  if not rolesHierarchy then
    return nil, 'Grupo não encontrado no cache.'
  end

  local currentIndex = findRoleIndex(rolesHierarchy, roleId)
  if not currentIndex then
    return nil, 'Cargo não encontrado na hierarquia.'
  end

  if currentIndex == 1 or currentIndex == 2 then
    return rolesHierarchy, 'Cargo já está no topo da hierarquia.'
  end

  rolesHierarchy[currentIndex], rolesHierarchy[currentIndex - 1] = rolesHierarchy[currentIndex - 1], rolesHierarchy[currentIndex]

  normalizeHierarchy(rolesHierarchy)
  self.cache[groupId] = rolesHierarchy
  persistGroupHierarchy(groupId, rolesHierarchy)

  return rolesHierarchy
end

function Roles:DownRoleHierarchy(groupId, roleId)
  local rolesHierarchy = self.cache[groupId]
  
  if not rolesHierarchy then
    return nil, 'Grupo não encontrado no cache.'
  end

  local currentIndex = findRoleIndex(rolesHierarchy, roleId)

  if not currentIndex then
    return nil, 'Cargo não encontrado na hierarquia.'
  end

  if currentIndex == #rolesHierarchy then
    return rolesHierarchy, 'Cargo já está na base da hierarquia.'
  end

  rolesHierarchy[currentIndex], rolesHierarchy[currentIndex + 1] = rolesHierarchy[currentIndex + 1], rolesHierarchy[currentIndex]

  normalizeHierarchy(rolesHierarchy)
  self.cache[groupId] = rolesHierarchy
  persistGroupHierarchy(groupId, rolesHierarchy)

  return rolesHierarchy
end