{ config, ... }: {

  imports = [
    ./alacritty.nix
    ./dotfiles.nix
    ./fonts.nix
    ./hammerspoon.nix
    ./homebrew.nix
    ./system.nix
    ./tmux.nix
    ./user.nix
    ./utilities.nix
  ];

  home-manager.users.${config.user}.home.stateVersion = "22.11";
  home-manager.users.root.home.stateVersion = "22.11";

}
