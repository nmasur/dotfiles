" LaTeX Settings
"---------------

" LaTeX Hotkeys
autocmd FileType tex inoremap ;bf \textbf{}<Esc>i
" Jump to the next occurence of <> and replace it with insert mode
autocmd FileType tex nnoremap <Leader><Space> /<><Esc>:noh<CR>c2l

" Autocompile LaTeX on save
autocmd BufWritePost *.tex silent! execute "!pdflatex -output-directory=%:p:h % >/dev/null 2>&1" | redraw!
