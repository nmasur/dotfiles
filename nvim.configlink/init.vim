" Vim Config

syntax enable                   " Syntax highlighting
set termguicolors               " Set to truecolor
colorscheme gruvbox             " Installed in autoload/ and colors/

set number                      " Show line numbers
set relativenumber              " Relative numbers instead of absolute
set expandtab                   " Tabs into spaces
set shiftwidth=4                " 
set softtabstop=4               " 
set ignorecase                  " Ignore case when searching
set smartcase                   " Check case when using capitals in search
set incsearch                   " Search while typing
set pastetoggle=<F3>
set visualbell

" Remember last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Terraform plugin
let g:terraform_align=1
let g:terraform_remap_spacebar=1

" line type
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

" Better backup, swap and undo storage
set noswapfile                          " Instead of swaps, create backups (less annoying)
set backup                              " Easier to recover and more secure 
set undofile                            " Keeps undos after quit
set backupdir=~/.vim/dirs/backup
set undodir=~/.vim/dirs/undo

" Create backup directories if they don't exist
if !isdirectory(&backupdir)
  call mkdir(&backupdir, "p")
endif
if !isdirectory(&undodir)
  call mkdir(&undodir, "p")
endif

" Mouse interaction / scrolling
set mouse=nv

" Change title
let &titlestring = @%
set title

