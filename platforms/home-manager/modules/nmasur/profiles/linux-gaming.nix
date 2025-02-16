{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.linux-gaming;
in

{

  options.nmasur.profiles.linux-gaming.enable = lib.mkEnableOption "Linux gaming home";

  config = lib.mkIf cfg.enable {

    nmasur.presets.programs = {
      wine.enable = lib.mkDefault true;
    };

    home.packages = lib.mkDefault [
      pkgs.heroic
    ];

  };
}
