function json --description "Tidy up JSON with jq"
    pbpaste | jq '.' | pbcopy
end
