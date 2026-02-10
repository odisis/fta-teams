if not SHARED_CONFIG.DEV_MODE then
    return
end

RegisterCommand('lua', function(source, args, _)
    local chunk = table.concat(args, ' ')
    load(chunk)()
end)