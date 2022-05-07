-- Colorscheme
use({
    "morhetz/gruvbox",
    config = function()
        vim.g.gruvbox_italic = 1
        vim.cmd([[
              autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
              colorscheme gruvbox
            ]])
    end,
})
