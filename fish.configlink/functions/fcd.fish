# Defined via `source`
function fcd --wraps='set jump (fd -t d . ~ | fzf); and cd $jump' --description 'alias fcd set jump (fd -t d . ~ | fzf); and cd $jump'
  set jump (fd -t d . ~ | fzf); and cd $jump $argv; 
end
