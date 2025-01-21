{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.nix-daemon;
in

{

  options.nmasur.presets.services.nix-daemon.enable = lib.mkEnableOption "Nix garbage collection";

  config = lib.mkIf cfg.enable {
    services.nix-daemon.enable = true;

    nix.gc.interval = {
      Hour = 12;
      Minute = 15;
      Day = 1;
    };
  };
}
