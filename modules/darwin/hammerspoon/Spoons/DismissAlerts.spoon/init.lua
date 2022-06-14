--- === Dismiss Alerts ===

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "DismissAlerts"
obj.version = "0.1"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "k", function()
        hs.osascript.javascriptFromFile("Spoons/DismissAlerts.spoon/close_notifications_applescript.js")
    end)
end

return obj
