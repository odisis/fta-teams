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