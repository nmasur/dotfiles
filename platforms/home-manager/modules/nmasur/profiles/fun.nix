{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nmasur.profiles.fun;
in

{

  options.nmasur.profiles.fun.enable = lib.mkEnableOption "Fun tools";

  config = lib.mkIf cfg.enable {

    home.packages = lib.mkDefault [

      # Charm tools

      pkgs.glow # Markdown previews
      pkgs.skate # Key-value store
      pkgs.charm # Manage account and filesystem
      pkgs.pop # Send emails from a TUI

    ];

  };

}
