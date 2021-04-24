ESX = nil
local waitingForPlayers = true

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetUsersForTax()
    while not ESX do
        Wait(1000)
    end
    local AllUser = ESX.GetPlayers()
    if #AllUser > 0 then
        RunTax(AllUser)
    else
        print("Waiting for user to join")
        waitingForPlayers = true
    end
end

AddEventHandler('esx:playerLoaded', function()
    if waitingForPlayers then
        waitingForPlayers = false
        print("User joined. Resuming taxing.")
        Wait(Config.TaxInterval)
        GetUsersForTax()
    end
end)

-- Bank Taxing
function BankTax(AllUser)
    for i=1 , #AllUser,1 do
        local xPlayer = ESX.GetPlayerFromId(AllUser[i])
        local bank = xPlayer.getAccount("bank").money
        local tax = 0

        if (bank > Config.HoboClassLimit) and (bank < Config.PoorClassLimit) then --Poor Class
            local taxpercent = Config.PoorClassTax 
            tax = (bank*taxpercent) / 1000 
        elseif (bank < Config.LowerClassLimit) then --Lower Class
            local taxpercent = Config.LowerClassTax 
            tax = (bank*taxpercent) / 1000 
        elseif (bank < Config.LowerMiddleClassLimit) then --Lower Middle Class
            local taxpercent = Config.LowerMiddleClassTax 
            tax = (bank*taxpercent) / 1000 
        elseif (bank < Config.MiddleClassLimit) then --Middle Class
            local taxpercent = Config.MiddleClassTax 
            tax = (bank*taxpercent) / 1000
        elseif (bank < Config.UpperMiddleClassLimit) then --Upper Middle Class
            local taxpercent = Config.UpperMiddleClassTax 
            tax = (bank*taxpercent) / 1000
        elseif (bank < Config.LowerHigherClassLimit) then --Lower Higher Class
            local taxpercent = Config.LowerHigherClassTax 
            tax = (bank*taxpercent) / 1000
        elseif  (bank < Config.HigherClassLimit) then --Higher Class
            local taxpercent = Config.HigherClassTax 
            tax = (bank*taxpercent) / 1000
        else
            local taxpercent = Config.UpperHigherClassTax 
            tax = (bank*taxpercent) / 1000
        end
        if(xPlayer ~= nil) then 
            if tax ~= 0 then
                print("---------")
                print("Pajak Bank " ..Config.SocietyAccount.. " Jumlah " ..ESX.Math.Round(tax))   
                TriggerClientEvent('tax:sendTax', xPlayer.source, Config.SocietyAccount, 'Pajak Bank', ESX.Math.Round(tax))  
            end         
        end
    end 
end

-- Car Taxing
function CarsTax(AllUser)     
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles',{},function(AllCars)
        local taxMultiplier = Config.CarTax
        for i=1, #AllUser, 1 do 
            local xPlayer = ESX.GetPlayerFromId(AllUser[i])
            local carCount = 0
            for a=1 , #AllCars,1 do
                if xPlayer.getIdentifier() == AllCars[a].owner and (AllCars[a].job ~= 'police' and AllCars[a].job ~= 'ambulance') then
                    carCount = carCount + 1
                end
            end
            if carCount > 0 then
                local tax = carCount * taxMultiplier
                if(xPlayer ~= nil) then
                    print("Pajak Kendaraan " ..Config.SocietyAccount.. " Jumlah " ..ESX.Math.Round(tax))
                    TriggerClientEvent('tax:sendTax', xPlayer.source, xPlayer.source, 'Pajak Kendaraan', ESX.Math.Round(tax))  
                end
            end            
        end
    end)
end

--Property Taxing
function PropertiesTax(AllUser)     
    MySQL.Async.fetchAll('SELECT * FROM owned_properties',{},function(AllProperties)
        local taxMultiplier = Config.PropertyTax
        for i=1, #AllUser, 1 do 
            local xPlayer = ESX.GetPlayerFromId(AllUser[i])
            local propertyCount = 0
            for a=1 , #AllProperties,1 do
                if xPlayer.getIdentifier() == AllProperties[a].owner then
                    propertyCount = propertyCount + 1
                end
            end
            if propertyCount > 0 then
                local tax = propertyCount * taxMultiplier
                if(xPlayer ~= nil) then  
                    print("Pajak Rumah " ..Config.SocietyAccount.. " Jumlah " ..ESX.Math.Round(tax))
                    TriggerClientEvent('tax:sendTax', xPlayer.source, xPlayer.source, 'Pajak Rumah', ESX.Math.Round(tax))
                end
            end            
        end
    end)
end

function RunTax(AllUser)
    BankTax(AllUser)
    Citizen.Wait(1000)
    CarsTax(AllUser)
    Citizen.Wait(1000)
    PropertiesTax(AllUser)
    Citizen.Wait(1000)
    Wait(Config.TaxInterval)
    GetUsersForTax()
end

CreateThread(function()
    GetUsersForTax()
end)