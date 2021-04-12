" Lightline Status Bar
"---------------------

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
