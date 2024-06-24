--- === Work Layout ===
-- Portions of this is adopted from:
-- https://github.com/anishathalye/dotfiles-local/tree/ffdadd313e58514eb622736b09b91a7d7eb7c6c9/hammerspoon
-- License is also available:
-- https://github.com/anishathalye/dotfiles-local/blob/ffdadd313e58514eb622736b09b91a7d7eb7c6c9/LICENSE.md

WORK_ONLY_MONITOR = "DELL U4021QW"
LAPTOP_MONITOR = "Built-in Retina Display"

-- Used to find out the name of the monitor in Hammerspoon
local function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

-- Turn on when looking for the monitor name
print(dump(hs.screen.allScreens()))

local function concat(...)
    local res = {}
    for _, tab in ipairs({ ... }) do
        for _, elem in ipairs(tab) do
            table.insert(res, elem)
        end
    end
    return res
end

local function worklayout()
    hs.hotkey.bind({ "alt", "ctrl", "cmd" }, "l", function()
        local u = hs.geometry.unitrect
        -- set the layout
        local left = {
            { "WezTerm", nil, WORK_ONLY_MONITOR, u(0, 0, 1 / 2, 1), nil, nil, visible = true },
        }
        local right = {
            { "Slack", nil, WORK_ONLY_MONITOR, u(1 / 2, 0, 1 / 2, 1), nil, nil, visible = true },
            { "Mail", nil, WORK_ONLY_MONITOR, u(1 / 2, 0, 1 / 2, 1), nil, nil, visible = true },
            { "zoom.us", nil, WORK_ONLY_MONITOR, u(5 / 8, 1 / 4, 1 / 4, 1 / 2), nil, nil, visible = true },
        }
        local laptop = {
            { "Firefox", nil, LAPTOP_MONITOR, u(0, 0, 1, 1), nil, nil, visible = true },
            { "Obsidian", nil, LAPTOP_MONITOR, u(0, 0, 1, 1), nil, nil, visible = true },
            { "Calendar", nil, LAPTOP_MONITOR, u(0, 0, 1, 1), nil, nil, visible = true },
        }
        local layout = concat(left, right, laptop)
        hs.layout.apply(layout)
    end)

    -- Reload Hammerspoon whenever layout changes
    hs.screen.watcher.new(function()
        -- Pause for 5 seconds to give time for layout to change
        hs.timer.doAfter(5, function()
            -- Perform the actual reload
            hs.reload()
        end)
    end)
end

return worklayout
