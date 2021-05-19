--- === ControlEscape ===
---
--- Adapted very loosely from https://github.com/jasonrudolph/ControlEscape.spoon
--- Removed timing/delay; always send Escape as well as Control
---
--- Make the `control` key more useful: If the `control` key is tapped, treat it
--- as the `escape` key. If the `control` key is held down and used in
--- combination with another key, then provide the normal `control` key
--- behavior.

local obj={}
obj.__index = obj

-- Metadata
obj.name = 'ControlEscape'
obj.version = '0.1'
obj.author = 'Jason Rudolph <jason@jasonrudolph.com>'
obj.homepage = 'https://github.com/jasonrudolph/ControlEscape.spoon'
obj.license = 'MIT - https://opensource.org/licenses/MIT'

function obj:init()
  self.sendEscape = false
  self.lastModifiers = {}

  -- Create an eventtap to run each time the modifier keys change (i.e., each
  -- time a key like control, shift, option, or command is pressed or released)
  self.controlTap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged},
    function(event)
      local newModifiers = event:getFlags()
      if not self.lastModifiers['ctrl'] then
        if newModifiers['ctrl'] then
          if (newModifiers['shift'] and newModifiers['cmd']) then
            ;
          elseif newModifiers['shift'] then
            hs.eventtap.keyStroke({'shift'}, 'escape', 0)
          else
            hs.eventtap.keyStroke(newModifiers, 'escape', 0)
          end
        end
      end
      self.lastModifiers = newModifiers
    end
  )
end

--- ControlEscape:start()
--- Method
--- Start sending `escape` when `control` is pressed and released in isolation
function obj:start()
  self.controlTap:start()
end

--- ControlEscape:stop()
--- Method
--- Stop sending `escape` when `control` is pressed and released in isolation
function obj:stop()
  -- Stop monitoring keystrokes
  self.controlTap:stop()

  -- Reset state
  self.sendEscape = false
  self.lastModifiers = {}
end

return obj
