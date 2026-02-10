SERVER = IsDuplicityVersion()
CLIENT = not SERVER

function table.maxn(t)
	local max = 0
	for k,v in pairs(t) do
		local n = tonumber(k)
		if n and n > max then max = n end
	end
	return max
end

function table:equals(comparation)
    if self == comparation then 
		return true 
	end

    local o1Type = type(self)
    local o2Type = type(comparation)
	
    if o1Type ~= o2Type then 
		return false 
	end

    if o1Type ~= 'table' then 
		return false 
	end

    local keySet = {}

    for key1, value1 in pairs(self) do
        local value2 = comparation[key1]
		
        if value2 == nil or table.equals(value1, value2) == false then
            return false
        end

        keySet[key1] = true
    end

    for key2, _ in pairs(comparation) do
        if not keySet[key2] then 
			return false 
		end
    end

    return true
end

local modules = {}
function require(rsc, path)
	if path == nil then
		path = rsc
		rsc = GetCurrentResourceName()
	end

	local key = rsc..path
	local module = modules[key]
	if module then
		return module
	else
		local code = LoadResourceFile(rsc, path..".lua")
		if code then
			local f,err = load(code, rsc.."/"..path..".lua")
			if f then
				local ok, res = xpcall(f, debug.traceback)
				if ok then
					modules[key] = res
					return res
				else
					error("error loading module "..rsc.."/"..path..":"..res)
				end
			else
				error("error parsing module "..rsc.."/"..path..":"..debug.traceback(err))
			end
		else
			error("resource file "..rsc.."/"..path..".lua not found")
		end
	end
end

local function wait(self)
	local rets = Citizen.Await(self.p)
	if not rets then
		rets = self.r 
	end
	return table.unpack(rets,1,table.maxn(rets))
end

local function areturn(self, ...)
	self.r = {...}
	self.p:resolve(self.r)
end

function async(func)
	if func then
		Citizen.CreateThreadNow(func)
	else
		return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
	end
end

function parseInt(v)
	local n = tonumber(v)
	if n == nil then 
		return 0
	else
		return math.floor(n)
	end
end

function parseDouble(v)
	local n = tonumber(v)
	if n == nil then n = 0 end
	return n
end

function parseFloat(v)
	return parseDouble(v)
end

local sanitize_tmp = {}
function sanitizeString(str, strchars, allow_policy)
	local r = ""
	local chars = sanitize_tmp[strchars]
	if chars == nil then
		chars = {}
		local size = string.len(strchars)
		for i=1,size do
			local char = string.sub(strchars,i,i)
			chars[char] = true
		end
		sanitize_tmp[strchars] = chars
	end

	size = string.len(str)
	for i=1,size do
		local char = string.sub(str,i,i)
		if (allow_policy and chars[char]) or (not allow_policy and not chars[char]) then
			r = r..char
		end
	end
	return r
end

function splitString(str, sep)
	if sep == nil then sep = "%s" end

	local t={}
	local i=1

	for str in string.gmatch(str, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end

function joinStrings(list, sep)
	if sep == nil then sep = "" end

	local str = ""
	local count = 0
	local size = #list
	for k,v in pairs(list) do
		count = count+1
		str = str..v
		if count < size then str = str..sep end
	end
	return str
end

function table:len()
	local n = 0
	for k,v in pairs(self) do
		n = n + 1
	end
	return n
end

function table:copy()
	local instance = {}
	for k,v in pairs(self) do
		if type(v) == 'table' then
			instance[k] = table.copy(v)
		else
			instance[k] = v
		end
	end
	return instance
end

function table:includes(searched)
	for k,v in pairs(self) do
		if searched == v then 
			return true 
		end
	end
end

function table:array()
	local instance = {}
	for _,v in pairs(self) do
		table.insert(instance, v)
	end
	return instance
end

function table:entries()
	local instance = {}

	for key, value in pairs(self) do 
		table.insert(instance, {key,value})
	end 

	return instance
end 

function table:fromEntries()
	local instance = {}

	for _, v in ipairs(self) do 
		instance[v[1]] = v[2]
	end 

	return instance
end 

function table:filter(schema)
	if schema == true then 
		return table.copy(self)
	end 

	local result = {}

	for k, v in pairs(schema) do 
		local _type1, _type2 = type(v), type(self[k])

		if (_type1 == 'table' or _type1:find('vector')) and (_type2 == 'table' or _type2:find('vector')) then
			result[k] = table.filter(self[k], v)
		else 
			result[k] = self[k]
		end 
	end 

	return result 			
end

function table:resolve(value, schema)
	if type(schema) == 'table' then 
		for k, v in pairs(schema) do 
			local _type1, _type2 = type(v), type(self[k])

			if v ~= nil then 
				if _type1 == 'table' then 
					if _type2 ~= 'table' then 
						self[k] = {}
					end 

					self[k] = table.resolve(self[k], value[k], v)
				else
					if _type2:find('vector') then 
						if value[k] then 
							if not self[k].z and not value[k].z then 
								self[k] = vector2(value[k].x or self[k].x, value[k].y or self[k].y)
							elseif _type2 == 'vector3' then 
								self[k] = vector3(value[k].x or self[k].x, value[k].y or self[k].y, value[k].z or self[k].z)
							end 
						else 
							self[k] = value[k]
						end 
					else
						self[k] = value[k]
					end
				end 
			end 
		end 
	else 
		return value
	end 

	return self
end 

function table:subtract(_table)
	local schema = {}

	for k, v in pairs(self) do 
		local _type1, _type2 = type(v), type(_table[k])

		if _type1 ~= 'function' then 
			if _type1 == 'table' and _type2 == 'table' then 
				schema[k] = table.subtract(v, _table[k])
			else 
				if _type1 ~= _type2 or v ~= _table[k] then 
					schema[k] = true
				end 
			end
		end 
	end 

	for k, v in pairs(_table) do 
		if self[k] == nil and v ~= nil then 
			schema[k] = true
		end 
	end 

	local length01 = table.len(self)
	local length02 = table.len(schema)
	local length03 = table.len(_table)

	if length01 == 0 and length03 == 0 then 
		return nil 
	end 

	if length01 == length02 or length03 == length02 then 
		return true
	end 

	return (not table.equals(schema, {}) and schema) or nil
end 

function format(n)
    n = parseInt(n)
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function f(n)
	return n/1
end

function positive(n)
    if n < 0 then
        return n * -1
    end
    return n
end

function parsePart(key)
	if type(key) == "string" and string.sub(key,1,1) == "p" then
		return true,tonumber(string.sub(key,2))
	else
		return false,tonumber(key)
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

function string:replace(o)
	for i in pairs(o) do 
		self = self:gsub('{{'..i..'}}', o[i])
	end
	return self
end

function splitString(Full, Symbol)
	local Table = {}

	if type(Full) == 'string' then
		if not Symbol then
			Symbol = '-'
		end

		for Full in string.gmatch(Full, '([^'..Symbol..']+)') do
			Table[#Table + 1] = Full
		end
	end

	return Table
end