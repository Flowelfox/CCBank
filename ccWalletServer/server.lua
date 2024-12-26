local ecnet2 = require "ecnet2"
local random = require "ccryptolib.random"
local sha256 = require "ccryptolib.sha256"
local logging = require "logging"


local serverName = "Wallet server"
local usersPath = '.users'
local sessionsPath = '.sessions'
local perDayAmount = 100
local lastRunFile = '.lastRun'
local serversChannel = 58235


logging.setLoggingLevel(logging.INFO)
logging.setLogFile("latest.log")
logging.setWriteToTerminal(true)

random.initWithTiming()
math.randomseed(os.time())
local identity = ecnet2.Identity(".identity")
-- Backend

local function bin_to_hex(binary)
    return (binary:gsub(".", function(c)
      return ("%02x"):format(c:byte())
    end))
end
  
local function getVersion()
    local currentDirectory = fs.getDir(shell.getRunningProgram())
    local versionFile = fs.open(currentDirectory .. "/version.txt", "r")
    if not versionFile then
        return "0.0.0"
    end
    local version = versionFile.readAll()
    versionFile.close()
    return version
end

local User = {}
function User.new(login, password)
    local self = {}
    self.login = login
    self.password = bin_to_hex(sha256.pbkdf2(password, identity.address, 5))
    self.balance = 0
    self.transactions = {}
    self.history = {}
    
    return self
end

local function loadUsers()
    if not fs.exists(usersPath) then
        print("No users file found")
        return {}
    end

    local file = fs.open(usersPath, "r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end

local function writeUsers(users)
    local file = fs.open(usersPath, "w")
    file.write(textutils.serialize(users))
    file.close()
end



local Session = {}
function Session.new(login, deviceId, isPocket)
    local self = {
        login = login,
        deviceId = deviceId,
        isPocket = isPocket,
        token = bin_to_hex(sha256.digest(login .. deviceId .. os.time())),
        created = os.time(os.date("*t"))
    }

    return self
end

local function loadSessions()
    if not fs.exists(sessionsPath) then
        print("No sessions file found")
        return {}
    end

    local file = fs.open(sessionsPath, "r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end

local function writeSessions(sessions)
    local file = fs.open(sessionsPath, "w")
    file.write(textutils.serialize(sessions))
    file.close()
end

local function addSession(session)
    if sessions[session.token] ~= nil then        
        return false
    end
    sessions[session.token] = session:serialize()
    writeSessions(sessions)
    
    return true
end

local function isSessionExpired(session)
    local created = session.created
    local now = os.time(os.date("*t"))
    if created + 86400 - now < 0 then
        return true
    end
    return false
end


local function checkToken(token)
    if token == nil then
        return "Please provide token"
    end

    local sessions = loadSessions()
    if sessions[token] == nil then
        return "Session not found"
    end

    local session = sessions[token]
    if isSessionExpired(session) then
        sessions[token] = nil
        writeSessions(sessions)
        return "Session expired"
    end

    return true
end

local function getModemSide()
    local sides = peripheral.getNames()
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "modem" then
            return side
        end
    end
    return nil
end

local function getModem()
    local modemSide = getModemSide()
    return peripheral.wrap(modemSide)
 end

local connections = {}
local function main()
    logging.info("Starting server...")
    local currentVersion = getVersion()
    os.setComputerLabel(serverName .. " v" .. currentVersion)
    ecnet2.open(getModemSide())
    
    -- Define a protocol.
    local api = identity:Protocol {
        name = "api",

        serialize = textutils.serialize,
        deserialize = textutils.unserialize,
    }


    local apiListener = api:listen()


    while true do
        local event, id, p2, p3, ch, dist = os.pullEvent()
        local requestTime = os.time(os.date("*t"))
        if event == "ecnet2_request" and id == apiListener.id then
            -- Accept the request and send a greeting message.
            local connection = apiListener:accept("Connected to BANK API", p2)
            connections[connection.id] = connection

        elseif event == "ecnet2_message" and connections[id] then
            local data = select(1, p3)
            local command = data['command']


            if command == "close" then
                -- Close the connection.
                connections[id] = nil

            elseif command == "getUser" then
                local users = loadUsers()
                local sessions = loadSessions()
                local token = data['token']

                local checkResult = checkToken(token)
                if  checkResult ~= true then
                    connections[id]:send({type='error', message=checkResult})
                else
                    local session = sessions[token]
                    local clearedUser = {
                        login = session.login,
                        balance = users[session.login].balance,
                        transactions = users[session.login].transactions,
                        history = users[session.login].history
                    }
                    connections[id]:send({type='success', user=clearedUser})
                end

            elseif command == "getRegisteredUsers" then
                local users = loadUsers()
                local sessions = loadSessions()
                local token = data['token']

                local checkResult = checkToken(token)
                if  checkResult ~= true then
                    connections[id]:send({type='error', message=checkResult})
                else
                    local clearedUsers = {}
                    for login, user in pairs(users) do
                        table.insert(clearedUsers, login)
                    end
                    connections[id]:send({type='success', users=clearedUsers})
                end

            elseif command == "sendMoney" then
                local users = loadUsers()
                local sessions = loadSessions()
                local token = data['token']
                local recipient = data['recipient']
                local amount = data['amount']
            
                local checkResult = checkToken(token)
                if  checkResult ~= true then
                    connections[id]:send({type='error', message=checkResult})
                else
                    local session = sessions[token]
                    if users[recipient] == nil then
                        connections[id]:send({type='error', message="Recipient not found"})
                    else
                        if session.login == recipient then
                            connections[id]:send({type='error', message="You can't send money to yourself"})
                        elseif users[session.login].balance < amount then
                            connections[id]:send({type='error', message="Not enough money"})
                        else
                            users[session.login].balance = users[session.login].balance - amount
                            users[recipient].balance = users[recipient].balance + amount
                            table.insert(users[session.login].transactions, {from=session.login, to=recipient, amount=amount, time=requestTime})
                            table.insert(users[recipient].transactions, {from=session.login, to=recipient, amount=amount, time=requestTime})
                            writeUsers(users)

                            table.insert(users[session.login].history, {deviceId = session.deviceId, device=session.isPocket, success=true, time=requestTime, message="Money sent to " .. recipient})
                            table.insert(users[recipient].history, {deviceId = session.deviceId, device=session.isPocket, success=true, time=requestTime, message="Money received from " .. session.login})
                            writeUsers(users)

                            connections[id]:send({type='success', message="Money sent"})
                            logging.info("User \"" .. session.login .. "\" sent " .. amount .. "$ to " .. recipient)
                        end
                    end
                end

            elseif command == "register" then
                local users = loadUsers()
                local login = data['login']
                local password = data['password']

                if login == nil or password == nil then
                    connections[id]:send({type='error', message="Please provide login and password"})
                else
                    if users[login] ~= nil then
                        connections[id]:send({type='error', message="User \"" .. login .."\" already exists"})
                    else
                        local newUser = User.new(login, password)
                        newUser.balance = 100
                        connections[id]:send({type='success', message="User created"})

                        users[login] = newUser
                        table.insert(users[login].history, {deviceId = p2, device=isPocket, success=true, time=requestTime, message="User registered"})
                        table.insert(users[login].transactions, {from="Server", to=login, amount=100, time=requestTime})
                        table.insert(users[login].history, {deviceId = p2, device=isPocket, success=true, time=requestTime, message="Registration bonus 100$"})
                        writeUsers(users)
                        logging.info("User \"" .. login .. "\" registered")
                    end
                end

            elseif command == "login" then
                local users = loadUsers()
                local sessions = loadSessions()
                local login = data['login']
                local password = data['password']
                local isPocket = data['isPocket']

                if login == nil or password == nil then
                    connections[id]:send({type='error', message="Please provide login and password"})
                else
                    if users[login] == nil then
                        logging.info("User \"" .. login .. "\" not found")
                        connections[id]:send({type='error', message="Bad login or password"})
                    else
                        local hashedPassword = bin_to_hex(sha256.pbkdf2(password, identity.address, 5))
                        if users[login].password == hashedPassword then
                            local newSession = Session.new(login, p2, isPocket)
                            sessions[newSession.token] = newSession
                            writeSessions(sessions)

                            table.insert(users[login].history, {deviceId = p2, device=isPocket, success=true, time=requestTime, message="Logged in"})
                            writeUsers(users)

                            connections[id]:send({type='success', token=newSession['token']})
                            logging.info("User \"" .. login .. "\" logged in")
                            
                            
                        else
                            logging.info("User \"" .. login .. "\" provided wrong password")                            
                            table.insert(users[login].history, {deviceId = p2, device=isPocket, success=false, time=requestTime, message="Wrong password"})
                            writeUsers(users)
                            connections[id]:send({type='error', message="Bad login or password"})
                        end
                    end
                end
            elseif command == 'logout' then
                local sessions = loadSessions()
                local token = data['token']

                local checkResult = checkToken(token)

                if "Session not found" == checkResult then
                    connections[id]:send({type='success', message="Logged out"})
                elseif checkResult ~= true then
                    connections[id]:send({type='error', message=checkResult})
                else
                    local session = sessions[token]
                    sessions[token] = nil
                    writeSessions(sessions)

                    local users = loadUsers()
                    table.insert(users[session.login].history, {deviceId = session.deviceId, device=session.isPocket, success=true, time=requestTime, message="Logged out"})
                    writeUsers(users)
                    connections[id]:send({type='success', message="Logged out"})
                    logging.info("User \"" .. session.login .. "\" logged out")
                end
            else
                connections[id]:send({type='error', message="Bad request"})
            end
        end
    end
end



local function getRunningServers()
    logging.info("Getting other running servers...")
    local modem = getModem()
    local replyChannel = math.random(1, 65535)
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

local function broadcastServerName()
    local modem = getModem()
    modem.open(serversChannel)
    modem.transmit(serversChannel, 65535 , "serverConnected " .. serverName)

    while true do
        local event, side, channel, replyChannel, message, distance
        repeat
            event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        until channel == serversChannel

        if message == "serverConnected" then
            logging.info("Server connected to network")
        elseif message == "getServers" then
            local serverData = {
                name = serverName,
                address = identity.address
            }
            modem.transmit(replyChannel,  65535, "serverAvailable " .. textutils.serialize(serverData))
            logging.info("Server requested from " .. replyChannel)
        end
    end
end

local function assignMoney()
    while true do
        local lastRunTime = 0
        if fs.exists(lastRunFile) then
            local file = fs.open(lastRunFile, "r")
            lastRunTime = tonumber(file.readAll())
            file.close()
        end

        
        local timePassed = os.time(os.date("*t")) - lastRunTime
        if  timePassed > 86400 then
            local giveTimes = 1
            if lastRunTime ~= 0 then
                giveTimes = math.floor(timePassed / 86400)
            end
            
            local users = loadUsers()
            for login, user in pairs(users) do
                user.balance = user.balance + (perDayAmount * giveTimes)
                table.insert(user.history, {deviceId = 'server', device=false, success=true, time=os.time(os.date("*t")), message="Daily bonus"})
            end
            writeUsers(users)

            local file = fs.open(lastRunFile, "w")
            file.write(os.time(os.date("*t")))
            file.close()

            logging.info("Daily bonus assigned to everyone registered x" .. giveTimes .. " times")
        end
        sleep(5)
    end
end

local checkModem = getModemSide()
if checkModem == nil then
    logging.error("No modem found")
    return
end

local runningServers = getRunningServers()
for _, Sdata in ipairs(runningServers) do
    if Sdata["name"] == serverName then
        logging.error("Server with the same name is already running")
        return
    end
end

parallel.waitForAny(main, broadcastServerName, assignMoney, ecnet2.daemon)