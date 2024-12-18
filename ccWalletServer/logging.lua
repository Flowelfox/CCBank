local function hang()
    while true do
        local event, key, is_held = os.pullEvent("key")
        if key ~= nil then
            return
        end
        sleep(1)
    end
end

local function setup(monitor_name, level)
    level = level or "INFO"

    settings.load()
    local settingsData = settings.get("logging")
    settingsData = {
        logLevel = level,
        logMonitor = monitor_name
    }
    settings.set("logging", settingsData)
    settings.save()
    return settingsData
end

local function loadSettings()
    local settingsData = settings.get("logging")
    if settingsData == nil then
        settingsData = setup("", "INFO")
    end
    return settingsData
end

local function getLoggingMonitor()  
    local settingsData = loadSettings()
    local loggingMonitor = peripheral.find(settingsData.logMonitor)
    if loggingMonitor == nil then
        return term
    else
        loggingMonitor.setTextScale(0.5)
        return loggingMonitor
    end
end


local function setLoggingMonitor(monitor)
    local settingsData = loadSettings()
    settingsData.logMonitor = monitor
    settings.set("logging", settingsData)
    settings.save()
end

local function setLoggingLevel(level)
    local settingsData = loadSettings()
    settingsData.logLevel = level
    settings.set("logging", settingsData)
    settings.save()
end


local function logingLevelIndex(level)
    if level == "DEBUG" then
        return 1
    elseif level == "INFO" then
        return 2
    elseif level == "WARNING" then
        return 3
    elseif level == "ERROR" then
        return 4
    elseif level == "CRITICAL" then
        return 5
    end
end

local function getLoggingLevel()
    local settingsData = loadSettings()
    local logLevelIndex = logingLevelIndex(settingsData.logLevel)
    if logLevelIndex == nill then
        printError("Logging level not set, setting to \"INFO\"")
        setLoggingLevel("INFO")
        return "INFO"
    else
        return settingsData.logLevel
    end
end

local function _log(text, level)
    local loggingMonitor = getLoggingMonitor()
    local loggingLevel = getLoggingLevel()

    local x, y = loggingMonitor.getCursorPos()
    local currentLevelIndex = logingLevelIndex(level)
    if currentLevelIndex < logingLevelIndex(loggingLevel) then
        return
    end

    if level == "DEBUG" then
        loggingMonitor.setTextColor(colors.gray)
    elseif level == "INFO" then
        loggingMonitor.setTextColor(colors.lightBlue)
    elseif level == "WARNING" then
        loggingMonitor.setTextColor(colors.yellow)
    elseif level == "ERROR" then
        loggingMonitor.setTextColor(colors.red)
    elseif level == "CRITICAL" then
        loggingMonitor.setTextColor(colors.red)
        loggingMonitor.write("!!!")
    end

    
    local width, height = loggingMonitor.getSize()
    
    if y >= height then
        loggingMonitor.scroll(1)
        loggingMonitor.setCursorPos(1, height)
    else
        loggingMonitor.setCursorPos(1, y + 1)
    end


    local currentTime = os.date("%T")
    loggingMonitor.write(currentTime .. " (".. level .."): " .. text)
end


function clear()
    local loggingMonitor = getLoggingMonitor()
    loggingMonitor.clear()
end

local function logDebug(text)
    _log(text, "DEBUG")
end
local function logInfo(text)
    _log(text, "INFO")
end
local function logWarning(text)
    _log(text, "WARNING")
end
local function logError(text)
    _log(text, "ERROR")
end
local function logCritical(text)
    _log(text, "CRITICAL")
end

local export = {
    setup = setup,
    debug = logDebug,
    info = logInfo,
    warning = logWarning,
    error = logError,
    critical = logCritical,
    DEBUG = "DEBUG",
    INFO = "INFO",
    WARNING = "WARNING",
    ERROR = "ERROR",
    CRITICAL = "CRITICAL"
}

return export