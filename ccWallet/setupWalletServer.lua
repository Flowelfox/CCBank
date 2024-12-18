local bankAPI = require("bankAPI")
local basalt = require("basalt")


term.clear()
term.setCursorPos(1, 1)
local function main()
    if fs.exists(".walletServerAddress.txt") then
        return
    end

    local modem = peripheral.find("modem")
    if not modem then
        print("No modem found")
        return
    end

    print("Searching for running servers...")
    local runningServers = bankAPI.getRunningServers(peripheral.getName(modem))
    if #runningServers == 0 then
        print("No servers running")
        return
    end




    -- Create main frame with border
    local mainFrame = basalt.createFrame()
        :setBackground(colors.lightGray)
        :setForeground(colors.white)

    -- Create inner frame with margin
    local innerFrame = mainFrame:addFrame()
        :setBackground(colors.gray)
        :setPosition(2, 2)
        :setSize("parent.w - 2", "parent.h - 2")

    -- Create decorative header
    local headerFrame = innerFrame:addFrame()
        :setPosition(1, 1)
        :setSize("parent.w", 3)
        :setBackground(colors.gray)

    -- Add decorative top border
    local topBorder = headerFrame:addLabel()
        :setText(string.rep("=", headerFrame:getWidth()))
        :setForeground(colors.magenta)
        :setBackground(colors.black)
        :setPosition(1, 1)

    -- Add title with better styling
    headerFrame:addLabel()
        :setText("Select Server")
        :setForeground(colors.magenta)
        :setBackground(colors.black)
        :setPosition("parent.w / 2 - 6", 2)

    -- Add decorative bottom border
    local bottomBorder = headerFrame:addLabel()
        :setText(string.rep("=", headerFrame:getWidth()))
        :setForeground(colors.magenta)
        :setBackground(colors.black)
        :setPosition(1, 3)

    local function saveData(address)
        local file = fs.open(".walletServerAddress.txt", "w")
        file.write(address)
        file.close()
    end

    -- Create server buttons with improved styling
    local buttons = {}
    local yPos = 5 -- Starting Y position after header
    for i, server in ipairs(runningServers) do
        local serverName = server.name:sub(1, 16) -- Strip server name to 16 symbols
        local button = innerFrame:addButton()
            :setText(serverName)
            :setPosition(2, yPos)
            :setSize("parent.w - 2", 3)
            :setBackground(colors.magenta)
            :setForeground(colors.white)
        
        -- Store server data with the button
        button.serverData = server
        
        table.insert(buttons, button)
        yPos = yPos + 3 -- Increment Y position by button height

        -- Add hover effects
        button:onGetFocus(function(self)
            self:setBackground(colors.lightBlue)
            self:setText(">" .. serverName .. "<")
        end)

        button:onLoseFocus(function(self)
            self:setBackground(colors.magenta)
            self:setText(serverName)
        end)

        -- Add click handler
        button:onClick(function()
            -- Save selected server address
            saveData(server.address)
            
            -- Close program
            basalt.stop()
        end)
    end

    -- Set focus to first button
    if #buttons > 0 then
        buttons[1]:setFocus()
    end

    -- Add keyboard navigation
    mainFrame:onKey(function(self, event, key)
        -- Guard against empty buttons table
        if #buttons == 0 then
            return
        end

        -- Find currently focused button
        local currentIndex = nil
        for i, button in ipairs(buttons) do
            if button:isFocused() then
                currentIndex = i
                break
            end
        end

        -- If no button is focused, focus the first one
        if not currentIndex then
            buttons[1]:setFocus()
            currentIndex = 1
        end

        if key == keys.up then
            local newIndex = currentIndex - 1
            if newIndex < 1 then
                newIndex = #buttons
            end
            buttons[newIndex]:setFocus()
        elseif key == keys.down or key == keys.tab then
            local newIndex = currentIndex + 1
            if newIndex > #buttons then
                newIndex = 1
            end
            buttons[newIndex]:setFocus()
        elseif key == keys.enter then
            local focusedButton = buttons[currentIndex]
            if focusedButton then
                -- Save selected server address using the stored server data
                saveData(focusedButton.serverData.address)
                
                -- Close program
                basalt.stop()
            end
        end
    end)

    basalt.autoUpdate()
end

main()
