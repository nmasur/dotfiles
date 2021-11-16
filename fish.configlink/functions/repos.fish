#!/usr/local/bin/fish

function repos --description 'Clone GitHub repositories' -a 'organization'
    set directory (gh-repos $organization)
    and cd $directory
end
    #switch $organization
    #    case t2; set organization "take-two"
    #    case d2c; set organization "take-two-t2gp"
    #    case t2gp; set organization "take-two-t2gp"
    #    case pd; set organization "private-division"
    #    case dots; set organization "playdots"
    #    case '*'; set organization "nmasur"
    #end

    #set selected (gh repo list "$organization" \
    #    --limit 50 \
    #    --no-archived \
    #    --json=name,description,isPrivate,updatedAt,primaryLanguage \
    #    | jq -r '.[] | .name + "," + if .description == "" then "-" else .description end + "," + .updatedAt + "," + .primaryLanguage.name' \
    #    | begin
    #        echo "REPO,DESCRIPTION,UPDATED,LANGUAGE"
    #        cat -
    #      end | column -s , -t
    #        | fzf \
    #            --header-lines=1 \
    #            --layout=reverse 
            #--bind "ctrl-o:execute:gh repo view -w $organization/{1}" \
            #--preview "GH_FORCE_TTY=49% gh repo view $organization/{1} | glow -" \
            #--preview-window up
#)
    #if test -n (echo $selected | tr -d '\r')
    #    set directory "$HOME/dev/work"
    #    if test $organization = "nmasur"
    #        set directory "$HOME/dev/personal"
    #    end
    #    set repo (echo $selected | awk '{print $1}')
    #    set repo_full "$organization/$repo"
    #    gh repo clone "$repo_full" "$directory/$repo"
    #    cd "$directory/$repo"
    #end
#end
