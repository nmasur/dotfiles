-- Bootstrap the Packer plugin manager
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
end

-- Packer plugin installations
require("packer").startup(function(use)
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
    use("tpope/vim-commentary") --- Use gc or gcc to add comments

    -- Convenience tweaks
    use("tpope/vim-eunuch") --- File manipulation in Vim
    use("tpope/vim-vinegar") --- Fixes netrw file explorer
    use("tpope/vim-fugitive") --- Git commands and syntax
    use("tpope/vim-repeat") --- Actually repeat using .
    use("christoomey/vim-tmux-navigator") --- Hotkeys for tmux panes

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

    -- Snippet engine
    use("L3MON4D3/LuaSnip")

    -- =======================================================================
    -- Language Server
    -- =======================================================================

    -- Language server engine
    use({
        "neovim/nvim-lspconfig",
        requires = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local capabilities = require("cmp_nvim_lsp").update_capabilities(
                vim.lsp.protocol.make_client_capabilities()
            )
            require("lspconfig").rust_analyzer.setup({ capabilities = capabilities })
            require("lspconfig").tflint.setup({ capabilities = capabilities })
            require("lspconfig").terraformls.setup({ capabilities = capabilities })
            require("lspconfig").pyright.setup({
                on_attach = function()
                    -- set keymaps (requires 0.7.0)
                    -- vim.keymap.set("n", "", "", {buffer=0})
                end,
                capabilities = capabilities,
            })
        end,
    })

    -- Pretty highlights
    use("folke/lsp-colors.nvim")

    -- Linting
    use({
        "jose-elias-alvarez/null-ls.nvim",
        branch = "main",
        requires = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("null-ls").setup({
                sources = {
                    require("null-ls").builtins.formatting.stylua,
                    require("null-ls").builtins.formatting.black,
                    require("null-ls").builtins.formatting.fish_indent,
                    require("null-ls").builtins.formatting.nixfmt,
                    require("null-ls").builtins.formatting.rustfmt,
                    require("null-ls").builtins.diagnostics.shellcheck,
                    require("null-ls").builtins.formatting.shfmt.with({
                        extra_args = { "-i", "4", "-ci" },
                    }),
                    require("null-ls").builtins.formatting.terraform_fmt,
                    -- require("null-ls").builtins.diagnostics.luacheck,
                    -- require("null-ls").builtins.diagnostics.markdownlint,
                    -- require("null-ls").builtins.diagnostics.pylint,
                },
                -- Format on save
                on_attach = function(client)
                    if client.resolved_capabilities.document_formatting then
                        vim.cmd([[
                        augroup LspFormatting
                            autocmd! * <buffer>
                            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
                        augroup END
                        ]])
                    end
                end,
            })
        end,
    })

    -- =======================================================================
    -- Completion System
    -- =======================================================================

    -- Completion sources
    use("hrsh7th/cmp-nvim-lsp") --- Language server completion plugin
    use("hrsh7th/cmp-buffer") --- Generic text completion
    use("hrsh7th/cmp-path") --- Local file completion
    use("hrsh7th/cmp-cmdline") --- Command line completion
    use("hrsh7th/cmp-nvim-lua") --- Nvim lua api completion
    use("saadparwaiz1/cmp_luasnip") --- Luasnip completion
    use("lukas-reineke/cmp-rg") --- Ripgrep completion

    -- Completion engine
    use({
        "hrsh7th/nvim-cmp",
        requires = { "L3MON4D3/LuaSnip" },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    ["<Esc>"] = function(fallback)
                        cmp.mapping({
                            i = cmp.mapping.abort(),
                            c = cmp.mapping.close(),
                        })
                        vim.cmd("stopinsert") --- Abort and leave insert mode
                    end,
                    -- ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
                    -- ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    }),
                    ["<C-r>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<C-l>"] = cmp.mapping(function(fallback)
                        if require("luasnip").expand_or_jumpable() then
                            require("luasnip").expand_or_jump()
                        end
                    end, { "i", "s" }),
                },
                sources = {
                    { name = "nvim_lua" },
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "luasnip" },
                    { name = "buffer", keyword_length = 3, max_item_count = 10 },
                    {
                        name = "rg",
                        keyword_length = 6,
                        max_item_count = 10,
                        option = { additional_arguments = "--ignore-case" },
                    },
                },
                experimental = {
                    native_menu = false, --- Use cmp menu instead of Vim menu
                    ghost_text = true, --- Show preview auto-completion
                },
            })

            -- Use buffer source for `/`
            cmp.setup.cmdline("/", {
                sources = {
                    { name = "buffer", keyword_length = 5 },
                },
            })

            -- Use cmdline & path source for ':'
            cmp.setup.cmdline(":", {
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
            })
        end,
    })

    -- =======================================================================
    -- Syntax
    -- =======================================================================

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

    -- =======================================================================
    -- Fuzzy Launcher
    -- =======================================================================

    use({
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            -- Telescope: quit instantly with escape
            local actions = require("telescope.actions")
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<esc>"] = actions.close,
                            ["<C-h>"] = "which_key",
                        },
                    },
                },
                pickers = {
                    find_files = { theme = "ivy" },
                    oldfiles = { theme = "ivy" },
                    buffers = { theme = "dropdown" },
                },
                extensions = {
                    fzy_native = {},
                    tmux = {},
                    zoxide = {},
                    --neoclip = {},
                    project = {
                        base_dirs = { "~/dev" },
                    },
                },
            })
        end,
    })

    -- Faster sorting
    use("nvim-telescope/telescope-fzy-native.nvim")

    -- Jump around tmux sessions
    use("camgraff/telescope-tmux.nvim")

    -- Jump directories
    use({
        "jvgrootveld/telescope-zoxide",
        requires = { "nvim-lua/popup.nvim" },
    })

    -- Jump projects
    use({
        "nvim-telescope/telescope-project.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("telescope").load_extension("project")
        end,
    })

    -- File browser
    use({
        "nvim-telescope/telescope-file-browser.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("telescope").load_extension("file_browser")
        end,
    })

    -- =======================================================================

    -- Install on initial bootstrap
    if packer_bootstrap then
        require("packer").sync()
    end
end)
