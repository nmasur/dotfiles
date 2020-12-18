function prj --description "cd to a project"
    set projdir (ls $PROJ | fzf)
    and cd $PROJ/$projdir
end
