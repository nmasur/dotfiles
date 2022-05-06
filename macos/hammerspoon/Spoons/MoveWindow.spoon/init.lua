--- === Move Window ===

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MoveWindow"
obj.version = "0.1"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    -- bind hotkey
    hs.hotkey.bind({ "alt", "ctrl", "cmd" }, "n", function()
        -- get the focused window
        local win = hs.window.focusedWindow()
        -- get the screen where the focused window is displayed, a.k.a. current screen
        local screen = win:screen()
        -- compute the unitRect of the focused window relative to the current screen
        -- and move the window to the next screen setting the same unitRect
        win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
    end)
end

return obj
