local modem = peripheral.find("modem", rednet.open)
local monitor = peripheral.find("monitor")
local server = 0

local function broadcast()
    print("Searching for reactor server")
    rednet.broadcast("reactor")
    local id, message = rednet.receive(nil, 5)
    if type(tonumber(message)) == "number" and id == tonumber(message) then
        print("Server set to: " .. tostring(message))
       server = tonumber(message)
       return tonumber(message)
    else
       sleep(1)
       return broadcast()
    end
end

local function send(text)
    --print(text)
    rednet.send(server, text)
end

local function centerText(text)
  x,y = monitor.getSize()
  x1,y1 = monitor.getCursorPos()
  monitor.setCursorPos((math.floor(x/2) - (math.floor(#text/2))), y1)
  monitor.write(text)
end

local function drawLabel(text, color, y)
    local width, height = monitor.getSize()
    local oldcolor = monitor.getBackgroundColor()
    --local oldx, oldy = monitor.getCursorPos()
    monitor.setCursorPos(1,y)
    monitor.setBackgroundColor(color)
    for i = 1,1,1 do
        for k = 1,width,1 do
            monitor.setCursorPos(k, y)
            monitor.write(" ")
        end
    end

    --monitor.setCursorPos(oldx, oldy)
    centerText(text)
end

local function drawBar(current, max, pos1, pos2)
    local width, height = monitor.getSize()
    local maxX = width - 2
    local x = ( maxX / max ) * current

    for i=0,2 do
        for z=1,maxX do
            monitor.setCursorPos(pos1+z,pos2+i)
            if z <= x then
                monitor.setBackgroundColor(colors.green)
            else
                monitor.setBackgroundColor(colors.white)
            end

            monitor.write(" ")
        end
    end
end

local function getActive()
   send("reactor_active")
   local id, message = rednet.receive(nil, 5)
   --print(message)
   if message == "true" then
       return true
   elseif message == "false" then
       return false
   else
       sleep(1)
       return getActive()
   end
end

local function setActive(value)
   if value == true then
       send("reactor_setActive_true")
   elseif value == false then
       send("reactor_setActive_false")
   end
end


local function getCapacity()
   send("reactor_capacity")
   local id, message = rednet.receive(nil, 5)
   if type(tonumber(message)) == "number" then
       return tonumber(message)
   else
       sleep(1)
       return getCapacity()
   end
end

local function getProducedLastTick()
   send("reactor_producedLastTick")
   local id, message = rednet.receive(nil, 5)
   if type(tonumber(message)) == "number" then
       return tonumber(message)
   else
       sleep(1)
       return getProducedLastTick()
   end
end

local function getStored()
   send("reactor_stored")
   local id, message = rednet.receive(nil, 5)
   if type(tonumber(message)) == "number" then
       return tonumber(message)
   else
       sleep(1)
       return getStored()
   end
end

local function getFuelCapacity()
   send("reactor_fuelCapacity")
   local id, message = rednet.receive(nil, 5)
   if type(tonumber(message)) == "number" then
       return tonumber(message)
   else
       sleep(1)
       return getFuelCapacity()
   end
end

local function getFuel()
   send("reactor_fuel")
   local id, message = rednet.receive(nil, 5)
   if type(tonumber(message)) == "number" then
       return tonumber(message)
   else
       sleep(1)
       return getFuel()
   end
end






broadcast()

while true do

    if getActive() then
        monitor.setBackgroundColor(colors.blue)
    else
        monitor.setBackgroundColor(colors.red)
    end
    monitor.clear()
    monitor.setCursorPos(1,1)

    drawLabel("Reactor", colors.black, 1)
    drawLabel("Battery " .. tostring(("%.3g"):format(getStored() / 1000 / 1000)) .." MeRF", colors.gray, 3)
    drawBar(getStored(), getCapacity(), 1, 5)
    drawLabel("Fuel " .. tostring(math.floor((getFuel() / getFuelCapacity()) * 100)) .. "%", colors.gray, 9)
    drawBar(getFuel(), getFuelCapacity(), 1, 11)
    drawLabel("Energy " .. tostring(tostring(("%.5g"):format(getProducedLastTick()/1000))) .. " kRF/t", colors.gray, 15)


    sleep(1)

end
