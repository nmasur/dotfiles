" Plugins
"--------

" Install vim-plugged if not installed
if empty(glob('$HOME/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $HOME/.config/nvim/init.vim
endif

" All plugins
call plug#begin('$HOME/.config/nvim/plugged')

" Core plugins
Plug 'nvim-lua/plenary.nvim'                        " Prerequisite library for other plugins
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Install fzf (prerequisite for fzf.vim)
Plug 'junegunn/fzf.vim'                             " Actual fuzzyfinder
Plug 'morhetz/gruvbox'                              " Colorscheme
Plug 'tpope/vim-surround'                           " Enables paren editing
Plug 'sheerun/vim-polyglot'                         " Syntax for every language
Plug 'lewis6991/gitsigns.nvim'                      " Git next to line numbers
Plug 'tpope/vim-commentary'                         " Use gc or gcc to comment
Plug 'phaazon/hop.nvim'                             " Quick jump around the buffer
Plug 'neovim/nvim-lspconfig'                        " Language server linting
Plug 'jiangmiao/auto-pairs'                         " Parentheses
Plug 'rafamadriz/friendly-snippets'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'hrsh7th/nvim-compe'                           " Auto-complete
Plug 'tpope/vim-repeat'                             " Actually repeat using .

" Ancillary plugins
Plug 'godlygeek/tabular'              " Spacing and alignment
Plug 'unblevable/quick-scope'         " Hints for f and t
Plug 'vimwiki/vimwiki'                " Wiki Markdown System
Plug 'airblade/vim-rooter'            " Change directory to git route
Plug 'tpope/vim-fugitive'             " Other git commands
Plug 'itchyny/lightline.vim'          " Status bar
Plug 'tpope/vim-eunuch'               " File manipulation in Vim
Plug 'tpope/vim-vinegar'              " Fixes netrw file explorer
Plug 'christoomey/vim-tmux-navigator' " Hotkeys for tmux panes

call plug#end()

" Enable plugins
lua << EOF
require('lspconfig').rust_analyzer.setup{}
require('lspconfig').pyls.setup{}
require('gitsigns').setup()
require'compe'.setup({
    enabled = true,
    source = {
        path = true,
        buffer = true,
        nvim_lsp = true,
    },
})
EOF

lua << EOF
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
_G.cr_complete = function()
    -- if vim.fn.pumvisible() == 1
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
EOF
