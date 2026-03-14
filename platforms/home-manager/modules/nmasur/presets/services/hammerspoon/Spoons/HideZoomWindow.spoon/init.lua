--- === Hide Zoom Window ===
-- Credit: https://news.ycombinator.com/item?id=47369091

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "HideZoomWindow"
obj.version = "0.1"

function obj:init()
    -- Hide Zoom's "share" windows so it doesn't come back on ESC keypress
    local zoomWindow = nil
    local originalFrame = nil

    hs.hotkey.bind({"cmd", "ctrl", "alt"}, "H", function()
      print("> trying to hide zoom")
      if not zoomWindow then
        print(">  looking for window")
        zoomWindow = hs.window.find("zoom share statusbar window")
      end

      if zoomWindow then
        print(">  found window")
        if originalFrame then
          print(">    restoring")
          zoomWindow:setFrame(originalFrame)
          originalFrame = nil
          zoomWindow = nil
        else
          print(">    hiding")
          originalFrame = zoomWindow:frame()
          local screen = zoomWindow:screen()
          local frame = zoomWindow:frame()
          frame.x = screen:frame().w + 99000
          frame.y = screen:frame().h + 99000
          zoomWindow:setFrame(frame)
        end
      else
        print(">  window not found")
      end
    end)
end

return obj
