local M = {}

M.packer = function(use)
    -- Git next to line numbers
    use({
        "lewis6991/gitsigns.nvim",
        branch = "main",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            require("gitsigns").setup()
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
