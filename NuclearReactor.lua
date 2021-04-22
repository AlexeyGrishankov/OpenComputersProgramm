comp = require("component")
reactor = comp.impact_reactor

screen = require("term")
computer = require("computer")
event = require("event")
graphics = require("graphics")

GPU1 = comp.gpu

screenWidth = 160
screenHeight = 40

GPU1.setResolution(screenWidth, screenHeight)

function rectangleAround(GPU, x, y, w, h, b, color)
    if y % 2 == 0 then
        error("Pixel position must be odd on y axis")
    end
    local b2 = 0
    if b == 1 then
        b2 = 1
    end
    graphics.rectangle(GPU, x, y, w - b, b + b2, color)
    graphics.rectangle(GPU, x + w - b, y, b, h - b + 1, color)
    graphics.rectangle(GPU, x + b - 1, y + h - b - b2, w - b + 1, b + b2, color)
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

function checkProgramm(x)
    graphics.text(GPU1, screenWidth-17, 3, 0x858585,"OFF - CTRL+C")
    graphics.text(GPU1, screenWidth-17, 7, 0x858585,"AUTHOR: 4GNAME")
    x = x + 1
    if (x % 2 == 0) then
        graphics.rectangle(GPU1, screenWidth-4, 3, 2, 2, 0x858585)
    else
        graphics.rectangle(GPU1, screenWidth-4, 3, 2, 2, 0x000)
    end
end

function parserFuel(fuel)
    fuel = string.gsub(fuel, "Thorium", "TH")
    fuel = string.gsub(fuel, "Mox", "MX")
    fuel = string.gsub(fuel, "Naquadah", "NQ")
    fuel = string.gsub(fuel, "Nq%* %- MOX like behaviour", "MX")
    fuel = string.gsub(fuel, "Uranium", "UR")
    fuel = string.gsub(fuel, "Fuel Rod", "")
    fuel = string.gsub(fuel, "Quad", "")
    fuel = string.gsub(fuel, "Dual", "")
    fuel = string.gsub(fuel, "%W", "")
    fuel = string.gsub(fuel, " ", "")
    return fuel
end

function checkRods()
    local LOGO = "IMPACT NUCLEAR REACTOR CONTROL"
    local rods = reactor.getStatusRod()
    local xRod = 7
    local yRod = 17
    local rodPosText = ""
    local rodIDText = ""
    local rodCellName = ""
    local rodCellDamage = 0
    local rodCellMaxDamage = 0
    local rodCellDiff = 0
    local rodCellDiffText = ""

    graphics.text(GPU1, screenWidth / 2 - (#LOGO / 2), 5, 0x7ec7ff, LOGO)

    for i = 1, #rods do
        rectangleAround(GPU1, xRod, yRod, 4, 24, 1, 0x858585)
        graphics.rectangle(GPU1, xRod + 1, yRod + 2 + rods[i] * 2, 2, 20 - rods[i] * 2, 0xFFA500)
        graphics.rectangle(GPU1, xRod + 1, yRod + 2, 2, rods[i] * 2, 0x7ec7ff)
        if rods[i] > 0 and rods[i] < 10 then
            rodPosText = "".. math.floor(rods[i]) * 10 .. "%"
        elseif rods[i] == 10 then
            rodPosText = "MAX"
        else
            rodPosText = "MIN"
        end
        if i < 10 then
            rodIDText = "0" .. i
        else
            rodIDText = "" .. i
        end
        graphics.text(GPU1, xRod + 1, yRod - 2, 0x858585, rodIDText)
        graphics.text(GPU1, xRod + 1, yRod + 24, 0x858585, rodPosText)
        graphics.text(GPU1, xRod, yRod + 24, 0x7ec7ff, "L")


        rodCellName = reactor.getSelectStatusRod(i)[1]
        rodCellDamage = reactor.getSelectStatusRod(i)[2]
        rodCellMaxDamage = reactor.getSelectStatusRod(i)[3]

        if rodCellName == nil then
        else
            if string.find(rodCellName, "Depleted") then
                rodCellName = nil
            end
        end

        if rodCellName == nil then
            graphics.text(GPU1, xRod, 31 + 16 + 6, 0x858585, " NO ")
            graphics.text(GPU1, xRod, 31 + 16 + 8, 0x858585, "FUEL")
        elseif rodCellMaxDamage > 100 then
            rodCellDiff = math.floor(rodCellDamage / rodCellMaxDamage * 100)
            graphics.text(GPU1, xRod + 1, 31 + 16 + 6, 0x7ec7ff, parserFuel(rodCellName))
            if rodCellDiff == 100 then
                rodCellDiffText = "MAX"
            elseif rodCellDiff <= 1  then
                rodCellDiffText = "MIN"
            else
                rodCellDiffText = "".. rodCellDiff .. "%"
            end
            graphics.text(GPU1, xRod + 1, 31 + 16 + 8, 0x7ec7ff, rodCellDiffText)
            graphics.text(GPU1, xRod, 31 + 16 + 8, 0x858585, "F")
        end

        xRod = xRod + 6
    end

    local inputName = string.upper(reactor.getInputFluid()[1])
    local inputAmount = math.floor(reactor.getInputFluid()[2])
    local outputName = string.upper(reactor.getOutputFluid()[1])
    local outputAmount = math.floor(reactor.getOutputFluid()[2])
    local isMox = reactor.getMox()
    local isMoxText = "MOX FUEL"
    local isFastDecayMode = reactor.getFastDecayMode()
    local isFastDecayModeText = "FAST DECAY MODE"

    if isMox == true then
        graphics.text(GPU1, xRod - #isMoxText, 51 + 16, 0xFF0000, isMoxText)
    else
        graphics.text(GPU1, xRod - #isMoxText, 51 + 16, 0xFF0000, "           ")
    end

    if isFastDecayMode == true then
        graphics.text(GPU1, xRod - #isFastDecayModeText, 55 + 16, 0xFF0000, isFastDecayModeText)
    else
        graphics.text(GPU1, xRod - #isFastDecayModeText, 55 + 16, 0xFF0000, "                  ")
    end

    graphics.text(GPU1, 7, 51 + 16, 0x858585, "INPUT " .. inputName .. " - " .. inputAmount .. " L/T                            ")
    graphics.text(GPU1, 7, 55 + 16, 0x858585, "OUTPUT " .. outputName .. " - " .. outputAmount .. " L/T                         ")

end

screen.clear()
ticker = 0

while true do
    ticker = ticker + 1
    if ticker > 99 then
        ticker = 0
    end
    checkProgramm(ticker)

    checkRods()
    graphics.update()
    os.sleep(.5)
    --break
    if event.pull(.5, "interrupted") then
        screen.clear()
        print("soft interrupt, closing")
        break
    end
end
