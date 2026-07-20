local CONTRACT_VERSION = 1
local CONTRACT_TABLE = 'fta_groups_baques_contracts'
local LOCK_TABLE = 'fta_groups_baques_locks'
local CHEST_STATE_TABLE = 'fta_groups_baques_chest_state'
local OWNERSHIP_TABLE = 'fta_groups_baques_territories'

local Contract = {
  initialized = false
}

local function query(sql, parameters)
  return exports['oxmysql']:executeSync(sql, parameters or {}) or {}
end

local function copy(value)
  if type(value) ~= 'table' then
    return value
  end

  return json.decode(json.encode(value))
end

local function sameId(left, right)
  return left ~= nil and right ~= nil and tostring(left) == tostring(right)
end

local function sameNullableId(left, right)
  if left == nil or right == nil then
    return left == nil and right == nil
  end

  return sameId(left, right)
end

local function positiveId(value)
  value = tonumber(value)
  return value and value > 0 and value or nil
end

local function groupById(groupId)
  groupId = positiveId(groupId)
  if not groupId or not Group then
    return nil
  end

  if type(Group.GetGroupById) == 'function' then
    local group = Group:GetGroupById(groupId)
    if group then
      return group
    end
  end

  for _, group in pairs(Group.groups or {}) do
    if tonumber(group.id) == groupId then
      return group
    end
  end

  return nil
end

local function inventoryExport(name, ...)
  if GetResourceState('fta-inventory') ~= 'started' then
    return nil, 'inventory_unavailable'
  end

  local arguments = { ... }
  local ok, result, reason, details = pcall(function()
    return exports['fta-inventory'][name](table.unpack(arguments))
  end)
  if not ok then
    return nil, 'inventory_contract_unavailable'
  end

  return result, reason, details
end

function Contract:EnsureTables()
  if self.initialized then
    return true
  end

  query(([=[
    CREATE TABLE IF NOT EXISTS `%s` (
      `transition_id` VARCHAR(64) NOT NULL,
      `operation_kind` VARCHAR(32) NOT NULL,
      `state` VARCHAR(24) NOT NULL,
      `snapshot_json` LONGTEXT NOT NULL,
      `committed` TINYINT(1) NOT NULL DEFAULT 0,
      `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`transition_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]=]):format(CONTRACT_TABLE))

  query(([=[
    CREATE TABLE IF NOT EXISTS `%s` (
      `organization_id` INT NOT NULL,
      `transition_id` VARCHAR(64) NOT NULL,
      `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (`organization_id`),
      KEY `idx_transition` (`transition_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]=]):format(LOCK_TABLE))

  query(([=[
    CREATE TABLE IF NOT EXISTS `%s` (
      `organization_id` INT NOT NULL,
      `chest_id` INT NULL,
      `placement_state` VARCHAR(24) NOT NULL DEFAULT 'not_created',
      `transition_id` VARCHAR(64) NULL,
      `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`organization_id`),
      KEY `idx_placement` (`placement_state`, `updated_at`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]=]):format(CHEST_STATE_TABLE))

  query(([=[
    CREATE TABLE IF NOT EXISTS `%s` (
      `territory_id` VARCHAR(64) NOT NULL,
      `organization_id` INT NULL,
      `team_id` VARCHAR(64) NULL,
      `control_state` VARCHAR(24) NOT NULL,
      `transition_id` VARCHAR(64) NOT NULL,
      `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`territory_id`),
      KEY `idx_organization` (`organization_id`),
      KEY `idx_transition` (`transition_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]=]):format(OWNERSHIP_TABLE))

  self.initialized = true
  return true
end

function Contract:GetRecord(transitionId)
  self:EnsureTables()
  local row = query(
    ('SELECT * FROM `%s` WHERE `transition_id` = ? LIMIT 1;'):format(CONTRACT_TABLE),
    { transitionId }
  )[1]
  if not row then
    return nil
  end

  row.snapshot = json.decode(row.snapshot_json or '{}') or {}
  return row
end

function Contract:SaveRecord(transitionId, operationKind, state, snapshot, committed)
  query(([=[
    INSERT INTO `%s`
      (`transition_id`, `operation_kind`, `state`, `snapshot_json`, `committed`)
    VALUES (?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      `operation_kind` = VALUES(`operation_kind`),
      `state` = VALUES(`state`),
      `snapshot_json` = VALUES(`snapshot_json`),
      `committed` = VALUES(`committed`);
  ]=]):format(CONTRACT_TABLE), {
    transitionId,
    operationKind,
    state,
    json.encode(snapshot or {}),
    committed and 1 or 0
  })
end

function Contract:GetChestState(organizationId)
  self:EnsureTables()
  local row = query(
    ('SELECT * FROM `%s` WHERE `organization_id` = ? LIMIT 1;'):format(CHEST_STATE_TABLE),
    { tonumber(organizationId) }
  )[1]

  if not row then
    return {
      organizationId = tonumber(organizationId),
      state = 'not_created'
    }
  end

  return {
    organizationId = tonumber(row.organization_id),
    chestId = tonumber(row.chest_id),
    state = row.placement_state,
    transitionId = row.transition_id
  }
end

function Contract:SetChestState(organizationId, chestId, state, transitionId)
  query(([=[
    INSERT INTO `%s`
      (`organization_id`, `chest_id`, `placement_state`, `transition_id`)
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      `chest_id` = VALUES(`chest_id`),
      `placement_state` = VALUES(`placement_state`),
      `transition_id` = VALUES(`transition_id`);
  ]=]):format(CHEST_STATE_TABLE), {
    tonumber(organizationId),
    tonumber(chestId),
    tostring(state or 'not_created'),
    transitionId
  })
end

function Contract:ResolveChest(group)
  if type(group) ~= 'table' then
    return nil, 'organization_not_found'
  end

  local chest = inventoryExport('getOrganizationChest', tonumber(group.id))
  if chest then
    local current = self:GetChestState(group.id)
    local state = current.state == 'pending_placement' and current.state or 'placed'
    self:SetChestState(group.id, chest.id, state, current.transitionId)
    return chest
  end

  chest = inventoryExport('getChestByName', group.name)
  if not chest then
    self:SetChestState(group.id, nil, 'not_created', nil)
    return nil
  end

  local bound, reason = inventoryExport(
    'bindOrganizationChest',
    tonumber(chest.id),
    tonumber(group.id)
  )
  if not bound then
    return nil, reason or 'organization_chest_bind_failed'
  end

  chest = inventoryExport('getOrganizationChest', tonumber(group.id)) or chest
  self:SetChestState(group.id, chest.id, 'placed', nil)
  return chest
end

function Contract:AcquireLocks(transitionId, organizationIds)
  local acquired = {}

  for _, organizationId in ipairs(organizationIds) do
    local current = query(
      ('SELECT `transition_id` FROM `%s` WHERE `organization_id` = ? LIMIT 1;'):format(LOCK_TABLE),
      { tonumber(organizationId) }
    )[1]

    if current and tostring(current.transition_id) ~= transitionId then
      for _, acquiredId in ipairs(acquired) do
        query(
          ('DELETE FROM `%s` WHERE `organization_id` = ? AND `transition_id` = ?;'):format(LOCK_TABLE),
          { acquiredId, transitionId }
        )
      end
      return false, 'organization_locked'
    end

    query(
      ('INSERT IGNORE INTO `%s` (`organization_id`, `transition_id`) VALUES (?, ?);'):format(LOCK_TABLE),
      { tonumber(organizationId), transitionId }
    )
    acquired[#acquired + 1] = tonumber(organizationId)
  end

  return true
end

local function collectOrganizationIds(territories)
  local values = {}
  local seen = {}

  local function add(value)
    value = positiveId(value)
    if value and not seen[value] then
      seen[value] = true
      values[#values + 1] = value
    end
  end

  for _, territory in ipairs(type(territories) == 'table' and territories or {}) do
    add(territory.fixedOrganizationId)
    add(territory.captorOrganizationId)
  end

  table.sort(values)
  return values
end

function Contract:PrepareMode(payload)
  local organizationIds = collectOrganizationIds((payload.plan or {}).territories)
  local snapshot = {
    organizations = {},
    skippedOrganizations = {}
  }

  for _, organizationId in ipairs(organizationIds) do
    local group = groupById(organizationId)
    if group then
      local chest, chestReason = self:ResolveChest(group)
      if chestReason and chestReason ~= 'organization_chest_not_found' then
        return nil, chestReason
      end

      local previousState = self:GetChestState(organizationId)
      snapshot.organizations[#snapshot.organizations + 1] = {
        organizationId = organizationId,
        ownerId = tonumber(group.ownerId),
        name = group.name,
        previousState = previousState.state,
        chestId = chest and tonumber(chest.id) or nil,
        coordinates = chest and copy(chest.coordinates or {}) or {}
      }
    else
      snapshot.skippedOrganizations[#snapshot.skippedOrganizations + 1] = organizationId
    end
  end

  local locked, reason = self:AcquireLocks(payload.transitionId, organizationIds)
  if not locked then
    return nil, reason
  end

  local collectedEntries = {}
  for _, entry in ipairs(snapshot.organizations) do
    if entry.chestId then
      local didCollect, collectReason = inventoryExport(
        'updateChestCoordinates',
        tonumber(entry.chestId),
        {},
        true
      )
      if not didCollect then
        for _, restored in ipairs(collectedEntries) do
          inventoryExport(
            'updateChestCoordinates',
            tonumber(restored.chestId),
            copy(restored.coordinates or {}),
            true
          )
          self:SetChestState(
            restored.organizationId,
            restored.chestId,
            restored.previousState or 'placed',
            nil
          )
        end
        return nil, collectReason or 'organization_chest_collect_failed'
      end
      collectedEntries[#collectedEntries + 1] = entry
      self:SetChestState(
        entry.organizationId,
        entry.chestId,
        'pending_placement',
        payload.transitionId
      )
    end
  end

  return snapshot
end

local function resultActorKind(payload)
  local plan = payload.plan or {}
  local snapshot = plan.snapshot or payload.snapshot or {}
  local result = snapshot.result or {}
  local winner = result.winner or {}
  return winner.actorKind
end

function Contract:PrepareControl(payload)
  local plan = payload.plan or {}
  local territory = plan.territory
  if type(territory) ~= 'table' or not territory.id then
    return nil, 'territory_required'
  end

  local previous = payload.previous or {}
  local nextOwner = payload.next or {}
  local policeControl = resultActorKind(payload) == 'police_department'
    or nextOwner.controlState == 'pacified'

  local previousOrganizationId = positiveId(previous.organizationId)
  local nextOrganizationId = positiveId(nextOwner.organizationId)

  if not policeControl and nextOrganizationId then
    if not groupById(nextOrganizationId) then
      return nil, 'organization_not_found'
    end
  end

  local organizationIds = {}
  if previousOrganizationId then
    organizationIds[#organizationIds + 1] = previousOrganizationId
  end
  if nextOrganizationId
    and not sameId(previousOrganizationId, nextOrganizationId)
  then
    organizationIds[#organizationIds + 1] = nextOrganizationId
  end

  local locked, reason = self:AcquireLocks(payload.transitionId, organizationIds)
  if not locked then
    return nil, reason
  end

  local previousRow = query(
    ('SELECT * FROM `%s` WHERE `territory_id` = ? LIMIT 1;'):format(OWNERSHIP_TABLE),
    { tostring(territory.id) }
  )[1]

  return {
    territory = {
      id = tostring(territory.id),
      previous = previousRow and {
        organizationId = tonumber(previousRow.organization_id),
        teamId = previousRow.team_id,
        controlState = previousRow.control_state,
        transitionId = previousRow.transition_id
      } or nil,
      next = {
        organizationId = policeControl and nil or nextOrganizationId,
        teamId = nextOwner.teamId and tostring(nextOwner.teamId) or nil,
        controlState = tostring(nextOwner.controlState or 'faction')
      }
    }
  }
end

function Contract:Prepare(payload)
  self:EnsureTables()
  local transitionId = tostring(payload.transitionId or '')
  if transitionId == '' then
    return { ok = false, reason = 'transition_id_required' }
  end

  local existing = self:GetRecord(transitionId)
  if existing then
    local organizationIds = {}
    for _, entry in ipairs(existing.snapshot.organizations or {}) do
      local organizationId = positiveId(entry.organizationId)
      if organizationId then
        organizationIds[#organizationIds + 1] = organizationId
      end
    end
    local territory = existing.snapshot.territory
    if territory then
      local previousOrganizationId = territory.previous
        and positiveId(territory.previous.organizationId)
      local nextOrganizationId = territory.next
        and positiveId(territory.next.organizationId)
      if previousOrganizationId then
        organizationIds[#organizationIds + 1] = previousOrganizationId
      end
      if nextOrganizationId then
        organizationIds[#organizationIds + 1] = nextOrganizationId
      end
    end
    local locked, lockReason = self:AcquireLocks(transitionId, organizationIds)
    if not locked then
      return { ok = false, reason = lockReason }
    end
    return { ok = true, state = existing.state }
  end

  local operationKind = payload.operation == 'territory_control'
    and 'territory_control'
    or 'mode_transition'
  local snapshot, reason
  if operationKind == 'territory_control' then
    snapshot, reason = self:PrepareControl(payload)
  else
    snapshot, reason = self:PrepareMode(payload)
  end

  if not snapshot then
    query(
      ('DELETE FROM `%s` WHERE `transition_id` = ?;'):format(LOCK_TABLE),
      { transitionId }
    )
    return { ok = false, reason = reason or 'snapshot_failed' }
  end

  self:SaveRecord(transitionId, operationKind, 'PREPARED', snapshot, false)
  return { ok = true, state = 'PREPARED' }
end

function Contract:ApplyControl(transitionId, snapshot)
  local territory = snapshot.territory
  if not territory then
    return false, 'territory_snapshot_missing'
  end

  query(([=[
    INSERT INTO `%s`
      (`territory_id`, `organization_id`, `team_id`, `control_state`, `transition_id`)
    VALUES (?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      `organization_id` = VALUES(`organization_id`),
      `team_id` = VALUES(`team_id`),
      `control_state` = VALUES(`control_state`),
      `transition_id` = VALUES(`transition_id`);
  ]=]):format(OWNERSHIP_TABLE), {
    territory.id,
    territory.next.organizationId,
    territory.next.teamId,
    territory.next.controlState,
    transitionId
  })

  local row = query(
    ('SELECT * FROM `%s` WHERE `territory_id` = ? LIMIT 1;'):format(OWNERSHIP_TABLE),
    { territory.id }
  )[1]
  return row
    and sameNullableId(row.organization_id, territory.next.organizationId)
    and sameId(row.team_id, territory.next.teamId)
    and row.control_state == territory.next.controlState,
    'territory_ownership_update_unconfirmed'
end

function Contract:Apply(payload)
  local transitionId = tostring(payload.transitionId or '')
  local record = self:GetRecord(transitionId)
  if not record then
    return { ok = false, reason = 'contract_not_prepared' }
  end
  if record.state == 'APPLIED' or tonumber(record.committed) == 1 then
    return { ok = true, state = record.state }
  end

  if record.operation_kind == 'territory_control' then
    local applied, reason = self:ApplyControl(transitionId, record.snapshot)
    if not applied then
      return { ok = false, reason = reason }
    end
  end

  self:SaveRecord(transitionId, record.operation_kind, 'APPLIED', record.snapshot, false)
  return { ok = true, state = 'APPLIED' }
end

function Contract:RestoreMode(record)
  for _, entry in ipairs(record.snapshot.organizations or {}) do
    if entry.chestId then
      local restored = inventoryExport(
        'updateChestCoordinates',
        tonumber(entry.chestId),
        copy(entry.coordinates or {}),
        true
      )
      if not restored then
        return false, 'organization_chest_restore_failed'
      end
      self:SetChestState(
        entry.organizationId,
        entry.chestId,
        entry.previousState or 'placed',
        nil
      )
    end
  end

  return true
end

function Contract:RestoreControl(record)
  local territory = record.snapshot.territory
  local previous = territory and territory.previous
  if not territory then
    return false, 'territory_snapshot_missing'
  end

  if previous then
    query(([=[
      INSERT INTO `%s`
        (`territory_id`, `organization_id`, `team_id`, `control_state`, `transition_id`)
      VALUES (?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        `organization_id` = VALUES(`organization_id`),
        `team_id` = VALUES(`team_id`),
        `control_state` = VALUES(`control_state`),
        `transition_id` = VALUES(`transition_id`);
    ]=]):format(OWNERSHIP_TABLE), {
      territory.id,
      previous.organizationId,
      previous.teamId,
      previous.controlState,
      previous.transitionId or record.transition_id
    })
  else
    query(
      ('DELETE FROM `%s` WHERE `territory_id` = ?;'):format(OWNERSHIP_TABLE),
      { territory.id }
    )
  end

  return true
end

function Contract:Rollback(payload)
  local transitionId = tostring(payload.transitionId or '')
  local record = self:GetRecord(transitionId)
  if not record then
    return { ok = true, state = 'NOT_PREPARED' }
  end
  if tonumber(record.committed) == 1 then
    return { ok = false, reason = 'contract_already_committed' }
  end

  local restored, reason
  if record.operation_kind == 'territory_control' then
    restored, reason = self:RestoreControl(record)
  else
    restored, reason = self:RestoreMode(record)
  end
  if not restored then
    return { ok = false, reason = reason }
  end

  self:SaveRecord(transitionId, record.operation_kind, 'ROLLED_BACK', record.snapshot, false)
  return { ok = true, state = 'ROLLED_BACK' }
end

function Contract:NotifyPlacement(entry)
  local playerSource = vRP.Source(tonumber(entry.ownerId))
  if playerSource then
    TriggerClientEvent(
      'Notify',
      playerSource,
      'warning',
      'O bau da sua organizacao foi recolhido. Posicione-o novamente no painel da organizacao.',
      15000
    )
  end
end

function Contract:Commit(payload)
  local transitionId = tostring(payload.transitionId or '')
  local record = self:GetRecord(transitionId)
  if not record then
    return { ok = false, reason = 'contract_not_prepared' }
  end
  if tonumber(record.committed) == 1 then
    return { ok = true, state = 'COMMITTED' }
  end

  if record.operation_kind == 'mode_transition' then
    for _, entry in ipairs(record.snapshot.organizations or {}) do
      if entry.chestId then
        local chest = inventoryExport('getChestById', tonumber(entry.chestId))
        if not chest or #(chest.coordinates or {}) > 0 then
          return { ok = false, reason = 'organization_chest_collect_unconfirmed' }
        end
        self:SetChestState(
          entry.organizationId,
          entry.chestId,
          'pending_placement',
          transitionId
        )
        self:NotifyPlacement(entry)
      end
    end
  else
    local applied, reason = self:ApplyControl(transitionId, record.snapshot)
    if not applied then
      return { ok = false, reason = reason }
    end
  end

  self:SaveRecord(transitionId, record.operation_kind, 'COMMITTED', record.snapshot, true)
  return { ok = true, state = 'COMMITTED' }
end

function Contract:Release(payload)
  local transitionId = tostring(payload.transitionId or '')
  local record = self:GetRecord(transitionId)

  query(
    ('DELETE FROM `%s` WHERE `transition_id` = ?;'):format(LOCK_TABLE),
    { transitionId }
  )

  if record then
    self:SaveRecord(
      transitionId,
      record.operation_kind,
      'RELEASED',
      record.snapshot,
      tonumber(record.committed) == 1
    )
  end

  return { ok = true, state = 'RELEASED' }
end

function Contract:MarkChestPlaced(organizationId, chestId)
  self:EnsureTables()
  self:SetChestState(organizationId, chestId, 'placed', nil)
  return true
end

function Contract:CanDeleteOrganization(organizationId)
  self:EnsureTables()
  organizationId = tonumber(organizationId)
  if not organizationId then
    return false, 'organization_id_required'
  end

  if GetResourceState('fta-baques') == 'started' then
    local ok, canDelete, baquesReason = pcall(function()
      return exports['fta-baques']:CanDeleteOrganization(organizationId)
    end)
    if not ok then
      return false, 'fta_baques_contract_unavailable'
    end
    if canDelete ~= true then
      return false, baquesReason or 'organization_used_by_fta_baques'
    end
  end

  local locked = query(
    ('SELECT 1 FROM `%s` WHERE `organization_id` = ? LIMIT 1;'):format(LOCK_TABLE),
    { organizationId }
  )[1]
  if locked then
    return false, 'organization_has_pending_migration'
  end

  local territory = query(
    ('SELECT 1 FROM `%s` WHERE `organization_id` = ? LIMIT 1;'):format(OWNERSHIP_TABLE),
    { organizationId }
  )[1]
  if territory then
    return false, 'organization_controls_territory'
  end

  local chestState = self:GetChestState(organizationId)
  if chestState.state == 'pending_placement' then
    return false, 'organization_chest_pending_placement'
  end

  return true
end

_G.FtaBaquesTeamsContract = Contract

exports('GetFtaBaquesCapabilities', function()
  Contract:EnsureTables()
  return {
    version = CONTRACT_VERSION,
    contracts = {
      organizationChestPlacement = true,
      organizationChest = true,
      territoryOwnership = true
    }
  }
end)

exports('HandleFtaBaquesTransition', function(action, payload)
  payload = type(payload) == 'table' and payload or {}
  if tonumber(payload.contractVersion) ~= CONTRACT_VERSION then
    return { ok = false, reason = 'unsupported_contract_version' }
  end

  local handlers = {
    prepare = 'Prepare',
    apply = 'Apply',
    rollback = 'Rollback',
    commit = 'Commit',
    release = 'Release'
  }
  local handler = handlers[tostring(action or '')]
  if not handler then
    return { ok = false, reason = 'unsupported_contract_action' }
  end

  local ok, response = xpcall(function()
    return Contract[handler](Contract, payload)
  end, debug.traceback)
  if not ok then
    print(('[fta-teams] FTA Baques contract failed: %s'):format(tostring(response)))
    return { ok = false, reason = 'contract_internal_error' }
  end

  return response
end)

exports('getOrganizationChestPlacement', function(organizationId)
  return Contract:GetChestState(organizationId)
end)

exports('markOrganizationChestPlaced', function(organizationId, chestId)
  return Contract:MarkChestPlaced(organizationId, chestId)
end)

exports('canDeleteOrganizationForFtaBaques', function(organizationId)
  return Contract:CanDeleteOrganization(organizationId)
end)
