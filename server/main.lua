ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_society:registerSociety', 'pemerintah', 'Pemerintah', 'society_pemerintah', 'society_pemerintah', 'society_pemerintah', {type = 'public'})

TriggerEvent('esx_phone:registerNumber', 'pemerintah', 'Pemerintah', true, true)