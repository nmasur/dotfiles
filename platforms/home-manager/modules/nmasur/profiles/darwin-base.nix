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
      services.hammerspoon.enable = lib.mkDefault true;
      programs.nixpkgs-darwin.enable = lib.mkDefault true;
    };

    home.homeDirectory = lib.mkForce "/Users/${config.home.username}";

    # Default shell setting doesn't work
    home.sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
    };

    # Used for aerc
    xdg.enable = lib.mkDefault pkgs.stdenv.isDarwin;

    programs.fish.shellAbbrs.t = "trash";

    # Add homebrew paths to CLI path
    home.sessionPath = [
      "/opt/homebrew/bin/"
      "/opt/homebrew/opt/trash/bin"
    ];

    home.packages = [
      pkgs.noti # Create notifications programmatically
    ];
  };

  # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
  # home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
}
