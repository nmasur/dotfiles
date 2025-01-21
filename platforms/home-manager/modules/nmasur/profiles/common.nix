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
    home.packages = with pkgs; [
      dig # DNS lookup
      fd # find
      htop # Show system processes
      killall # Force quit
      inetutils # Includes telnet, whois
      jq # JSON manipulation
      rsync # Copy folders
      ripgrep # grep
      sd # sed
      unzip # Extract zips
    ];

  };
}
