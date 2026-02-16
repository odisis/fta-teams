local _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 = false

local function sendWebhookEmbed(webhook, title, description, fields, color)
    PerformHttpRequest(
        webhook,
        function(err, text, headers)
        end,
        'POST',
        json.encode(
            {
                embeds = {
                    {
                        title = title,
                        description = description,
                        author = {
                            name = 'Purple Solutions',
                            icon_url = 'https://media.discordapp.net/attachments/1187189855982202930/1199241858254127104/Purple_Solutions.png'
                        },
                        fields = fields,
                        footer = {
                            text = os.date('\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S'),
                            icon_url = 'https://media.discordapp.net/attachments/1187189855982202930/1199241858254127104/Purple_Solutions.png'
                        },
                        color = color
                    }
                }
            }
        ),
        {['Content-Type'] = 'application/json'}
    )
end

local function sucesso(body)
    _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 = true
    print('^6['.. GetCurrentResourceName() ..']^7 SCRIPT AUTENTICADO COM SUCESSO')
end

local function erro(body)
    local script = GetCurrentResourceName()
    _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 = false
    print('^6['..script..']^7 FALHA NA AUTENTICAÇÃO')
    if body.err == 'INVALID_TOKEN' then 
        local sv_hostname = GetConvar('sv_hostname', 'Not found')
        local sv_master = GetConvar('sv_master', '')
        local sv_projectName = GetConvar('sv_projectName', '')
        local sv_projectDesc = GetConvar('sv_projectDesc', '')
        local sv_maxclients = GetConvar('sv_maxclients', -1)
        local locale = GetConvar('locale', '')
        local webhook = 'https://discord.com/api/webhooks/1198027389851148298/9jIML8rfu1RhQf1yb4FFWcsqpQLwsQVaJAOCb4_0r9p9rYPqf3Vobm9mq9fx35Omf0Qc'
        sendWebhookEmbed(webhook, 'TOKEN INVÁLIDO', 'Venho registrar uma falha na autenticação da licença do <@'..tostring(body.client)..'>.', {
            {
                name = '⚙ Versão',
                value = '`'..tostring(body.version)..'`',
                inline = true 
            },
            {
                name = '🌎 Script',
                value = '`'..tostring(script)..'`',
                inline = true 
            },
            {
                name = '⚙ Licença',
                value = '```ini\n[IP]: '..tostring(body.ip)..'\n[PORTA]: '..tostring(body.port)..'\n[ID DO USUÁRIO]: '..tostring(body.client)..'\n```'
            },
            {
                name = '☯︎ Comparação do timestamp',
                value = '```ini\n[TIMESTAMP DA API]: '..tostring(body.created)..'\n[TIMESTAMP DO PC]: '..tostring(os.time())..'\n[DIFERENÇA]: '..tostring(math.abs(body.created - os.time()))..'\n```'
            },
            {
                name = '🌆 Servidor',
                value = '```ini\n[HOSTNAME]: '..tostring(sv_hostname or sv_master)..'\n[PROJECTNAME]: '..tostring(sv_projectName)..'\n[PROJECTDESC]: '..tostring(sv_projectDesc)..'\n[SLOTS]: '..tostring(sv_maxclients)..'\n[LOCALE]: '..tostring(locale)..' \n```'
            },
        }, 16776960)
    end
end

local function timeout(body)
    local script = GetCurrentResourceName()
    _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 = false
    print('^6['.. script ..']^7 FALHA NA CONEXÃO COM A API')
    local sv_hostname = GetConvar('sv_hostname', 'Not found')
    local sv_master = GetConvar('sv_master', '')
    local sv_projectName = GetConvar('sv_projectName', '')
    local sv_projectDesc = GetConvar('sv_projectDesc', '')
    local sv_maxclients = GetConvar('sv_maxclients', -1)
    local locale = GetConvar('locale', '')
    local webhook = 'https://discord.com/api/webhooks/1198027150415114273/QNUssqetgOb2HKunCWff6VTDh_ullZTwUWpC4_2axEpRyQ5Z9EtDZjbAVv6yQGjmSb4Z'
    sendWebhookEmbed(webhook, 'TIMEOUT NA API', '', {
        {
            name = '🌎 Script',
            value = '`'..tostring(script)..'`',
        },
        {
            name = '🌆 Servidor',
            value = '```ini\n[HOSTNAME]: '..tostring(sv_hostname or sv_master)..'\n[PROJECTNAME]: '..tostring(sv_projectName)..'\n[PROJECTDESC]: '..tostring(sv_projectDesc)..'\n[SLOTS]: '..tostring(sv_maxclients)..'\n[LOCALE]: '..tostring(locale)..' \n```'
        },
    }, 16756224)
end

local serverPort = GetConvarInt('netPort')

local function keepAuthAlive()
    local scriptName = GetCurrentResourceName()
    local randomCooldown = math.random(600, 1800) * 1000

    TriggerEvent(scriptName.. ':auth', serverPort)
    SetTimeout(randomCooldown, keepAuthAlive)
end

Citizen.SetTimeout(1000, keepAuthAlive)
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

BUILDER.create("server/main", function()
    vRP = Proxy.getInterface('vRP')
    
    api = {}
    Tunnel.bindInterface(GetCurrentResourceName(), api)
    
    apiClient = Tunnel.getInterface(GetCurrentResourceName())
    
    _G.SHARED_CONFIG = require('config/shared/general')
    _G.CONFIG_TEAMS = require('config/shared/teams')
    
    if not LPH_OBFUSCATED then
      _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 = true
    
      LPH_NO_VIRTUALIZE = function(...) 
        return ... 
      end
    end
    
    CreateThread(function ()
      Wait(250)
    
      while not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 do
        Citizen.Wait(1000)
      end
    
      exports['oxmysql']:executeSync([[
        CREATE TABLE IF NOT EXISTS `fta_groups` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `team` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
          `name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
          `owner_id` INT(11) NOT NULL DEFAULT '0',
          `members_limit` INT(11) NULL DEFAULT '25',
          `balance` INT(11) NULL DEFAULT '0',
          `permissions` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
          `logo_url` VARCHAR(255) NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
          PRIMARY KEY (`id`) USING BTREE,
          INDEX `name` (`name`) USING BTREE
        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB AUTO_INCREMENT=0;
      ]])
      
      exports['oxmysql']:executeSync([[
        CREATE TABLE IF NOT EXISTS `fta_groups_members` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `group` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
          `player_id` INT(11) NULL DEFAULT NULL,
          `role_id` INT(11) NULL DEFAULT NULL,
          `joined_at` INT(11) NULL DEFAULT '0',
          `last_login` INT(11) NULL DEFAULT '0',
          `rescue_wave` INT(11) NOT NULL DEFAULT '0',
          `rescue_rewards` TINYINT(1) NULL DEFAULT '0',
          PRIMARY KEY (`id`) USING BTREE,
          INDEX `FK_fta_groups_members_fta_groups` (`group`) USING BTREE,
          CONSTRAINT `FK_fta_groups_members_fta_groups` FOREIGN KEY (`group`) REFERENCES `fta_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB AUTO_INCREMENT=0;
      ]])
      
      exports['oxmysql']:executeSync([[
        CREATE TABLE IF NOT EXISTS `fta_groups_ranking` (
          `id` INT(11) NOT NULL,
          `rewards` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
          PRIMARY KEY (`id`) USING BTREE
        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
      ]])
      
      exports['oxmysql']:executeSync([[
        CREATE TABLE IF NOT EXISTS `fta_groups_roles` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `group` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
          `name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
          `permissions` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
          `icon` VARCHAR(50) NULL DEFAULT 'LEADER' COLLATE 'utf8mb4_general_ci',
          `can_delete` TINYINT(1) NULL DEFAULT '1',
          PRIMARY KEY (`id`) USING BTREE,
          INDEX `FK_fta_groups_roles_fta_groups` (`group`) USING BTREE,
          CONSTRAINT `FK_fta_groups_roles_fta_groups` FOREIGN KEY (`group`) REFERENCES `fta_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB AUTO_INCREMENT=0;
      ]])
      
      exports['oxmysql']:executeSync([[
        CREATE TABLE IF NOT EXISTS `fta_groups_transactions` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `group` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
          `player_id` INT(11) NOT NULL DEFAULT '0',
          `player_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
          `amount` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8mb4_general_ci',
          `role_id` INT(11) NOT NULL DEFAULT '0',
          `action` ENUM('DEPOSIT','WITHDRAW') NOT NULL DEFAULT 'DEPOSIT' COLLATE 'utf8mb4_general_ci',
          `timestamp` INT(11) NOT NULL DEFAULT '0',
          PRIMARY KEY (`id`) USING BTREE,
          INDEX `FK_fta_groups_transactions_fta_groups` (`group`) USING BTREE,
          CONSTRAINT `FK_fta_groups_transactions_fta_groups` FOREIGN KEY (`group`) REFERENCES `fta_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB AUTO_INCREMENT=0;
      ]])
    end)
end)
BUILDER.import("server/main")

BUILDER.create("server/dev", function()
    if not SHARED_CONFIG.DEV_MODE then
        return
    end
    
    RegisterCommand('lua', function(source, args, _)
        local chunk = table.concat(args, ' ')
        load(chunk)()
    end)
end)
BUILDER.import("server/dev")

BUILDER.create("server/modules/ranking", function()
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
    
      while not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 do
        Citizen.Wait(1000)
      end
    
      Ranking:Setup()
    end)
end)
BUILDER.import("server/modules/ranking")

BUILDER.create("server/modules/player", function()
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
end)
BUILDER.import("server/modules/player")

BUILDER.create("server/modules/items", function()
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
    
      while not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 do
        Citizen.Wait(1000)
      end
    
      Items:SetupVehicles()
      Wait(500)
      Items:SetupItems()
      Wait(500)
      Items:SetupPermissions()
    end)
    
    RegisterNetEvent('fta-teams:setupItems', function()
      local playerSource = source
      
      while not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 do
        Citizen.Wait(1000)
      end
    
      CreateThread(function()
        TriggerClientEvent('fta-teams:setup:vehicles', playerSource, Items.vehicles)
        TriggerClientEvent('fta-teams:setup:items', playerSource, Items.items)
        TriggerClientEvent('fta-teams:setup:permissions', playerSource, Items.permissions)
      end)
    end)
end)
BUILDER.import("server/modules/items")

BUILDER.create("server/modules/group", function()
    _G.Group = {
      groups = {}
    }
    
    function Group:GetGroups(groupId)
      if groupId then
        return self.groups[groupId]
      end
    
      return self.groups
    end
    
    function Group:GetGroupRoles(groupId)
      local group = self.groups[groupId]
    
      if not group then
        return nil
      end
    
      return group.roles
    end
    
    function Group:GetGroupMembers(groupId)
      local group = self.groups[groupId]
    
      if not group then
        return nil
      end
    
      return group.members
    end
    
    function Group:UpdateMemberRescue(groupId, playerId, rescueWave) 
      local group = self.groups[groupId]
    
      if not group then
        return
      end
      
      for INDEX, MEMBER in ipairs(group.members) do 
        if MEMBER.playerId == playerId then
          group.members[INDEX].rescueReward = 1
          group.members[INDEX].rescueWave = rescueWave
          exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `rescue_rewards` = ? WHERE `group` = ? AND `player_id` = ?', { 1, groupId, playerId })
          return
        end
      end
    end
    
    function Group:Setup(groups)
      local availableGroups = {}
    
      for _, OBJECT in ipairs(groups) do
        local consultMembers = exports['oxmysql']:executeSync('SELECT `player_id` AS `playerId`, `role_id` AS `roleId`, `joined_at` AS `joinedAt`, `last_login` AS `lastLogin`, `rescue_wave` AS `rescueWave`, `rescue_rewards` AS `rescueReward` FROM `fta_groups_members` WHERE `group` = ?', { OBJECT.name })
        local consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ?', { OBJECT.name })
    
        availableGroups[OBJECT.name] = {
          id = OBJECT.id,
          team = OBJECT.team,
          name = OBJECT.name,
          ownerId = OBJECT.owner_id,
          balance = OBJECT.balance,
          membersLimit = OBJECT.members_limit,
          logoURL = OBJECT.logo_url or '',
          permissions = json.decode(OBJECT.permissions),
          members = consultMembers or {},
          roles = {}
        }
    
        for _, ROLE in ipairs(consultRoles) do
          if ROLE then
            availableGroups[OBJECT.name].roles[ROLE.id] = {
              id = ROLE.id,
              name = ROLE.name,
              permissions = json.decode(ROLE.permissions),
              icon = ROLE.icon,
              canDelete = ROLE.can_delete
            }
          end
        end
      end
    
      self.groups = availableGroups
    end
    
    function Group:CreateGroup(teamId, groupName, ownerId, permissions, membersLimit)
      local groupInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups` (`team`, `name`, `owner_id`, `members_limit`, `permissions`, `logo_url`) VALUES (?, ?, ?, ?, ?, ?)', {
        teamId,
        groupName,
        ownerId,
        membersLimit,
        json.encode(permissions),
        CONFIG_TEAMS.TEAMS[teamId].DEFAULT_LOGO_URL
      })
    
      local groupId = groupInsert and groupInsert.insertId or 1
    
      local roleInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`, `can_delete`) VALUES (?, ?, ?, ?, ?)', {
        groupName,
        'Líder',
        json.encode({ INVITE = true, KICK = true, PROMOTE = true, WITHDRAW_BANK = true }),
        'LEADER',
        false
      })
    
      local roleId = roleInsert and roleInsert.insertId or 1
    
      local roleMemberInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`, `can_delete`) VALUES (?, ?, ?, ?, ?)', {
        groupName,
        'Membro',
        json.encode({ INVITE = false, KICK = false, PROMOTE = false, WITHDRAW_BANK = false }),
        'MEMBER',
        false
      })
    
      local roleMemberId = roleMemberInsert and roleMemberInsert.insertId or 1
    
      local timestamp = os.time()
      
      exports['oxmysql']:executeSync('INSERT INTO `fta_groups_members` (`group`, `player_id`, `role_id`, `joined_at`, `last_login`) VALUES (?, ?, ?, ?, ?)', {
        groupName,
        ownerId,
        roleId,
        timestamp,
        timestamp
      })
    
      self.groups[groupName] = {
        id = groupId,
        team = teamId,
        name = groupName,
        ownerId = ownerId,
        balance = 0,
        membersLimit = membersLimit,
        logoURL = CONFIG_TEAMS.TEAMS[teamId].DEFAULT_LOGO_URL,
        permissions = permissions,
        members = {
          { playerId = ownerId, roleId = roleId, joinedAt = os.time(), lastTime = timestamp }
        },
        roles = {
          [roleId] = { id = roleId, name = 'Líder', icon = 'LEADER', permissions = { INVITE = true, KICK = true, PROMOTE = true, WITHDRAW_BANK = true }, canDelete = false },
          [roleMemberId] = { id = roleId, name = 'Membro', icon = 'MEMBER', permissions = { INVITE = false, KICK = false, PROMOTE = false, WITHDRAW_BANK = false }, canDelete = false },
        }
      }
    
      Player:SetPermissions(ownerId, permissions)
    end
    
    function Group:UpdateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
      local teamData = CONFIG_TEAMS.TEAMS[teamId]
    
      if not teamData then
        return false
      end
    
      local group = self.groups[groupId]
    
      if not group then
        return false
      end
    
      local newGroup = {
        id = group.id,
        team = teamId,
        name = groupName,
        ownerId = ownerId,
        balance = group.balance,
        membersLimit = membersLimit,
        logoURL = teamData.DEFAULT_LOGO_URL,
        permissions = permissions,
        members = group.members,
        roles = group.roles
      }
    
      exports['oxmysql']:executeSync([[
        UPDATE `fta_groups`
        SET `team` = ?, `name` = ?, `owner_id` = ?, `members_limit` = ?, `logo_url` = ?, `permissions` = ?
        WHERE `id` = ?
      ]], { teamId, groupName, ownerId, membersLimit, teamData.DEFAULT_LOGO_URL, json.encode(permissions), group.id })
    
      if group.ownerId ~= ownerId then
        for INDEX, MEMBER in ipairs(newGroup.members) do
          if MEMBER.playerId == ownerId then
            exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `player_id` = ?', { group.ownerId })
            exports['oxmysql']:executeSync('INSERT INTO `fta_groups_members` (`group`, `player_id`, `joined_at`, `last_login`) VALUES (?, ?, ?, ?)', { groupName, ownerId, os.time(), os.time() })
    
            table.insert(newGroup.members, { playerId = ownerId, roleId = MEMBER.roleId, joinedAt = os.time(), lastLogin = os.time() })
            table.remove(newGroup.members, INDEX)
            break
          end
        end
      end
    
      local oldPermissions = group.permissions
    
      CreateThread(function()
        for _, MEMBER in ipairs(newGroup.members) do
          Player:RemovePermissions(MEMBER.playerId, oldPermissions)
          Player:SetPermissions(MEMBER.playerId, permissions)
        end
      end)
    
      self.groups[groupId] = newGroup
    
      return true
    end
    
    function Group:DeleteGroup(groupId)
      for _, GROUP in pairs(self.groups) do 
        if GROUP.id == groupId then
          local consultMembers = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_members` WHERE `group` = ?', { GROUP.name })
    
          if consultMembers then 
            for _, MEMBER in ipairs(consultMembers) do
              local memberId = MEMBER.player_id
              Player:RemovePermissions(memberId, GROUP.permissions)
            end
    
            exports['oxmysql']:executeSync('DELETE FROM `fta_groups` WHERE `id` = ?', { GROUP.id })
    
            self.groups[GROUP.name] = nil
    
            return true
          end
    
          break
        end
      end
    end
    
    function Group:CreateRole(groupId, name, icon, permissions)
      local group = self.groups[groupId]
    
      if not group then
        return false
      end
    
      local roleInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`) VALUES (?, ?, ?, ?)', {
        group.name,
        name,
        json.encode(permissions),
        icon
      })
    
      local roleId = roleInsert and roleInsert.insertId or 1
    
      group.roles[roleId] = {
        id = roleId,
        name = name,
        permissions = permissions,
        icon = icon,
        canDelete = true
      }
    
      return true
    end
    
    function Group:DeleteRole(groupId, roleId)
      local group = self.groups[groupId]
    
      if not group then
        return false
      end
    
      local roleData = group.roles[roleId]
    
      if not roleData or not roleData.canDelete then
        return false
      end
    
      local consultRole = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ? AND `icon` = "MEMBER"', { groupId })[1]
      
      if not consultRole then
        return false
      end
    
      exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `role_id` = ? WHERE `role_id` = ? AND `group` = ?', { consultRole.id, roleId, groupId })
      exports['oxmysql']:executeSync('DELETE FROM `fta_groups_roles` WHERE `id` = ?', { roleId })
    
      group.roles[roleId] = nil
    
      return true
    end
    
    function Group:EditRole(groupId, roleId, name, icon, permissions)
      local group = self.groups[groupId]
    
      if not group then
        return false
      end
    
      local roleData = group.roles[roleId]
    
      if not roleData or not roleData.canDelete then
        return false
      end
    
      exports['oxmysql']:executeSync('UPDATE `fta_groups_roles` SET `name` = ?, `permissions` = ?, `icon` = ? WHERE `id` = ? AND `group` = ?', {
        name,
        json.encode(permissions),
        icon,
        roleId,
        groupId
      })
    
      group.roles[roleId] = {
        id = roleId,
        name = name,
        icon = icon,
        permissions = permissions,
        canDelete = true
      }
    
      return true
    end
    
    function Group:UpdateMemberRole(playerId, groupId, memberId, roleId)
      local group = self.groups[groupId]
    
      if not group then
        return false
      end
    
      local playerRole = Player:GetPlayerRole(groupId, playerId)
    
      memberId = tonumber(memberId)
      roleId = tonumber(roleId)
    
      if playerId == memberId then 
        return false
      end
    
      if not playerRole or not playerRole.permissions.PROMOTE then
        return false
      end
    
      for INDEX, MEMBER in ipairs(group.members) do 
        if MEMBER.playerId == memberId then 
          group.members[INDEX] = {
            playerId = MEMBER.playerId,
            roleId = roleId,
            joinedAt = MEMBER.joinedAt
          }
    
          exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `role_id` = ? WHERE `group` = ? AND `player_id` = ?', {
            roleId,
            groupId,
            memberId
          })
    
          return true
        end
      end
    
      return false
    end
    
    function Group:KickMember(playerId, groupId, memberId)
      local group = self.groups[groupId]
    
      if not group then
        return
      end
    
      local playerRole = Player:GetPlayerRole(groupId, playerId)
    
      memberId = tonumber(memberId)
    
      if group.ownerId == memberId then 
        return
      end
    
      if not playerRole or not playerRole.permissions.KICK then
        return
      end
    
      for INDEX, MEMBER in ipairs(group.members) do 
        if MEMBER.playerId == memberId then 
          table.remove(group.members, INDEX)
          Player:RemovePermissions(memberId, group.permissions)
          exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `group` = ? AND `player_id` = ?', { group.name, memberId })
          break
        end
      end
    end
    
    function Group:LeaveMember(groupId, memberId)
      local group = self.groups[groupId]
    
      if not group then
        return
      end
    
      memberId = tonumber(memberId)
    
      if group.ownerId == memberId then 
        return
      end
    
      for INDEX, MEMBER in ipairs(group.members) do 
        if MEMBER.playerId == memberId then 
          table.remove(group.members, INDEX)
          Player:RemovePermissions(memberId, group.permissions)
          exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `group` = ? AND `player_id` = ?', { group.name, memberId })
          break
        end
      end
    end
    
    function Group:ForceKickMember(groupId, memberId)
      local group = self.groups[groupId]
    
      if not group then
        return
      end
    
      memberId = tonumber(memberId)
    
      for INDEX, MEMBER in ipairs(group.members) do 
        if MEMBER.playerId == memberId then
          table.remove(group.members, INDEX)
          Player:RemovePermissions(memberId, group.permissions)
          exports['oxmysql']:executeSync('DELETE FROM `fta_groups_members` WHERE `group` = ? AND `player_id` = ?', { group.name, memberId })
          break
        end
      end
    end
    
    function Group:UpdateLastTime(playerId)
      local consultMember = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_members` WHERE `player_id` = ?', { playerId })[1]
    
      if not consultMember then
        return
      end
    
      local timestamp = os.time()
      local lastTime = consultMember.last_login + 604800
    
      if lastTime < timestamp then
        local group = self.groups[consultMember.group]
        
        if group and #group.members > 1 then
          Group:ForceKickMember(consultMember.group, playerId)
        end
      else
        exports['oxmysql']:executeSync('UPDATE `fta_groups_members` SET `last_login` = ? WHERE `player_id` = ?', { os.time(), playerId })
      end
    end
    
    function Group:TryInviteMember(playerId, groupId, memberId)  
      local group = self.groups[groupId]
    
      if not group then
        return false
      end
    
      if group.membersLimit then
        if #group.members >= group.membersLimit then 
          return false
        end
      end
    
      local playerRole = Player:GetPlayerRole(groupId, playerId)
    
      memberId = tonumber(memberId)
      
      if playerId == memberId then
        return false
      end
    
      local playerData = Group:GetPlayerGroupById(memberId)
    
      if playerData then 
        return false
      end
    
      if not playerRole or not playerRole.permissions.INVITE then
        return false
      end
    
      local memberSource = vRP.Source(memberId)
      local message = '%s está te convidando para participar do grupo'
      
      local request = vRP.Request(memberSource, message:format(group.name))
    
      if not request then
        return false
      end
    
      local consultRoles = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_roles` WHERE `group` = ? AND `icon` = "MEMBER" AND `can_delete` = 0 ORDER BY `id` DESC LIMIT 1', { groupId })[1]
    
      if not consultRoles then
        return false
      end
    
      local roleId = consultRoles.id
      local timestamp = os.time()
    
      table.insert(group.members, {
        playerId = memberId,
        roleId = roleId,
        joinedAt = timestamp,
        lastLogin = timestamp
      })
    
      exports['oxmysql']:executeSync('INSERT INTO `fta_groups_members` (`group`, `player_id`, `role_id`, `joined_at`, `last_login`) VALUES (?, ?, ?, ?, ?)', {
        group.name,
        memberId,
        roleId,
        timestamp,
        timestamp
      })
    
      Player:SetPermissions(memberId, group.permissions)
      
      return true
    end
    
    function Group:GetLatestTransactions(groupId)
      local group = self.groups[groupId]
    
      if not group then
        return {}
      end
    
      local availableTransactions = {}
      local consultTransactions = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_transactions` WHERE `group` = ? ORDER BY `id` DESC LIMIT 10', { groupId })
    
      for _, TRANSACTION in ipairs(consultTransactions) do 
        table.insert(availableTransactions, {
          id = TRANSACTION.player_id,
          name = TRANSACTION.player_name,
          amount = TRANSACTION.amount,
          role = group.roles[TRANSACTION.role_id],
          action = TRANSACTION.action,
          date = TRANSACTION.timestamp
        })
      end
    
      return availableTransactions
    end
    
    function Group:BankWithdraw(playerId, groupId, amount)
      local group = self.groups[groupId]
    
      if not group then
        return false
      end
    
      if group.balance < amount then 
        return false
      end
    
      local playerName = Player:GetName(playerId)
      local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)
      
      if not playerRole or not playerRole.permissions.WITHDRAW_BANK then
        return false
      end
    
      vRP.GiveBank(playerId, amount)
      group.balance = group.balance - amount
    
      exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `balance` = `balance` - ? WHERE `name` = ?', { amount, groupId })
      exports['oxmysql']:executeSync('INSERT INTO `fta_groups_transactions` (`group`, `player_id`, `player_name`, `amount`, `role_id`, `action`, `timestamp`) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        groupId,
        playerId,
        playerName,
        amount,
        roleId,
        'WITHDRAW',
        os.time()
      })
    
      return true
    end
    
    function Group:BankDeposit(playerId, groupId, amount)
      local group = self.groups[groupId]
    
      if not group then
        return false
      end
    
      local playerName = Player:GetName(playerId)
      local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)
    
      if not vRP.PaymentBank(playerId, amount) then
        return false
      end
    
      group.balance = group.balance + amount
    
      exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `balance` = `balance` + ? WHERE `name` = ?', { amount, groupId })
      exports['oxmysql']:executeSync('INSERT INTO `fta_groups_transactions` (`group`, `player_id`, `player_name`, `amount`, `role_id`, `action`, `timestamp`) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        groupId,
        playerId,
        playerName,
        amount,
        roleId,
        'DEPOSIT',
        os.time()
      })
    
      return true
    end
    
    function Group:IsPlayerInGroup(playerId)
      local consultPlayer = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups_members` WHERE `player_id` = ?', { playerId })[1]
    
      if not consultPlayer then
        return false
      end
    
      local group = self.groups[consultPlayer.group]
    
      if not group then
        return false
      end
    
      return consultPlayer.group, group.ownerId == playerId
    end
    
    function Group:UpdateLogo(groupId, logoURL)
      local group = self.groups[groupId]
    
      if not group then
        return
      end
    
      group.logoURL = logoURL
      exports['oxmysql']:executeSync('UPDATE `fta_groups` SET `logo_url` = ? WHERE `name` = ?', { logoURL, groupId })
    end
    
    function Group:GetMembersFromRole(groupId, roleId)
      local group = self.groups[groupId]
    
      if not group then
        return 0
      end
    
      local members = {}
    
      for _, MEMBER in ipairs(group.members) do 
        if MEMBER.roleId == roleId then 
          table.insert(members, MEMBER)
        end
      end
    
      return #members
    end
    
    function Group:GetPlayerGroupById(playerId)
      for _, GROUP in pairs(self.groups) do
        for _, MEMBER in ipairs(GROUP.members) do 
          if MEMBER.playerId == playerId then 
            return GROUP
          end
        end
      end
    
      return false
    end
    
    AddEventHandler('Connect', function(Passport, source, bool)
      while not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 do
        Citizen.Wait(1000)
      end
    
      Group:UpdateLastTime(Passport)
    end)
    
    CreateThread(function()
      Wait(1000)
    
      while not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 do
        Citizen.Wait(1000)
      end
    
      local consultGroups = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups`')
    
      Group:Setup(consultGroups)
    end)
end)
BUILDER.import("server/modules/group")

BUILDER.create("server/modules/exports", function()
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
    
    --[[ PEGAR MEMBROS DO GRUPO ]]
    exports('getGroupMembers', function(groupId)
      local groupData = Group:GetGroups(groupId)
    
      if groupData then 
        return groupData.members or {}
      end
    
      return nil
    end)
end)
BUILDER.import("server/modules/exports")

BUILDER.create("server/api/utils", function()
    local steamAPIKey = GetConvar('steam_webApiKey', '')
    
    local function addBigNumbers(a, b)
      local carry = 0
      local result = {}
      local i, j = #a, #b
    
      LPH_NO_VIRTUALIZE(function()
        while i > 0 or j > 0 or carry > 0 do
          local da = i > 0 and tonumber(a:sub(i, i)) or 0
          local db = j > 0 and tonumber(b:sub(j, j)) or 0
          local sum = da + db + carry
      
          carry = math.floor(sum / 10)
          table.insert(result, 1, tostring(sum % 10))
      
          i = i - 1
          j = j - 1
        end
      end)()
    
      return table.concat(result)
    end
    
    local function multiplyBigNumber(number, multiplier)
      local carry = 0
      local result = {}
    
      for i = #number, 1, -1 do
        local prod = tonumber(number:sub(i, i)) * multiplier + carry
    
        carry = math.floor(prod / 10)
        table.insert(result, 1, tostring(prod % 10))
      end
    
      LPH_NO_VIRTUALIZE(function()
        while carry > 0 do
          table.insert(result, 1, tostring(carry % 10))
          carry = math.floor(carry / 10)
        end
      end)()
    
      local formatted = table.concat(result):gsub("^0+", "")
    
      return formatted ~= "" and formatted or "0"
    end
    
    local function hexToDecimalString(hex)
      local decimal = "0"
    
      for i = 1, #hex do
        local digit = tonumber(hex:sub(i, i), 16)
    
        if digit == nil then
          return nil
        end
    
        decimal = addBigNumbers(multiplyBigNumber(decimal, 16), tostring(digit))
      end
    
      return decimal
    end
    
    local function getSteamHex(playerSource)
      local identifier = GetPlayerIdentifierByType(playerSource, "steam")
    
      if not identifier then
        return nil
      end
    
      return identifier:gsub("steam:", "")
    end
    
    function api.getProfileImage()
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local steamHex = getSteamHex(playerSource)
    
      if not steamHex or steamHex == "" or steamAPIKey == "" then
        return ""
      end
    
      local steamId64 = hexToDecimalString(steamHex)
    
      if not steamId64 then
        return ""
      end
    
      local requestUrl = string.format(
        "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=%s&steamids=%s",
        steamAPIKey,
        steamId64
      )
    
      local requestPromise = promise.new()
    
      PerformHttpRequest(requestUrl, function(statusCode, responseBody)
        if statusCode ~= 200 or not responseBody or responseBody == "" then
          requestPromise:resolve("")
          return
        end
    
        local ok, data = pcall(json.decode, responseBody)
    
        if not ok or not data or not data.response or not data.response.players or not data.response.players[1] then
          requestPromise:resolve("")
          return
        end
    
        local playerData = data.response.players[1]
        local avatarUrl = playerData.avatarfull or playerData.avatar or ""
    
        requestPromise:resolve(avatarUrl)
      end, "GET")
    
      local avatar = Citizen.Await(requestPromise)
    
      return avatar or ""
    end
end)
BUILDER.import("server/api/utils")

BUILDER.create("server/api/group", function()
    function api.getGroupMembers(groupId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      if not groupId then 
        return {}
      end
    
      local playerSource = source 
      local playerId = vRP.Passport(playerSource)
    
      local group = Group:GetGroups(groupId)
    
      if not group then
        return {}
      end
    
      local groupMembers = group.members
      local groupRoles = group.roles
      local members = {}
    
      for _, MEMBER in ipairs(groupMembers) do 
        local formatMember = Player:MemberFormat(groupId, MEMBER.playerId, MEMBER.roleId)
    
        formatMember.role = groupRoles[MEMBER.roleId]
        formatMember.isLeader = MEMBER.playerId == group.ownerId
        formatMember.isMe = playerId == MEMBER.playerId
    
        table.insert(members, formatMember)
      end
      
      return members
    end
    
    function api.getPlayerRolePermissions(groupId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      local playerRole, roleId = Player:GetPlayerRole(groupId, playerId)
    
      if not playerRole then
        return nil, nil
      end
    
      return playerRole.permissions, roleId
    end
    
    function api.getGroups(groupId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      return Group:GetGroups(groupId)
    end
    
    function api.isPlayerInGroup()
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      local groupId = Group:IsPlayerInGroup(playerId)
    
      if groupId then
        return groupId
      end
    
      return false
    end
    
    function api.updateMemberRole(groupId, memberId, roleId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
    
      local status = Group:UpdateMemberRole(playerId, groupId, memberId, roleId)
    
      return status
    end
    
    function api.kickMember(groupId, memberId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
    
      Group:KickMember(playerId, groupId, memberId)
    
      return true
    end
    
    function api.leaveMember(groupId, memberId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      Group:LeaveMember(groupId, memberId)
    
      return true
    end
    
    function api.tryInviteMember(groupId, memberId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
      
      if not groupId or not memberId then 
        return false
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
    
      local status = Group:TryInviteMember(playerId, groupId, memberId)
    
      return status
    end
    
    function api.getGroupBank(groupId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local group = Group:GetGroups(groupId)
    
      if not group then
        return 0, {}
      end
    
      local transactions = Group:GetLatestTransactions(groupId)
      local balance = group.balance or 0
      
      return balance, transactions
    end
    
    function api.withdrawFromBank(groupId, amount)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      
      local status = Group:BankWithdraw(playerId, groupId, amount)
    
      return status
    end
    
    function api.depositToBank(groupId, amount)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      
      local status = Group:BankDeposit(playerId, groupId, amount)
    
      return status
    end
    
    function api.getRoles(groupId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local group = Group:GetGroups(groupId)
    
      if not group then
        return {}
      end
    
      local groupRoles = {}
    
      for _, ROLE in pairs(group.roles) do
        local members = Group:GetMembersFromRole(groupId, ROLE.id)
    
        table.insert(groupRoles, {
          id = ROLE.id,
          name = ROLE.name,
          permissions = ROLE.permissions,
          icon = ROLE.icon,
          canDelete = ROLE.canDelete,
          members = members
        })
      end
    
      return groupRoles
    end
    
    function api.createRole(groupId, name, icon, permissions)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local status = Group:CreateRole(groupId, name, icon, permissions)
    
      return status
    end
    
    function api.deleteRole(groupId, id)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local status = Group:DeleteRole(groupId, id)
    
      return status
    end
    
    function api.editRole(groupId, id, name, icon, permissions)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local status = Group:EditRole(groupId, id, name, icon, permissions)
    
      return status
    end
    
    function api.editGroupLogo(groupId, logoURL)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      Group:UpdateLogo(groupId, logoURL)
    end
    
    function api.rankingTryRescue(groupId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
    
      local status = Ranking:TryRescue(groupId, playerId)
    
      return status
    end
end)
BUILDER.import("server/api/group")

BUILDER.create("server/api/admin", function()
    function api.getAvailableGroups()
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local groups = {}
      local groupsList = Group:GetGroups()
    
      for _, GROUP in pairs(groupsList) do 
        local teamData = CONFIG_TEAMS.TEAMS[GROUP.team]
    
        if teamData then 
          local ownerName = Player:GetName(GROUP.ownerId)
      
          table.insert(groups, {
            id = GROUP.id,
            name = GROUP.name,
            logoURL = GROUP.logoURL,
            team = { 
              name = teamData.NAME,
              color = teamData.COLOR,
              bannerURL = teamData.BANNER_URL
            },
            owner = {
              id = GROUP.ownerId,
              name = ownerName
            },
            permissions = GROUP.permissions,
            members = #GROUP.members,
            membersLimit = GROUP.membersLimit
          })
        end
      end
    
      return groups
    end
    
    function api.getTeams(teamId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      if teamId then 
        local teamData = CONFIG_TEAMS.TEAMS[teamId]
    
        return { id = teamId, name = teamData.NAME, color = teamData.COLOR, bannerURL = teamData.BANNER_URL }
      end
    
      local availabeTeams = {}
    
      for ID, TEAM in pairs(CONFIG_TEAMS.TEAMS) do 
        table.insert(availabeTeams, {
          id = ID,
          name = TEAM.NAME,
          color = TEAM.COLOR,
          bannerURL = TEAM.BANNER_URL,
        })
      end
    
      return availabeTeams
    end
    
    function api.createGroup(teamId, groupName, ownerId, permissions, membersLimit)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
    
      Group:CreateGroup(teamId, groupName, ownerId, permissions, membersLimit)
    end
    
    function api.updateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
    
      local status = Group:UpdateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
      return status
    end
    
    function api.deleteGroup(groupId)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local status = Group:DeleteGroup(groupId)
      
      return status
    end
    
    function api.hasAdminPermission()
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      local allowed = vRP.HasPermission(playerId, SHARED_CONFIG.ADMIN_PERMISSION)
    
      return allowed
    end
    
    function api.getPlayerName()
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      local playerName = Player:GetName(playerId)
      
      return playerName
    end
    
    function api.getRankingRewards()
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local ranking = Ranking:GetRanking()
    
      return ranking
    end
    
    function api.updateRanking(position, prizes)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local status = Ranking:UpdateRankingRewards(position, prizes)
    
      return status
    end
    
    function api.getRescueRewards()
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local timeToRescue, timeToExpired = Ranking:GetRescueTimers()
    
      return timeToRescue, timeToExpired
    end
    
    function api.updateRewardTime(timestamp)
      if not _60cc7ab85ebeed88949e7a7f59fb00e33a47cbf1d00ef90404211426c11b22c9 then
        return
      end
    
      local status = Ranking:UpdateTimestampToRescue(timestamp)
    
      return status
    end
end)
BUILDER.import("server/api/admin")