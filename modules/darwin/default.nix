{ config, ... }: {

  imports = [
    ./alacritty.nix
    ./fonts.nix
    ./hammerspoon.nix
    ./homebrew.nix
    ./nixpkgs.nix
    ./system.nix
    ./tmux.nix
    ./user.nix
    ./utilities.nix
  ];

}
