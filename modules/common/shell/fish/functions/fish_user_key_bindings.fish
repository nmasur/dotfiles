bind -M insert \co edit
bind -M default \co edit
bind -M insert \cs search-and-edit
bind -M default \cs search-and-edit
bind -M insert \ca 'cd ~; and edit; and commandline -a "; cd -"; commandline -f execute'
bind -M default \ca 'cd ~; and edit; and commandline -a "; cd -"; commandline -f execute'
bind -M insert \ce recent
bind -M default \ce recent
bind -M default \cg commandline-git-commits
bind -M insert \cg 'commandline -i (git rev-parse --show-toplevel 2>/dev/null || echo ".")'
bind -M insert \cf fcd
bind -M default \cf fcd
bind -M insert \cp projects
bind -M default \cp projects
bind -M insert \x1F accept-autosuggestion
bind -M default \x1F accept-autosuggestion
bind -M insert \cn 'commandline -r "nix shell nixpkgs#"'
bind -M default \cn 'commandline -r "nix shell nixpkgs#"'
bind -M insert \x11F nix-fzf
bind -M default \x11F nix-fzf
bind -M insert \ch '_atuin_search --filter-mode global'
bind -M default \ch '_atuin_search --filter-mode global'
