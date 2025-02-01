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
        bat.enable = true;
        ripgrep.enable = true;
        fd.enable = true;
      };
      services = {
        loadkey.enable = lib.mkDefault true;
      };
    };

  };
}
