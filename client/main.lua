IsDead = false
ESX = nil

Citizen.CreateThread(
    function()
        while ESX == nil do
            TriggerEvent(
                "esx:getSharedObject",
                function(obj)
                    ESX = obj
                end
            )
            Citizen.Wait(0)
        end

        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(100)
        end

        PlayerLoaded = true
        ESX.PlayerData = ESX.GetPlayerData()
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(100)
            SetPlayerHealthRechargeMultiplier(PlayerId(), 0)
        end
    end
)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler(
    "esx:playerLoaded",
    function(xPlayer)
        ESX.PlayerData = xPlayer
        PlayerLoaded = true
    end
)

RegisterNetEvent("esx:setJob")
AddEventHandler(
    "esx:setJob",
    function(job)
        ESX.PlayerData.job = job
    end
)

AddEventHandler(
    "esx:onPlayerDeath",
    function(data)
        isDead = true
    end
)

-- function

OpenPemerintahMenu = function()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        "default",
        GetCurrentResourceName(),
        "pemerintah_actions",
        {
            title = "Pemerintah",
            align = "top-right",
            elements = {
                {label = "Interaksi Warga", value = "citizen_interaction"}
            }
        },
        function(data, menu)
            if data.current.value == "citizen_interaction" then
                local elements = {
                    {label = "Cek tagihan", value = "unpaid_bills"},
                    {label = "Tagihan", value = "billing"}
                }

                if ESX.PlayerData.job.grade_name == "boss" then
                    table.insert(elements, {label = "Aksi Boss", value = "aksi_boss"})
                end

                ESX.UI.Menu.Open(
                    "default",
                    GetCurrentResourceName(),
                    "citizen_interaction",
                    {
                        title = "Interaksi Warga",
                        align = "top-right",
                        elements = elements
                    },
                    function(data2, menu2)
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        local action = data2.current.value

                        if action == "unpaid_bills" then
                            OpenUnpaidBillsMenu(closestPlayer)
                        elseif action == "billing" then
                            BukaBillingMenu()
                        elseif action == "aksi_boss" then
                            TriggerEvent(
                                "esx_society:openBossMenu",
                                "pemerintah",
                                function(data, menu)
                                    menu.close()
                                end,
                                {wash = false}
                            )
                        end
                    end,
                    function(data2, menu2)
                        menu2.close()
                    end
                )
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

BukaBillingMenu = function()
    ESX.UI.Menu.Open(
        "dialog",
        GetCurrentResourceName(),
        "billing",
        {
            title = "Jumlah invoice"
        },
        function(data, menu)
            local amount = tonumber(data.value)

            if amount == nil or amount < 0 then
                ESX.ShowNotification("Harap masukan nilai invoice yang benar")
            else
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer == -1 or closestDistance > 3.0 then
                    -- exports['mythic_notify']:DoCustomHudText('inform', _U('no_players_nearby'), 2500, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
                    ESX.ShowNotification("Tidak ada player disekitar")
                else
                    menu.close()
                    TriggerServerEvent(
                        "esx_billing:sendBill",
                        GetPlayerServerId(closestPlayer),
                        "society_pemerintah",
                        "Pemerintah",
                        amount
                    )
                end
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

OpenUnpaidBillsMenu = function(player)
    local elements = {}

    ESX.TriggerServerCallback(
        "esx_billing:getTargetBills",
        function(bills)
            for k, bill in ipairs(bills) do
                table.insert(
                    elements,
                    {
                        -- label = ('%s - <span style="color:red;">%s</span>'):format(bill.label, _U('armory_item', ESX.Math.GroupDigits(bill.amount))),
                        label = ('%s - <span style="color:red;">%s</span>'):format(
                            bill.label,
                            "Rp " .. ESX.Math.GroupDigits(bill.amount)
                        ),
                        billId = bill.id
                    }
                )
            end

            ESX.UI.Menu.Open(
                "default",
                GetCurrentResourceName(),
                "billing",
                {
                    title = "Billing belum dibayar",
                    align = "top-right",
                    elements = elements
                },
                nil,
                function(data, menu)
                    menu.close()
                end
            )
        end,
        GetPlayerServerId(player)
    )
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            if
                IsControlJustReleased(0, 167) and not isDead and ESX.PlayerData.job and
                    ESX.PlayerData.job.name == "pemerintah"
             then
                OpenPemerintahMenu()
            end
        end
    end
)
