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

    home.packages = with pkgs; [

      # Charm tools

      glow # Markdown previews
      skate # Key-value store
      charm # Manage account and filesystem
      pop # Send emails from a TUI

    ];

  };

}
