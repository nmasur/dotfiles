local M = {}

M.packer = function(use)
    -- Startup speed hacks
    use({
        "lewis6991/impatient.nvim",
        config = function()
            require("impatient")
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
end

return M
