local QBCore = exports['qb-core']:GetCoreObject()

local function ApplyVehicleTax()
    exports.oxmysql:execute('SELECT DISTINCT citizenid FROM player_vehicles', {}, function(players)
        for _, playerData in ipairs(players) do
            local citizenid = playerData.citizenid
            local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)

            if player then
                local src = player.PlayerData.source
                local discordId = nil

                for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
                    if string.find(identifier, "discord:") then
                        discordId = identifier:gsub("discord:", "")
                        break
                    end
                end

                if discordId then
                    local totalTax = baTu.SabitVergiTutari
                    player.Functions.RemoveMoney('bank', totalTax, 'vehicle-tax')
                    TriggerClientEvent('QBCore:Notify', player.PlayerData.source, 'Devlete Vergiyi Ödedin: $' .. totalTax, 'success')
                    PerformHttpRequest(baTu.VebcukuYapistir, function(err, text, headers) end, 'POST', json.encode({
                        username = 'baTu Vergi Sistemi',
                        embeds = {
                            {
                                title = 'Vergi Kişilerin Listesi',
                                description = string.format(
                                    "CitizenID: %s\nDiscord ID: %s\nVergi Miktarı: $%s\nTarih: %s",
                                    citizenid,
                                    discordId,
                                    totalTax,
                                    os.date('%Y-%m-%d %H:%M:%S')
                                ),
                                color = 65280
                            }
                        }
                    }), { ['Content-Type'] = 'application/json' })
                else
                    print('Discord ID bulunamadı, CitizenID: ' .. citizenid)
                end
            end
        end
    end)
end

CreateThread(function()
    while true do
        ApplyVehicleTax()
        Wait(baTu.VergiKesimAraligi * 1000)
    end
end)
