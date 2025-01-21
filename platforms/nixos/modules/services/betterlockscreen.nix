{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.betterlockscreen;
  lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen --lock --display 1 --blur 0.5 --span";
in

{

  options.services.betterlockscreen.enable = lib.mkEnableOption "Betterlockscreen X server display lock";

  config = lib.mkIf cfg.enable {

    # Ref: https://github.com/betterlockscreen/betterlockscreen/blob/next/system/betterlockscreen%40.service
    systemd.services.lock = {
      enable = true;
      description = "Lock the screen on resume from suspend";
      before = [
        "sleep.target"
        "suspend.target"
      ];
      serviceConfig = {
        User = config.user;
        Type = "simple";
        Environment = "DISPLAY=:0";
        TimeoutSec = "infinity";
        ExecStart = lockCmd;
        ExecStartPost = "${pkgs.coreutils-full}/bin/sleep 1";
      };
      wantedBy = [
        "sleep.target"
        "suspend.target"
      ];
    };
  };
}
