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
    use 'wbthomason/packer.nvim'               -- Maintain plugin manager
    use 'tpope/vim-eunuch'                     -- File manipulation in Vim
    use 'tpope/vim-vinegar'                    -- Fixes netrw file explorer
    use 'tpope/vim-fugitive'                   -- Git commands
    use 'tpope/vim-surround'                   -- Manipulate parentheses
    use 'tpope/vim-commentary'                 -- Use gc or gcc to add comments
    use 'tpope/vim-repeat'                     -- Actually repeat using .
    use 'christoomey/vim-tmux-navigator'       -- Hotkeys for tmux panes
    use 'morhetz/gruvbox'                      -- Colorscheme
    use 'phaazon/hop.nvim'                     -- Quick jump around the buffer
    use 'neovim/nvim-lspconfig'                -- Language server linting
    use 'folke/lsp-colors.nvim'                -- Pretty LSP highlights
    use 'rafamadriz/friendly-snippets'
    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/vim-vsnip-integ'
    use 'hrsh7th/nvim-compe'                   -- Auto-complete
    use 'godlygeek/tabular'                    -- Spacing and alignment
    use 'vimwiki/vimwiki'                      -- Wiki Markdown System
    use 'airblade/vim-rooter'                  -- Change directory to git route
    use {                                      -- Status bar
	'hoob3rt/lualine.nvim',
	requires = {
	    'kyazdani42/nvim-web-devicons',
	    opt = true
        }
    }
    use {                                      -- Syntax highlighting for most languages
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use 'bfontaine/Brewfile.vim'               -- Brewfile syntax
    use 'blankname/vim-fish'                   -- Fish syntax
    use 'chr4/nginx.vim'                       -- Nginx syntax
    use 'hashivim/vim-terraform'               -- Terraform syntax
    use 'cespare/vim-toml'                     -- TOML syntax
    use 'towolf/vim-helm'                      -- Helm syntax
    use 'LnL7/vim-nix'                         -- Nix syntax
    use 'rodjek/vim-puppet'                    -- Puppet syntax
    use {                                      -- Git next to line numbers
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'},
        config = function()
            require('gitsigns').setup()
        end
    }
    use {                                      -- Fuzzy finder
        'junegunn/fzf.vim',
        requires = {'/usr/local/opt/fzf'}
    }
	-- use 'ludovicchabant/vim-gutentags'
end)

-- LSP Settings
-- ============

require('lspconfig').rust_analyzer.setup{}
require('lspconfig').pyright.setup{
    cmd = { "poetry", "run", "pyright-langserver", "--stdio" }
}
require'compe'.setup({
    enabled = true,
    source = {
        path = true,
        buffer = true,
        nvim_lsp = true,
    },
})
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

-- Auto-complete
-- ====================

-- Auto-complete mapping
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end
-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-p>"
    elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
        return t "<Plug>(vsnip-jump-prev)"
    else
        return t "<S-Tab>"
    end
end

-- Auto-complete keybinds
vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

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
vim.o.inccommand = "split"             -- Live preview search and replace
vim.o.completeopt = "menuone,noselect" -- Required for nvim-compe completion

-- Remember last position when reopening file
vim.api.nvim_exec([[
    if has("autocmd")
      au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    endif
]], false)

-- Better backup, swap and undo storage
vim.o.backup = true                      -- Easier to recover and more secure
vim.bo.swapfile = false                  -- Instead of swaps, create backups
vim.bo.undofile = true                   -- Keeps undos after quit

-- Create backup directories if they don't exist
vim.api.nvim_exec([[
    set backupdir=~/.local/share/nvim/backup
    set undodir=~/.local/share/nvim/undo
    if !isdirectory(&backupdir)
        call mkdir(&backupdir, "p")
    endif
    if !isdirectory(&undodir)
        call mkdir(&undodir, "p")
    endif
]], false)

-- Keep selection when tabbing
vim.api.nvim_set_keymap("v", "<", "<gv", {noremap=true})
vim.api.nvim_set_keymap("v", ">", ">gv", {noremap=true})

-- Force filetype patterns that Vim doesn't know about
vim.api.nvim_exec([[
    au BufRead,BufNewFile *.Brewfile setfiletype brewfile
    au BufRead,BufNewFile tmux.conf* setfiletype tmux
    au BufRead,BufNewFile *ignore.*link setfiletype gitignore
    au BufRead,BufNewFile gitconfig.*link setfiletype gitconfig
    au BufRead,BufNewFile *.toml.*link setfiletype toml
    au BufRead,BufNewFile *.muttrc setfiletype muttrc
    au BufRead,BufNewFile .env* set ft=text | set syntax=sh
    au BufRead,BufNewFile *.hcl set ft=terraform
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

-- Rust stuff
-- vim.api.nvim_exec([[
--     au BufWritePost *.rs silent! execute "%! rustfmt"
-- ]], false)

-- Auto-pairs
vim.g.AutoPairsFlyMode = 0

-- Netrw
vim.g.netrw_liststyle = 3    -- Change style to 'tree' view
vim.g.netrw_banner = 0       -- Remove useless banner
vim.g.netrw_winsize = 15     -- Explore window takes % of page
vim.g.netrw_browse_split = 4 -- Open in previous window
vim.g.netrw_altv = 1         -- Always split left

-- Polyglot
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

-- Status bar
require('lualine').setup({
    options = { theme = 'gruvbox' }
})

-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", {noremap=true, silent=true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Unset search pattern register
vim.api.nvim_set_keymap("n", "<CR>", ":noh<CR><CR>", {noremap=true, silent=true})

-- Shuffle lines around
vim.api.nvim_set_keymap("n", "<A-j>", ":m .+1<CR>==", {noremap=true})
vim.api.nvim_set_keymap("n", "<A-k>", ":m .-2<CR>==", {noremap=true})
vim.api.nvim_set_keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi", {noremap=true})
vim.api.nvim_set_keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi", {noremap=true})
vim.api.nvim_set_keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", {noremap=true})
vim.api.nvim_set_keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", {noremap=true})

-- Fzf (fuzzy finder)
vim.api.nvim_set_keymap("n", "<Leader>/", ":Rg<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>ff", ":Files<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>fr", ":History<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>b", ":Buffers<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>s", ":BLines<CR>", {noremap=true})

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
vim.api.nvim_set_keymap("n", "<Leader>tt", [[<Cmd>exe 'edit ~/notes/journal/'.strftime("%Y-%m-%d_%a").'.md'<CR>]], {noremap=true})

-- Window commands
vim.api.nvim_set_keymap("n", "<Leader>wv", ":vsplit<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>wh", ":split<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>wm", ":only<CR>", {noremap=true})

-- Tabularize
vim.api.nvim_set_keymap("", "<Leader>ta", ":Tabularize /", {noremap=true})
vim.api.nvim_set_keymap("", "<Leader>t#", ":Tabularize /#<CR>", {noremap=true})
vim.api.nvim_set_keymap("", "<Leader>t\"", ":Tabularize /\"<CR>", {noremap=true})

-- Vimrc editing
vim.api.nvim_set_keymap("n", "<Leader>fv", ":edit $MYVIMRC<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>rr", ":luafile $MYVIMRC<CR>", {noremap=true})

-- Other
vim.api.nvim_set_keymap("n", "<Leader><Space>", ":HopWord<CR>", {noremap=true})
vim.api.nvim_set_keymap("t", "<A-CR>", "<C-\\><C-n>", {noremap=true}) -- Exit terminal mode
vim.api.nvim_set_keymap("n", "<A-CR>", ":noh<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true})

-- Keep cursor in place
vim.api.nvim_set_keymap("n", 'n', "nzz", {noremap=true})
vim.api.nvim_set_keymap("n", 'N', "Nzz", {noremap=true})
vim.api.nvim_set_keymap("n", 'J', "mzJ`z", {noremap=true}) -- Mark and jump back to it

-- Add undo breakpoints
vim.api.nvim_set_keymap("i", ',', ",<C-g>u", {noremap=true})
vim.api.nvim_set_keymap("i", '.', ".<C-g>u", {noremap=true})
vim.api.nvim_set_keymap("i", '!', "!<C-g>u", {noremap=true})
vim.api.nvim_set_keymap("i", '?', "?<C-g>u", {noremap=true})
