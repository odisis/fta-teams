RegisterNUICallback('tryCreateChest', function(data, callback)
    apiServer.tryCreateChest()

    callback({})
end)

RegisterNUICallback('tryEditChestLocation', function(data, callback)
    apiServer.tryEditChestLocation()

    callback({})
end)

RegisterNUICallback('tryBuyMoreChestWeight', function(data, callback)
    apiServer.tryBuyMoreChestWeight()

    callback({})
end)

RegisterNUICallback('canCreateChest', function(data, callback)
    local canCreate = apiServer.canCreateChest()

    callback({
        canCreate = canCreate
    })
end)