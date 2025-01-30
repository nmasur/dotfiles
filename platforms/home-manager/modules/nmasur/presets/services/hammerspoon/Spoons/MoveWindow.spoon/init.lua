--- === Move Window ===

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MoveWindow"
obj.version = "0.1"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    hs.window.animationDuration = 0.1
    dofile(hs.spoons.resourcePath("worklayout.lua"))()
    -- bind hotkey
    hs.hotkey.bind({ "alt", "ctrl", "cmd" }, "n", function()
        -- get the focused window
        local win = hs.window.focusedWindow()
        -- get the screen where the focused window is displayed, a.k.a. current screen
        local screen = win:screen()
        -- local nextScreen = screen:next()
        -- compute the unitRect of the focused window relative to the current screen
        -- and move the window to the next screen setting the same unitRect
        win:moveToScreen(screen:next(), true, true, 0)
    end)

    hs.hotkey.bind({ "alt", "ctrl", "cmd" }, "b", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        win:moveToScreen(screen:previous(), true, true, 0)
    end)

    -- Maximize
    hs.hotkey.bind({ "alt", "ctrl", "cmd" }, "m", function()
        -- get the focused window
        local win = hs.window.focusedWindow()
        local frame = win:frame()
        -- maximize if possible
        local max = win:screen():fullFrame()
        frame.x = max.x
        frame.y = max.y
        frame.w = max.w
        frame.h = max.h
        win:setFrame(frame)
        -- -- first maximize to grid
        -- hs.grid.maximizeWindow(win)
        -- -- then spam maximize
        -- for i = 1, 8 do
        --     win:maximize()
        -- end
    end)

    -- Half-maximize (right)
    hs.hotkey.bind({ "alt", "ctrl", "cmd" }, "o", function()
        -- get the focused window
        local win = hs.window.focusedWindow()
        local frame = win:frame()
        -- maximize if possible
        local max = win:screen():fullFrame()
        frame.x = (max.x * 2 + max.w) / 2
        frame.y = max.y
        frame.w = max.w / 2
        frame.h = max.h
        win:setFrame(frame)
    end)

    -- Half-maximize (left)
    hs.hotkey.bind({ "alt", "ctrl", "cmd" }, "u", function()
        -- get the focused window
        local win = hs.window.focusedWindow()
        local frame = win:frame()
        -- maximize if possible
        local max = win:screen():fullFrame()
        frame.x = max.x
        frame.y = max.y
        frame.w = max.w / 2
        frame.h = max.h
        win:setFrame(frame)
    end)
end

return obj
