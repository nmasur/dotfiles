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
    # Default shell setting doesn't work
    home.sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
    };

    # Used for aerc
    xdg.enable = lib.mkDefault pkgs.stdenv.isDarwin;

    home.packages = [
      pkgs.noti # Create notifications programmatically
    ];
  };

  # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
  # home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
}
