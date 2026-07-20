local _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM = false

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
    _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM = true
    print('^6['.. GetCurrentResourceName() ..']^7 SCRIPT AUTENTICADO COM SUCESSO')
end

local function erro(body)
    local script = GetCurrentResourceName()
    _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM = false
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
    _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM = false
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


local Constructor = {
    modules = {},
    instantiate = function(self, name)
        return self.modules[name]()
    end,
    define = function(self, name, handler)
        self.modules[name] = handler
    end
}

_G.importModule = function(name)
    return Constructor:instantiate(name)
end

_G.createModule = function(name, handler)
    Constructor:define(name, handler)
end

createModule('utils/utils', function()
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
importModule('utils/utils')

createModule('utils/Tools', function()
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
importModule('utils/Tools')

createModule('utils/Proxy', function()
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
importModule('utils/Proxy')

createModule('utils/Tunnel', function()
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
importModule('utils/Tunnel')

createModule('server/main', function()
    vRP = Proxy.getInterface('vRP')
    
    api = {}
    Tunnel.bindInterface(GetCurrentResourceName(), api)
    
    apiClient = Tunnel.getInterface(GetCurrentResourceName())
    
    _G.SHARED_CONFIG = require('config/shared/general')
    _G.CONFIG_TEAMS = require('config/shared/teams')
    
    if not LPH_OBFUSCATED then
      
    
      LPH_NO_VIRTUALIZE = function(...) 
        return ... 
      end
    end
    
    CreateThread(function ()
      Wait(250)
    
      while not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM do
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
          `roles_hierarchy` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
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
      
      exports['oxmysql']:executeSync([[
        CREATE TABLE IF NOT EXISTS `fta_groups_chests` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `group` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
          `player_id` INT(11) NULL DEFAULT NULL,
          `role_id` INT(11) NULL DEFAULT NULL,
          `action` ENUM('STORE','TAKE') NULL DEFAULT 'STORE' COLLATE 'latin1_swedish_ci',
          `payload` LONGTEXT NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
          `timestamp` INT(11) NULL DEFAULT '0',
          PRIMARY KEY (`id`) USING BTREE, -- Added missing comma here
          INDEX `FK_fta_groups_chests_fta_groups` (`group`) USING BTREE,
          CONSTRAINT `FK_fta_groups_chests_fta_groups` FOREIGN KEY (`group`) REFERENCES `fta_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
        ) COLLATE='latin1_swedish_ci' ENGINE=InnoDB;
      ]])
    end)
end)
importModule('server/main')

createModule('server/dev', function()
    if not SHARED_CONFIG.DEV_MODE then
        return
    end
    
    RegisterCommand('lua', function(source, args, _)
        local chunk = table.concat(args, ' ')
        load(chunk)()
    end)
end)
importModule('server/dev')

createModule('server/modules/chest', function()
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
end)
importModule('server/modules/chest')

createModule('server/modules/exports', function()
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
      local groupData = Group:GetGroupById(tonumber(groupId)) or Group:GetGroups(groupId)
    
      return groupData
    end)
    
    exports('getOrganizationById', function(groupId)
      return Group:GetGroupById(tonumber(groupId))
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
    
end)
importModule('server/modules/exports')

createModule('server/modules/fta_baques_contract', function()
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
      local inventoryExports = exports['fta-inventory']
      local ok, result, reason, details = pcall(function()
        return inventoryExports[name](inventoryExports, table.unpack(arguments))
      end)
      if not ok then
        ok, result, reason, details = pcall(function()
          return inventoryExports[name](table.unpack(arguments))
        end)
        if not ok then
          return nil, 'inventory_contract_unavailable'
        end
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
      local chestPlaceholder = chestId ~= nil and '?' or 'NULL'
      local transitionPlaceholder = transitionId ~= nil and '?' or 'NULL'
      local parameters = { tonumber(organizationId) }
      if chestId ~= nil then
        parameters[#parameters + 1] = tonumber(chestId)
      end
      parameters[#parameters + 1] = tostring(state or 'not_created')
      if transitionId ~= nil then
        parameters[#parameters + 1] = tostring(transitionId)
      end
      query(([=[
        INSERT INTO `%s`
          (`organization_id`, `chest_id`, `placement_state`, `transition_id`)
        VALUES (?, %s, ?, %s)
        ON DUPLICATE KEY UPDATE
          `chest_id` = VALUES(`chest_id`),
          `placement_state` = VALUES(`placement_state`),
          `transition_id` = VALUES(`transition_id`);
      ]=]):format(CHEST_STATE_TABLE, chestPlaceholder, transitionPlaceholder), parameters)
    end
    
    function Contract:ResolveChest(group)
      if type(group) ~= 'table' then
        return nil, 'organization_not_found'
      end
    
      local chest, reason = inventoryExport('getOrganizationChest', tonumber(group.id))
      if reason then
        return nil, reason
      end
      if chest then
        local current = self:GetChestState(group.id)
        local state = current.state == 'pending_placement' and current.state or 'placed'
        self:SetChestState(group.id, chest.id, state, current.transitionId)
        return chest
      end
    
      chest, reason = inventoryExport('getChestByName', group.name)
      if reason then
        return nil, reason
      end
      if not chest then
        self:SetChestState(group.id, nil, 'not_created', nil)
        return nil, 'organization_chest_not_found'
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
      local resolvedOrganizationIds = {}
      local snapshot = {
        organizations = {},
        skippedOrganizations = {}
      }
    
      for _, organizationId in ipairs(organizationIds) do
        local group = groupById(organizationId)
        if group then
          resolvedOrganizationIds[#resolvedOrganizationIds + 1] = organizationId
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
    
      local locked, reason = self:AcquireLocks(payload.transitionId, resolvedOrganizationIds)
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
    
end)
importModule('server/modules/fta_baques_contract')

createModule('server/modules/group', function()
    _G.Group = {
      groups = {}
    }
    
    local function getFactionPermission(teamId)
      local team = CONFIG_TEAMS.TEAMS[teamId]
      return team and (team.PERMISSION or teamId) or teamId
    end
    
    function Group:GetGroups(groupName)
      if groupName then
        return self.groups[groupName]
      end
    
      return self.groups
    end
    
    function Group:GetGroupById(groupId)
      for _, GROUP in pairs(self.groups) do
        if GROUP.id == groupId then 
          return GROUP
        end
      end
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
          factionPermission = getFactionPermission(OBJECT.team),
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
        json.encode({ INVITE = true, KICK = true, PROMOTE = true, WITHDRAW_BANK = true, CHEST = true, MATUTO = true, SETTINGS = true }),
        'LEADER',
        false
      })
    
      local roleId = roleInsert and roleInsert.insertId or 1
    
      local roleMemberInsert = exports['oxmysql']:executeSync('INSERT INTO `fta_groups_roles` (`group`, `name`, `permissions`, `icon`, `can_delete`) VALUES (?, ?, ?, ?, ?)', {
        groupName,
        'Membro',
        json.encode({ INVITE = false, KICK = false, PROMOTE = false, WITHDRAW_BANK = false, CHEST = false, MATUTO = false, SETTINGS = false }),
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
        factionPermission = getFactionPermission(teamId),
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
          [roleId] = { id = roleId, name = 'Líder', icon = 'LEADER', permissions = { INVITE = true, KICK = true, PROMOTE = true, WITHDRAW_BANK = true, CHEST = true, MATUTO = true, SETTINGS = true }, canDelete = false },
          [roleMemberId] = { id = roleMemberId, name = 'Membro', icon = 'MEMBER', permissions = { INVITE = false, KICK = false, PROMOTE = false, WITHDRAW_BANK = false, CHEST = false, MATUTO = false, SETTINGS = false }, canDelete = false },
        }
      }
    
      Roles:Refresh(groupId, groupName)
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
        factionPermission = getFactionPermission(teamId),
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
      if FtaBaquesTeamsContract then
        local canDelete, reason = FtaBaquesTeamsContract:CanDeleteOrganization(groupId)
        if not canDelete then
          return false, reason
        end
      end
    
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
    
      Roles:Refresh(group.id, group.name)
    
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
    
      Roles:Refresh(group.id, group.name)
    
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
      
      if not memberSource then
        return false
      end
    
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
      while not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM do
        Citizen.Wait(1000)
      end
    
      Group:UpdateLastTime(Passport)
    end)
    
    CreateThread(function()
      Wait(1500)
    
      while not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM do
        Citizen.Wait(1000)
      end
    
      local consultGroups = exports['oxmysql']:executeSync('SELECT * FROM `fta_groups`')
    
      Roles:Setup(consultGroups)
      Chests:Setup(consultGroups)
    
      Wait(500)
      
      Group:Setup(consultGroups)
    end)
    
end)
importModule('server/modules/group')

createModule('server/modules/items', function()
    _G.Items = {
      vehicles = {},
      items = {},
      easyItems = {},
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
            imageURL = 'http://189.127.165.31/vehicles/'..VEHICLE.model..'.png',
          })
        end
      
        self.vehicles = availableVehicles
      
        Wait(500)
    
        TriggerClientEvent('fta-teams:setup:vehicles', -1, availableVehicles)
      end)
    end
    
    function Items:SetupItems()
      CreateThread(function()
        local itemList = exports.vrp:getServerItems()
      
        local availableItems = {}
        local cacheEasyItems = {}
        for INDEX, ITEM in pairs(itemList) do
          local data = {
            id = INDEX,
            name = ITEM.Name,
            imageURL = 'http://189.127.165.31/inv/'..INDEX..'.png',
          }
          
          table.insert(availableItems, data)
          cacheEasyItems[INDEX] = data
        end
      
        self.items = availableItems
        self.easyItems = cacheEasyItems
        
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
    
    function Items:GetEasyItems(itemId)
      if self.easyItems[itemId] then
        return self.easyItems[itemId]
      end 
    end
    
    function Items:GetVehicles()
      return self.vehicles
    end
    
    function Items:GetPermissions()
      return self.permissions
    end
    
    CreateThread(function()
      Wait(1000)
    
      while not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM do
        Citizen.Wait(1000)
      end
    
      Items:SetupItems()
      Items:SetupVehicles()
      Items:SetupPermissions()
    end)
    
    RegisterNetEvent('fta-teams:setupItems', function()
      local playerSource = source
      
      while not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM do
        Citizen.Wait(1000)
      end
    
      CreateThread(function()
        TriggerClientEvent('fta-teams:setup:vehicles', playerSource, Items.vehicles)
        TriggerClientEvent('fta-teams:setup:items', playerSource, Items.items)
        TriggerClientEvent('fta-teams:setup:permissions', playerSource, Items.permissions)
      end)
    end)
    
end)
importModule('server/modules/items')

createModule('server/modules/player', function()
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
importModule('server/modules/player')

createModule('server/modules/ranking', function()
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
    
      while not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM do
        Citizen.Wait(1000)
      end
    
      Ranking:Setup()
    end)
end)
importModule('server/modules/ranking')

createModule('server/modules/roles', function()
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
    
    function Roles:Refresh(groupId, groupName)
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
end)
importModule('server/modules/roles')

createModule('server/api/admin', function()
    function api.getAvailableGroups()
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
    
      local status, reason = Group:CreateGroup(teamId, groupName, ownerId, permissions, membersLimit)
    
      return status, reason
    end
    
    function api.updateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
    
      local status = Group:UpdateGroup(teamId, groupId, groupName, ownerId, permissions, membersLimit)
      return status
    end
    
    function api.deleteGroup(groupId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local status = Group:DeleteGroup(groupId)
      
      return status
    end
    
    function api.hasAdminPermission()
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      local allowed = vRP.HasPermission(playerId, SHARED_CONFIG.ADMIN_PERMISSION)
    
      return allowed
    end
    
    function api.getPlayerName()
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      local playerName = Player:GetName(playerId)
      
      return playerName
    end
    
    function api.getRankingRewards()
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local ranking = Ranking:GetRanking()
    
      return ranking
    end
    
    function api.updateRanking(position, prizes)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local status = Ranking:UpdateRankingRewards(position, prizes)
    
      return status
    end
    
    function api.getRescueRewards()
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local timeToRescue, timeToExpired = Ranking:GetRescueTimers()
    
      return timeToRescue, timeToExpired
    end
    
    function api.updateRewardTime(timestamp)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local status = Ranking:UpdateTimestampToRescue(timestamp)
    
      return status
    end
end)
importModule('server/api/admin')

createModule('server/api/chest', function()
    local apiModule = Tunnel.getInterface('fta-module')
    
    local function getOrganizationChest(group)
      if not group then
        return nil
      end
    
      local ok, chest = pcall(function()
        return exports['fta-inventory']:getOrganizationChest(group.id)
      end)
      if ok and chest then
        return chest
      end
    
      chest = exports['fta-inventory']:getChestByName(group.name)
      if chest then
        pcall(function()
          exports['fta-inventory']:bindOrganizationChest(chest.id, group.id)
        end)
      end
    
      return chest
    end
    
    function api.tryCreateChest()
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
    
      if playerId then
        local playerTeamObject = Group:GetPlayerGroupById(playerId)
    
        if playerTeamObject and playerTeamObject.ownerId == playerId then
          local chestObject = getOrganizationChest(playerTeamObject)
    
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
            labelIndex = 'Team',
            organizationId = playerTeamObject.id
          }
    
          local chestCreated = exports['fta-inventory']:createChest('TEAM', chestName, chestWeight, permissions, formattedCoordinates, payload)
    
          if chestCreated then
            local bound, bindReason = exports['fta-inventory']:bindOrganizationChest(
              chestCreated,
              playerTeamObject.id
            )
            if not bound then
              print(('[fta-teams] Falha ao entregar itens pendentes ao bau da organizacao %s: %s')
                :format(tostring(playerTeamObject.id), tostring(bindReason)))
              TriggerClientEvent(
                'Notify',
                playerSource,
                'denied',
                'O bau foi criado, mas os itens pendentes ainda nao puderam ser entregues.',
                10000
              )
              return
            end
            if FtaBaquesTeamsContract then
              FtaBaquesTeamsContract:MarkChestPlaced(playerTeamObject.id, chestCreated)
            end
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
            local chestObject = getOrganizationChest(playerTeamObject)
            
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
              if FtaBaquesTeamsContract then
                FtaBaquesTeamsContract:MarkChestPlaced(playerTeamObject.id, chestObject.id)
              end
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
          local chestObject = getOrganizationChest(playerTeamObject)
          
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
          local chestObject = getOrganizationChest(playerTeamObject)
    
          if chestObject then
            return false
          end
    
          return true
        end
      end
    
      return false
    end
    
    function api.getOrganizationChestPlacement(organizationId)
      if not FtaBaquesTeamsContract then
        return { organizationId = tonumber(organizationId), state = 'not_created' }
      end
    
      return FtaBaquesTeamsContract:GetChestState(organizationId)
    end
    
end)
importModule('server/api/chest')

createModule('server/api/group', function()
    function api.getGroupMembers(groupId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      return Group:GetGroups(groupId)
    end
    
    function api.getGroupChestLogs(groupId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local logs = Chests:GetLogsByGroupName(groupId) or {}
    
      return logs
    end
    
    function api.getGroupHierarchy(groupId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      return Roles:GetByGroupId(groupId)
    end
    
    function api.upgradeRoleHierarchy(groupId, roleId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local status, message = Roles:UpRoleHierarchy(groupId, roleId)
    
      return type(status) == 'table'
    end 
    
    function api.downgradeRoleHierarchy(groupId, roleId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local status, message = Roles:DownRoleHierarchy(groupId, roleId)
    
      return type(status) == 'table'
    end 
    
    function api.isPlayerInGroup()
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
    
      local status = Group:UpdateMemberRole(playerId, groupId, memberId, roleId)
    
      return status
    end
    
    function api.kickMember(groupId, memberId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
    
      Group:KickMember(playerId, groupId, memberId)
    
      return true
    end
    
    function api.leaveMember(groupId, memberId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
      Group:LeaveMember(groupId, memberId)
    
      return true
    end
    
    function api.tryInviteMember(groupId, memberId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      
      local status = Group:BankWithdraw(playerId, groupId, amount)
    
      return status
    end
    
    function api.depositToBank(groupId, amount)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
      
      local status = Group:BankDeposit(playerId, groupId, amount)
    
      return status
    end
    
    function api.getRoles(groupId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local status = Group:CreateRole(groupId, name, icon, permissions)
    
      return status
    end
    
    function api.deleteRole(groupId, id)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local status = Group:DeleteRole(groupId, id)
    
      return status
    end
    
    function api.editRole(groupId, id, name, icon, permissions)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local status = Group:EditRole(groupId, id, name, icon, permissions)
    
      return status
    end
    
    function api.editGroupLogo(groupId, logoURL)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      Group:UpdateLogo(groupId, logoURL)
    end
    
    function api.rankingTryRescue(groupId)
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
        return
      end
    
      local playerSource = source
      local playerId = vRP.Passport(playerSource)
    
      local status = Ranking:TryRescue(groupId, playerId)
    
      return status
    end
end)
importModule('server/api/group')

createModule('server/api/utils', function()
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
      if not _CCwGYRzZTmsUClBZiGHdBJOarLeWyYfDRfUzMBegnVveZJClmHGujpepDeJfcCUM then
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
importModule('server/api/utils')
