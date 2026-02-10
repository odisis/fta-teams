function NUI:HidePainel()
  self.groupId = nil
  SetNuiFocus(false, false)
end

RegisterNUICallback('closePainel', function (data, cb)
  NUI:HidePainel()
  
  cb()
end)