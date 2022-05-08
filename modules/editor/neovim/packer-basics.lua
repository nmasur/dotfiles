-- Maintain plugin manager
use("wbthomason/packer.nvim")

-- Startup speed hacks
use({
    "lewis6991/impatient.nvim",
    config = function()
        require("impatient")
    end,
})

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

-- Improve speed and filetype detection
use({
    "nathom/filetype.nvim",
    config = function()
        -- Filetype for .env files
        local envfiletype = function()
            vim.bo.filetype = "text"
            vim.bo.syntax = "sh"
        end
        -- Force filetype patterns that Vim doesn't know about
        require("filetype").setup({
            overrides = {
                extensions = {
                    Brewfile = "brewfile",
                    muttrc = "muttrc",
                    tfvars = "terraform",
                    tf = "terraform",
                },
                literal = {
                    Caskfile = "brewfile",
                    [".gitignore"] = "gitignore",
                    config = "config",
                },
                complex = {
                    [".*git/config"] = "gitconfig",
                    ["tmux.conf%..*link"] = "tmux",
                    ["gitconfig%..*link"] = "gitconfig",
                    [".*ignore%..*link"] = "gitignore",
                    [".*%.toml%..*link"] = "toml",
                },
                function_extensions = {},
                function_literal = {
                    [".envrc"] = envfiletype,
                    [".env"] = envfiletype,
                    [".env.dev"] = envfiletype,
                    [".env.prod"] = envfiletype,
                    [".env.example"] = envfiletype,
                },
            },
        })
    end,
})

-- Alignment tool
use("godlygeek/tabular")

-- Markdown renderer / wiki notes
use("vimwiki/vimwiki")

-- Markdown pretty view
use("ellisonleao/glow.nvim")

-- Hex color previews
use({
    "norcalli/nvim-colorizer.lua",
    config = function()
        require("colorizer").setup()
    end,
})
