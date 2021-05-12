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
Plug 'hrsh7th/nvim-compe'                           " Auto-complete

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
