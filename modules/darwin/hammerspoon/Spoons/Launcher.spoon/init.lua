--- === Launcher ===

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Launcher"
obj.version = "0.1"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local width = hs.screen.mainScreen():fullFrame().w
local switcherWidth = 500
obj.canvas = hs.canvas.new({
    x = width / 2 - switcherWidth / 2,
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
        obj.canvas:show()
    end

    -- Behaviors on exit
    function self.launcher:exited()
        -- hs.alert("Exited mode")
        obj.canvas:hide()
    end

    -- Use escape to exit launcher mode
    self.launcher:bind("", "escape", function()
        self.launcher:exit()
    end)

    -- Launcher shortcuts
    self.launcher:bind("ctrl", "space", function()
    end)
    self.launcher:bind("", "return", function()
        self:switch("@kitty@")
    end)
    self.launcher:bind("", "C", function()
        self:switch("Calendar.app")
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
    self.launcher:bind("", "G", function()
        self:switch("Mimestream.app")
    end)
    self.launcher:bind("", "M", function()
        self:switch("Messages.app")
    end)
    self.launcher:bind("", "O", function()
        self:switch("Obsidian.app")
    end)
    self.launcher:bind("", "P", function()
        self:switch("System Preferences.app")
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
