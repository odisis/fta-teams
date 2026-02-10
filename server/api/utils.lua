local steamAPIKey = GetConvar('steam_webApiKey', '')

local function addBigNumbers(a, b)
  local carry = 0
  local result = {}
  local i, j = #a, #b

  while i > 0 or j > 0 or carry > 0 do
    local da = i > 0 and tonumber(a:sub(i, i)) or 0
    local db = j > 0 and tonumber(b:sub(j, j)) or 0
    local sum = da + db + carry

    carry = math.floor(sum / 10)
    table.insert(result, 1, tostring(sum % 10))

    i = i - 1
    j = j - 1
  end

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

  while carry > 0 do
    table.insert(result, 1, tostring(carry % 10))
    carry = math.floor(carry / 10)
  end

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