" General
"--------

" Basic Settings
filetype plugin on  " Load the plugin for current filetype (vimwiki)
syntax enable       " Syntax highlighting
set termguicolors   " Set to truecolor
colorscheme gruvbox " Installed in autoload/ and colors/

" Options
set hidden                 " Don't unload buffers when leaving them
set number                 " Show line numbers
set relativenumber         " Relative numbers instead of absolute
set list                   " Reveal whitespace with ---
set expandtab              " Tabs into spaces
set shiftwidth=4           " Amount to shift with > key
set softtabstop=4          " Amount to shift with <TAB> key
set ignorecase             " Ignore case when searching
set smartcase              " Check case when using capitals in search
set infercase              " Don't match cases when completing suggestions
set incsearch              " Search while typing
set visualbell             " No sounds
set scrolljump=1           " Scroll more than one line (or 1 line)
set scrolloff=3            " Margin of lines when to start scrolling
set splitright             " Vertical splits on the right side
set splitbelow             " Horizontal splits on the lower side
set pastetoggle=<F3>       " Use F3 to enter raw paste mode
set clipboard+=unnamedplus " Uses system clipboard for yanking
set updatetime=300         " Faster diagnostics
set mouse=nv               " Mouse interaction / scrolling

" Neovim only
set inccommand=split       " Live preview search and replace

" Remember last position when reopening file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Better backup, swap and undo storage
set noswapfile                           " Instead of swaps, create backups (less annoying)
set backup                               " Easier to recover and more secure
set undofile                             " Keeps undos after quit
set backupdir=~/.config/nvim/dirs/backup
set undodir=~/.config/nvim/dirs/undo

" Keep selection when tabbing
vnoremap < <gv
vnoremap > >gv

" Create backup directories if they don't exist
if !isdirectory(&backupdir)
  call mkdir(&backupdir, "p")
endif
if !isdirectory(&undodir)
  call mkdir(&undodir, "p")
endif
