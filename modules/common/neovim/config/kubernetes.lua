local k9s = require("toggleterm.terminal").Terminal:new({ cmd = "k9s" })
function K9S_TOGGLE()
    k9s:toggle()
end

vim.keymap.set("n", "<Leader>9", K9S_TOGGLE)
