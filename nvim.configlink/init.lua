-- Bootstrap the Packer plugin manager
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system(
        {
            'git', 'clone', '--depth', '1',
            'https://github.com/wbthomason/packer.nvim', install_path
        }
    )
end

-- Packer plugin installations
require('packer').startup(function(use)

    -- Maintain plugin manager
    use 'wbthomason/packer.nvim'

    -- Startup speed hacks
    use {
        'lewis6991/impatient.nvim',
        config = function()
            require('impatient')
        end
    }

    -- Important tweaks
    use 'tpope/vim-surround'             --- Manipulate parentheses
    use 'tpope/vim-commentary'           --- Use gc or gcc to add comments

    -- Convenience tweaks
    use 'tpope/vim-eunuch'               --- File manipulation in Vim
    use 'tpope/vim-vinegar'              --- Fixes netrw file explorer
    use 'tpope/vim-fugitive'             --- Git commands and syntax
    use 'tpope/vim-repeat'               --- Actually repeat using .
    use 'christoomey/vim-tmux-navigator' --- Hotkeys for tmux panes
    use 'airblade/vim-rooter'            --- Change directory to git route

    -- Colorscheme
    use {
        'morhetz/gruvbox',
        config = function()
            vim.cmd[[colorscheme gruvbox]]
        end
    }

    -- Git next to line numbers
    use {
        'lewis6991/gitsigns.nvim',
        branch = 'main',
        requires = {'nvim-lua/plenary.nvim'},
        config = function()
            require('gitsigns').setup()
        end
    }

    -- Status bar
    use {
        'hoob3rt/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'gruvbox',
                    icons_enabled = true
                }
            })
        end
    }

    -- Improve speed and filetype detection
    use {
        'nathom/filetype.nvim',
        config = function()
            -- Filetype for .env files
            local envfiletype = function()
                vim.bo.filetype = 'text'
                vim.bo.syntax = 'sh'
            end
            -- Force filetype patterns that Vim doesn't know about
            require('filetype').setup({
                overrides = {
                    extensions = {
                        Brewfile = 'brewfile',
                        muttrc = 'muttrc',
                        hcl = 'terraform',
                    },
                    literal = {
                        Caskfile = 'brewfile',
                        [".gitignore"] = 'gitignore',
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
                }
            })
        end
    }

    -- Alignment tool
    use 'godlygeek/tabular'

    -- Markdown renderer / wiki notes
    use 'vimwiki/vimwiki'

    -- Snippet engine
    use 'L3MON4D3/LuaSnip'

    -- =======================================================================
    -- Language Server
    -- =======================================================================

    -- Language server completion plugin
    use 'hrsh7th/cmp-nvim-lsp'

    -- Language server engine
    use {
        'neovim/nvim-lspconfig',
        requires = { 'hrsh7th/cmp-nvim-lsp' },
        config = function()
            local capabilities = require('cmp_nvim_lsp').update_capabilities(
                vim.lsp.protocol.make_client_capabilities()
            )
            require('lspconfig').rust_analyzer.setup{ capabilities = capabilities }
            require('lspconfig').tflint.setup{ capabilities = capabilities }
            require('lspconfig').terraformls.setup{ capabilities = capabilities }
            require('lspconfig').pyright.setup{
                cmd = { "poetry", "run", "pyright-langserver", "--stdio" },
                capabilities = capabilities,
            }
            if require('lspconfig/util').has_bins('diagnostic-languageserver') then
                require('lspconfig').diagnosticls.setup{
                    cmd = { "diagnostic-languageserver", "--stdio" },
                    filetypes = { "sh" },
                    on_attach = on_attach,
                    init_options = {
                        filetypes = { sh = "shellcheck" },
                        linters = {
                            shellcheck = {
                                sourceName = "shellcheck",
                                command = "shellcheck",
                                debounce = 100,
                                args = { "--format=gcc", "-" },
                                offsetLine = 0,
                                offsetColumn = 0,
                                formatLines = 1,
                                formatPattern = {
                                    "^[^:]+:(\\d+):(\\d+):\\s+([^:]+):\\s+(.*)$",
                                    { line = 1, column = 2, message = 4, security = 3 }
                                },
                                securities = { error = "error", warning = "warning", }
                            },
                        }
                    }
                }
            end
        end
    }

    -- Pretty highlights
    use 'folke/lsp-colors.nvim'

    -- =======================================================================
    -- Completion System
    -- =======================================================================

    -- Completion sources
    use 'hrsh7th/cmp-buffer'       --- Generic text completion
    use 'hrsh7th/cmp-path'         --- Local file completion
    use 'hrsh7th/cmp-cmdline'      --- Command line completion
    use 'hrsh7th/cmp-nvim-lua'     --- Nvim lua api completion
    use 'saadparwaiz1/cmp_luasnip' --- Luasnip completion

    -- Completion engine
    use {
        'hrsh7th/nvim-cmp',
        requires = { 'L3MON4D3/LuaSnip', },
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                snippet = {
                    expand = function(args)
                       require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
                    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
                    ['<Esc>'] = function(fallback)
                        cmp.mapping({
                            i = cmp.mapping.abort(),
                            c = cmp.mapping.close(),
                        })
                        vim.cmd('stopinsert') --- Abort and leave insert mode
                    end,
                    -- ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
                    -- ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
                    ['<CR>'] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    })
                },
                sources = {
                    { name = 'nvim_lua' },
                    { name = 'nvim_lsp' },
                    { name = 'path' },
                    { name = 'luasnip' },
                    { name = 'buffer', keyword_length = 5, max_item_count = 10 },
                },
                experimental = {
                    native_menu = false, --- Use cmp menu instead of Vim menu
                    ghost_text = true,   --- Show preview auto-completion
                },
            })

            -- Use buffer source for `/`
            cmp.setup.cmdline('/', {
                sources = {
                    { name = 'buffer', keyword_length = 5 }
                }
            })

            -- Use cmdline & path source for ':'
            cmp.setup.cmdline(':', {
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end
    }

    -- =======================================================================
    -- Syntax
    -- =======================================================================

    -- Syntax engine
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                highlight = { enable = true },
                indent = { enable = true },
            }
        end
    }

    -- Additional syntax sources
    use 'bfontaine/Brewfile.vim' -- Brewfile syntax
    use 'chr4/nginx.vim'         -- Nginx syntax
    use 'hashivim/vim-terraform' -- Terraform formatting
    use 'towolf/vim-helm'        -- Helm syntax
    use 'rodjek/vim-puppet'      -- Puppet syntax

    -- =======================================================================
    -- Fuzzy Launcher
    -- =======================================================================

    use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
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
                    find_files = { theme = "dropdown" },
                    oldfiles = { theme = "dropdown" },
                    buffers = { theme = "dropdown" },
                },
                extensions = {
                    fzy_native = {},
                    tmux = {},
                    zoxide = {},
                    neoclip = {},
                },
            })
        end
    }

    -- Faster sorting
    use 'nvim-telescope/telescope-fzy-native.nvim'

    -- Jump around tmux sessions
    use 'camgraff/telescope-tmux.nvim'

    -- Jump directories
    use {
        'jvgrootveld/telescope-zoxide',
        requires = {'nvim-lua/popup.nvim'},
    }

    -- Clipboard history
    use {
        "AckslD/nvim-neoclip.lua",
        branch = 'main',
        requires = {
            {'tami5/sqlite.lua', module = 'sqlite'},
            {'nvim-telescope/telescope.nvim'},
        },
        config = function()
            require('neoclip').setup({
                enable_persistant_history = true,
            })
            require('telescope').load_extension('neoclip')
        end
    }

    -- =======================================================================

    -- Install on initial bootstrap
    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- ===========================================================================
-- Settings
-- ===========================================================================

vim.o.termguicolors = true      --- Set to truecolor
vim.o.hidden = true             --- Don't unload buffers when leaving them
vim.wo.number = true            --- Show line numbers
vim.wo.relativenumber = true    --- Relative numbers instead of absolute
vim.o.list = true               --- Reveal whitespace with dashes
vim.o.expandtab = true          --- Tabs into spaces
vim.o.shiftwidth = 4            --- Amount to shift with > key
vim.o.softtabstop = 4           --- Amount to shift with <TAB> key
vim.o.ignorecase = true         --- Ignore case when searching
vim.o.smartcase = true          --- Check case when using capitals in search
vim.o.infercase = true          --- Don't match cases when completing suggestions
vim.o.incsearch = true          --- Search while typing
vim.o.visualbell = true         --- No sounds
vim.o.scrolljump = 1            --- Number of lines to scroll
vim.o.scrolloff = 3             --- Margin of lines to see while scrolling
vim.o.splitright = true         --- Vertical splits on the right side
vim.o.splitbelow = true         --- Horizontal splits on the bottom side
vim.o.pastetoggle = "<F3>"      --- Use F3 to enter raw paste mode
vim.o.clipboard = "unnamedplus" --- Uses system clipboard for yanking
vim.o.updatetime = 300          --- Faster diagnostics
vim.o.mouse = "nv"              --- Mouse interaction / scrolling

-- Neovim features
vim.o.inccommand = "split"                  --- Live preview search and replace
vim.o.completeopt = "menu,menuone,noselect" --- Required for nvim-cmp completion
-- Required until 0.6.0: do not source the default filetype.vim
vim.g.did_load_filetypes = 1

-- Remember last position when reopening file
vim.api.nvim_exec([[
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]], false)

-- Better backup, swap and undo storage
vim.o.backup = true     --- Easier to recover and more secure
vim.bo.swapfile = false --- Instead of swaps, create backups
vim.bo.undofile = true  --- Keeps undos after quit

-- Create backup directories if they don't exist
-- Should be fixed in 0.6 by https://github.com/neovim/neovim/pull/15433
vim.o.backupdir = vim.fn.stdpath('cache') .. '/backup'
vim.api.nvim_exec([[
    if !isdirectory(&backupdir)
        call mkdir(&backupdir, "p")
    endif
]], false)

-- LaTeX options
vim.api.nvim_exec([[
    au FileType tex inoremap ;bf \textbf{}<Esc>i
    au BufWritePost *.tex silent! execute "!pdflatex -output-directory=%:p:h % >/dev/null 2>&1" | redraw!
]], false)

-- Highlight when yanking
vim.api.nvim_exec([[
    au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 250 }
]], false)

-- Auto-pairs
vim.g.AutoPairsFlyMode = 0

-- Netrw
vim.g.netrw_liststyle = 3    -- Change style to 'tree' view
vim.g.netrw_banner = 0       -- Remove useless banner
vim.g.netrw_winsize = 15     -- Explore window takes % of page
vim.g.netrw_browse_split = 4 -- Open in previous window
vim.g.netrw_altv = 1         -- Always split left

-- Formatting
vim.g.terraform_fmt_on_save = 1 -- Formats with terraform plugin
vim.g.rustfmt_autosave = 1      -- Formats with rust plugin

-- VimWiki
vim.g.vimwiki_list = {
    {
        ["path"] = "$NOTES_PATH",
        ["syntax"] = "markdown",
        ["index"] = "home",
        ["ext"] = ".md"
    }
}
vim.g.vimwiki_key_mappings = {
    ["all_maps"] = 1,
    ["mouse"] = 1,
}
vim.g.vimwiki_auto_chdir = 1     -- Set local dir to Wiki when open
vim.g.vimwiki_create_link = 0    -- Don't automatically create new links
vim.g.vimwiki_listsyms = " x"    -- Set checkbox symbol progression
vim.g.vimwiki_table_mappings = 0 -- VimWiki table keybinds interfere with tab completion
vim.api.nvim_exec([[
    au FileType markdown inoremap ;tt <Esc>:AddTag<CR>

    function! PInsert(item)
        let @z=a:item
        norm "zpx
    endfunction

    command! AddTag call fzf#run({'source': 'rg "#[A-Za-z/]+[ |\$]" -o --no-filename --no-line-number | sort | uniq', 'sink': function('PInsert')})
]], false)

-- ===========================================================================
-- Key Mapping
-- ===========================================================================

-- Function to cut down config boilerplate
local key = function(mode, key_sequence, action, params)
    params = params or {}
    params["noremap"] = true
    vim.api.nvim_set_keymap(mode, key_sequence, action, params)
end

-- Remap space as leader key
key("", "<Space>", "<Nop>", {silent=true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keep selection when changing indentation
key("v", "<", "<gv")
key("v", ">", ">gv")

-- Unset search pattern register
key("n", "<CR>", ":noh<CR><CR>", {silent=true})

-- Shuffle lines around
key("n", "<A-j>", ":m .+1<CR>==")
key("n", "<A-k>", ":m .-2<CR>==")
key("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
key("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
key("v", "<A-j>", ":m '>+1<CR>gv=gv")
key("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Telescope (fuzzy finder)
key("n", "<Leader>/", ":Telescope live_grep<CR>")
key("n", "<Leader>ff", ":Telescope find_files<CR>")
key("n", "<Leader>fa", ":Telescope file_browser<CR>")
key("n", "<Leader>wt", ":Telescope tmux sessions<CR>")
key("n", "<Leader>ww", ":Telescope tmux windows<CR>")
key("n", "<Leader>w/", ":Telescope tmux pane_contents<CR>")
key("n", "<Leader>fz", ":Telescope zoxide list<CR>")
key("n", "<Leader>b", ":Telescope buffers<CR>")
key("n", "<Leader>hh", ":Telescope help_tags<CR>")
key("n", "<Leader>fr", ":Telescope oldfiles<CR>")
key("n", "<Leader>cc", ":Telescope commands<CR>")
key("n", "<Leader>cr", ":Telescope command_history<CR>")
key("n", "<Leader>y", ":Telescope neoclip<CR>")
key("n", "<Leader>s", ":Telescope current_buffer_fuzzy_find<CR>")
key("n", "<Leader>gc", ":Telescope git_commits<CR>")
key("n", "<Leader>gf", ":Telescope git_bcommits<CR>")
key("n", "<Leader>gb", ":Telescope git_branches<CR>")
key("n", "<Leader>gs", ":Telescope git_status<CR>")

-- LSP
key("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", {silent=true})
key("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", {silent=true})
key("n", "gh", "<Cmd>lua vim.lsp.buf.hover()<CR>", {silent=true})
key("n", "]e", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", {silent=true})
key("n", "[e", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", {silent=true})
key("n", "<Leader>e", "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", {silent=true})

-- File commands
key("n", "<Leader>q", ":quit<CR>")
key("n", "<Leader>Q", ":quitall<CR>")
key("n", "<Leader>fs", ":write<CR>")
key("n", "<Leader>fe", ":!chmod 755 %<CR><CR>")
key("n", "<Leader>fn", ":!chmod 644 %<CR><CR>")
key("n", "<Leader>fd", ":lcd %:p:h<CR>", {silent=true})
key("n", "<Leader>fu", ":lcd ..<CR>", {silent=true})
key("n", "<Leader><Tab>", ":b#<CR>", {silent=true})
key("n", "<Leader>gr", ":!gh repo view -w<CR><CR>", {silent=true})
key("n", "<Leader>tt",
    [[<Cmd>exe 'edit ~/notes/journal/'.strftime("%Y-%m-%d_%a").'.md'<CR>]]
)

-- Window commands
key("n", "<Leader>wv", ":vsplit<CR>")
key("n", "<Leader>wh", ":split<CR>")
key("n", "<Leader>wm", ":only<CR>")

-- Tabularize
key("", "<Leader>ta", ":Tabularize /")
key("", "<Leader>t#", ":Tabularize /#<CR>")
key("", "<Leader>t\"", ":Tabularize /\"<CR>")
key("", "<Leader>tl", ":Tabularize /--<CR>")
key("", "<Leader>tL", ":Tabularize /---<CR>")

-- Vimrc editing
key("n", "<Leader>fv", ":edit $MYVIMRC<CR>")
key("n", "<Leader>rr", ":luafile $MYVIMRC<CR>")
key("n", "<Leader>rp", ":luafile $MYVIMRC<CR>:PackerInstall<CR>:PackerCompile<CR>")
key("n", "<Leader>rc", ":luafile $MYVIMRC<CR>:PackerCompile<CR>")

-- Keep cursor in place
key("n", 'n', "nzz")
key("n", 'N', "Nzz")
key("n", 'J', "mzJ`z") --- Mark and jump back to it

-- Add undo breakpoints
key("i", ',', ",<C-g>u")
key("i", '.', ".<C-g>u")
key("i", '!', "!<C-g>u")
key("i", '?', "?<C-g>u")

-- Other
key("t", "<A-CR>", "<C-\\><C-n>")             --- Exit terminal mode
key("n", "<A-CR>", ":noh<CR>", {silent=true}) --- Clear search
key("n", "Y", "y$")                           --- Copy to end of line
