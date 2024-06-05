-- Keymap to open file in GitHub web
vim.keymap.set("n", "<Leader>gr", ":!gh browse %<CR><CR>", { silent = true })

-- Pop a terminal to watch the current run
local gitwatch = require("toggleterm.terminal").Terminal:new({
    cmd = "fish --interactive --init-command 'gh run watch'",
    hidden = true,
    direction = "float",
})

-- Set a toggle for this terminal
function GITWATCH_TOGGLE()
    gitwatch:toggle()
end

-- Keymap to toggle the run
vim.keymap.set("n", "<Leader>W", GITWATCH_TOGGLE)
