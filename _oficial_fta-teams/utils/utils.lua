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