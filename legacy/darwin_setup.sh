#!/bin/bash

# List brews
brew list --formula

# List dependencies
brew list -1 | while read -r cask; do
    echo -ne "\x1B[1;34m $cask \x1B[0m"
    brew uses "$cask" --installed | awk '{printf(" %s ", $0)}'
    echo ""
done

# Uninstall brews
brew remove --force "$(brew list --formula)"
brew remove --force sd
brew remove --force zoxide
brew remove --force bat
brew remove --force fzf
brew remove --force tealdeer
brew remove --force glow
brew remove --force dos2unix
brew remove --force tree
brew remove --force wget
brew remove --force telnet
brew remove --force prettyping
brew remove --force httpie
brew remove --force gpg
brew remove --force qrencode
brew remove --force mpv
brew remove --force youtube-dl
brew remove --force pandoc
brew remove --force saulpw/vd/visidata
brew remove --force mdp
brew remove --force ansible
brew remove --force terraform
brew remove --force packer
brew remove --force awscli
brew remove --force kubectl
brew remove --force k9s
brew remove --force nmasur/repo/drips
brew remove --force hashicorp/tap/terraform-ls
brew remove --force tflint
brew remove --force noti
brew remove --force awslogs
brew remove --force shellcheck
brew remove --force shfmt
brew remove --force stylua
brew remove --force python
brew remove --force ipython
brew remove --force poetry
brew remove --force ruby
brew remove --force node
brew remove --force jq
brew remove --force gh
brew remove --force direnv
brew remove --force git
brew remove --force ripgrep
brew remove --force fd
brew remove --force neovim
brew remove --force exa
brew remove --force starship
brew remove --force tmux
brew remove --force fish
# brew remove --force trash

# Uninstall casks
brew remove --force keybase
brew remove --force discord
brew remove --force obsidian
brew remove --force dropbox
brew remove --force 1password
brew remove --force firefox
brew remove --force font-fira-mono-nerd-font
brew remove --force alacritty
# brew remove --force scroll-reverser
# brew remove --force meetingbar
# brew remove --force gitify
# brew remove --force hammerspoon
# brew remove --force logitech-g-hub

# Uninstall homebrew
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Install Nix
sh -c "$(curl -L https://nixos.org/nix/install)"

# Install nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

# Use with flake (requires installing first)
darwin-rebuild switch --flake .
darwin-rebuild switch --flake .#macbook # not sure if required
