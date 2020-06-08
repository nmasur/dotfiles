syntax enable
set background=dark
" colorscheme solarized
set nu
set expandtab
set shiftwidth=4
set softtabstop=4
set ignorecase
set smartcase
set pastetoggle=<F3>
set visualbell

" remember last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" path manipulation
execute pathogen#infect()
filetype plugin indent on

" terraform plugin
let g:terraform_align=1
let g:terraform_remap_spacebar=1

" powerline
let g:Powerline_symbols = 'fancy'

" line type
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

" better backup, swap and undo storage
set noswapfile
set backup
set undofile
set backupdir=~/.vim/dirs/backup
set undodir=~/.vim/dirs/undo
if !isdirectory(&backupdir)
  call mkdir(&backupdir, "p")
endif
if !isdirectory(&undodir)
  call mkdir(&undodir, "p")
endif

" 256 colors
" if !has("gui_running")
"     set nocompatible
"     colorscheme solarized
"     set mouse=a
" endif
set mouse=nv

" change title
let &titlestring = @%
set title
