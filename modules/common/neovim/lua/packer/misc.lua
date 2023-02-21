local M = {}

M.packer = function(use)
    -- Important tweaks
    use("tpope/vim-surround") --- Manipulate parentheses

    -- Convenience tweaks
    use("tpope/vim-eunuch") --- File manipulation in Vim
    use("tpope/vim-vinegar") --- Fixes netrw file explorer
    use("tpope/vim-fugitive") --- Git commands and syntax
    use("tpope/vim-repeat") --- Actually repeat using .

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
    -- use("vimwiki/vimwiki")
    use({
        "jakewvincent/mkdnflow.nvim",
        config = function()
            require("mkdnflow").setup({
                modules = {
                    bib = false,
                    conceal = true,
                    folds = false,
                },
                perspective = {
                    priority = "current",
                    fallback = "first",
                    nvim_wd_heel = false, -- Don't change working dir
                },
                links = {
                    style = "markdown",
                    conceal = true,
                },
                wrap = true,
                to_do = {
                    symbols = { " ", "-", "x" },
                },
            })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function()
                    vim.o.autowriteall = true -- Save in new buffer
                    vim.o.wrapmargin = 79 -- Wrap text automatically
                end,
            })
        end,
    })
end

return M
