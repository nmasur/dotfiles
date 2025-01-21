{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.dunst;
in

{

  options.nmasur.presets.services.dunst.enable = lib.mkEnableOption "Dunst notification system";

  config = lib.mkIf cfg.enable {
    enable = false;
    settings = {
      global = {
        width = 300;
        height = 200;
        offset = "30x50";
        origin = "top-right";
        transparency = 0;
        padding = 20;
        horizontal_padding = 20;
        frame_color = config.theme.colors.base03;
      };

      urgency_normal = {
        background = config.theme.colors.base00;
        foreground = config.theme.colors.base05;
        timeout = 10;
      };
    };

  };
}
