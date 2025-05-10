{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.services.betterlockscreen;
  # Disable Dunst so that it's not attempting to reach a non-existent dunst service
  betterlockscreen = pkgs.betterlockscreen.override { withDunst = cfg.dunst.enable; };
in

{

  options.services.betterlockscreen = {
    enable = lib.mkEnableOption "Betterlockscreen X server display lock";
    dunst.enable = lib.mkEnableOption "Dunst integration";
  };

  config = lib.mkIf cfg.enable {

    programs.i3lock.enable = true; # Required for unlocking to work

    # Ref: https://github.com/betterlockscreen/betterlockscreen/blob/next/system/betterlockscreen%40.service
    systemd.services.lock = {
      enable = true;
      description = "Lock the screen on resume from suspend";
      before = [
        "sleep.target"
        "suspend.target"
      ];
      serviceConfig = {
        User = username;
        Type = "simple";
        Environment = "DISPLAY=:0";
        TimeoutSec = "infinity";
        ExecStart = "${lib.getExe betterlockscreen} --lock --display 1 --blur 0.5 --span";
        ExecStartPost = "${lib.getExe' pkgs.coreutils-full "sleep"} 1";
      };
      wantedBy = [
        "sleep.target"
        "suspend.target"
      ];
    };
  };
}
