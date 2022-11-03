local M = {}

M.packer = function(use)
    use({
        "lifepillar/vim-gruvbox8",
        config = function()
            vim.g.gruvbox_italicize_strings = 0
            vim.cmd("colorscheme gruvbox8")
            vim.cmd("set background=dark")
        end,
    })
end

return M
