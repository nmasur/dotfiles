-- =======================================================================
-- Syntax
-- =======================================================================

local M = {}

M.packer = function(use)
    -- Syntax engine
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "hcl",
                    "python",
                    "lua",
                    "nix",
                    "fish",
                    "toml",
                    "yaml",
                    "json",
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    })

    -- Syntax-aware Textobjects
    use({
        "nvim-treesitter/nvim-treesitter-textobjects",
        requires = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter.configs").setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Jump forward automatically
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["al"] = "@loop.outer",
                            ["il"] = "@loop.inner",
                            ["aa"] = "@call.outer",
                            ["ia"] = "@call.inner",
                            ["ar"] = "@parameter.outer",
                            ["ir"] = "@parameter.inner",
                            ["aC"] = "@comment.outer",
                            ["iC"] = "@comment.outer",
                            ["a/"] = "@comment.outer",
                            ["i/"] = "@comment.outer",
                            ["a;"] = "@statement.outer",
                            ["i;"] = "@statement.outer",
                        },
                    },
                },
            })
        end,
    })

    -- Additional syntax sources
    use("bfontaine/Brewfile.vim") --- Brewfile syntax
    use("chr4/nginx.vim") --- Nginx syntax
    use("towolf/vim-helm") --- Helm syntax
    use("rodjek/vim-puppet") --- Puppet syntax
end

return M
