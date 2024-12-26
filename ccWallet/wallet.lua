-- Imports
local basalt = require("basalt")
local bankAPI = require("bankAPI")

-- Config
local disableLogging = true
local modemSide = "back"

local function getWalletServer()
    local addressFile = fs.open(".walletServerAddress.txt", "r")
    local server = addressFile.readAll()
    addressFile.close()
    return server
end

local server = getWalletServer()

local function log(message)
    if not disableLogging then
        basalt.debug(message)
    end
end

local function wrap(label1, label2, text, limit)
    if #text > limit then
        local splitPos = limit
        while splitPos > 0 and text:sub(splitPos, splitPos) ~= " " do
            splitPos = splitPos - 1
        end
        if splitPos == 0 then
            splitPos = limit
        end
        label1:setText(text:sub(1, splitPos))
        label2:setText(text:sub(splitPos + 1))
    else
        label1:setText(text)
        label2:setText("")
    end
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

local function main()    
    local currentVersion = getVersion()
    os.setComputerLabel("Wallet v" .. currentVersion)
    local isInitiated = bankAPI.init(server, modemSide, log)
    if isInitiated == false then
        printError("Failed to initialize API")
        return
    end

    -- GUI
    local main = nil
    local monitor = nil
    if monitorSide ~= nil then
        monitor = peripheral.wrap(monitorSide)
        monitor.setTextScale(0.5)
        main = basalt.addMonitor()
        main:setMonitor(monitor)
    else
        main = basalt.createFrame()
    end

    local mainMenu = main:addFrame()
        :setPosition(1, 1)
        :setSize("parent.w", "parent.h")
        :setBackground(colors.white)

    mainMenu:addLabel()
        :setText("Wallet")
        :setForeground(colors.magenta)
        :setBackground(colors.white)
        :setFontSize(2)
        :setTextAlign('center')
        :setPosition('parent.w / 2 - 8', 2)

    mainMenu:addLabel()
        :setText("Login")
        :setTextAlign('center')
        :setPosition(1, 6)
        :setSize('parent.w', 1)

    local loginInput = mainMenu:addInput()
        :setPosition(2, 7)
        :setSize(24, 1)
        :setInputLimit(20)
        :setInputType("text")

    local loginErrorLabel = mainMenu:addLabel()
        :setText("")
        :setTextAlign('center')
        :setPosition(1, 8)
        :setSize('parent.w', 1)
        :setForeground(colors.red)

    mainMenu:addLabel()
        :setText("Password")
        :setTextAlign('center')
        :setPosition(1, 9)
        :setSize('parent.w', 1)

    local passwordInput = mainMenu:addInput()
        :setPosition(2, 10)
        :setSize(24, 1)
        :setInputLimit(20)
        :setInputType("password")

    local passwordErrorLabel = mainMenu:addLabel()
        :setText("")
        :setTextAlign('center')
        :setPosition(1, 11)
        :setSize('parent.w', 1)
        :setForeground(colors.red)

    local passwordErrorLabel2 = mainMenu:addLabel()
        :setText("")
        :setTextAlign('center')
        :setPosition(1, 12)
        :setSize('parent.w', 1)
        :setForeground(colors.red)
    

    local loginButton = mainMenu
        :addButton()
        :setPosition("parent.w / 2 - 6", "parent.h - 7")
        :setSize(15, 3)
        :setBackground(colors.magenta)
        :setText("Login")

    local registerButton = mainMenu
        :addButton()
        :setPosition("parent.w / 2 - 6", "parent.h - 3")
        :setSize(15, 3)
        :setBackground(colors.magenta)
        :setText("Register")


    local registerMenu = main
        :addFrame()
        :setPosition(1, 1)
        :setSize("parent.w", "parent.h")
        :setBackground(colors.white)
        :hide()
        :disable()

    
    registerMenu:addLabel()
        :setText("Wallet")
        :setForeground(colors.magenta)
        :setBackground(colors.white)
        :setFontSize(2)
        :setTextAlign('center')
        :setPosition('parent.w / 2 - 8', 2)

        local registerLoginLabel = registerMenu:addLabel()
            :setText("New login")
            :setTextAlign('center')
            :setPosition(1, 6)
            :setSize('parent.w', 1)

        local registerLoginInput = registerMenu:addInput()
            :setPosition(2, 7)
            :setSize(24, 1)
            :setInputLimit(20)
            :setInputType("text")

        local registerPasswordLabel = registerMenu:addLabel()
            :setText("New password")
            :setTextAlign('center')
            :setPosition(1, 9)
            :setSize('parent.w', 1)

        local registerPasswordInput = registerMenu:addInput()    
            :setPosition(2, 10)
            :setSize(24, 1)
            :setInputLimit(20)
            :setInputType("password")

        local passwordRepeatLabel = registerMenu:addLabel()
            :setText("Repeat password")
            :setTextAlign('center')
            :setPosition(1, 12)
            :setSize('parent.w', 1)

        local passwordRepeatInput = registerMenu:addInput()
            :setPosition(2, 13)
            :setSize(24, 1)
            :setInputLimit(20)
            :setInputType("password")

        local registerErrorLabel1 = registerMenu:addLabel()
            :setText("")
            :setTextAlign('center')
            :setPosition(1, 15)
            :setSize('parent.w', 1)
            :setForeground(colors.red)
        local registerErrorLabel2 = registerMenu:addLabel()
            :setText("")
            :setTextAlign('center')
            :setPosition(1, 16)
            :setSize('parent.w', 1)
            :setForeground(colors.red)

    local confirmRegisterButton = registerMenu
        :addButton()
        :setPosition(2, "parent.h - 3")
        :setSize(11, 3)
        :setBackground(colors.magenta)
        :setText("Register")

    local backFromRegisterButton = registerMenu
        :addButton()
        :setPosition("parent.w - 11", "parent.h - 3")
        :setSize(11, 3)
        :setBackground(colors.magenta)
        :setText("Back")
    
    local accountMenu = main
        :addFrame()
        :setPosition(1, 1)
        :setSize("parent.w", "parent.h")
        :setBackground(colors.white)
        :hide()
        :disable()

    local accountNameLabel = accountMenu:addLabel()
        :setText("Account: ")
        :setPosition(2, 2)
        :setSize(8, 1)

    local accountNameValueLabel = accountMenu:addLabel()
        :setText("SomeUser")
        :setPosition(accountNameLabel.getX() + accountNameLabel.getWidth(), 2)
        :setForeground(colors.green)

    local balanceLabel = accountMenu:addLabel()
        :setText("Balance:")
        :setPosition(2,3)
        :setSize(8,1)

    local balanceValueLabel = accountMenu:addLabel()
        :setText("0$")
        :setPosition(balanceLabel.getX() + balanceLabel.getWidth(), 3)
        :setForeground(colors.green)

    local transactionsButton = accountMenu:addButton()
        :setText("Transactions")
        :setPosition(2, 5)
        :setSize('parent.w - 2', 3)
        :setBackground(colors.magenta)

    local sendButton = accountMenu:addButton()
        :setText("Send")
        :setPosition(2, 9)
        :setSize("parent.w - 2", 3)
        :setBackground(colors.magenta)

    local historyButton = accountMenu:addButton()
        :setText("History")
        :setPosition(2, 13)
        :setSize('parent.w - 2', 3)
        :setBackground(colors.magenta)        


    local logoutButton = accountMenu:addButton()
    :setText("Logout")
    :setPosition(2, 17)
    :setSize('parent.w - 2', 3)
    :setBackground(colors.magenta)

    local transactionsMenu = accountMenu
        :addFrame()
        :setPosition(2, 4)
        :setSize("parent.w - 2", "parent.h - 4")
        :setBackground(colors.white)
        :hide()
        :disable()

    local lastTransactionsLabel = transactionsMenu:addLabel()
        :setText("Last transactions:")
        :setPosition(1,1)
        :setSize(18,1)

    local transactionsLabels = {}

    for i = 1, 10 do
        transactionsLabels[i] = transactionsMenu:addLabel()
            :setText("Transaction " .. i)
            :setPosition(1, 2 + i)
            :setSize(30, 1)
    end

    local backFromTransactionsButton = transactionsMenu:addButton()
        :setText("Back")
        :setPosition("parent.w / 2 - 6", "parent.h - 2")
        :setSize(15, 3)
        :setBackground(colors.magenta)

    local sendMenu = accountMenu
        :addFrame()
        :setPosition(2, 4)
        :setSize("parent.w - 2", "parent.h - 4")
        :setBackground(colors.white)
        :hide()
        :disable()
 
    sendMenu:addLabel()
        :setText("Send money")
        :setPosition(1,1)
        :setSize(8,1)

    sendMenu:addLabel()
        :setText("Recipient: ")
        :setPosition(1,3)
        :setSize(10,1)

    local sendToInput = sendMenu:addInput()
        :setPosition(1, 4)
        :setSize(20, 1)
        :setInputLimit(20)
        :setInputType("text")
        :setZIndex(1)

    sendMenu:addLabel()
        :setText("Amount: ")
        :setPosition(1,6)
        :setSize(10,1)

    local sendAmountInput = sendMenu:addInput()
        :setPosition(1, 7)
        :setSize(20, 1)
        :setInputLimit(20)
        :setInputType("number")
        :setValue(0)
        :setZIndex(1)

    local sendErrorLabel = sendMenu:addLabel()
        :setText("")
        :setPosition(1, 8)
        :setSize("parent.w", 1)
        :setForeground(colors.red)
    local sendErrorLabel2 = sendMenu:addLabel()
        :setText("")
        :setPosition(1, 9)
        :setSize("parent.w", 1)
        :setForeground(colors.red)

    local confirmSendButton = sendMenu:addButton()
        :setText("Confirm")
        :setPosition("parent.w / 2 - 6", 10)
        :setSize(15, 3)
        :setBackground(colors.magenta)

    local backFromSendButton = sendMenu:addButton()
        :setText("Back")
        :setPosition("parent.w / 2 - 6", "parent.h - 2")
        :setSize(15, 3)
        :setBackground(colors.magenta)

    local firstSuggession = sendMenu:addLabel()
        :setText("")
        :setForeground(colors.green)
        :setPosition(20, 4)
        :setSize(20, 1)
        :setZIndex(5)

    local recipientSuggessionList = sendMenu:addList()
        :setPosition(1, 5)
        :setSize(20, 10)
        :setBackground(colors.gray)
        :setZIndex(4)
        :setSelectionColor(colors.lightBlue, colors.black)
        :hide()


    local historyMenu = accountMenu
        :addFrame()
        :setPosition(2, 4)
        :setSize("parent.w - 2", "parent.h - 4")
        :setBackground(colors.white)
        :hide()
        :disable()

    local historyLabel = historyMenu:addLabel()
        :setText("History:")
        :setPosition(1,1)
        :setSize(8,1)

    local historyLabels = {}

    for i = 1, 10 do
        historyLabels[i] = historyMenu:addLabel()
            :setText("")
            :setPosition(1, 2 + i)
            :setSize(30, 1)
    end

    local backFromHistoryButton = historyMenu:addButton()
        :setText("Back")
        :setPosition("parent.w / 2 - 6", "parent.h - 2")
        :setSize(15, 3)
        :setBackground(colors.magenta)


    local function refreshUserData()
        local user = bankAPI.getUser()
        if user == false then
            errorLabel:setText("Failed to get user data")
            return
        end

        accountNameValueLabel:setText(user.login)
        local balanceValueRounded = math.floor(user.balance * 100) / 100
        balanceValueLabel:setText(balanceValueRounded .. "$")

        if #user.transactions == 0 then
            transactionsLabels[1]:setText("No transactions")
        else
            local transactionCount = #user.transactions
        
            for i = 1, 10 do
                local transactionIndex = transactionCount - i + 1
                if transactionIndex > 0 then
                    local transaction = user.transactions[transactionIndex]
                    local transactionAmountRounded = math.floor(transaction.amount * 100) / 100
                    transactionsLabels[i]:setText(transaction.from .. " -> " .. transaction.to .. ": " .. transactionAmountRounded .. "$")
                else
                    transactionsLabels[i]:setText("")
                end
            end
        end

        -- {deviceId = p2, device=isPocket, success=false, time=requestTime, message="Wrong password"})
        if #user.history == 0 then
            historyLabels[1]:setText("No history")
        else
            local historyCount = #user.history
        
            for i = 1, 10 do
                local historyIndex = historyCount - i + 1
                if historyIndex > 0 then
                    local history = user.history[historyIndex]
                    historyLabels[i]:setText(os.date("%R", history.time) .. ":" .. history.message)
                else
                    historyLabels[i]:setText("")
                end
            end
        end
    end



    local function openTransactionsMenu()
        refreshUserData()

        -- Show transactions menu
        transactionsMenu:show():enable():setFocus()

        -- Hide other menus
        sendMenu:hide():disable()
        historyMenu:hide():disable()

        -- Hide buttons
        transactionsButton:hide():disable()
        sendButton:hide():disable()
        historyButton:hide():disable()
        logoutButton:hide():disable()
    end

    local function openSendMenu()
        refreshUserData()

        -- Show send menu
        sendMenu:show():enable():setFocus()

        -- Hide other menus
        transactionsMenu:hide():disable()
        historyMenu:hide():disable()

        -- Hide buttons
        transactionsButton:hide():disable()
        sendButton:hide():disable()
        historyButton:hide():disable()
        logoutButton:hide():disable()
    end

    local function openHistoryMenu()
        refreshUserData()

        -- Show history menu
        historyMenu:show():enable():setFocus()

        -- Hide other menus
        transactionsMenu:hide():disable()
        sendMenu:hide():disable()
        
        -- Hide buttons
        transactionsButton:hide():disable()
        sendButton:hide():disable()
        historyButton:hide():disable()
        logoutButton:hide():disable()
    end

    local function openAccountMenu()
        loginInput:setValue("")
        passwordInput:setValue("")
        loginErrorLabel:setText("")
        passwordErrorLabel:setText("")
        passwordErrorLabel2:setText("")
        mainMenu:hide():disable()
        sendToInput:setValue("")
        sendAmountInput:setValue(0)
        accountMenu:show():enable():setFocus()
    end

    local function openRegisterMenu()
        registerLoginInput:setValue(loginInput:getValue())
        loginInput:setValue("")
        registerPasswordInput:setValue(passwordInput:getValue())
        passwordInput:setValue("")

        mainMenu:hide():disable()
        registerMenu:show():enable():setFocus()
    end
    
    local function closeTransactionsMenu()
        -- Hide transactions menu
        transactionsMenu:hide():disable()

        -- Show buttons
        transactionsButton:show():enable()
        sendButton:show():enable()
        historyButton:show():enable()
        logoutButton:show():enable()

        -- Show account menu
        accountMenu:getParent():clearFocusedChild()
        accountMenu:show():enable():setFocus()
    end

    local function closeSendMenu()
        -- Hide send menu
        sendMenu:hide():disable()

        -- Show buttons
        transactionsButton:show():enable()
        sendButton:show():enable()
        historyButton:show():enable()
        logoutButton:show():enable()

        -- Show account menu
        accountMenu:getParent():clearFocusedChild()
        accountMenu:show():enable():setFocus()
    end

    local function closeHistoryMenu()
        -- Hide history menu
        historyMenu:hide():disable()

        -- Show buttons
        transactionsButton:show():enable()
        sendButton:show():enable()
        historyButton:show():enable()
        logoutButton:show():enable()

        -- Show account menu
        accountMenu:getParent():clearFocusedChild()
        accountMenu:show():enable():setFocus()
    end


    local function closeAccountMenu()
        accountNameValueLabel:setText("")
        balanceValueLabel:setText("")
        for i = 1, 10 do
            transactionsLabels[i]:setText("")
        end
        accountMenu:hide():disable()
        mainMenu:show():enable():setFocus()
    end

    local function closeRegisterMenu()
        registerLoginInput:setValue("")
        registerPasswordInput:setValue("")
        passwordRepeatInput:setValue("")

        registerMenu:hide():disable()
        mainMenu:show():enable()
        loginInput:setFocus()
        mainMenu:setFocus()
    end

    local function registerUser(login, password, passwordRepeat)
        registerErrorLabel1:setText("")
        registerErrorLabel2:setText("")

        if login == "" then
            registerErrorLabel1:setText("Please specify login")
            return
        elseif password == "" then
            registerErrorLabel1:setText("Please specify password")
            return
        elseif passwordRepeat == "" then
            registerErrorLabel1:setText("Please repeat password")
            return
        elseif password ~= passwordRepeat then
            registerErrorLabel1:setText("Passwords do not match")
            return
        end

        local isSuccess, message = bankAPI.register(login, password)
        if isSuccess then
            closeRegisterMenu()
            passwordErrorLabel:setForeground(colors.green)
            passwordErrorLabel2:setForeground(colors.green)
            wrap(passwordErrorLabel, passwordErrorLabel2, "User \"" .. login .. "\" registered", 20)
        else
            wrap(registerErrorLabel1, registerErrorLabel2, message, 20)
        end
    end

    local function loginUser(login, password)
        loginErrorLabel:setText("")
        passwordErrorLabel:setText(""):setForeground(colors.red)
        passwordErrorLabel2:setText(""):setForeground(colors.red)

        if login == "" then
            loginErrorLabel:setText("Please specify login")
            return
        elseif password == "" then
            passwordErrorLabel:setText("Please specify password")
            return
        end

        local isSuccess, message = bankAPI.login(login, password)
        if isSuccess then
                refreshUserData()
                openAccountMenu()
        else
            wrap(passwordErrorLabel, passwordErrorLabel2, message, 20)
        end
    end

    local function logoutUser()
        local isSuccess = bankAPI.logout()
        if isSuccess then
            closeAccountMenu()
        end
    end

    local function sendMoney(recipient, amount)

        if recipient == "" then
            sendErrorLabel:setForeground(colors.red)
            sendErrorLabel2:setForeground(colors.red)

            wrap(sendErrorLabel, sendErrorLabel2, "Please specify recipient", 20)
            return
        elseif amount == nil then
            sendErrorLabel:setForeground(colors.red)
            sendErrorLabel2:setForeground(colors.red)

            wrap(sendErrorLabel, sendErrorLabel2, "Please specify amount", 20)
            return
        elseif amount <= 0 then
            sendErrorLabel:setForeground(colors.red)
            sendErrorLabel2:setForeground(colors.red)

            wrap(sendErrorLabel, sendErrorLabel2, "Amount must be greater than 0", 20)
            return
        end

        local isSuccess, message = bankAPI.sendMoney(recipient, amount)
        if isSuccess then
            sendToInput:setValue("")
            sendAmountInput:setValue(0)
            refreshUserData()

            sendErrorLabel:setForeground(colors.green)
            sendErrorLabel2:setForeground(colors.green)

            wrap(sendErrorLabel, sendErrorLabel2, "Money sent to " .. recipient, 20)
        else
            sendErrorLabel:setForeground(colors.red)
            sendErrorLabel2:setForeground(colors.red)

            wrap(sendErrorLabel, sendErrorLabel2, message, 20)
        end
    end


    -- Keyboard events
    mainMenu:onKey(function(self, event, key)
        if key == keys.up then
            if loginInput:isFocused() then
                registerButton:setFocus()
            elseif passwordInput:isFocused() then
                loginInput:setFocus()
            elseif loginButton:isFocused() then
                passwordInput:setFocus()
            elseif registerButton:isFocused() then
                loginButton:setFocus()
            end
        elseif key == keys.down or key == keys.tab then
            if loginInput:isFocused() then
                passwordInput:setFocus()
            elseif passwordInput:isFocused() then
                loginButton:setFocus()
            elseif loginButton:isFocused() then
                registerButton:setFocus()
            elseif registerButton:isFocused() then
                loginInput:setFocus()
            end        
        elseif key == keys.enter and self:isEnabled() then
            if loginButton:isFocused() then
                local login = loginInput:getValue()
                local password = passwordInput:getValue()
        
                loginUser(login, password)
                return false
            elseif registerButton:isFocused() then
                openRegisterMenu()
                return false
            end
        end
    end)

    registerMenu:onKey(function(self, event, key)
        if key == keys.up then
            if registerLoginInput:isFocused() then
                passwordRepeatInput:setFocus()
            elseif registerPasswordInput:isFocused() then
                registerLoginInput:setFocus()
            elseif passwordRepeatInput:isFocused() then
                registerPasswordInput:setFocus()
            elseif confirmRegisterButton:isFocused() then
                passwordRepeatInput:setFocus()
            elseif backFromRegisterButton:isFocused() then
                passwordRepeatInput:setFocus()
            end
        elseif key == keys.down or key == keys.tab then
            if registerLoginInput:isFocused() then
                registerPasswordInput:setFocus()
            elseif registerPasswordInput:isFocused() then
                passwordRepeatInput:setFocus()
            elseif passwordRepeatInput:isFocused() then
                confirmRegisterButton:setFocus()
            elseif confirmRegisterButton:isFocused() then
                registerLoginInput:setFocus()
            elseif backFromRegisterButton:isFocused() then
                registerLoginInput:setFocus()
            end
        elseif key == keys.left or key == keys.right then
            if confirmRegisterButton:isFocused() then
                backFromRegisterButton:setFocus()
            elseif backFromRegisterButton:isFocused() then
                confirmRegisterButton:setFocus()
            end
        elseif key == keys.enter and self:isEnabled() then
            if confirmRegisterButton:isFocused() then
                local login = registerLoginInput:getValue()
                local password = registerPasswordInput:getValue()
                local passwordRepeat = passwordRepeatInput:getValue()

                registerUser(login, password, passwordRepeat)
                return false
            elseif backFromRegisterButton:isFocused() then
                closeRegisterMenu()
                return false
            end
        end
    end)

    accountMenu:onKey(function(self, event, key)
        if key == keys.up then
            if transactionsButton:isFocused() then
                logoutButton:setFocus()
            elseif sendButton:isFocused() then
                transactionsButton:setFocus()
            elseif historyButton:isFocused() then
                sendButton:setFocus()
            elseif logoutButton:isFocused() then
                historyButton:setFocus()
            end
        elseif key == keys.down or key == keys.tab then
            if transactionsButton:isFocused() then
                sendButton:setFocus()
            elseif sendButton:isFocused() then
                historyButton:setFocus()
            elseif historyButton:isFocused() then
                logoutButton:setFocus()
            elseif logoutButton:isFocused() then
                transactionsButton:setFocus()
            end
        elseif key == keys.left then
            if transactionsButton:isFocused() then
                openTransactionsMenu()
            elseif sendButton:isFocused() then
                openSendMenu()
            elseif historyButton:isFocused() then
                openHistoryMenu()
            end
        elseif key == keys.enter and self:isEnabled() then
            if not transactionsMenu:isEnabled() and not sendMenu:isEnabled() and not historyMenu:isEnabled() then        
                log("No menu enabled")
                if transactionsButton:isFocused() then
                    openTransactionsMenu()
                elseif sendButton:isFocused() then
                    openSendMenu()
                    sendToInput:setFocus()
                elseif historyButton:isFocused() then
                    openHistoryMenu()
                elseif logoutButton:isFocused() then
                    logoutUser()
                end
                return false
            end
        end
    end)

    transactionsMenu:onKey(function(self, event, key)
        if self:isEnabled() then
            if key == keys.up or key == keys.tab or key == keys.down then
                backFromTransactionsButton:setFocus()
            elseif key == keys.enter then
                if backFromTransactionsButton:isFocused() then
                    closeTransactionsMenu()
                end
            end
        end
    end)

    sendMenu:onKey(function(self, event, key)
        if self:isEnabled() then
            if key == keys.up then
                local currentSelectedIndex = recipientSuggessionList:getItemIndex()
                local suggessionsCount = recipientSuggessionList:getItemCount()

                if recipientSuggessionList.isVisible() and suggessionsCount > 0 and currentSelectedIndex ~= 1 then
                    return
                end

                if sendToInput:isFocused() then
                    backFromSendButton:setFocus()
                elseif sendAmountInput:isFocused() then
                    sendToInput:setFocus()
                elseif confirmSendButton:isFocused() then
                    sendAmountInput:setFocus()
                elseif backFromSendButton:isFocused() then
                    confirmSendButton:setFocus()
                end
            
            elseif key == keys.down then
                local currentSelectedIndex = recipientSuggessionList:getItemIndex()
                local suggessionsCount = recipientSuggessionList:getItemCount()

                if recipientSuggessionList.isVisible() and suggessionsCount > 0 and (currentSelectedIndex ~= suggessionsCount and suggessionsCount > 1) then
                    return
                end

                if sendToInput:isFocused() then
                    sendAmountInput:setFocus()
                elseif sendAmountInput:isFocused() then
                    confirmSendButton:setFocus()
                elseif confirmSendButton:isFocused() then
                    backFromSendButton:setFocus()
                elseif backFromSendButton:isFocused() then
                    sendToInput:setFocus()
                end
            elseif key == keys.enter then
                if confirmSendButton:isFocused() then
                    local recipient = sendToInput:getValue()
                    local amount = sendAmountInput:getValue()
                    sendMoney(recipient, amount)
                elseif backFromSendButton:isFocused() then
                    closeSendMenu()
                end
            end
        end
    end)

    historyMenu:onKey(function(self, event, key)
        if self:isEnabled() then
            if key == keys.up or key == keys.tab or key == keys.down then
                backFromHistoryButton:setFocus()
            elseif key == keys.enter then
                if backFromHistoryButton:isFocused() then
                    closeHistoryMenu()
                end
            end
        end
    end)


    loginInput:onKey(function(self, event, key)
        if key == keys.enter then
            if self.getValue() ~= "" then
                passwordInput:setFocus()
            end
            return false
        elseif key == keys.delete then
            local cursorPos = self:getTextOffset()
            local value = tostring(self:getValue())
            if cursorPos <= #value then
                self:setValue(value:sub(1, cursorPos - 1) .. value:sub(cursorPos + 1))
                self:setTextOffset(cursorPos)
            end
        elseif key ==keys["end"] then
            self:setTextOffset(#tostring(self:getValue()) + 1)
        elseif key == keys["home"] then
            self:setTextOffset(1)
        end
    end)

    passwordInput:onKey(function(self, event, key)
        if key == keys.enter then
            if self.getValue() ~= "" then
                loginButton:setFocus()
            end
            return false
        elseif key ==keys["end"] then
            self:setTextOffset(#tostring(self:getValue()) + 1)
        elseif key == keys["home"] then
            self:setTextOffset(1)
        end
    end)


    local function updateSuggessionList()
        local value = sendToInput:getValue()
        local charsCount = #value + 1
        if charsCount < 3 or not sendToInput:isFocused() then
            firstSuggession:setText("")
            recipientSuggessionList:clear():hide()
            return
        end

        local existingUsers = bankAPI.getRegisteredUsers()
        local suggestions = {}
        for i = 1, 5 do
            if existingUsers[i] ~= nil and existingUsers[i]:find(value) == 1 then
                table.insert(suggestions, existingUsers[i])
            end
        end
        recipientSuggessionList:clear()
        local suggessionsSize = math.min(5, #suggestions)
        if suggessionsSize > 0 then
            recipientSuggessionList:show()

            for i = 1, suggessionsSize do
                recipientSuggessionList:addItem(suggestions[i] or "EMPTY", colors.gray, colors.green)
            end
            recipientSuggessionList:setSize(20, suggessionsSize)

            local selectedIndex = recipientSuggessionList:getItemIndex()
            local selectedValue = recipientSuggessionList:getItem(selectedIndex).text
            firstSuggession:setText(selectedValue:sub(charsCount))
            firstSuggession:setPosition(charsCount, sendToInput:getY())
        else
            recipientSuggessionList:hide()
            firstSuggession:setText("")
            firstSuggession:setPosition(charsCount, sendToInput:getY())
        end
    end


    sendToInput:onKey(function(self, event, key)
        local inputValue = self:getValue()
        if key == keys.enter then
            if firstSuggession:getText() ~= "" then
                self:setValue(inputValue .. firstSuggession:getText())
                updateSuggessionList()
            end

            if inputValue ~= "" then
                sendAmountInput:setFocus()
            end
            return false
        elseif key == keys.delete then
            local cursorPos = self:getTextOffset()
            local value = tostring(inputValue)
            if cursorPos <= #value then
                self:setValue(value:sub(1, cursorPos - 1) .. value:sub(cursorPos + 1))
                self:setTextOffset(cursorPos)
            end
        elseif key == keys.tab then
            if firstSuggession:getText() ~= "" then
                self:setValue(inputValue .. firstSuggession:getText())
                updateSuggessionList()
            end
        elseif key == keys.down then
            if recipientSuggessionList:isVisible() then
                local selectedIndex = recipientSuggessionList:getItemIndex()
                if selectedIndex < recipientSuggessionList:getItemCount() then
                    recipientSuggessionList:selectItem(selectedIndex + 1)
                    local selectedValue = recipientSuggessionList:getItem(selectedIndex + 1).text
                    firstSuggession:setText(selectedValue:sub(#inputValue + 1))
                    firstSuggession:setPosition(#inputValue + 1, sendToInput:getY())
                end
            end

        elseif key == keys.up then
            if recipientSuggessionList:isVisible() then
                local selectedIndex = recipientSuggessionList:getItemIndex()
                if selectedIndex > 1 then
                    recipientSuggessionList:selectItem(selectedIndex - 1)
                    local selectedValue = recipientSuggessionList:getItem(selectedIndex - 1).text
                    firstSuggession:setText(selectedValue:sub(#inputValue + 1))
                    firstSuggession:setPosition(#inputValue + 1, sendToInput:getY())
                end
            end
            
        elseif key ==keys["end"] then
            self:setTextOffset(#tostring(inputValue) + 1)
        elseif key == keys["home"] then
            self:setTextOffset(1)
        end
    end)

    sendToInput:onKeyUp(function(self, event, key)
        if key ~= keys.down then
            updateSuggessionList()
        end
    end)

    sendAmountInput:onKey(function(self, event, key)
        if key == keys.enter then
            if self:getValue() ~= "" then
                confirmSendButton:setFocus()
            end
            return false
        elseif key == keys.delete then
            local cursorPos = self:getTextOffset()
            local value = tostring(self:getValue())
            if cursorPos <= #value then
                self:setValue(value:sub(1, cursorPos - 1) .. value:sub(cursorPos + 1))
                self:setTextOffset(cursorPos)
            end
        elseif key ==keys["end"] then
            self:setTextOffset(#tostring(self:getValue()) + 1)
        elseif key == keys["home"] then
            self:setTextOffset(1)
        end
    end)

    sendAmountInput:onChar(function(self, event, char)
        if char == "-" then
            return false
        end

        if tonumber(char) == nil and char ~= '.' then
            return false
        end

        if self:getValue() == 0 then
            self:setValue("")
        end
    end)

    sendAmountInput:onKeyUp(function(self, event, key)
        if self:getValue() == "" then
            self:setValue(0)
        end
    end)

    registerLoginInput:onKey(function(self, event, key)
        if key == keys.enter then
            if self.getValue() ~= "" then
                registerPasswordInput:setFocus()
            end
            return false
        elseif key == keys.delete then
            local cursorPos = self:getTextOffset()
            local value = tostring(self:getValue())
            if cursorPos <= #value then
                self:setValue(value:sub(1, cursorPos - 1) .. value:sub(cursorPos + 1))
                self:setTextOffset(cursorPos)
            end
        elseif key ==keys["end"] then
            self:setTextOffset(#tostring(self:getValue()) + 1)
        elseif key == keys["home"] then
            self:setTextOffset(1)
        end
    end)

    registerPasswordInput:onKey(function(self, event, key)
        if key == keys.enter then
            if self.getValue() ~= "" then
                passwordRepeatInput:setFocus()
            end
            return false
        elseif key ==keys["end"] then
            self:setTextOffset(#tostring(self:getValue()) + 1)
        elseif key == keys["home"] then
            self:setTextOffset(1)
        end
    end)

    passwordRepeatInput:onKey(function(self, event, key)
        if key == keys.enter then
            if self.getValue() ~= "" then
                confirmRegisterButton:setFocus()
            end
            return false
        elseif key ==keys["end"] then
            self:setTextOffset(#tostring(self:getValue()) + 1)
        elseif key == keys["home"] then
            self:setTextOffset(1)
        end
    end)
    

    -- On focus events
    local lastMainMenuFocus = loginInput
    local lastRegisterMenuFocus = registerLoginInput
    local lastAccountMenuFocus = transactionsButton
    local lastSendMenuFocus = sendToInput

    loginInput:onGetFocus(function(self)
        lastMainMenuFocus = loginInput
    end)

    passwordInput:onGetFocus(function(self)
        lastMainMenuFocus = passwordInput
    end)

    loginButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Login<")
        lastMainMenuFocus = self
    end)

    loginButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Login")
    end)

    registerButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Register<")
        lastMainMenuFocus = self
    end)

    registerButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Register")
    end)

    confirmRegisterButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Register<")
        lastRegisterMenuFocus = self
    end)

    confirmRegisterButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Register")
    end)

    backFromRegisterButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Back<")
        lastRegisterMenuFocus = self
    end)

    backFromRegisterButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Back")
    end)

    registerLoginInput:onGetFocus(function(self)
        lastRegisterMenuFocus = self
    end)

    registerPasswordInput:onGetFocus(function(self)
        lastRegisterMenuFocus = self
    end)

    passwordRepeatInput:onGetFocus(function(self)
        lastRegisterMenuFocus = self
    end)

    transactionsButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Transactions<")
        lastAccountMenuFocus = self
    end)

    transactionsButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Transactions")
    end)

    sendButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Send<")
        lastAccountMenuFocus = self
    end)

    sendButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Send")
    end)

    historyButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">History<")
        lastAccountMenuFocus = self
    end)

    historyButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("History")
    end)

    logoutButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Logout<")
        lastAccountMenuFocus = self
    end)

    logoutButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Logout")
    end)

    sendToInput:onGetFocus(function(self)
        lastSendMenuFocus = self
    end)

    sendToInput:onLoseFocus(function(self)
        recipientSuggessionList:hide()
        firstSuggession:setText("")
    end)

    sendAmountInput:onGetFocus(function(self)
        lastSendMenuFocus = self
    end)

    confirmSendButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Confirm<")
        lastSendMenuFocus = self
    end)

    confirmSendButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Confirm")
    end)

    backFromSendButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Back<")
        lastSendMenuFocus = self
    end)

    backFromSendButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Back")
    end)

    backFromTransactionsButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Back<")
    end)

    backFromTransactionsButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Back")
    end)

    backFromSendButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Back<")
    end)

    backFromSendButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Back")
    end)

    backFromHistoryButton:onGetFocus(function(self)
        self:setBackground(colors.lightBlue)
        self:setText(">Back<")
    end)

    backFromHistoryButton:onLoseFocus(function(self)
        self:setBackground(colors.magenta)
        self:setText("Back")
    end)

    mainMenu:onGetFocus(function(self)
        lastMainMenuFocus:setFocus()
    end)

    registerMenu:onGetFocus(function(self)
        lastRegisterMenuFocus:setFocus()
    end)

    accountMenu:onGetFocus(function(self)
        log("accountMenu foccused")
        lastAccountMenuFocus:setFocus()
    end)

    sendMenu:onGetFocus(function(self)
        lastSendMenuFocus:setFocus()
    end)

    transactionsMenu:onGetFocus(function(self)
        backFromTransactionsButton:setFocus()
    end)

    historyMenu:onGetFocus(function(self)
        backFromHistoryButton:setFocus()
    end)

    -- On click events

    mainMenu:onClickUp(function(self)
        lastMainMenuFocus:setFocus()
    end)

    registerMenu:onClickUp(function(self)
        lastRegisterMenuFocus:setFocus()
    end)

    main:onClickUp(function(self)
        if mainMenu:isEnabled() then
            mainMenu:setFocus()
        elseif registerMenu:isEnabled() then
            registerMenu:setFocus()
        elseif transactionsMenu:isEnabled() then
            transactionsMenu:setFocus()
            backFromTransactionsButton:setFocus()
        elseif sendMenu:isEnabled() then
            sendMenu:setFocus()
        elseif historyMenu:isEnabled() then
            historyMenu:setFocus()
        elseif accountMenu:isEnabled() then
            accountMenu:setFocus()
            lastAccountMenuFocus:setFocus()
        end
    end)

    confirmSendButton:onClick(function(self)
        local recipient = sendToInput:getValue()
        local amount = sendAmountInput:getValue()
        sendMoney(recipient, amount)
    end)

    
    loginButton:onClick(function(self)
        self:setFocus()
        local login = loginInput:getValue()
        local password = passwordInput:getValue()

        loginUser(login, password)
    end)

    registerButton:onClick(function(self)
        openRegisterMenu()
    end)

    confirmRegisterButton:onClick(function(self)
        local login = registerLoginInput:getValue()
        local password = registerPasswordInput:getValue()
        local passwordRepeat = passwordRepeatInput:getValue()

        registerUser(login, password, passwordRepeat)
    end)

    backFromRegisterButton:onClick(function(self)
        closeRegisterMenu()
    end)


    transactionsButton:onClick(function(self)
        openTransactionsMenu()
    end)

    sendButton:onClick(function(self)
        openSendMenu()
    end)

    historyButton:onClick(function(self)
        openHistoryMenu()
    end)

    logoutButton:onClick(function(self)
        logoutUser()
    end)

    backFromTransactionsButton:onClick(function(self)
        closeTransactionsMenu()
    end)

    backFromSendButton:onClick(function(self)
        closeSendMenu()
    end)

    backFromHistoryButton:onClick(function(self)
        closeHistoryMenu()
    end)


    mainMenu:setFocus()
    basalt.autoUpdate()
end

bankAPI.start(main)