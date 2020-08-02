" Vim Config

" Plugins
"--------

" Install vim-plugged if not installed
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source ~/.config/nvim/init.vim
endif

" All plugins
call plug#begin('~/.config/nvim/plugged')

Plug 'morhetz/gruvbox'                              " Colorscheme
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Required for fuzzyfinder
Plug 'junegunn/fzf.vim'                             " Actual fuzzyfinder
Plug 'tpope/vim-surround'                           " Enables paren editing
Plug 'tmsvg/pear-tree'                              " Auto- and smart-parentheses
Plug 'tpope/vim-commentary'                         " Use gc or gcc to comment
Plug 'sheerun/vim-polyglot'                         " Syntax for every language
Plug 'vimwiki/vimwiki'                              " Wiki Markdown System
Plug 'jreybert/vimagit'                             " Git 'gui' buffer
Plug 'airblade/vim-gitgutter'                       " Git next to line numbers
Plug 'tpope/vim-fugitive'                           " Other git commands
Plug 'machakann/vim-highlightedyank'                " Highlight text when copied
Plug 'itchyny/lightline.vim'                        " Status bar
Plug 'tpope/vim-vinegar'                            " Fixes netrw file explorer
Plug 'lambdalisue/fern.vim'                         " File explorer / project drawer
Plug 'christoomey/vim-tmux-navigator'               " Hotkeys for tmux panes
Plug 'neoclide/coc.nvim', {'branch': 'release'}     " Code completion

call plug#end()

" Basic Settings
filetype plugin on              " Load the plugin for current filetype (vimwiki)
syntax enable                   " Syntax highlighting
set termguicolors               " Set to truecolor
colorscheme gruvbox             " Installed in autoload/ and colors/

" Options
set number                      " Show line numbers
set relativenumber              " Relative numbers instead of absolute
set list                        " Reveal whitespace with ---
set expandtab                   " Tabs into spaces
set shiftwidth=4                " Amount to shift with > key
set softtabstop=4               " Amount to shift with TAB key
set ignorecase                  " Ignore case when searching
set smartcase                   " Check case when using capitals in search
set incsearch                   " Search while typing
set visualbell                  " No sounds
set scrolljump=1                " Scroll more than one line (or 1 line)
set scrolloff=3                 " Margin of lines when scrolling
set pastetoggle=<F3>            " Use F3 to enter paste mode
set clipboard+=unnamedplus      " Uses system clipboard for yanking

" Neovim only
set inccommand=split            " Live preview search and replace

" Mouse interaction / scrolling
set mouse=nv

" Remember last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Better backup, swap and undo storage
set noswapfile                          " Instead of swaps, create backups (less annoying)
set backup                              " Easier to recover and more secure 
set undofile                            " Keeps undos after quit
set backupdir=~/.config/nvim/dirs/backup
set undodir=~/.config/vim/dirs/undo

" Create backup directories if they don't exist
if !isdirectory(&backupdir)
  call mkdir(&backupdir, "p")
endif
if !isdirectory(&undodir)
  call mkdir(&undodir, "p")
endif

" Custom commands
command Vimrc edit ~/.config/nvim/init.vim  " Edit .vimrc (this file)

" Custom Keybinds
"----------------

" Map the leader key
map <Space> <Leader>

"This unsets the `last search pattern` register by hitting return
nnoremap <silent> <CR> :noh<CR><CR>

" Jump to text in this directory
nnoremap <Leader>/ :Rg<CR>

" Open file in this directory
nnoremap <Leader>f :Files<cr>

" Open a recent file
nnoremap <Leader>r :History<cr>

" Switch between multiple open files
nnoremap <Leader>b :Buffers<cr>

" Jump to text in this file
nnoremap <Leader>s :BLines<cr>

" Start Magit buffer
nnoremap <Leader>g :Magit<cr>

" Toggle Git gutter (by line numbers)
nnoremap <Leader>` :GitGutterToggle<cr>

" Git push
nnoremap <Leader>p :Git push<cr>

" Close all other splits
nnoremap <Leader>m :only<cr>

" Open file tree
noremap <silent> <Leader>t :Fern . -drawer -width=35 -toggle<CR><C-w>=

" Plugin Settings
"----------------

" Built-in explorer plugin
let g:netrw_liststyle = 3               " Change style to 'tree' view
let g:netrw_banner = 0                  " Remove useless banner
let g:netrw_winsize = 15                " Explore window takes % of page
let g:netrw_browse_split = 4            " Open in previous window
let g:netrw_altv = 1                    " Always split left

" Pear Tree parentheses plugin
let g:pear_tree_repeatable_expand = 0   " Don't hide paren until escape
let g:pear_tree_smart_openers = 1       " Smart paren mode, which checks outer or inners
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1

" Gitgutter plugin
let g:gitgutter_enabled = 0             " Disable on start

" Polyglot syntax plugin
let g:terraform_fmt_on_save=1           " Formats with terraform plugin

" VimWiki plugin
let g:vimwiki_list = [
  \ {
  \   'path': '~/Documents/notes/',
  \   'syntax': 'markdown',
  \   'ext': '.md'
  \ }
  \ ]

" Lightline status bar plugin
let g:lightline = {
  \ 'colorscheme': 'jellybeans',
  \ 'active': {
  \   'right': [[ 'lineinfo' ]],
  \   'left': [[ 'mode', 'paste' ],
  \            [ 'readonly', 'relativepath', 'gitbranch', 'modified' ]]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'fugitive#head'
  \ }
  \ }
