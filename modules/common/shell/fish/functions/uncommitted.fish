echo "Searching git repos..." >&2
find "$HOME/dev" -type d -name '.git' | while read dir
    set fullPath (dirname "$dir")
    set relativePath (echo "$fullPath" | cut -d'/' -f5-)
    if test -n (echo (git -C "$fullPath" status -s))
        echo "$relativePath"
        git -C "$fullPath" status -s
    end
end
