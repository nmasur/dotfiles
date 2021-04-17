" VimWiki
"--------

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
let g:vimwiki_auto_chdir = 1  " Set local dir to Wiki when open
let g:vimwiki_create_link = 0 " Don't automatically create new links