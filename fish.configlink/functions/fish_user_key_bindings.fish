#!/usr/local/bin/fish

function fish_user_key_bindings
    bind -M insert \co 'edit'
    bind -M insert \ce 'recent'
    bind -M insert \cg 'commandline-git-commits'
end
