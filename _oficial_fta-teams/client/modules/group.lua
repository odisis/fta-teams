RegisterCommand('paineleqp', function()
  local groupId = apiServer.isPlayerInGroup()

  if groupId then 
    NUI:OpenGroup(groupId)
  end
end)