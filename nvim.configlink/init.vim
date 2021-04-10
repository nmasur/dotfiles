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

" Core plugins
Plug 'morhetz/gruvbox'                              " Colorscheme
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Required for fuzzyfinder
Plug 'junegunn/fzf.vim'                             " Actual fuzzyfinder
Plug 'tpope/vim-surround'                           " Enables paren editing
Plug 'sheerun/vim-polyglot'                         " Syntax for every language
Plug 'airblade/vim-gitgutter'                       " Git next to line numbers
Plug 'tpope/vim-commentary'                         " Use gc or gcc to comment
Plug 'godlygeek/tabular'                            " Spacing and alignment

" Ancillary plugins
Plug 'unblevable/quick-scope'                       " Hints for f and t
Plug 'vimwiki/vimwiki'                              " Wiki Markdown System
Plug 'jreybert/vimagit'                             " Git 'gui' buffer
Plug 'tpope/vim-fugitive'                           " Other git commands
Plug 'machakann/vim-highlightedyank'                " Highlight text when copied
Plug 'itchyny/lightline.vim'                        " Status bar
Plug 'tpope/vim-vinegar'                            " Fixes netrw file explorer
Plug 'lambdalisue/fern.vim'                         " File explorer / project drawer
Plug 'christoomey/vim-tmux-navigator'               " Hotkeys for tmux panes

" CoC
Plug 'neoclide/coc.nvim', {'branch': 'release'}     " Code completion

call plug#end()

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
set softtabstop=4          " Amount to shift with TAB key
set ignorecase             " Ignore case when searching
set smartcase              " Check case when using capitals in search
set incsearch              " Search while typing
set visualbell             " No sounds
set scrolljump=1           " Scroll more than one line (or 1 line)
set scrolloff=3            " Margin of lines when scrolling
set pastetoggle=<F3>       " Use F3 to enter paste mode
set clipboard+=unnamedplus " Uses system clipboard for yanking
set updatetime=300         " Faster diagnostics

" Neovim only
set inccommand=split            " Live preview search and replace

" Mouse interaction / scrolling
set mouse=nv

" Remember last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Better backup, swap and undo storage
set noswapfile                           " Instead of swaps, create backups (less annoying)
set backup                               " Easier to recover and more secure
set undofile                             " Keeps undos after quit
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

" Replace all
nnoremap <Leader>S :%s//g<Left><Left>

" Jump to text in this directory
nnoremap <Leader>/ :Rg<CR>

" Quit vim
nnoremap <Leader>q :quit<cr>

" Save file
nnoremap <Leader>fs :write<cr>

" Open file in this directory
nnoremap <Leader>ff :Files<cr>

" Change directory to this file
nnoremap <silent> <Leader>fd :lcd %:p:h<cr>

" Back up directory
nnoremap <silent> <Leader>fu :lcd ..<cr>

" Open a recent file
nnoremap <Leader>fr :History<cr>

" Switch between multiple open files
nnoremap <Leader>bb :Buffers<cr>

" Jump to text in this file
nnoremap <Leader>s :BLines<cr>

" Start Magit buffer
nnoremap <Leader>gs :Magit<cr>

" Toggle Git gutter (by line numbers)
nnoremap <Leader>` :GitGutterToggle<cr>

" Git push
nnoremap <Leader>gp :Git push<cr>

" Split window
nnoremap <Leader>ws :vsplit<cr>

" Close all other splits
nnoremap <Leader>wm :only<cr>

" Open file tree
noremap <silent> <Leader>ft :Fern . -drawer -width=35 -toggle<CR><C-w>=

" CoC Settings
"-------------

let g:coc_global_extensions = [
    \ 'coc-rust-analyzer',
    \ 'coc-pairs',
    \ 'coc-diagnostic',
\ ]

" Set tab to completion
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
" Uses updatetime for delay before showing info.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" LaTeX Settings
"---------------

" LaTeX Hotkeys
autocmd FileType tex inoremap ;bf \textbf{}<Esc>i
" Jump to the next occurence of <> and replace it with insert mode
autocmd FileType tex nnoremap <Leader><Space> /<><Esc>:noh<CR>c2l

" Autocompile LaTeX on save
autocmd BufWritePost *.tex silent! execute "!pdflatex -output-directory=%:p:h % >/dev/null 2>&1" | redraw!

" Plugin Settings
"----------------

" Built-in explorer plugin
let g:netrw_liststyle = 3    " Change style to 'tree' view
let g:netrw_banner = 0       " Remove useless banner
let g:netrw_winsize = 15     " Explore window takes % of page
let g:netrw_browse_split = 4 " Open in previous window
let g:netrw_altv = 1         " Always split left

" Gitgutter plugin
let g:gitgutter_enabled = 1 " Enabled on start

" Polyglot syntax plugin
let g:terraform_fmt_on_save=1 " Formats with terraform plugin
let g:rustfmt_autosave = 1    " Formats with rust plugin

" VimWiki plugin
let g:vimwiki_list = [
  \ {
  \   'path': $NOTES_PATH,
  \   'syntax': 'markdown',
  \   'index': 'home',
  \   'ext': '.md'
  \ }
  \ ]
let g:vimwiki_key_mappings =
  \ {
  \   'all_maps': 1,
  \   'mouse': 1,
  \ }
let g:vimwiki_auto_chdir = 1

" Quickscope only highlight on keypress
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" Lightline status bar plugin
let g:lightline = {
  \ 'colorscheme': 'jellybeans',
  \ 'active': {
  \   'right': [[ 'lineinfo' ]],
  \   'left': [[ 'mode', 'paste' ],
  \            [ 'cocstatus', 'readonly', 'relativepath', 'gitbranch', 'modified' ]]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'fugitive#head',
  \   'cocstatus': 'coc#status'
  \ },
  \ }

" Use autocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
