--- === Launcher ===

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Launcher"
obj.version = "0.1"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local screen = hs.screen.primaryScreen()
local switcherWidth = 500

function obj:init()
    -- Begin launcher mode
    if self.launcher == nil then
        self.launcher = hs.hotkey.modal.new("ctrl", "space")

        print(self.canvas)
        print(obj.canvas)
    end

    -- Behaviors on enter
    function self.launcher:entered()
        -- hs.alert("Entered mode")
        obj.canvas = hs.canvas.new({
            x = (screen:fullFrame().x + screen:fullFrame().w) / 2 - switcherWidth / 2,
            y = 1,
            h = 3,
            w = switcherWidth,
        })
        -- Draw switcher
        obj.canvas[#obj.canvas + 1] = {
            action = "build",
            type = "rectangle",
        }
        obj.canvas[#obj.canvas + 1] = {
            type = "rectangle",
            fillColor = { alpha = 1, red = 0.8, green = 0.6, blue = 0.3 },
            action = "fill",
        }
        obj.canvas:show()
    end

    -- Behaviors on exit
    function self.launcher:exited()
        -- hs.alert("Exited mode")
        obj.canvas:delete(0.2)
    end

    -- Use escape to exit launcher mode
    self.launcher:bind("", "escape", function()
        self.launcher:exit()
    end)

    -- Launcher shortcuts
    self.launcher:bind("ctrl", "space", function() end)
    self.launcher:bind("", "return", function()
        self:switch("@wezterm@")
    end)
    self.launcher:bind("", "C", function()
        self:switch("Calendar.app")
    end)
    self.launcher:bind("shift", "D", function()
        hs.execute("launchctl remove com.paloaltonetworks.gp.pangps")
        hs.execute("launchctl remove com.paloaltonetworks.gp.pangpa")
        hs.alert.show("Disconnected from GlobalProtect", nil, nil, 4)
        self.launcher:exit()
    end)
    self.launcher:bind("", "E", function()
        self:switch("Mail.app")
    end)
    self.launcher:bind("", "F", function()
        self:switch("@firefox@")
    end)
    self.launcher:bind("", "H", function()
        self:switch("Hammerspoon.app")
    end)
    self.launcher:bind("", "M", function()
        self:switch("Messages.app")
    end)
    self.launcher:bind("", "O", function()
        self:switch("@obsidian@")
    end)
    self.launcher:bind("", "P", function()
        self:switch("System Preferences.app")
    end)
    self.launcher:bind("shift", "P", function()
        hs.execute("launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist")
        hs.execute("launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist")
        hs.alert.show("Reconnecting to GlobalProtect", nil, nil, 4)
        self.launcher:exit()
    end)
    self.launcher:bind("", "R", function()
        hs.console.clearConsole()
        hs.reload()
    end)
    self.launcher:bind("", "S", function()
        self:switch("@slack@")
    end)
    self.launcher:bind("", "Z", function()
        self:switch("zoom.us.app")
    end)
end

function obj:switch(app)
    hs.application.launchOrFocus(app)
    self.launcher:exit()
end

return obj
