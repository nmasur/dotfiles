{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.;
in

{

  options.nmasur.presets.services..enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
  };
}
