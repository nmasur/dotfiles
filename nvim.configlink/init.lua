-- Bootstrap the Packer plugin manager
local execute = vim.api.nvim_command
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

-- Packer plugin installations
local use = require('packer').use
require('packer').startup(function()
    use 'wbthomason/packer.nvim'              -- Maintain plugin manager
    use 'lewis6991/impatient.nvim'            -- Startup speed hacks
    use 'tpope/vim-eunuch'                    -- File manipulation in Vim
    use 'tpope/vim-vinegar'                   -- Fixes netrw file explorer
    use 'tpope/vim-fugitive'                  -- Git commands and syntax
    use 'tpope/vim-surround'                  -- Manipulate parentheses
    use 'tpope/vim-commentary'                -- Use gc or gcc to add comments
    use 'tpope/vim-repeat'                    -- Actually repeat using .
    use 'christoomey/vim-tmux-navigator'      -- Hotkeys for tmux panes
    use 'morhetz/gruvbox'                     -- Colorscheme
    use 'L3MON4D3/LuaSnip'                    -- Snippet engine
    use 'neovim/nvim-lspconfig'               -- Language server linting
    use 'folke/lsp-colors.nvim'               -- Pretty LSP highlights
    use 'hrsh7th/cmp-nvim-lsp'                -- Language server completion
    use 'hrsh7th/cmp-buffer'                  -- Generic text completion
    use 'hrsh7th/cmp-path'                    -- Local file completion
    use 'hrsh7th/cmp-cmdline'                 -- Command line completion
    use 'hrsh7th/cmp-nvim-lua'                -- Nvim lua api completion
    use 'saadparwaiz1/cmp_luasnip'            -- Luasnip completion
    use 'hrsh7th/nvim-cmp'                    -- Completion system
    use 'godlygeek/tabular'                   -- Spacing and alignment
    use 'vimwiki/vimwiki'                     -- Wiki Markdown System
    use 'airblade/vim-rooter'                 -- Change directory to git route
    use {                                     -- Status bar
	'hoob3rt/lualine.nvim',
	requires = {
	    'kyazdani42/nvim-web-devicons',
	    opt = true
        }
    }
    use 'nathom/filetype.nvim'                -- Faster startup
    use {                                     -- Syntax highlighting processor
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use 'bfontaine/Brewfile.vim'              -- Brewfile syntax
    use 'chr4/nginx.vim'                      -- Nginx syntax
    use 'hashivim/vim-terraform'              -- Terraform formatting
    use 'towolf/vim-helm'                     -- Helm syntax
    use 'rodjek/vim-puppet'                   -- Puppet syntax
    use {                                     -- Git next to line numbers
        'lewis6991/gitsigns.nvim',
        branch = 'main',
        requires = {'nvim-lua/plenary.nvim'},
        config = function()
            require('gitsigns').setup()
        end
    }
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use 'nvim-telescope/telescope-fzy-native.nvim'
    use 'camgraff/telescope-tmux.nvim'
    use {
        'jvgrootveld/telescope-zoxide',
        requires = {'nvim-lua/popup.nvim'},
    }
    use {
        "AckslD/nvim-neoclip.lua",
        branch = 'main',
        requires = {'tami5/sqlite.lua', module = 'sqlite'},
    }
    -- use 'ludovicchabant/vim-gutentags'
end)

require('impatient') -- Faster startup

-- Completion Settings
-- ===================

local cmp = require'cmp'

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
            vim.cmd('stopinsert') -- Abort and leave insert mode
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
        native_menu = false, -- Use cmp menu instead of Vim menu
        ghost_text = true,   -- Show preview auto-completion
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


-- LSP Settings
-- ============

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

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
            filetypes = {
                sh = "shellcheck",
            },
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
                        {
                            line = 1,
                            column = 2,
                            message = 4,
                            security = 3
                        }
                    },
                    securities = {
                        error = "error",
                        warning = "warning",
                    }
                },
            }
        }
    }
end

-- Settings
-- ========

-- Basic Settings
vim.o.termguicolors = true      -- Set to truecolor
vim.cmd[[colorscheme gruvbox]]  -- Installed with a plugin
vim.o.hidden = true             -- Don't unload buffers when leaving them
vim.wo.number = true            -- Show line numbers
vim.wo.relativenumber = true    -- Relative numbers instead of absolute
vim.o.list = true               -- Reveal whitespace with dashes
vim.o.expandtab = true          -- Tabs into spaces
vim.o.shiftwidth = 4            -- Amount to shift with > key
vim.o.softtabstop = 4           -- Amount to shift with <TAB> key
vim.o.ignorecase = true         -- Ignore case when searching
vim.o.smartcase = true          -- Check case when using capitals in search
vim.o.infercase = true          -- Don't match cases when completing suggestions
vim.o.incsearch = true          -- Search while typing
vim.o.visualbell = true         -- No sounds
vim.o.scrolljump = 1            -- Number of lines to scroll
vim.o.scrolloff = 3             -- Margin of lines to see while scrolling
vim.o.splitright = true         -- Vertical splits on the right side
vim.o.splitbelow = true         -- Horizontal splits on the bottom side
vim.o.pastetoggle = "<F3>"      -- Use F3 to enter raw paste mode
vim.o.clipboard = "unnamedplus" -- Uses system clipboard for yanking
vim.o.updatetime = 300          -- Faster diagnostics
vim.o.mouse = "nv"              -- Mouse interaction / scrolling

-- Neovim features
vim.o.inccommand = "split"                  -- Live preview search and replace
vim.o.completeopt = "menu,menuone,noselect" -- Required for nvim-cmp completion
-- Required until 0.6.0: do not source the default filetype.vim
vim.g.did_load_filetypes = 1

-- Remember last position when reopening file
vim.api.nvim_exec([[
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]], false)

-- Better backup, swap and undo storage
vim.o.backup = true     -- Easier to recover and more secure
vim.bo.swapfile = false -- Instead of swaps, create backups
vim.bo.undofile = true  -- Keeps undos after quit

-- Create backup directories if they don't exist
-- Should be fixed in 0.6 by https://github.com/neovim/neovim/pull/15433
vim.o.backupdir = vim.fn.stdpath('cache') .. '/backup'
vim.api.nvim_exec([[
    if !isdirectory(&backupdir)
        call mkdir(&backupdir, "p")
    endif
]], false)

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

-- Tree-Sitter Syntax Processing
require('nvim-treesitter.configs').setup {
  highlight = { enable = true },
  indent = { enable = true },
}

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

-- Status bar
require('lualine').setup({
    options = {
        theme = 'gruvbox',
        icons_enabled = true
    }
})

-- Clipboard history
require('neoclip').setup({
    enable_persistant_history = true,
})

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
require('telescope').load_extension('neoclip')

-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", {noremap=true, silent=true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keep selection when changing indentation
vim.api.nvim_set_keymap("v", "<", "<gv", {noremap=true})
vim.api.nvim_set_keymap("v", ">", ">gv", {noremap=true})

-- Unset search pattern register
vim.api.nvim_set_keymap("n", "<CR>", ":noh<CR><CR>", {noremap=true, silent=true})

-- Shuffle lines around
vim.api.nvim_set_keymap("n", "<A-j>", ":m .+1<CR>==", {noremap=true})
vim.api.nvim_set_keymap("n", "<A-k>", ":m .-2<CR>==", {noremap=true})
vim.api.nvim_set_keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi", {noremap=true})
vim.api.nvim_set_keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi", {noremap=true})
vim.api.nvim_set_keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", {noremap=true})
vim.api.nvim_set_keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", {noremap=true})

-- Telescope (fuzzy finder)
vim.api.nvim_set_keymap("n", "<Leader>/", ":Telescope live_grep<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>ff", ":Telescope find_files<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fa", ":Telescope file_browser<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>wt", ":Telescope tmux sessions<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>ww", ":Telescope tmux windows<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>w/", ":Telescope tmux pane_contents<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fz", ":Telescope zoxide list<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>b", ":Telescope buffers<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>hh", ":Telescope help_tags<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fr", ":Telescope oldfiles<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>cc", ":Telescope commands<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>cr", ":Telescope command_history<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>y", ":Telescope neoclip<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>s", ":Telescope current_buffer_fuzzy_find<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>gc", ":Telescope git_commits<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>gf", ":Telescope git_bcommits<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>gb", ":Telescope git_branches<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>gs", ":Telescope git_status<CR>", {noremap=true})

-- LSP
vim.api.nvim_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "gh", "<Cmd>lua vim.lsp.buf.hover()<CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "]e", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "[e", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>e", "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", {silent=true, noremap=true})

-- File commands
vim.api.nvim_set_keymap("n", "<Leader>q", ":quit<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>Q", ":quitall<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fs", ":write<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fe", ":!chmod 755 %<CR><CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fn", ":!chmod 644 %<CR><CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fd", ":lcd %:p:h<CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fu", ":lcd ..<CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "<Leader><Tab>", ":b#<CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>gr", ":!gh repo view -w<CR><CR>", {silent=true, noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>tt",
    [[<Cmd>exe 'edit ~/notes/journal/'.strftime("%Y-%m-%d_%a").'.md'<CR>]], {noremap=true}
)

-- Window commands
vim.api.nvim_set_keymap("n", "<Leader>wv", ":vsplit<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>wh", ":split<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>wm", ":only<CR>", {noremap=true})

-- Tabularize
vim.api.nvim_set_keymap("", "<Leader>ta", ":Tabularize /", {noremap=true})
vim.api.nvim_set_keymap("", "<Leader>t#", ":Tabularize /#<CR>", {noremap=true})
vim.api.nvim_set_keymap("", "<Leader>t\"", ":Tabularize /\"<CR>", {noremap=true})
vim.api.nvim_set_keymap("", "<Leader>tl", ":Tabularize /--<CR>", {noremap=true})

-- Vimrc editing
vim.api.nvim_set_keymap("n", "<Leader>fv", ":edit $MYVIMRC<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>rr", ":luafile $MYVIMRC<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>rp", ":luafile $MYVIMRC<CR>:PackerInstall<CR>:PackerCompile<CR>", {noremap=true})

-- Other
vim.api.nvim_set_keymap("t", "<A-CR>", "<C-\\><C-n>", {noremap=true})           -- Exit terminal mode
vim.api.nvim_set_keymap("n", "<A-CR>", ":noh<CR>", {noremap=true, silent=true}) -- Clear search
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true})                      -- Copy to end of line

-- Keep cursor in place
vim.api.nvim_set_keymap("n", 'n', "nzz", {noremap=true})
vim.api.nvim_set_keymap("n", 'N', "Nzz", {noremap=true})
vim.api.nvim_set_keymap("n", 'J', "mzJ`z", {noremap=true}) -- Mark and jump back to it

-- Add undo breakpoints
vim.api.nvim_set_keymap("i", ',', ",<C-g>u", {noremap=true})
vim.api.nvim_set_keymap("i", '.', ".<C-g>u", {noremap=true})
vim.api.nvim_set_keymap("i", '!', "!<C-g>u", {noremap=true})
vim.api.nvim_set_keymap("i", '?', "?<C-g>u", {noremap=true})
