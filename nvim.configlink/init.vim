" Vim Config

" Plugins
call plug#begin('~/.config/nvim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Required for fuzzyfinder
Plug 'junegunn/fzf.vim'                             " Actual fuzzyfinder
Plug 'tpope/vim-surround'                           " Enables paren editing
Plug 'Raimondi/delimitMate'                         " Auto-close parentheses
Plug 'tpope/vim-commentary'                         " Use gc or gcc to comment
Plug 'hashivim/vim-terraform'                       " Terraform HCL syntax
Plug 'vimwiki/vimwiki'                              " Wiki System
Plug 'jreybert/vimagit'                             " Git 'gui' buffer
Plug 'airblade/vim-gitgutter'                       " Git next to line numbers
Plug 'tpope/vim-fugitive'                           " Other git commands
Plug 'machakann/vim-highlightedyank'                " Highlight text when copied
Plug 'itchyny/lightline.vim'                        " Status bar
Plug 'shinchu/lightline-gruvbox.vim'                " Colors for status bar
Plug 'tpope/vim-vinegar'                            " Fixes netrw file explorer

call plug#end()

" Settings
filetype plugin on              " Load the plugin for current filetype (vimwiki)
syntax enable                   " Syntax highlighting
set termguicolors               " Set to truecolor
colorscheme gruvbox             " Installed in autoload/ and colors/

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

set clipboard+=unnamedplus      " Uses system clipboard for yanking

" Remember last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Line type
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

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

" Command to edit vimrc (this file)
command Vimrc edit ~/.config/nvim/init.vim

" Map the leader key
map <Space> <Leader>

" Jump to text in this directory
nnoremap <Leader>/ :Rg<CR>

" Open file in this directory
nnoremap <Leader>f :Files<cr>

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
nnoremap <Leader>t :Vexplore<cr>

" Mouse interaction / scrolling
set mouse=nv

" Change title
let &titlestring = @%
set title

" Make whitespace pretty
" if &listchars ==# 'eol:$'
"   set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
" endif

" Built-in explorer plugin
let g:netrw_liststyle = 3               " Change style to 'tree' view
let g:netrw_banner = 0                  " Remove useless banner
let g:netrw_winsize = 15                " Explore window takes % of page
let g:netrw_browse_split = 4            " Open in previous window
let g:netrw_altv = 1                    " idk

" Gitgutter plugin
let g:gitgutter_enabled = 0             " Disable on start

" Terraform Plugin
let g:terraform_fmt_on_save=1

" VimWiki Plugin
let g:vimwiki_list = [{'path': '~/Documents/notes/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction

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
" let g:lightline.colorscheme = 'gruvbox'

" set statusline+=%{GitStatus()}
