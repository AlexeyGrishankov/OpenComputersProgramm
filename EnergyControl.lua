comp = require("component")
lsc = comp.impact_lsc

screen = require("term")
computer = require("computer")
event = require("event")
graphics = require("graphics")
colors = require("Colors")

local uc = require("unicode")

local internet = comp.internet
local web = require("internet")

GPU1 = comp.gpu

Telegram = {
    "1419789128:AAGTdGmq2-XFX89Nn4hqYKbx79QYIOcej7A", "329730862"
}

screenWidth = 160
screenHeight = 40

GPU1.setResolution(screenWidth, screenHeight)

function SendTelega(Text)
    local url ="https://api.telegram.org/bot"..Telegram[1].."/sendMessage?chat_id="..Telegram[2].."&text="..Text
    internet.request(url)
end

function rectangleAround(GPU, x, y, w, h, b, color)
    if y % 2 == 0 then
        error("Pixel position must be odd on y axis")
    end
    graphics.rectangle(GPU, x, y, w - b, b, color)
    graphics.rectangle(GPU, x + w - b, y, b, h - b + 1, color)
    graphics.rectangle(GPU, x + b - 1, y + h - b, w - b + 1, b, color)
    graphics.rectangle(GPU, x, y + b - 1, b, h - b + 1, color)
end

function splitNumber(number)
    number = math.floor(number)
    local formattedNumber = {}
    local string = tostring(math.abs(number))
    local sign = number / math.abs(number)
    for i = 1, #string do
        n = string:sub(i, i)
        formattedNumber[i] = n
        if ((#string - i) % 3 == 0) and (#string - i > 0) then
            formattedNumber[i] = formattedNumber[i] .. ","
        end
    end
    if (sign < 0) then
        table.insert(formattedNumber, 1, "-")
    end
    return table.concat(formattedNumber, "")
end

function time(number)
    local formattedTime = {}
    formattedTime[1] = math.floor(number / 3600); formattedTime[2] = " H, "
    formattedTime[3] = math.floor((number - formattedTime[1] * 3600) / 60); formattedTime[4] = " M, "
    formattedTime[5] = number % 60; formattedTime[6] = " S"
    return table.concat(formattedTime, "")
end

function drawCharge()
    local chargeFirst = lsc.getChargePercent()
    local stored, capacity, input, output = lsc.getStoredLSC()
    local pX = 20
    local pY = 53
    local pW = screenWidth - 2 * pX
    local pH = 8
    local charge = (pW - 2) * (lsc.getChargePercent() / 100)
    local capacityEU = "CAPACITY: " .. splitNumber(capacity) .. " EU"
    local storedEU = "STORED: " .. splitNumber(stored) .. " EU"
    local inputEU = "IN: " .. splitNumber(input) .. " EU/T"
    local outputEU = "OUT: " .. splitNumber(output) .. " EU/T "
    local chargePercent = "       CHARGE: " .. math.floor(chargeFirst) .. " %"
    local differenceIO = input - output



    rectangleAround(GPU1, pX, pY, pW, pH, 2, 0x131e27)

    graphics.rectangle(GPU1, pX + 2, pY + 2, charge - 2, 4, 0x7ec7ff)
    if chargeFirst > 0 and chargeFirst < 100 then
        graphics.rectangle(GPU1, pX + charge + 1, pY + 2, pW - 2 - charge, 4, 0x294052)
    else
        if chargeFirst <= 0 then
            graphics.rectangle(GPU1, pX + 2, pY + 2, pW - 4, 4, 0x294052)
        end
    end
    local diftext = "              " .. "COST: " .. splitNumber(math.abs(differenceIO)) .. " EU/T"
    if differenceIO < 0 then
        graphics.text(GPU1, pX + pW - #diftext, pY + pH, 0xff0000, diftext)
    else
        graphics.text(GPU1, pX + pW - #diftext, pY + pH, 0x33ff00, diftext)
    end
    graphics.text(GPU1, pX + pW - #chargePercent, pY - 2, 0x7ec7ff, chargePercent)
    graphics.text(GPU1, pX, pY - 2, 0x7ec7ff, capacityEU .. "              ")
    graphics.text(GPU1, pX, pY + pH, 0x7ec7ff, storedEU .. "              ")
    graphics.text(GPU1, pX, pY + pH + 4, 0x33ff00, inputEU .. "              ")
    graphics.text(GPU1, pX, pY + pH + 6, 0xff0000, outputEU .. "              ")

    if differenceIO > 0 then
        fillTime = math.floor((capacity - stored) / (differenceIO * 20))
        fillTimeString = "                        FULL: " .. time(math.abs(fillTime))
        graphics.text(GPU1, pX + pW - #fillTimeString, pY + pH + 2, 0x7ec7ff, fillTimeString .. "              ")
    else if differenceIO == 0 then
        if stored >= (capacity * 90 / 100) then
            fillTimeString = "                       STABLE CHARGE"
        else if stored <= (capacity * 10 / 100) then
            fillTimeString = "                         NEED CHARGE"
        end
            fillTimeString = "                        NOT CHARGING"
        end
        graphics.text(GPU1, pX + pW - #fillTimeString, pY + pH + 2, 0x7ec7ff, fillTimeString)
    else
        fillTime = math.floor((stored) / (differenceIO * 20))
        fillTimeString = "                        EMPTY: " .. time(math.abs(fillTime))
        graphics.text(GPU1, pX + pW - #fillTimeString, pY + pH + 2, 0x7ec7ff, fillTimeString .. "              ")
    end
    end
end

local genActive = false

function startGenerators(is)
    local pX = screenWidth - 40
    local pY = 3
    local pW = 2
    local pH = 2
    if genActive == false and is == true then
        graphics.rectangle(GPU1, pX, pY, pW, pH, 0x858585)
        genActive = true
    end
    if genActive == true and is == false then
        graphics.rectangle(GPU1, pX, pY, pW, pH, 0x000)
        genActive = false
    end
end

function checkProgramm(x)
    graphics.text(GPU1, screenWidth-17, 3, 0x858585,"OFF - CTRL+C")
    graphics.text(GPU1, screenWidth-17, 5, 0x858585,"TICKER: " .. x .. "   ")
    x = x + 1
    if (x % 2 == 0) then
        graphics.rectangle(GPU1, screenWidth-4, 3, 2, 2, 0x858585)
    else
        graphics.rectangle(GPU1, screenWidth-4, 3, 2, 2, 0x000)
    end
end


local checkLoop = "true"
local checkLoopArray = "true"
function parserTG()
    local req = web.request("https://api.telegram.org/bot"..Telegram[1].."/getUpdates?offset=-1")
    local msg = ""
    local msgArray = {}
    for line in req do
        line = string.match(line, "\"text\".+\"")
        line = string.gsub(line, "[\":]+", "")
        line = string.gsub(line, "text", "")
        if line == "gen on" then
            startGenerators(true)
            msg = "Generators Enabled"
        elseif line == "gen off" then
            startGenerators(false)
            msg = "Generators Disabled"
        elseif line == "lsc status" then
            lscStatus()
        elseif line == "hello" then
            graphics.text(GPU1, 4, 7, 0x858585, "Hello! I am Bot OC Impact")
        end
        if #line < 30 then
            graphics.text(GPU1, 4, 3, 0x858585, "Last command: " .. line .. "                                           ")
        end
        if (msg == "") then
        else
            graphics.text(GPU1, 4, 7, 0x858585, msg .. "                                           ")

            if checkLoop == msg then
            else
                SendTelega(msg)
            end
            checkLoop = msg
        end
    end
end

function lscStatus()
    local status = {}
    local chargeFirst = lsc.getChargePercent()
    local capacity, stored, input, output = lsc.getStoredLSC()
    status[1] = "CAPACITY: " .. splitNumber(capacity) .. " EU"
    status[2] = " STORED: " .. splitNumber(stored) .. " EU"
    status[3]= " IN: " .. splitNumber(input) .. " EU/T"
    status[4] = " OUT: " .. splitNumber(output) .. " EU/T "
    status[5] = "  CHARGE: " .. math.floor(chargeFirst) .. " %"
    return status
end

screen.clear()
ticker = 0

while true do
    ticker = ticker + 1
    if ticker > 99 then
        ticker = 0
    end

    parserTG()
    checkProgramm(ticker)

    drawCharge()
    graphics.update()

    os.sleep(.1)

    if event.pull(.5, "interrupted") then
        screen.clear()
        print("soft interrupt, closing")
        break
    end
end
