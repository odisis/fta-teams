local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')
vRP = Proxy.getInterface('vRP')

api = {}
Tunnel.bindInterface(GetCurrentResourceName(), api)

apiServer = Tunnel.getInterface(GetCurrentResourceName())

_G.NUI = {
  groupId = nil,
  profileImage = ''
}

CreateThread(function()
  Wait(1000)

  TriggerServerEvent('fta-teams:setupItems')
end)