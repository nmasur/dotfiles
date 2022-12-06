vim.keymap.set("", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local gitsigns = require("gitsigns")
vim.keymap.set("n", "<Leader>gB", gitsigns.blame_line)
vim.keymap.set("n", "<Leader>gp", gitsigns.preview_hunk)
vim.keymap.set("v", "<Leader>gp", gitsigns.preview_hunk)
vim.keymap.set("n", "<Leader>gd", gitsigns.diffthis)
vim.keymap.set("v", "<Leader>gd", gitsigns.diffthis)
vim.keymap.set("n", "<Leader>rgf", gitsigns.reset_buffer)
vim.keymap.set("v", "<Leader>hs", gitsigns.stage_hunk)
vim.keymap.set("n", "<Leader>hr", gitsigns.reset_hunk)
vim.keymap.set("v", "<Leader>hr", gitsigns.reset_hunk)

-- Navigation
vim.keymap.set("n", "]g", function()
    if vim.wo.diff then
        return "]g"
    end
    vim.schedule(function()
        gitsigns.next_hunk()
    end)
    return "<Ignore>"
end, { expr = true })

vim.keymap.set("n", "[g", function()
    if vim.wo.diff then
        return "[g"
    end
    vim.schedule(function()
        gitsigns.prev_hunk()
    end)
    return "<Ignore>"
end, { expr = true })
