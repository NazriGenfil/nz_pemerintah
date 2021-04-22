Config = {}

-- Config pajak

-- Class bank
Config.HoboClassLimit  =  2000
Config.PoorClassLimit  =  10000
Config.LowerClassLimit  =  20000
Config.LowerMiddleClassLimit = 50000
Config.MiddleClassLimit = 100000
Config.UpperMiddleClassLimit = 250000
Config.LowerHigherClassLimit =  500000
Config.HigherClassLimit =  800000

-- pengalian dari class bank
Config.HoboClassTax  =  0
Config.PoorClassTax  =  1
Config.LowerClassTax  =  2
Config.LowerMiddleClassTax = 2
Config.MiddleClassTax =  2
Config.UpperMiddleClassTax =  3
Config.LowerHigherClassTax = 3
Config.HigherClassTax =  3
Config.UpperHigherClassTax = 4
--[[
    Contoh : 
    kita meiliki uang dibank senilai 50k berarti kita sudah memasuki class "LowerMiddleClassLimit"
    atau jika kita memiliki uang diatas 20k tetapi tidak lebih dari 50k berarti kita masuk ke calss "LowerClassLimit".
    
    Perhitungan : 
    Misal kita memiliki uang 100k berarti kita masuk ke class "MiddleClassLimit"

    Di ketahui uang yang kita miliki adalah 100k 
    makan 100k dikali 2 di bagi 1000
    
    jadi hasilnya adalah 200

    200 adalah pajak bank yang harus dibayar
]]


--[[
    Pengalian banyak kendaraan

    misal kita memiliki kendaraan 4 jadi 4 dikali 250 = 1000
    pajak kendaraan yang harus dibayar adalah 1.000
]]
Config.CarTax = 250


-- Untuk property sama seperti kendaraan
Config.PropertyTax = 350

-- Setiap berapa kali player mendapat pajak. 60000 adalah 1 menit dalam ms
Config.TaxInterval = 30 * 60000 -- setaip 30 menit

-- Society Account
Config.SocietyAccount = "society_pemerintah" 
--[[
    setelah player membayar pajak uang pajak akan masuk kemana. INGAT script ini tidak me-ngecek apakah perusahaan tersebut ada atau tidak ini dapat menyebabkan script error
    HARAP dicek terlebih dahulu
]]