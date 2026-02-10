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