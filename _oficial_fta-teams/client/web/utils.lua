function NUI:HidePainel()
  self.groupId = nil
  self.groupData = nil
  SetNuiFocus(false, false)
end

RegisterNUICallback('closePainel', function (data, cb)
  NUI:HidePainel()
  
  cb()
end)