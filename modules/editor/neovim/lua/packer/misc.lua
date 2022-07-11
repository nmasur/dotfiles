local M = {}

M.packer = function(use)
    -- Important tweaks
    use("tpope/vim-surround") --- Manipulate parentheses

    -- Convenience tweaks
    use("tpope/vim-eunuch") --- File manipulation in Vim
    use("tpope/vim-vinegar") --- Fixes netrw file explorer
    use("tpope/vim-fugitive") --- Git commands and syntax
    use("tpope/vim-repeat") --- Actually repeat using .
    use("christoomey/vim-tmux-navigator") --- Hotkeys for tmux panes

    -- Use gc or gcc to add comments
    use({
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    })

    -- Alignment tool
    use({
        "godlygeek/tabular",
        config = function()
            vim.keymap.set("", "<Leader>ta", ":Tabularize /")
            vim.keymap.set("", "<Leader>t#", ":Tabularize /#<CR>")
            vim.keymap.set("", "<Leader>tl", ":Tabularize /---<CR>")
        end,
    })

    -- Markdown renderer / wiki notes
    use("vimwiki/vimwiki")
end

return M
