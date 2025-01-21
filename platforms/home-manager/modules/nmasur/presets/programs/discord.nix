{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.discord;
in

{

  options.nmasur.presets.programs.discord.enable = lib.mkEnableOption "Discord chat";

  config = lib.mkIf cfg.enable {
    unfreePackages = [ "discord" ];
    home.packages = [ pkgs.discord ];
    xdg.configFile."discord/settings.json".text = pkgs.formats.json {
      BACKGROUND_COLOR = "#202225";
      IS_MAXIMIZED = false;
      IS_MINIMIZED = false;
      OPEN_ON_STARTUP = false;
      MINIMIZE_TO_TRAY = false;
      SKIP_HOST_UPDATE = true;
    };
  };
}
