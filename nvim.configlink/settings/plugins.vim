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
Plug 'morhetz/gruvbox'                              " Colorscheme
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Install fzf (required)
Plug 'junegunn/fzf.vim'                             " Actual fuzzyfinder
Plug 'tpope/vim-surround'                           " Enables paren editing
Plug 'sheerun/vim-polyglot'                         " Syntax for every language
Plug 'airblade/vim-gitgutter'                       " Git next to line numbers
Plug 'tpope/vim-commentary'                         " Use gc or gcc to comment
Plug 'phaazon/hop.nvim'                             " Quick jump around the buffer

" Ancillary plugins
Plug 'godlygeek/tabular'              " Spacing and alignment
Plug 'unblevable/quick-scope'         " Hints for f and t
Plug 'vimwiki/vimwiki'                " Wiki Markdown System
Plug 'airblade/vim-rooter'            " Change directory to git route
Plug 'tpope/vim-fugitive'             " Other git commands
Plug 'machakann/vim-highlightedyank'  " Highlight text when copied
Plug 'itchyny/lightline.vim'          " Status bar
Plug 'tpope/vim-eunuch'               " File manipulation in Vim
Plug 'tpope/vim-vinegar'              " Fixes netrw file explorer
Plug 'christoomey/vim-tmux-navigator' " Hotkeys for tmux panes

" CoC (Language Server Protocol, requires NodeJS)
Plug 'neoclide/coc.nvim', {'branch': 'release'}     " Code completion

call plug#end()
