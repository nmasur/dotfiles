{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.;
in

{

  options.nmasur.presets.programs..enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
  };
}
