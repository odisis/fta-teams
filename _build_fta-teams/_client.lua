local BUILDER = { modules = {} }

function BUILDER.create(name, func)
    BUILDER.modules[name] = { load = func }
end

function BUILDER.import(_name)
    local name = tostring(_name)
    local mod = BUILDER.modules[name]
    assert(mod, 'Module '..name..' not found')
    
    if not mod.resolved then
        mod.resolved = { mod.load() }
    end

    return table.unpack(mod.resolved)
end

_G.import = BUILDER.import

BUILDER.create("utils/utils", function()
    SERVER = IsDuplicityVersion()
    CLIENT = not SERVER
    
    function table.maxn(tbl)
    	local maxValue = 0
    
    	for key, value in pairs(tbl) do
    		local numericKey = tonumber(key)
    
    		if numericKey and numericKey > maxValue then 
    			maxValue = numericKey 
    		end
    	end
    
    	return maxValue
    end
    
    function table:equals(comparisonTable)
    	if self == comparisonTable then 
    		return true 
    	end
    
    	local typeSelf = type(self)
    	local typeComparison = type(comparisonTable)
    	
    	if typeSelf ~= typeComparison then 
    		return false 
    	end
    
    	if typeSelf ~= 'table' then 
    		return false 
    	end
    
    	local keysChecked = {}
    
    	for key1, value1 in pairs(self) do
    		local value2 = comparisonTable[key1]
    		
    		if value2 == nil or not table.equals(value1, value2) then
    			return false
    		end
    
    		keysChecked[key1] = true
    	end
    
    	for key2, _ in pairs(comparisonTable) do
    		if not keysChecked[key2] then 
    			return false 
    		end
    	end
    
    	return true
    end
    
    local loadedModules = {}
    
    function require(resource, path)
    	if path == nil then
    		path = resource
    		resource = GetCurrentResourceName()
    	end
    
    	local moduleKey = resource .. path
    	local module = loadedModules[moduleKey]
    
    	if module then
    		return module
    	else
    		local code = LoadResourceFile(resource, path .. '.lua')
    		
    		if code then
    			local loadedFunction, errorMsg = load(code, resource .. '/' .. path .. '.lua')
    			
    			if loadedFunction then
    				local success, result = xpcall(loadedFunction, debug.traceback)
    				
    				if success then
    					loadedModules[moduleKey] = result
    
    					return result
    				else
    					error('Error loading module ' .. resource .. '/' .. path .. ': ' .. result)
    				end
    			else
    				error('Error parsing module ' .. resource .. '/' .. path .. ': ' .. debug.traceback(errorMsg))
    			end
    		else
    			error('Resource file ' .. resource .. '/' .. path .. '.lua not found')
    		end
    	end
    end
    
    local function wait(asyncObj)
    	local result = Citizen.Await(asyncObj.p)
    
    	if not result then
    		result = asyncObj.r 
    	end
    
    	return table.unpack(result, 1, table.maxn(result))
    end
    
    local function areturn(asyncObj, ...)
    	asyncObj.r = {...}
    	asyncObj.p:resolve(asyncObj.r)
    end
    
    function async(func)
    	if func then
    		Citizen.CreateThreadNow(func)
    	else
    		return setmetatable(
    			{ 
    				wait = wait, 
    				p = promise.new() 
    			}, 
    			{ 
    				__call = areturn 
    			}
    		)
    	end
    end
    
    function parseInt(value)
    	local number = tonumber(value)
    
    	return number and math.floor(number) or 0
    end
    
    function parseDouble(value)
    	local number = tonumber(value)
    
    	return number or 0
    end
    
    function parseFloat(value)
    	return parseDouble(value)
    end
    
    local sanitizeCache = {}
    
    function sanitizeString(str, allowedChars, allowPolicy)
    	local result = ''
    	local chars = sanitizeCache[allowedChars]
    	
    	if chars == nil then
    		chars = {}
    		
    		local len = string.len(allowedChars)
    
    		for i = 1, len do
    			local char = string.sub(allowedChars, i, i)
    
    			chars[char] = true
    		end
    
    		sanitizeCache[allowedChars] = chars
    	end
    
    	len = string.len(str)
    
    	for i = 1, len do
    		local char = string.sub(str, i, i)
    
    		if (allowPolicy and chars[char]) or (not allowPolicy and not chars[char]) then
    			result = result .. char
    		end
    	end
    	
    	return result
    end
    
    function splitString(str, sep)
    	sep = sep or '%s'
    
    	local resultTable = {}
    	local index = 1
    
    	for part in string.gmatch(str, '([^' .. sep .. ']+)') do
    		resultTable[index] = part
    		index = index + 1
    	end
    
    	return resultTable
    end
    
    function joinStrings(list, sep)
    	sep = sep or ''
    
    	local str = ''
    	local count = 0
    	local size = #list
    
    	for _, value in pairs(list) do
    		count = count + 1
    		str = str .. value
    
    		if count < size then 
    			str = str .. sep 
    		end
    	end
    
    	return str
    end
    
    function table:length()
    	local count = 0
    
    	for _, _ in pairs(self) do
    		count = count + 1
    	end
    
    	return count
    end
    
    function table:copy()
    	local copy = {}
    
    	for key, value in pairs(self) do
    		if type(value) == 'table' then
    			copy[key] = table.copy(value)
    		else
    			copy[key] = value
    		end
    	end
    
    	return copy
    end
    
    function table:includes(searchedValue)
    	for _, value in pairs(self) do
    		if searchedValue == value then 
    			return true 
    		end
    	end
    
    	return false
    end
    
    function table:array()
    	local array = {}
    
    	for _, value in pairs(self) do
    		table.insert(array, value)
    	end
    
    	return array
    end
    
    function table:entries()
    	local entries = {}
    
    	for key, value in pairs(self) do 
    		table.insert(entries, {key, value})
    	end 
    
    	return entries
    end 
    
    function table:fromEntries()
    	local result = {}
    
    	for _, entry in ipairs(self) do 
    		result[entry[1]] = entry[2]
    	end 
    
    	return result
    end 
    
    function table:filter(schema)
    	if schema == true then 
    		return table.copy(self)
    	end 
    
    	local result = {}
    
    	for key, value in pairs(schema) do 
    		local valueType1, valueType2 = type(value), type(self[key])
    
    		if (valueType1 == 'table' or valueType1:find('vector')) and (valueType2 == 'table' or valueType2:find('vector')) then
    			result[key] = table.filter(self[key], value)
    		else 
    			result[key] = self[key]
    		end 
    	end 
    
    	return result 			
    end
    
    function table:resolve(value, schema)
    	if type(schema) == 'table' then 
    		for key, value in pairs(schema) do 
    			local valueType1, valueType2 = type(value), type(self[key])
    
    			if value ~= nil then 
    				if valueType1 == 'table' then 
    					if valueType2 ~= 'table' then 
    						self[key] = {}
    					end 
    
    					self[key] = table.resolve(self[key], value[key], value)
    				else
    					if valueType2:find('vector') then 
    						if value[key] then 
    							if not self[key].z and not value[key].z then 
    								self[key] = vector2(value[key].x or self[key].x, value[key].y or self[key].y)
    							elseif valueType2 == 'vector3' then 
    								self[key] = vector3(value[key].x or self[key].x, value[key].y or self[key].y, value[key].z or self[key].z)
    							end 
    						else 
    							self[key] = value[key]
    						end 
    					else
    						self[key] = value[key]
    					end
    				end 
    			end 
    		end 
    	else 
    		return value
    	end 
    
    	return self
    end 
    
    function table:subtract(subtractionTable)
    	local schema = {}
    
    	for key, value in pairs(self) do 
    		local valueType1, valueType2 = type(value), type(subtractionTable[key])
    
    		if valueType1 ~= 'function' then 
    			if valueType1 == 'table' and valueType2 == 'table' then 
    				schema[key] = table.subtract(value, subtractionTable[key])
    			else 
    				if valueType1 ~= valueType2 or value ~= subtractionTable[key] then 
    					schema[key] = true
    				end 
    			end
    		end 
    	end 
    
    	for key, value in pairs(subtractionTable) do 
    		if self[key] == nil and value ~= nil then 
    			schema[key] = true
    		end 
    	end 
    
    	local selfLength = table.len(self)
    	local schemaLength = table.len(schema)
    	local subtractionTableLength = table.len(subtractionTable)
    
    	if selfLength == 0 and subtractionTableLength == 0 then 
    		return nil 
    	end 
    
    	if selfLength == schemaLength or subtractionTableLength == schemaLength then 
    		return true
    	end 
    
    	return (not table.equals(schema, {}) and schema) or nil
    end 
    
    function format(number)
        number = parseInt(number)
    
        local left, num, right = string.match(number, '^([^%d]*%d)(%d*)(.-)$')
    
    	return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
    end
    
    function f(number)
    	return number / 1
    end
    
    function positive(number)
        if number < 0 then
            return number * -1
        end
    
        return number
    end
    
    function parsePart(key)
    	if type(key) == 'string' and string.sub(key, 1, 1) == 'p' then
    		return true, tonumber(string.sub(key, 2))
    	else
    		return false, tonumber(key)
    	end
    end
    
    function generateRelativeCoords(radius) 
    	local x = math.random() * (radius / math.sqrt(2))
    	local y = math.random() * (radius / math.sqrt(2))
    
    	if math.random() > 0.5 then 
    		x = -x 
    	end 
    
    	if math.random() > 0.5 then 
    		y = -y 
    	end 
    
    	return vector3(x, y, 0.1)
    end
    
    function string:replace(replacements)
    	for key, value in pairs(replacements) do 
    		self = self:gsub('{{' .. key .. '}}', value)
    	end
    
    	return self
    end
    
    module = require
end)
BUILDER.import("utils/utils")

BUILDER.create("utils/Tools", function()
    Tools = {}
    
    local IDGenerator = {}
    
    function Tools.newIDGenerator()
    	local generatorInstance = setmetatable({}, { __index = IDGenerator })
    	
    	generatorInstance:construct()
    
    	return generatorInstance
    end
    
    function IDGenerator:construct()
    	self:clear()
    end
    
    function IDGenerator:clear()
    	self.max = 0
    	self.ids = {}
    end
    
    function IDGenerator:gen()
    	if #self.ids > 0 then
    		return table.remove(self.ids)
    	else
    		local newId = self.max
    
    		self.max = self.max + 1
    
    		return newId
    	end
    end
    
    function IDGenerator:free(id)
    	table.insert(self.ids, id)
    end
end)
BUILDER.import("utils/Tools")

BUILDER.create("utils/Proxy", function()
    Proxy = {}
    
    local callbackStore = setmetatable({}, { __mode = 'v' })
    
    local function proxyResolve(interfaceTable, key)
    	local metaTable = getmetatable(interfaceTable)
    	local interfaceName = metaTable.name
    	local idGenerator = metaTable.idGenerator
    	local callbackStore = metaTable.callbackStore
    	local identifier = metaTable.identifier
    
    	local functionName = key
    	local noWait = false
    
    	if string.sub(key, 1, 1) == '_' then
    		functionName = string.sub(key, 2)
    		noWait = true
    	end
    
    	local functionCall = function(...)
    		local requestId, asyncResult
    		local asyncProfile
    
    		if noWait then
    			requestId = -1
    		else
    			asyncResult = async()
    			requestId = idGenerator:gen()
    			callbackStore[requestId] = asyncResult
    		end
    
    		local args = { ... }
    
    		TriggerEvent(interfaceName .. ':proxy', functionName, args, identifier, requestId)
        
    		if not noWait then
    			return asyncResult:wait()
    		end
    	end
    
    	interfaceTable[key] = functionCall
    
    	return functionCall
    end
    
    function Proxy.addInterface(interfaceName, interfaceTable)
    	AddEventHandler(interfaceName .. ':proxy', function(member, args, identifier, requestId)
    		local func = interfaceTable[member]
    		local returnValues = {}
    
    		if type(func) == 'function' then
    			returnValues = { func(table.unpack(args, 1, table.maxn(args))) }
    		end
    
    		if requestId >= 0 then
    			TriggerEvent(interfaceName .. ':' .. identifier .. ':proxy_res', requestId, returnValues)
    		end
    	end)
    end
    
    function Proxy.getInterface(interfaceName, identifier)
    	if not identifier then
    		identifier = GetCurrentResourceName()
    	end
    
    	local idGenerator = Tools.newIDGenerator()
    	local callbackStore = {}
    	local interface = setmetatable({}, {
    		__index = proxyResolve,
    		name = interfaceName,
    		idGenerator = idGenerator,
    		callbackStore = callbackStore,
    		identifier = identifier
    	})
    
    	AddEventHandler(interfaceName .. ':' .. identifier .. ':proxy_res', function(requestId, returnValues)
    		local callback = callbackStore[requestId]
    
    		if callback then
    			idGenerator:free(requestId)
    			callbackStore[requestId] = nil
    			callback(table.unpack(returnValues, 1, table.maxn(returnValues)))
    		end
    	end)
    
    	return interface
    end
end)
BUILDER.import("utils/Proxy")

BUILDER.create("utils/Tunnel", function()
    local TriggerRemoteEvent = nil
    local RegisterLocalEvent = nil
    
    if SERVER then
    	TriggerRemoteEvent = TriggerClientEvent
    	RegisterLocalEvent = RegisterServerEvent
    else
    	TriggerRemoteEvent = TriggerServerEvent
    	RegisterLocalEvent = RegisterNetEvent
    end
    
    Tunnel = {}
    Tunnel.delays = {}
    
    function Tunnel.setDestDelay(destination, delay)
    	Tunnel.delays[destination] = { delay, 0 }
    end
    
    local function tunnelResolve(interfaceTable, key)
    	local metaTable = getmetatable(interfaceTable)
    	local interfaceName = metaTable.name
    	local idGenerator = metaTable.tunnelIds
    	local callbackStore = metaTable.tunnelCallbacks
    	local identifier = metaTable.identifier
    	local functionName = key
    	local noWait = false
    
    	if string.sub(key, 1, 1) == '_' then
    		functionName = string.sub(key, 2)
    		noWait = true
    	end
    
    	local functionCall = function(...)
    		local asyncResult = nil
    		local args = { ... }
    		local destination = nil
    
    		if SERVER then
    			destination = args[1]
    			args = { table.unpack(args, 2, table.maxn(args)) }
    
    			if destination >= 0 and not noWait then
    				asyncResult = async()
    			end
    		elseif not noWait then
    			asyncResult = async()
    		end
    
    		local delayData = Tunnel.delays[destination] or { 0, 0 }
    		local additionalDelay = delayData[1]
    		
    		delayData[2] = delayData[2] + additionalDelay
    
    		local function triggerTunnelRequest()
    			delayData[2] = delayData[2] - additionalDelay
    			local requestId = -1
    
    			if asyncResult then
    				requestId = idGenerator:gen()
    				callbackStore[requestId] = asyncResult
    			end
    
    			if SERVER then
    				TriggerRemoteEvent(interfaceName .. ':tunnel_req', destination, functionName, args, identifier, requestId)
    			else
    				TriggerRemoteEvent(interfaceName .. ':tunnel_req', functionName, args, identifier, requestId)
    			end
    		end
    
    		if delayData[2] > 0 then
    			SetTimeout(delayData[2], triggerTunnelRequest)
    		else
    			triggerTunnelRequest()
    		end
    
    		if asyncResult then
    			return asyncResult:wait()
    		end
    	end
    
    	interfaceTable[key] = functionCall
    
    	return functionCall
    end
    
    function Tunnel.bindInterface(interfaceName, interfaceTable)
    	RegisterLocalEvent(interfaceName .. ':tunnel_req')
    	AddEventHandler(interfaceName .. ':tunnel_req', function(methodName, args, identifier, requestId)
    		local sourcePlayer = source
    		local method = interfaceTable[methodName]
    		local returnValues = {}
    
    		if type(method) == 'function' then
    			returnValues = { method(table.unpack(args, 1, table.maxn(args))) }
    		end
    
    		if requestId >= 0 then
    			if SERVER then
    				TriggerRemoteEvent(interfaceName .. ':' .. identifier .. ':tunnel_res', sourcePlayer, requestId, returnValues)
    			else
    				TriggerRemoteEvent(interfaceName .. ':' .. identifier .. ':tunnel_res', requestId, returnValues)
    			end
    		end
    	end)
    end
    
    function Tunnel.getInterface(interfaceName, identifier)
    	if not identifier then
    		identifier = GetCurrentResourceName()
    	end
    
    	local idGenerator = Tools.newIDGenerator()
    	local callbackStore = {}
    	local interface = setmetatable({}, {
    		__index = tunnelResolve,
    		name = interfaceName,
    		tunnelIds = idGenerator,
    		tunnelCallbacks = callbackStore,
    		identifier = identifier
    	})
    
    	RegisterLocalEvent(interfaceName .. ':' .. identifier .. ':tunnel_res')
    	AddEventHandler(interfaceName .. ':' .. identifier .. ':tunnel_res', function(requestId, returnValues)
    		local callback = callbackStore[requestId]
    
    		if callback then
    			idGenerator:free(requestId)
    			callbackStore[requestId] = nil
    			callback(table.unpack(returnValues, 1, table.maxn(returnValues)))
    		end
    	end)
    
    	return interface
    end
end)
BUILDER.import("utils/Tunnel")

BUILDER.create("client/main", function()
    vRP = Proxy.getInterface('vRP')
    
    api = {}
    Tunnel.bindInterface(GetCurrentResourceName(), api)
    
    apiServer = Tunnel.getInterface(GetCurrentResourceName())
    
    _G.SHARED_CONFIG = require('config/shared/general')
    _G.CONFIG_TEAMS = require('config/shared/teams')
    
    if not LPH_OBFUSCATED then
      LPH_NO_VIRTUALIZE = function(...) 
        return ... 
      end
    end
    
    _G.NUI = {
      groupId = nil,
      profileImage = ''
    }
    
    CreateThread(function()
      Wait(1000)
    
      TriggerServerEvent('fta-teams:setupItems')
    end)
end)
BUILDER.import("client/main")

BUILDER.create("client/dev", function()
    if not SHARED_CONFIG.DEV_MODE then
        return
    end
    
    RegisterCommand('clua', function(source, args, _)
        local chunk = table.concat(args, ' ')
        load(chunk)()
    end)
end)
BUILDER.import("client/dev")

BUILDER.create("client/modules/items", function()
    _G.Items = {
      vehicles = {},
      items = {},
      permissions = {}
    }
    
    function Items:SetupVehicles(vehicles)
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
end)
BUILDER.import("client/modules/items")

BUILDER.create("client/modules/group", function()
    RegisterCommand('paineleqp', function()
      local groupId = apiServer.isPlayerInGroup()
    
      if groupId then 
        NUI:OpenGroup(groupId)
      end
    end)
end)
BUILDER.import("client/modules/group")

BUILDER.create("client/web/utils", function()
    function NUI:HidePainel()
      self.groupId = nil
      SetNuiFocus(false, false)
    end
    
    RegisterNUICallback('closePainel', function (data, cb)
      NUI:HidePainel()
      
      cb()
    end)
end)
BUILDER.import("client/web/utils")

BUILDER.create("client/web/group", function()
    function NUI:OpenGroup(groupId)
      local playerPermissions = apiServer.getPlayerRolePermissions(groupId)
    
      if not playerPermissions then
        return
      end
    
      local groupData = apiServer.getGroups(groupId)
    
      if not groupData then 
        return
      end
      
      local teamData = CONFIG_TEAMS.TEAMS[groupData.team]
      local rolesList = {}
    
      self.groupId = groupId
    
      for _, ROLE in pairs(groupData.roles) do 
        table.insert(rolesList, {
          id = ROLE.id,
          name = ROLE.name,
          permissions = ROLE.permissions,
          canDelete = ROLE.canDelete
        })
      end
    
      SetNuiFocus(true, true)
      SendNUIMessage({
        action = 'openGroup',
        data = {
          name = groupId,
          permissions = playerPermissions,
          faction = {
            name = teamData.NAME,
            color = teamData.COLOR
          },
          bannerURL = teamData.BANNER_URL,
          logoURL = groupData.logoURL,
          rolesList = rolesList,
        }
      })
    end
    
    function NUI:HideGroup()
      self:HidePainel()
    
      SendNUIMessage({
        action = 'closeGroup'
      })
    end
    
    RegisterNUICallback('getGroupMembers', function(data, cb)
      local members = apiServer.getGroupMembers(NUI.groupId)
      
      cb({
        members = members
      })
    end)
    
    RegisterNUICallback('updateMemberRole', function(data, cb)
      local memberId, roleId = data.memberId, data.roleId
      local status = apiServer.updateMemberRole(NUI.groupId, memberId, roleId)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('kickMember', function(data, cb)
      local memberId = data.memberId
      local status = apiServer.kickMember(NUI.groupId, memberId)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('leaveGroup', function(data, cb)
      local memberId = data.memberId
      local status = apiServer.leaveMember(NUI.groupId, memberId)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('tryInviteMember', function(data, cb)
      local memberId = data.memberId
      local status = apiServer.tryInviteMember(NUI.groupId, memberId)
    
      cb({ status = status })
    end)
    
    
    RegisterNUICallback('getGroupBank', function(data, cb)
      local balance, transactions = apiServer.getGroupBank(NUI.groupId)
    
      cb({
        balance = balance,
        transactions = transactions
      })
    end)
    
    RegisterNUICallback('withdrawFromBank', function(data, cb)
      local amount = data.amount
      local status = apiServer.withdrawFromBank(NUI.groupId, amount)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('depositToBank', function(data, cb)
      local amount = data.amount
      local status = apiServer.depositToBank(NUI.groupId, amount)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('getRoles', function(data, cb)
      local roles = apiServer.getRoles(NUI.groupId)
      
      table.sort(roles, function(a, b)
          return a.id < b.id
      end)
    
      cb({
        roles = roles
      })
    end)
    
    RegisterNUICallback('createRole', function(data, cb)
      local name, icon, permissions = data.name, data.icon, data.permissions
      local status = apiServer.createRole(NUI.groupId, name, icon, permissions)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('deleteRole', function(data, cb)
      local roleId = data.id
      local status = apiServer.deleteRole(NUI.groupId, roleId)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('editRole', function(data, cb)
      local id, name, icon, permissions = data.id, data.name, data.icon, data.permissions
      local status = apiServer.editRole(NUI.groupId, id, name, icon, permissions)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('updateGroupLogo', function(data, cb)
      apiServer.editGroupLogo(NUI.groupId, data.logoURL)
      
      cb({ status = true })
    end)
    
    RegisterNUICallback('tryRescueRewards', function(data, cb)
      local status = apiServer.rankingTryRescue(NUI.groupId)
      cb({ success = status })
    end)
end)
BUILDER.import("client/web/group")

BUILDER.create("client/web/admin", function()
    function NUI:OpenAdmin(playerName)
      local playerImage = apiServer.getProfileImage()
    
      self.profileImage = playerImage
    
      SetNuiFocus(true, true)
    
      SendNUIMessage({
        action = 'openAdmin',
        data = {
          name = playerName,
          profile = self.profileImage
        }
      })
    end
    
    function NUI:HideAdmin()
      self:HidePainel()
    
      SendNUIMessage({
        action = 'closeAdmin',
        data = {}
      })  
    end
    
    function NUI:HideAdmin()
      self:HidePainel()
    
      SendNUIMessage({
        action = 'closeAdmin'
      })  
    end
    
    RegisterNUICallback('getTeams', function(data, cb)
      local teams = apiServer.getTeams()
    
      cb({
        teams = teams
      })
    end)
    
    RegisterNUICallback('createGroup', function(data, cb)
      local teamId, groupName, ownerId, permissions, membersLimit = data.teamId, data.groupName, data.ownerId, data.permissions, data.membersLimit
      local status = apiServer.createGroup(teamId, groupName, ownerId, permissions, membersLimit)
    
      cb({ status = true })
    end)
    
    
    RegisterNUICallback('editGroup', function(data, cb)
      local teamId, groupId, groupName, ownerId, permissions, membersLimit = data.teamId, data.id, data.groupName, data.ownerId, data.permissions, data.membersLimit
      local status = apiServer.updateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
      
      cb({ status = status })
    end)
    
    RegisterNUICallback('getGroups', function(data, cb)
      local groups = apiServer.getAvailableGroups()
      
      cb({
        groups = groups
      })
    end)
    
    RegisterNUICallback('deleteGroup', function(data, cb)
      local groupId = data.groupId
      local status = apiServer.deleteGroup(groupId)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('editGroup', function(data, cb)
      local groupId = data.groupId
      local status = apiServer.editGroup(groupId)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('getAdminItems', function(data, cb)
      local items = Items:GetItems()
      
      cb({
        items = items
      })
    end)
    
    RegisterNUICallback('getAdminVehicles', function(data, cb)
      local vehicles = Items:GetVehicles()
      
      cb({
        items = vehicles
      })
    end)
    
    RegisterNUICallback('getAdminPermissions', function(data, cb)
      local permissions = Items:GetPermissions()
    
      cb({
        items = permissions
      })
    end)
    
    RegisterNUICallback('assignRankingPrize', function(data, cb)
      local position = data.position
      local prizes = data.prizes
      
      local status = apiServer.updateRanking(position, prizes)
    
      cb({ status = status })
    end)
    
    RegisterNUICallback('getRescueRewards', function(data, cb)
      local timeToRescue, timeToExpired = apiServer.getRescueRewards()
    
      cb({ timeToRescue = timeToRescue, timeToExpired = timeToExpired })
    end)
    
    RegisterNUICallback('getGroupRanking', function(data, cb)
      local availableGroups = apiServer.getAvailableGroups()
      local rankings = {}
    
      for _, GROUP in ipairs(availableGroups) do 
        table.insert(rankings, {
          name = GROUP.name,
          contracts = GROUP.members,
          bannerURL = GROUP.team.bannerURL or 'https://media.discordapp.net/attachments/968335309731414106/1459340441269829683/image.png?ex=6962ec32&is=69619ab2&hm=a96d2b1122707c893fdafe3a18d1437186ea557ef7d3df0082bb61a2a9419571&=&format=webp&quality=lossless'
        })
      end
      
      cb({
        rankings = rankings
      })
    end)
    
    RegisterNUICallback('getRankingRewards', function(data, cb)
      local availableRewards = apiServer.getRankingRewards()
      local rewards = {}
      
      for _, REWARD in pairs(availableRewards) do 
        if REWARD then 
          table.insert(rewards, {
            position = REWARD.position,
            rewards = REWARD.rewards
          })
        end
      end
    
      cb({
        rewards = rewards
      })
    end)
    
    RegisterNUICallback('updateRewardTime', function(data, cb)
      local timestamp = data.timestamp
    
      local status = apiServer.updateRewardTime(tonumber(timestamp))
    
      cb({ status = status })
    end)
    
    RegisterCommand('adminpainel', function()
      local allowed = apiServer.hasAdminPermission()
    
      if allowed then 
        local playerName = apiServer.getPlayerName()
        NUI:OpenAdmin(playerName)
      end
    end)
end)
BUILDER.import("client/web/admin")