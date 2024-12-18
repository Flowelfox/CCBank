local bankAPI = {}
local ecnet2 = require("ecnet2")
local random = require("ccryptolib.random")
local serversChannel = 58235


random.initWithTiming()
local id = ecnet2.Identity(".identity")

-- Define a protocol.
local api = id:Protocol {
    -- Programs will only see packets sent on the same protocol.
    -- Only one active listener can exist at any time for a given protocol name.
    name = "api",

    -- Objects must be serialized before they are sent over.
    serialize = textutils.serialize,
    deserialize = textutils.unserialize,
}
local server = nil
local timeout = 5
local side = 'back'
local isPocket = false
if pocket then
    isPocket = true
end

local function log(message)
    print("[bankAPI] " .. message)
end

function bankAPI.init(serverId, modemSide, logFunction)
    if serverId == nil then
        printError("Server is not set")
        return false
    elseif modemSide == nil then
        printError("Modem side is not set")
        return false
    end

    local modemType = peripheral.getType(modemSide)
    if modemType == nil then
        printError("Modem not found")
        return false
    elseif modemType ~= "modem" then
        printError("It is not a modem on the \"" .. modemSide .. "\" side")
        return false
    end
    if logFunction ~= nil then
        log = logFunction
    end
    server = serverId
    side = modemSide
    ecnet2.open(side)
end

function bankAPI.start(main)
    parallel.waitForAny(main, ecnet2.daemon)
end

local function waitResponse(connection, timeout)
    local response = select(2, connection:receive(timeout))
    if response == nil then
        log("Response timeout")
        return nil
    end

    return response
end

local function readToken()
    if not fs.exists(".token") then
        log("Token not found")
        return nil
    end
    local tokenFile = fs.open(".token", "r")
    local token = tokenFile.readAll()
    tokenFile.close()
    if token == nil or token == "" then
        log("Token is empty")
        return nil
    end

    return token
end


local function createConnection()
    -- Create a connection to the server.
    log("Connecting to \"" .. server .. "\"")
    local connection = api:connect(server, "back")
    -- Wait for the greeting.
    local response = waitResponse(connection, timeout)
    if response == nil then
        log("Can't connect to the server")
        return nil
    end
    return connection
end

function bankAPI.sendMoney(recipient, amount)
    local connection = createConnection()
    -- Send a message.
    local token = readToken()
    connection:send({command = "sendMoney", token = token, recipient = recipient, amount = amount})
    local response = waitResponse(connection, timeout)
    if response == nil then
        connection:send({command = "close"})
        return false
    end

    local type = response['type']
    local message = response['message']

    if type == nil or message == nil then
        log("Invalid response")
        connection:send({command = "close"})
        return false
    end

    log(type .. ": " .. message)
    connection:send({command = "close"})
    return type == "success", message
end

function bankAPI.getUser()
    local connection = createConnection()
    -- Send a message.
    local token = readToken()
    connection:send({command = "getUser", token = token})
    local response = waitResponse(connection, timeout)
    if response == nil then
        connection:send({command = "close"})
        return false
    end

    local type = response['type']
    local user = response['user']
    local message = response['message']
    
    if type == "error" then
        log(type .. ": " .. message)
        connection:send({command = "close"})
        return false
    elseif type == "success" then
        log("Got user information")
        connection:send({command = "close"})
        return user
    elseif type == nil or user == nil then
        log("Invalid response")
        connection:send({command = "close"})
        return false
    end
    
end

function bankAPI.register(login, password)
    local connection = createConnection()
    if connection == nil then
        return false, "Can't connect to the server"
    end
    -- Send a message.
    connection:send({command = "register", login = login, password = password})
    local response = waitResponse(connection, timeout)
    if response == nil then
        connection:send({command = "close"})
        return false, "Request timeout"
    end

    local type = response['type']
    local message = response['message']

    if type == nil or message == nil then
        log("Invalid response")
        connection:send({command = "close"})
        return false, "Internal error"
    end

    log(type .. ": " .. message)
    connection:send({command = "close"})
    return type == "success", message
end

function bankAPI.login(login, password)
    local connection = createConnection()
    if connection == nil then
        return false, "Can't connect to the server"
    end
    -- Send a message.
    connection:send({command = "login", login = login, password = password, isPocket = isPocket})
    local response = waitResponse(connection, timeout)
    if response == nil then
        connection:send({command = "close"})
        return false, "Request timeout"
    end

    local type = response['type']
    local token = response['token']
    local message = response['message']


    if type == "error" then
        log(type .. ": " .. message)
        connection:send({command = "close"})
        return false, message
    elseif type == nil or token == nil then
        log("Invalid response")
        connection:send({command = "close"})
        return false, "Internal error"
    else            
        log("Token: " .. token)
        local tokenFile = fs.open(".token", "w")
        tokenFile.write(token)
        tokenFile.close()
        connection:send({command = "close"})
        return true, user
    end 
    
end

function bankAPI.logout()
    local connection = createConnection()

    local token = readToken()

    connection:send({command = "logout", token = token})
    local response = waitResponse(connection, timeout)
    if response == nil then
        connection:send({command = "close"})
        return false
    end



    local type = response['type']
    local message = response['message']

    if type == nil or message == nil then
        log("Invalid response")
        connection:send({command = "close"})
        return false
    end

    log(type .. ": " .. message)
    if type == "error" then
        connection:send({command = "close"})
        return false
    else
        fs.delete(".token")
        connection:send({command = "close"})
        return true
    end
end

function bankAPI.getRunningServers(modemSide)
    local modem = peripheral.wrap(modemSide)
    local replyChannel = math.random(1, 65535)
    local stopSearch = false
    local servers = {}
    os.startTimer(2)
    
    modem.open(replyChannel)
    modem.transmit(serversChannel, replyChannel, "getServers")
    while true do
        local event, side, channel, _, message, distance
        repeat
            event, side, channel, _, message, distance = os.pullEvent()
            if event == "timer" then
                stopSearch = true
                break
            end
        until event == "modem_message" and channel == replyChannel
        if stopSearch then
            modem.close(replyChannel)
            return servers
        end
        if message ~= nil then
            if message:sub(1, 15) == "serverAvailable" then
                local serverData = textutils.unserialize(message:sub(16))
                table.insert(servers, serverData)
            end
        end
    end
end

return bankAPI