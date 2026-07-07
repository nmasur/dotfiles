{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.darwin-base;
in

{

  options.nmasur.profiles.darwin-base.enable = lib.mkEnableOption "Base macOS home-manager config";

  config = lib.mkIf cfg.enable {

    nmasur.presets = {
      fonts.enable = lib.mkDefault true;
      services = {
        darwin-settings.enable = lib.mkDefault true;
        dock.enable = lib.mkDefault true;
        finder.enable = lib.mkDefault true;
        hammerspoon.enable = lib.mkDefault true;
        menubar.enable = lib.mkDefault true;
      };
      programs = {
        fish-darwin.enable = lib.mkDefault true;
        homebrew.enable = lib.mkDefault true;
        nixpkgs-darwin.enable = lib.mkDefault true;
        mpv.enable = lib.mkDefault true;
        noti.enable = lib.mkDefault true;
      };
    };

    home.homeDirectory = lib.mkForce "/Users/${config.home.username}";
  };

  # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
  # home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
}
