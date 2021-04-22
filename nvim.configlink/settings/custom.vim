" Custom Commands
"----------------

command! Vimrc edit $MYVIMRC     " Edit .vimrc (this file)
command! Refresh source $MYVIMRC " Refresh from .vimrc (this file)
command! Today exe 'edit ~/notes/journal/'.strftime("%Y-%m-%d_%a").'.md'

" Custom Keybinds
"----------------

" Map the leader key
map <Space> <Leader>

"This unsets the `last search pattern` register by hitting return
nnoremap <silent> <CR> :noh<CR><CR>

" Replace all
nnoremap <Leader>S :%s//g<Left><Left>

" Shuffle lines around
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Jump to text in this directory
nnoremap <Leader>/ :Rg<CR>

" Quit vim
nnoremap <Leader>q :quit<cr>
nnoremap <Leader>Q :quitall<cr>

" Save file
nnoremap <Leader>fs :write<cr>

" Make file executable
nnoremap <silent> <Leader>fe :!chmod 755 %<cr><cr>

" Make file normal permissions
nnoremap <silent> <Leader>fn :!chmod 644 %<cr><cr>

" Open file in this directory
nnoremap <Leader>ff :Files<cr>

" Change directory to this file
nnoremap <silent> <Leader>fd :lcd %:p:h<cr>

" Back up directory
nnoremap <silent> <Leader>fu :lcd ..<cr>

" Open a recent file
nnoremap <Leader>fr :History<cr>

" Switch between multiple open files
nnoremap <Leader>b :Buffers<cr>

" Switch between two open files
nnoremap <Leader><Tab> :b#<cr>

" Jump to text in this file
nnoremap <Leader>s :BLines<cr>

" Start Magit buffer
nnoremap <Leader>gs :Magit<cr>

" Toggle Git gutter (by line numbers)
nnoremap <Leader>` :GitGutterToggle<cr>

" Git push
nnoremap <Leader>gp :Git push<cr>

" Git repo
nnoremap <silent> <Leader>gr :!gh repo view -w<cr><cr>

" Split window
nnoremap <Leader>wv :vsplit<cr>
nnoremap <Leader>wh :split<cr>

" Close all other splits
nnoremap <Leader>wm :only<cr>

" Zoom / Restore window.
" https://stackoverflow.com/a/26551079
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <leader>z :ZoomToggle<CR>

" Exit terminal mode (requires Alacritty escape)
tnoremap <S-CR> <C-\><C-n>

" Reload Vimrc settings
nnoremap <Leader>rr :Refresh<cr>
nnoremap <Leader>rp :Refresh<cr> :PlugInstall<cr>

" Open file tree
noremap <silent> <Leader>ft :Fern . -drawer -width=35 -toggle<CR><C-w>=

" Tabularize
noremap <Leader>ta :Tabularize /
noremap <Leader>t# :Tabularize /#<CR>
noremap <Leader>t" :Tabularize /"<CR>

" Read todo comments
nnoremap <Leader>td /# \?TODO:\?<CR>
