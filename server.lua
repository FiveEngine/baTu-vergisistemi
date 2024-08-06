local QBCore = exports['qb-core']:GetCoreObject()

local function ApplyVehicleTax()
    MySQL.query('SELECT DISTINCT citizenid FROM player_vehicles', {}, function(players)
        for _, playerData in ipairs(players) do
            local citizenid = playerData.citizenid
            local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)

            if player then
                MySQL.query('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenid}, function(vehicles)
                    for _, vehicle in ipairs(vehicles) do
                        local price = vehicle.price
                        local tax = price * baTu.VergiOrani
                        player.Functions.RemoveMoney('bank', tax, 'vehicle-tax')
                        TriggerClientEvent('QBCore:Notify', player.PlayerData.source, 'Devlete Vergiyi Ödedin: $' .. tax, 'success')
                        PerformHttpRequest(baTu.VebcukuYapistir, function(err, text, headers) end, 'POST', json.encode({
                            username = 'Vergi Sistemi',
                            embeds = {
                                {
                                    title = 'Vergi Kesildi',
                                    description = string.format("Araç: %s\nVergi Miktarı: $%s", vehicle.plate, tax),
                                    color = 65280
                                }
                            }
                        }), { ['Content-Type'] = 'application/json' })
                    end
                end)
            end
        end
    end)
end

CreateThread(function()
    while true do
        ApplyVehicleTax()
        Wait(baTu.VergiKesimAraligi * 60000)
    end
end)
