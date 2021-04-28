IsDead = false
ESX = nil
sleep, HasAlreadyEnteredMarker, InsideMarker = true, false, false
PlayerData, CurrentActionData = {}, {}

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
        PlayerData = xPlayer
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

AddEventHandler('nz_pemerintah:hasEnteredMarker', function(zone)
	if zone == 'Actions' then
		CurrentAction     = 'pemerintah_storage'
		CurrentActionMsg  = 'Tekan ~INPUT_CONTEXT~ untuk membuka storage'
		CurrentActionData = {}
	end
end)

AddEventHandler('nz_pemerintah:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

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

OpenStorage = function()
    local elements = {
		{ label = 'Deposit Item', action = 'put_stock'},
        {label = 'Ambil Item',  action = 'get_stock'}
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "pemerintah_OpenStorage",
		{
			title    = Config.PoliceArmoryTitle,
			align    = "top-right",
			elements = elements
		},
	function(data, menu)
		local action = data.current.action

		if action == "put_stock" then
			OpenPutStocksMenu()
		elseif action == "get_stock" then
			OpenGetStocksMenu()
		end	
	end, function(data, menu)
		menu.close()
        CurrentAction     = 'pemerintah_storage'
		CurrentActionMsg  = "Tekan ~INPUT_CONTEXT~ untuk membuka penyimpanan"
		CurrentActionData = {}
	end, function(data, menu)

	end)
end

OpenGetStocksMenu = function()
    ESX.TriggerServerCallback('nz_pemerintah:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = 'Ambil barang dari penyimpanan',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = 'Jumlah'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('Jumlah tidak valid')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('nz_pemerintah:getStockItem', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

OpenPutStocksMenu = function()
    ESX.TriggerServerCallback('nz_pemerintah:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = 'Masukan barang ke penyimpanan',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_put_item_count', {
				title = 'Jumlah'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('Jumlah tidak valid')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('nz_pemerintah:putStockItems', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if CurrentAction ~= nil then
			sleep = false
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            
            if IsControlJustReleased(0, 38) and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'pemerintah' then

                if CurrentAction == 'pemerintah_storage' then
                    OpenStorage()
                end

                CurrentAction = nil
            end
        end		

		if sleep then
			Citizen.Wait(3000)
		end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'pemerintah' then
			sleep = false
			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil
			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end
			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('nz_pemerintah:hasEnteredMarker', currentZone)
			end
			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('nz_pemerintah:hasExitedMarker', LastZone)
			end
		end
		if sleep then
			Citizen.Wait(3000)
		end
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'pemerintah' then
			local coords = GetEntityCoords(GetPlayerPed(-1))

			for k,v in pairs(Config.Zones) do
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					sleep = false
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
		if sleep then
			Citizen.Wait(5000)
		end
	end
end)

-- F6

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
