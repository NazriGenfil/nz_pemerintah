ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_society:registerSociety', 'pemerintah', 'Pemerintah', 'society_pemerintah', 'society_pemerintah', 'society_pemerintah', {type = 'public'})


ESX.RegisterServerCallback('nz_pemerintah:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

ESX.RegisterServerCallback('nz_pemerintah:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pemerintah', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('nz_pemerintah:getStockItem')
AddEventHandler('nz_pemerintah:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pemerintah', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then

			-- can the player carry the said amount of x item?
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
                TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'success', text = 'Berhasil mengambil ' ..inventoryItem.label.. ' sejumlah ' ..count.. ' dari berangkas'})
				-- xPlayer.showNotification(_U('have_withdrawn', count, inventoryItem.label))
			else
				-- xPlayer.showNotification(_U('quantity_invalid'))
                TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = 'Jumlah tidak valid!'})
			end
		else
            TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = 'Jumlah tidak valid!'})
			-- xPlayer.showNotification(_U('quantity_invalid'))
		end
	end)
end)

RegisterNetEvent('nz_pemerintah:putStockItems')
AddEventHandler('nz_pemerintah:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pemerintah', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)

            TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'success', text = 'Berhasil deposit ' ..inventoryItem.label.. ' sejumlah ' ..count})
			-- xPlayer.showNotification(_U('have_deposited', count, inventoryItem.label))
		else
            TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = 'Jumlah tidak valid!'})
			-- xPlayer.showNotification(_U('quantity_invalid'))
		end
	end)
end)