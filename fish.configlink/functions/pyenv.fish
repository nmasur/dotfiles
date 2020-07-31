#!/usr/local/bin/fish

function 'pyenv' --description 'Features for Pyenv virtualenvs'

    set -g PYENV_VERSIONS_DIR $HOME/.pyenv/versions

    abbr -a d 'deactivate'
    alias pv='cd $PYENV_VERSIONS_DIR'
    alias ip='source $PYENV_VERSIONS_DIR/ipython/bin/activate.fish'


    function 'venv' --description 'Enter a pyenv virtualenv'
        source ~/.pyenv/versions/$argv[1]/bin/activate.fish
    end

    # vers - switch to pyenv virtualenv with fuzzy menu
    function 'vers' --description 'Switch to virtualenv'
        set pyversion (bash -c "pyenv versions --bare --skip-aliases" | fzf)
        if test $status -ne 0
            return 1
        else
            source "$PYENV_VERSIONS_DIR/$pyversion/bin/activate.fish"
        end
    end

    function 'ipy' --description 'Borrow iPython interpreter'
        set STORED_VENV $VIRTUAL_ENV
        source $PYENV_VERSIONS_DIR/ipython/bin/activate.fish; and \
            ipython; and \
            deactivate; and \
            if [ $STORED_VENV ];
                source $STORED_VENV/bin/activate.fish
            end
    end
end
