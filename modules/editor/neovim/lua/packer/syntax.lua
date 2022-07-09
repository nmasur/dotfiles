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
                highlight = { enable = true },
                indent = { enable = true },
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
