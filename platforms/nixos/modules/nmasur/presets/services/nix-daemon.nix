{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.nix-daemon;
in

{

  options.nmasur.presets.services.nix-daemon.enable = lib.mkEnableOption "Nix daemon";

  config = lib.mkIf cfg.enable {

    nix.gc.dates = "09:03"; # Run every morning (but before upgrade)

  };
}
