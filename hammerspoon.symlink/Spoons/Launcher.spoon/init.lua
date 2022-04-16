--- === Launcher ===

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Launcher"
obj.version = "0.1"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function drawSwitcher()
    -- Drawing
    canv = hs.canvas.new({ x = 850, y = 1, h = 3, w = 120 })
    canv[#canv + 1] = {
        action = "build",
        type = "rectangle",
    }
    canv[#canv + 1] = {
        type = "rectangle",
        fillColor = { alpha = 1, red = 0.8, green = 0.6, blue = 0.3 },
        action = "fill",
    }
    return canv:show()
end

function obj:init()
    -- Begin launcher mode
    self.launcher = hs.hotkey.modal.new("ctrl", "space")

    -- Behaviors on enter
    function self.launcher:entered()
        -- hs.alert("Entered mode")
        self.canv = drawSwitcher()
    end
    -- Behaviors on exit
    function self.launcher:exited()
        -- hs.alert("Exited mode")
        self.canv:hide()
    end

    -- Use escape to exit launcher mode
    self.launcher:bind("", "escape", function()
        self.launcher:exit()
    end)

    -- Launcher shortcuts
    self.launcher:bind("", "space", function()
        hs.hints.windowHints()
        self.launcher:exit()
    end)
    self.launcher:bind("", "return", function()
        self:switch("Alacritty.app")
    end)
    self.launcher:bind("", "C", function()
        self:switch("Calendar.app")
    end)
    self.launcher:bind("", "D", function()
        self:switch("Discord.app")
    end)
    self.launcher:bind("", "E", function()
        self:switch("Mail.app")
    end)
    self.launcher:bind("", "F", function()
        self:switch("Firefox.app")
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
        hs.reload()
    end)
    self.launcher:bind("", "S", function()
        self:switch("Slack.app")
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
