{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.common;
in
{
  options.nmasur.profiles.common.enable = lib.mkEnableOption "Common home-manager config";

  config = lib.mkIf cfg.enable {

    home.username = config.nmasur.settings.username;
    home.homeDirectory =
      if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

    home.packages = [
      pkgs.dig # DNS lookup
      pkgs.fd # find
      pkgs.htop # Show system processes
      pkgs.killall # Force quit
      pkgs.inetutils # Includes telnet, whois
      pkgs.jq # JSON manipulation
      pkgs.rsync # Copy folders
      pkgs.ripgrep # grep
      pkgs.sd # sed
      pkgs.unzip # Extract zips
    ];

    nmasur.presets = {
      programs = {
        bat.enable = lib.mkDefault true;
        chawan.enable = lib.mkDefault true;
        fd.enable = lib.mkDefault true;
        ripgrep.enable = lib.mkDefault true;
        starship.enable = lib.mkDefault true;
        nixpkgs.enable = lib.mkDefault true;
      };
      services = {
        loadkey.enable = lib.mkDefault true;
      };
    };

  };
}
