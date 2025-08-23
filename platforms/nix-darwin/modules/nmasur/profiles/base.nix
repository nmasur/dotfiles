{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.base;
in

{

  options.nmasur.profiles.base.enable = lib.mkEnableOption "base macOS config";

  config = lib.mkIf cfg.enable {

    system.primaryUser = config.nmasur.settings.username;

    nmasur.presets = {
      programs = {
        fish.enable = lib.mkDefault true;
        homebrew.enable = lib.mkDefault true;
      };
      services = {
        dock.enable = lib.mkDefault true;
        finder.enable = lib.mkDefault true;
        hammerspoon.enable = lib.mkDefault true;
        menubar.enable = lib.mkDefault true;
        nix.enable = lib.mkDefault true;
        settings.enable = lib.mkDefault true;
        user.enable = lib.mkDefault true;
      };
    };

    homebrew.brews = [
      "trash" # Delete files and folders to trash instead of rm
    ];
    homebrew.casks = [
      "scroll-reverser" # Different scroll style for mouse vs. trackpad
      "notunes" # Don't launch Apple Music with the play button
      "topnotch" # Darkens the menu bar to complete black
      "ghostty" # Terminal application (not buildable on Nix on macOS)
    ];

  };
}
