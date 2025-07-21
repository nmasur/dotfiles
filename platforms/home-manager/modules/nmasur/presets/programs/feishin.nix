{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.feishin;
in

{

  options.nmasur.presets.programs.feishin.enable = lib.mkEnableOption "Feishin music player";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.feishin ];
  };
}
