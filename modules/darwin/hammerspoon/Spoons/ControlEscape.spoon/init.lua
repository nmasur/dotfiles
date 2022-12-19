--- === ControlEscape ===
---
--- Adapted very loosely from https://github.com/jasonrudolph/ControlEscape.spoon
--- Removed timing/delay; always send Escape as well as Control
---
--- Make the `control` key more useful: If the `control` key is tapped, treat it
--- as the `escape` key. If the `control` key is held down and used in
--- combination with another key, then provide the normal `control` key
--- behavior.

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ControlEscape"
obj.version = "0.1"
obj.author = "Jason Rudolph <jason@jasonrudolph.com>"
obj.homepage = "https://github.com/jasonrudolph/ControlEscape.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    self.movements = 0
    self.sendEscape = false
    self.lastModifiers = {}

    -- Create an eventtap to run each time the modifier keys change (i.e., each
    -- time a key like control, shift, option, or command is pressed or released)
    self.controlTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
        local newModifiers = event:getFlags()

        -- If this change to the modifier keys does not involve a *change* to the
        -- up/down state of the `control` key (i.e., it was up before and it's
        -- still up, or it was down before and it's still down), then don't take
        -- any action.
        if self.lastModifiers["ctrl"] == newModifiers["ctrl"] then
            return false
        end

        -- Control was not down but is now
        if not self.lastModifiers["ctrl"] then
            -- Only prepare to send escape if no other modifier keys are in use
            self.lastModifiers = newModifiers
            if not self.lastModifiers["cmd"] and not self.lastModifiers["alt"] then
                self.sendEscape = true
                self.movements = 0
            end

            -- Control was down and is up, hasn't been blocked by another key, and
            -- isn't above the movement threshold
        elseif self.sendEscape == true and not newModifiers["ctrl"] and self.movements < 30 then
            self.lastModifiers = newModifiers

            -- Allow for shift-escape
            if newModifiers["shift"] then
                hs.eventtap.keyStroke({ "shift" }, "escape", 0)
            else
                hs.eventtap.keyStroke(newModifiers, "escape", 0)
            end
            self.sendEscape = false
            self.movements = 0
            self.numberOfCharacters = 0

            -- Control was down and is up, but isn't ready to send escape
        else
            self.lastModifiers = newModifiers
        end
    end)

    -- If any other key is pressed, don't send escape
    self.asModifier = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(_)
        self.sendEscape = false
        -- print("Don't sent escape")
    end)

    -- If mouse is moving significantly, don't send escape
    self.scrolling = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
        local touches = event:getTouches()
        local i, v = next(touches, nil)
        while i do
            if v["phase"] == "moved" then
                -- Increment the movement counter
                self.movements = self.movements + 1
            end
            i, v = next(touches, i) -- get next index
        end
    end)
end

--- ControlEscape:start()
--- Method
--- Start sending `escape` when `control` is pressed and released in isolation
function obj:start()
    self.controlTap:start()
    self.asModifier:start()
    self.scrolling:start()
end

--- ControlEscape:stop()
--- Method
--- Stop sending `escape` when `control` is pressed and released in isolation
function obj:stop()
    -- Stop monitoring keystrokes
    self.controlTap:stop()
    self.asModifier:stop()
    self.scrolling:stop()

    -- Reset state
    self.sendEscape = false
    self.lastModifiers = {}
end

return obj
