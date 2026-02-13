local __isAuth__ = false

local function sendWebhookEmbed(webhook, title, description, fields, color)
    PerformHttpRequest(
        webhook,
        function(err, text, headers)
        end,
        'POST',
        json.encode(
            {
                embeds = {
                    {
                        title = title,
                        description = description,
                        author = {
                            name = 'Purple Solutions',
                            icon_url = 'https://media.discordapp.net/attachments/1187189855982202930/1199241858254127104/Purple_Solutions.png'
                        },
                        fields = fields,
                        footer = {
                            text = os.date('\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S'),
                            icon_url = 'https://media.discordapp.net/attachments/1187189855982202930/1199241858254127104/Purple_Solutions.png'
                        },
                        color = color
                    }
                }
            }
        ),
        {['Content-Type'] = 'application/json'}
    )
end

local function sucesso(body)
    __isAuth__ = true
    print('^6['.. GetCurrentResourceName() ..']^7 SCRIPT AUTENTICADO COM SUCESSO')
end

local function erro(body)
    local script = GetCurrentResourceName()
    __isAuth__ = false
    print('^6['..script..']^7 FALHA NA AUTENTICAÇÃO')
    if body.err == 'INVALID_TOKEN' then 
        local sv_hostname = GetConvar('sv_hostname', 'Not found')
        local sv_master = GetConvar('sv_master', '')
        local sv_projectName = GetConvar('sv_projectName', '')
        local sv_projectDesc = GetConvar('sv_projectDesc', '')
        local sv_maxclients = GetConvar('sv_maxclients', -1)
        local locale = GetConvar('locale', '')
        local webhook = 'https://discord.com/api/webhooks/1198027389851148298/9jIML8rfu1RhQf1yb4FFWcsqpQLwsQVaJAOCb4_0r9p9rYPqf3Vobm9mq9fx35Omf0Qc'
        sendWebhookEmbed(webhook, 'TOKEN INVÁLIDO', 'Venho registrar uma falha na autenticação da licença do <@'..tostring(body.client)..'>.', {
            {
                name = '⚙ Versão',
                value = '`'..tostring(body.version)..'`',
                inline = true 
            },
            {
                name = '🌎 Script',
                value = '`'..tostring(script)..'`',
                inline = true 
            },
            {
                name = '⚙ Licença',
                value = '```ini\n[IP]: '..tostring(body.ip)..'\n[PORTA]: '..tostring(body.port)..'\n[ID DO USUÁRIO]: '..tostring(body.client)..'\n```'
            },
            {
                name = '☯︎ Comparação do timestamp',
                value = '```ini\n[TIMESTAMP DA API]: '..tostring(body.created)..'\n[TIMESTAMP DO PC]: '..tostring(os.time())..'\n[DIFERENÇA]: '..tostring(math.abs(body.created - os.time()))..'\n```'
            },
            {
                name = '🌆 Servidor',
                value = '```ini\n[HOSTNAME]: '..tostring(sv_hostname or sv_master)..'\n[PROJECTNAME]: '..tostring(sv_projectName)..'\n[PROJECTDESC]: '..tostring(sv_projectDesc)..'\n[SLOTS]: '..tostring(sv_maxclients)..'\n[LOCALE]: '..tostring(locale)..' \n```'
            },
        }, 16776960)
    end
end

local function timeout(body)
    local script = GetCurrentResourceName()
    __isAuth__ = false
    print('^6['.. script ..']^7 FALHA NA CONEXÃO COM A API')
    local sv_hostname = GetConvar('sv_hostname', 'Not found')
    local sv_master = GetConvar('sv_master', '')
    local sv_projectName = GetConvar('sv_projectName', '')
    local sv_projectDesc = GetConvar('sv_projectDesc', '')
    local sv_maxclients = GetConvar('sv_maxclients', -1)
    local locale = GetConvar('locale', '')
    local webhook = 'https://discord.com/api/webhooks/1198027150415114273/QNUssqetgOb2HKunCWff6VTDh_ullZTwUWpC4_2axEpRyQ5Z9EtDZjbAVv6yQGjmSb4Z'
    sendWebhookEmbed(webhook, 'TIMEOUT NA API', '', {
        {
            name = '🌎 Script',
            value = '`'..tostring(script)..'`',
        },
        {
            name = '🌆 Servidor',
            value = '```ini\n[HOSTNAME]: '..tostring(sv_hostname or sv_master)..'\n[PROJECTNAME]: '..tostring(sv_projectName)..'\n[PROJECTDESC]: '..tostring(sv_projectDesc)..'\n[SLOTS]: '..tostring(sv_maxclients)..'\n[LOCALE]: '..tostring(locale)..' \n```'
        },
    }, 16756224)
end

local serverPort = GetConvarInt('netPort')

local function keepAuthAlive()
    local scriptName = GetCurrentResourceName()
    local randomCooldown = math.random(600, 1800) * 1000

    TriggerEvent(scriptName.. ':auth', serverPort)
    SetTimeout(randomCooldown, keepAuthAlive)
end

Citizen.SetTimeout(1000, keepAuthAlive)