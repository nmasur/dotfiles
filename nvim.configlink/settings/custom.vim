" Custom Commands
"----------------

command! Vimrc edit $MYVIMRC     " Edit .vimrc (this file)
command! Refresh source $MYVIMRC " Refresh from .vimrc (this file)

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

" Split window
nnoremap <Leader>ws :vsplit<cr>

" Close all other splits
nnoremap <Leader>wm :only<cr>

" Exit terminal mode (requires Alacritty escape)
tnoremap <S-CR> <C-\><C-n>

" Reload Vimrc settings
nnoremap <Leader>rr :Refresh<cr>
nnoremap <Leader>rp :Refresh<cr> :PlugInstall<cr>

" Open file tree
noremap <silent> <Leader>ft :Fern . -drawer -width=35 -toggle<CR><C-w>=

" Tabularize
nnoremap <Leader>ta :Tabularize /
nnoremap <Leader>t# :Tabularize /#<CR>
nnoremap <Leader>t" :Tabularize /"<CR>

" Read todo comments
nnoremap <Leader>td /# \?TODO:\?<CR>
