local modem = peripheral.find("modem", rednet.open)
local reactor = peripheral.find("BiggerReactors_Reactor")
local clients = {}

local function sendToClients(text)
    for i in pairs(clients) do
        rednet.send(clients[i], text)
    end
end

local function networkHandeler()
while true do
    local id, message = rednet.receive()
    print(("Computer %d sent message %s"):format(id, message))
    if message == "reactor" then
        rednet.send(id, tostring(os.computerID()))
        local uniq = true
        for i in pairs(clients) do
            if clients[i] == id then
                uniq = false
            end
        end
        if uniq then
            clients[#clients + 1] = id
        end
        print("")
        print("clients: ")
        for i in pairs(clients) do
            print(tostring(clients[i]))
        end
        print("")
    elseif message == "reactor_active" then
        rednet.send(id, tostring(reactor.active()))
    elseif message == "reactor_capacity" then
        rednet.send(id, tostring(reactor.battery().capacity()))
    elseif message == "reactor_producedLastTick" then
        rednet.send(id, tostring(reactor.battery().producedLastTick()))
    elseif message == "reactor_stored" then
        rednet.send(id, tostring(reactor.battery().stored()))
    elseif message == "reactor_fuelCapacity" then
        rednet.send(id, tostring(reactor.fuelTank().capacity()))
    elseif message == "reactor_fuel" then
        rednet.send(id, tostring(reactor.fuelTank().fuel()))
    elseif message == "reactor_setActive_true" then
        reactor.setActive(true)
        sendToClients("reactor_on")
    elseif message == "reactor_setActive_false" then
        reactor.setActive(false)
        sendToClients("reactor_off")
    end
end
end

local function reactorHandeler()
    while true do
    if reactor.battery().stored() < ( reactor.battery().capacity() * 0.1 ) and reactor.active() == false then
        print("reactor auto on")
        reactor.setActive(true)
        sendToClients("reactor_on")
    elseif reactor.battery().stored() > ( reactor.battery().capacity() * 0.9 ) and reactor.active() then
        print("reactor auto off")
        reactor.setActive(false)
        sendToClients("reactor_off")
    end

    sleep(2)
    end
end


while true do
   parallel.waitForAny(networkHandeler, reactorHandeler)
   sleep(1)

end
