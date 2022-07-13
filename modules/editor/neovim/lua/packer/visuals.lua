local M = {}

M.packer = function(use)
    -- Git next to line numbers
    use({
        "lewis6991/gitsigns.nvim",
        branch = "main",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            local gitsigns = require("gitsigns")
            gitsigns.setup()
            vim.keymap.set("n", "<Leader>gB", gitsigns.blame_line)
            vim.keymap.set("n", "<Leader>gp", gitsigns.preview_hunk)
            vim.keymap.set("v", "<Leader>gp", gitsigns.preview_hunk)
            vim.keymap.set("n", "<Leader>gd", gitsigns.diffthis)
            vim.keymap.set("v", "<Leader>gd", gitsigns.diffthis)
            vim.keymap.set("n", "<Leader>rgf", gitsigns.reset_buffer)
            vim.keymap.set("v", "<Leader>hs", gitsigns.stage_hunk)
            vim.keymap.set("v", "<Leader>hs", gitsigns.reset_hunk)
        end,
    })

    -- Status bar
    use({
        "hoob3rt/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "gruvbox",
                    icons_enabled = true,
                },
            })
        end,
    })

    -- Buffer line ("tabs")
    use({
        "akinsho/bufferline.nvim",
        tag = "v2.*",
        requires = { "kyazdani42/nvim-web-devicons", "moll/vim-bbye" },
        config = function()
            require("bufferline").setup({
                options = {
                    diagnostics = "nvim_lsp",
                    always_show_bufferline = false,
                    separator_style = "slant",
                    offsets = { { filetype = "NvimTree" } },
                },
            })
            -- Move buffers
            vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { silent = true })
            vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { silent = true })

            -- Kill buffer
            vim.keymap.set("n", "<Leader>x", " :Bdelete<CR>", { silent = true })

            -- Shift buffers
            -- vim.keymap.set("n", "<C-L>", ":BufferLineMoveNext<CR>")
            -- vim.keymap.set("i", "<C-L>", "<Esc>:BufferLineMoveNext<CR>i")
            -- vim.keymap.set("n", "<C-H>", ":BufferLineMovePrev<CR>")
            -- vim.keymap.set("i", "<C-H>", "<Esc>:BufferLineMovePrev<CR>i")
        end,
    })

    -- File explorer
    use({
        "kyazdani42/nvim-tree.lua",
        requires = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                disable_netrw = true,
                hijack_netrw = true,
                diagnostics = {
                    enable = true,
                    icons = {
                        hint = "",
                        info = "",
                        warning = "",
                        error = "",
                    },
                },
                view = {
                    width = 30,
                    height = 30,
                    hide_root_folder = false,
                    side = "left",
                    mappings = {
                        custom_only = false,
                        list = {
                            {
                                key = { "l", "<CR>", "o" },
                                cb = require("nvim-tree.config").nvim_tree_callback("edit"),
                            },
                            { key = "h", cb = require("nvim-tree.config").nvim_tree_callback("close_node") },
                            { key = "v", cb = require("nvim-tree.config").nvim_tree_callback("vsplit") },
                        },
                    },
                    number = false,
                    relativenumber = false,
                },
            })
            vim.keymap.set("n", "<Leader>e", ":NvimTreeFindFileToggle<CR>", { silent = true })
        end,
    })

    -- Markdown pretty view
    use("ellisonleao/glow.nvim")

    -- Hex color previews
    use({
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    })
end

return M
