function copy --description 'Copy file contents into clipboard'
    cat $argv | pbcopy
end
