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