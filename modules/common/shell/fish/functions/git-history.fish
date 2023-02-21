if not count $argv >/dev/null
    echo "Must provide filename."
    return 1
end
set commitline ( git log \
    --follow \
    --pretty="format:%C(auto)%ar %h%d %s" \
    -- ./$argv \
    | fzf \
        --height 100% \
        --preview "git diff --color=always (echo {} | cut -d' ' -f4)^1..(echo {} | cut -d' ' -f4) -- ./$argv" \
        )
and set commit (echo $commitline | cut -d" " -f4)
and echo $commit
