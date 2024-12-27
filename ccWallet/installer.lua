local NAME = "Wallet Installer"

local DOWNLOADS = {}
local argStr = table.concat({...}, " ")

DOWNLOADS[#DOWNLOADS + 1] = "https://raw.githubusercontent.com/Flowelfox/CCWallet/main/ccWallet/version.txt"
DOWNLOADS[#DOWNLOADS + 1] = "https://basalt.madefor.cc/install.lua"
DOWNLOADS[#DOWNLOADS + 1] = "https://raw.githubusercontent.com/Flowelfox/CCWallet/main/ccWallet/installer.lua"
DOWNLOADS[#DOWNLOADS + 1] = "https://raw.githubusercontent.com/Flowelfox/CCWallet/main/ccWallet/wallet.lua"
DOWNLOADS[#DOWNLOADS + 1] = "https://raw.githubusercontent.com/Flowelfox/CCWallet/main/lib/bankAPI.lua"
DOWNLOADS[#DOWNLOADS + 1] = "https://raw.githubusercontent.com/Flowelfox/CCWallet/main/lib/ecnet2.lua"
DOWNLOADS[#DOWNLOADS + 1] = "https://raw.githubusercontent.com/Flowelfox/CCWallet/main/ccWallet/setupWalletServer.lua"

local disableComputerValidation = false
local width, height = term.getSize()
local totalDownloaded = 0
local barLine = 6
local line = 8
local installFolder = "ccWallet"
local isPocket = false
if pocket then
    isPocket = true
end

local function update(text)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1, line)
    write(text)
    line = line + 1
end

local function bar(ratio)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.lime)
    term.setCursorPos(1, barLine)
    for i = 1, width do
        if (i / width < ratio) then write("|") else write(" ") end
    end
end

local function checkRemoteVersion(attempt)
    local rawData = http.get(DOWNLOADS[1])
    if not rawData then
        if attempt == 3 then error("Failed to check version after 3 attempts!") end
        return checkRemoteVersion(attempt + 1)
    end
    return rawData.readAll()
end

local function download(path, attempt)
    local rawData = http.get(path)
    local fileName = path:match("^.+/(.+)$")
    update("Downloaded " .. fileName .. "!")
    if not rawData then
        if attempt == 3 then error("Failed to download " .. path .. " after 3 attempts!") end
        update("Failed to download " .. path .. ". Trying again (attempt " .. (attempt + 1) .. "/3)")
        return download(path, attempt + 1)
    end
    local data = rawData.readAll()

    local file = fs.open(installFolder .. '/' .. fileName, "w")
    file.write(data)
    file.close()
end

local function downloadAll(downloads, total)
    local nextFile = table.remove(downloads, 1)
    if nextFile then
        sleep(0.3)
        parallel.waitForAll(function() downloadAll(downloads, total) end, function()
            download(nextFile, 1)
            totalDownloaded = totalDownloaded + 1
            bar(totalDownloaded / total)
        end)
    end
end

local function installBasalt()
    if fs.exists("startup") then
        fs.delete("startup")
    end
    shell.run(installFolder .. "/install.lua", "release", "latest.lua")
    fs.delete(installFolder .. "/basalt.lua")
    shell.run("mv", "basalt.lua", installFolder .. "/basalt.lua")
    fs.delete(installFolder .. "/install.lua")
end

local function rewriteStartup()
    local file = fs.open("startup", "w")

    file.writeLine("shell.run(\"".. installFolder .. "/installer.lua\")")
    file.writeLine("shell.run(\"".. installFolder .. "/setupWalletServer.lua\")")
    file.writeLine("while (true) do")
    file.writeLine("	shell.run(\"" .. installFolder .. "/wallet.lua\")")
    file.writeLine("	sleep(1)")
    file.writeLine("end")
    file.close()
end

local function checkCurrentVersion()
    if fs.exists(installFolder .. "/version.txt") then
        local file = fs.open(installFolder .. "/version.txt", "r")
        local version = file.readAll()
        file.close()
        return version
    end
    return nil
end

local function createInstallationFolder()
    if not fs.exists(installFolder) then
        fs.makeDir(installFolder)
    end
end

local function removeOldVersion()
    if fs.exists(installFolder) then
        fs.delete(installFolder)
    end
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

local function validateComputer()
    if disableComputerValidation then
        return true
    end

    if not isPocket then
        printError("This installer is only for Pocket Computers!")
        return false
    end
    local modemSide = getModemSide()
    if not modemSide then
        printError("No modem found, this can be installed on a Pocket Computer with a wireless modem!")
        return false
    end
    local modem = peripheral.wrap(modemSide)
    if not modem.isWireless() then
        printError("This installer is only for Pocket Computers with a wireless modem!")
        return false
    end    
    return true
end

local function install()
    local canInstall = validateComputer()
    if not canInstall then
        return
    end

    -- Check version first without writing to file
    local newVersion = checkRemoteVersion(1)
    local currentVersion = checkCurrentVersion()
    
    if currentVersion == newVersion then
        return
    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.yellow)
    term.clear()

    term.setCursorPos(math.floor(width / 2 - #NAME / 2 + 0.5), 2)
    write(NAME)

    term.setTextColor(colors.white)
    term.setCursorPos(1, barLine - 2)
    if currentVersion then
        term.write("Updating from " .. currentVersion .. " to " .. newVersion .. "...")
    else
        term.write("Installing version " .. newVersion .. "...")
    end

    bar(0)
    totalDownloaded = 0

    removeOldVersion()
    downloadAll(DOWNLOADS, #DOWNLOADS)
    update("Installing basalt...")
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, line + 1)

    installBasalt()
    term.setCursorPos(1, line)

    term.setTextColor(colors.green)
    term.setBackgroundColor(colors.black)
    if currentVersion then
        update("Updated to version " .. newVersion .. "!")
    else
        update("Installed version " .. newVersion .. "!")
    end
    
    rewriteStartup()

    for i = 1, 3 do
        term.setCursorPos(1, line)
        term.clearLine()
        term.write("Rebooting in " .. (4 - i) .. " seconds...")
        sleep(1)
    end
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    os.reboot()
end

install()
