-- ===========================================================================
-- Settings
-- ===========================================================================

-- Remember last position when reopening file
vim.api.nvim_exec(
    [[
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]]   ,
    false
)

-- Better backup, swap and undo storage
vim.o.backup = true --- Easier to recover and more secure
vim.bo.swapfile = false --- Instead of swaps, create backups
vim.bo.undofile = true --- Keeps undos after quit

-- Create backup directories if they don't exist
-- Should be fixed in 0.6 by https://github.com/neovim/neovim/pull/15433
vim.o.backupdir = vim.fn.stdpath("cache") .. "/backup"
vim.api.nvim_exec(
    [[
    if !isdirectory(&backupdir)
        call mkdir(&backupdir, "p")
    endif
]]   ,
    false
)

-- LaTeX options
vim.api.nvim_exec(
    [[
    au FileType tex inoremap ;bf \textbf{}<Esc>i
    au BufWritePost *.tex silent! execute "!pdflatex -output-directory=%:p:h % >/dev/null 2>&1" | redraw!
]]   ,
    false
)

-- Highlight when yanking
vim.api.nvim_exec(
    [[
    au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 250 }
]]   ,
    false
)

vim.filetype.add({
    pattern = {
        [".*%.tfvars"] = "terraform",
    },
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*.eml",
    callback = function()
        vim.o.wrapmargin = 79 -- Wrap text automatically
    end,
})

-- Netrw
vim.g.netrw_liststyle = 3 -- Change style to 'tree' view
vim.g.netrw_banner = 0 -- Remove useless banner
vim.g.netrw_winsize = 15 -- Explore window takes % of page
vim.g.netrw_browse_split = 4 -- Open in previous window
vim.g.netrw_altv = 1 -- Always split left
